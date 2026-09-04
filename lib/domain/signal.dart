import 'candle.dart';
import 'constants.dart';
import 'market_symbol.dart';
import 'rsi.dart';

enum SignalType { oversold, overbought }

/// Một lần RSI **cắt qua** ngưỡng giữa hai Nến đã đóng liền kề (FR-4).
///
/// Không có nơi lưu trữ nào cho Tín hiệu — nó luôn được sinh lại từ chuỗi nến
/// (AD-2). Xoá dữ liệu rồi tải lại phải cho ra đúng danh sách này.
class Signal {
  const Signal({
    required this.symbol,
    required this.type,
    required this.weekOpenTime,
    required this.closePrice,
    required this.rsiValue,
    required this.candleIndex,
  });

  final MarketSymbol symbol;
  final SignalType type;

  /// Mốc mở tuần của nến sinh ra Tín hiệu, UTC (AD-3).
  final DateTime weekOpenTime;
  final double closePrice;
  final double rsiValue;

  /// Chỉ số nến trong chuỗi đã lọc `isClosed` — để điều hướng tới đúng cột
  /// trên biểu đồ (Story 5.2).
  final int candleIndex;

  @override
  bool operator ==(Object other) =>
      other is Signal &&
      other.symbol == symbol &&
      other.type == type &&
      other.weekOpenTime == weekOpenTime;

  @override
  int get hashCode => Object.hash(symbol, type, weekOpenTime);

  @override
  String toString() =>
      'Signal(${symbol.label}, $type, ${weekOpenTime.toIso8601String()}, '
      'rsi=${rsiValue.toStringAsFixed(1)})';
}

/// Tìm mọi Tín hiệu trong một chuỗi nến (FR-4).
///
/// Chỉ xét Nến đã đóng — Nến đang chạy có RSI nhảy liên tục và có thể quay đầu
/// trước khi tuần kết thúc, nên không bao giờ được sinh Tín hiệu (AD-5).
///
/// Quy tắc cắt ngưỡng, không phải quy tắc ở dưới/trên ngưỡng: một đợt giảm dài
/// giữ RSI dưới 30 suốt tám tuần chỉ sinh **một** Tín hiệu, tại tuần cắt xuống
/// đầu tiên. Nến có RSI đầu tiên trong chuỗi không sinh Tín hiệu vì không có
/// nến liền trước để so.
///
/// Kết quả xếp theo thời gian **tăng dần**.
List<Signal> detectSignals(MarketSymbol symbol, List<Candle> candles) {
  final closed = candles.where((c) => c.isClosed).toList(growable: false);
  if (closed.length < minCandlesForRsi) return const [];

  final rsiPoints = computeRsi([for (final c in closed) c.close]);
  if (rsiPoints.length < 2) return const [];

  final signals = <Signal>[];
  for (var i = 1; i < rsiPoints.length; i++) {
    final previous = rsiPoints[i - 1].value;
    final current = rsiPoints[i];

    final SignalType? type;
    if (previous >= oversoldThreshold && current.value < oversoldThreshold) {
      type = SignalType.oversold;
    } else if (previous <= overboughtThreshold &&
        current.value > overboughtThreshold) {
      type = SignalType.overbought;
    } else {
      type = null;
    }
    if (type == null) continue;

    final candle = closed[current.candleIndex];
    signals.add(
      Signal(
        symbol: symbol,
        type: type,
        weekOpenTime: candle.openTime,
        closePrice: candle.close,
        rsiValue: current.value,
        candleIndex: current.candleIndex,
      ),
    );
  }
  return signals;
}
