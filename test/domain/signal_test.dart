import 'package:flutter_test/flutter_test.dart';
import 'package:rsi_alert/domain/candle.dart';
import 'package:rsi_alert/domain/constants.dart';
import 'package:rsi_alert/domain/market_symbol.dart';
import 'package:rsi_alert/domain/signal.dart';

/// Dựng chuỗi nến có RSI bám sát [targetRsi].
///
/// `detectSignals` tự tính RSI bên trong, nên test không thể "đặt" RSI trực
/// tiếp. Cách làm: mồi 15 nến đi ngang để RSI khởi tạo ở 50, rồi với mỗi mục
/// tiêu, dò nhị phân mức biến động giá cho ra đúng RSI đó. Nhờ vậy mỗi ca thử
/// vẫn nói bằng ngôn ngữ "chuỗi RSI là 35, 28, 26, 31" như trong Story 1.3.
List<Candle> candlesWithRsi(List<double> targetRsi, {bool lastOpen = false}) {
  final closes = <double>[100.0];
  // Mồi: 15 nến so le rất nhỏ để có đủ dữ liệu cho giá trị RSI đầu tiên.
  for (var i = 0; i < rsiPeriod; i++) {
    closes.add(closes.last + (i.isEven ? 1.0 : -1.0));
  }

  for (final target in targetRsi) {
    var low = -0.5, high = 0.5; // tỷ lệ thay đổi giá
    for (var iteration = 0; iteration < 80; iteration++) {
      final mid = (low + high) / 2;
      final candidate = [...closes, closes.last * (1 + mid)];
      final rsi = _lastRsi(candidate);
      if (rsi < target) {
        low = mid;
      } else {
        high = mid;
      }
    }
    closes.add(closes.last * (1 + (low + high) / 2));
  }

  var time = DateTime.utc(2024, 1, 1);
  final candles = <Candle>[];
  for (var i = 0; i < closes.length; i++) {
    final isLast = i == closes.length - 1;
    candles.add(
      Candle(
        openTime: time,
        open: i == 0 ? closes[i] : closes[i - 1],
        high: closes[i] + 1,
        low: closes[i] - 1,
        close: closes[i],
        volume: 1000,
        isClosed: !(isLast && lastOpen),
      ),
    );
    time = time.add(const Duration(days: 7));
  }
  return candles;
}

double _lastRsi(List<double> closes) {
  var gain = 0.0, loss = 0.0;
  for (var i = 1; i <= rsiPeriod; i++) {
    final change = closes[i] - closes[i - 1];
    change > 0 ? gain += change : loss += -change;
  }
  var avgGain = gain / rsiPeriod, avgLoss = loss / rsiPeriod;
  for (var i = rsiPeriod + 1; i < closes.length; i++) {
    final change = closes[i] - closes[i - 1];
    avgGain = (avgGain * (rsiPeriod - 1) + (change > 0 ? change : 0)) / rsiPeriod;
    avgLoss = (avgLoss * (rsiPeriod - 1) + (change < 0 ? -change : 0)) / rsiPeriod;
  }
  if (avgLoss == 0) return 100;
  if (avgGain == 0) return 0;
  return 100 - 100 / (1 + avgGain / avgLoss);
}

void main() {
  group('detectSignals — FR-4', () {
    test('đợt giảm dài chỉ sinh MỘT tín hiệu, tại tuần cắt xuống', () {
      final candles = candlesWithRsi([35, 28, 26, 31]);
      final signals = detectSignals(MarketSymbol.btc, candles);

      expect(signals.length, 1);
      expect(signals.single.type, SignalType.oversold);
      expect(signals.single.rsiValue, closeTo(28, 0.5));
    });

    test('hai lần cắt lên trên 70 sinh hai tín hiệu', () {
      final candles = candlesWithRsi([65, 72, 75, 68, 73]);
      final signals = detectSignals(MarketSymbol.vnindex, candles);

      expect(signals.length, 2);
      expect(signals.every((s) => s.type == SignalType.overbought), isTrue);
      expect(signals[0].rsiValue, closeTo(72, 0.5));
      expect(signals[1].rsiValue, closeTo(73, 0.5));
    });

    test('AD-5: nến đang chạy không bao giờ sinh tín hiệu', () {
      final withOpenCandle = candlesWithRsi([35, 24], lastOpen: true);
      expect(detectSignals(MarketSymbol.btc, withOpenCandle), isEmpty);

      // Cùng chuỗi đó nhưng nến cuối đã đóng thì tín hiệu xuất hiện.
      final allClosed = candlesWithRsi([35, 24]);
      expect(detectSignals(MarketSymbol.btc, allClosed).length, 1);
    });

    test('nến RSI đầu tiên không sinh tín hiệu dù đã dưới ngưỡng', () {
      // Chuỗi mồi đi ngang cho RSI đầu ~50, rồi rơi thẳng xuống 20.
      final candles = candlesWithRsi([20, 22]);
      final signals = detectSignals(MarketSymbol.btc, candles);

      // Chỉ có cú cắt xuống ở nến RSI 20; nến 22 vẫn dưới ngưỡng nên không
      // sinh thêm.
      expect(signals.length, 1);
      expect(signals.single.rsiValue, closeTo(20, 0.5));
    });

    test('chuỗi quá ngắn trả về rỗng', () {
      final candles = candlesWithRsi([]).take(5).toList();
      expect(detectSignals(MarketSymbol.btc, candles), isEmpty);
    });

    test('tín hiệu mang đủ trường và xếp theo thời gian tăng dần', () {
      final candles = candlesWithRsi([35, 25, 45, 75, 50, 20]);
      final signals = detectSignals(MarketSymbol.vnindex, candles);

      expect(signals.length, greaterThanOrEqualTo(2));
      for (final s in signals) {
        expect(s.symbol, MarketSymbol.vnindex);
        expect(s.weekOpenTime.isUtc, isTrue);
        expect(s.closePrice, greaterThan(0));
        expect(s.rsiValue, inInclusiveRange(0, 100));
        expect(s.candleIndex, greaterThanOrEqualTo(rsiPeriod));
      }
      for (var i = 1; i < signals.length; i++) {
        expect(
          signals[i].weekOpenTime.isAfter(signals[i - 1].weekOpenTime),
          isTrue,
        );
      }
    });

    test('nến đang chạy bị loại khỏi việc đánh chỉ số nến', () {
      final candles = candlesWithRsi([35, 25, 50], lastOpen: true);
      final signals = detectSignals(MarketSymbol.btc, candles);

      // candleIndex phải trỏ vào chuỗi đã lọc isClosed, nên luôn nhỏ hơn số
      // nến đã đóng.
      final closedCount = candles.where((c) => c.isClosed).length;
      for (final s in signals) {
        expect(s.candleIndex, lessThan(closedCount));
        expect(candles[s.candleIndex].openTime, s.weekOpenTime);
      }
    });
  });
}
