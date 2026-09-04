// ignore_for_file: avoid_print — đây là công cụ dòng lệnh, in ra là mục đích.
// Công cụ đối chiếu số liệu (Story 6.2).
//
// Chạy: fvm dart run tool/doi_chieu.dart
//
// Nó gọi thẳng các nguồn dữ liệu thật, tính RSI bằng đúng mã nguồn app dùng,
// rồi in ra bảng để đối chiếu thủ công với TradingView. Việc so với TradingView
// là bước của con người — công cụ này chỉ dọn sẵn số cho việc đó.
import 'package:rsi_alert/data/binance_source.dart';
import 'package:rsi_alert/data/market_data_source.dart';
import 'package:rsi_alert/data/ssi_source.dart';
import 'package:rsi_alert/data/vndirect_source.dart';
import 'package:rsi_alert/domain/candle.dart';
import 'package:rsi_alert/domain/market_symbol.dart';
import 'package:rsi_alert/domain/rsi.dart';
import 'package:rsi_alert/domain/rsi_status.dart';
import 'package:rsi_alert/domain/signal.dart';

Future<void> main() async {
  final plans = <MarketSymbol, List<MarketDataSource>>{
    MarketSymbol.btc: [BinanceSource()],
    MarketSymbol.vnindex: [SsiSource(), VndirectSource()],
  };

  for (final entry in plans.entries) {
    final symbol = entry.key;
    List<Candle>? candles;
    String? usedSource;

    for (final source in entry.value) {
      try {
        candles = await source.fetchWeekly();
        usedSource = source.name;
        break;
      } on MarketDataException catch (error) {
        print('  ! ${source.name} hỏng: ${error.kind.name} — ${error.message}');
      }
    }

    print('\n=== ${symbol.label} (nguồn: ${usedSource ?? 'KHÔNG CÓ'}) ===');
    if (candles == null) continue;

    final closed = candles.where((c) => c.isClosed).toList();
    print('Tổng nến: ${candles.length} · đã đóng: ${closed.length}');
    print('Từ ${candles.first.openTime.toIso8601String()} '
        'đến ${candles.last.openTime.toIso8601String()}');
    print('Nến cuối đã đóng: ${candles.last.isClosed}');

    final rsi = computeRsi([for (final c in candles) c.close]);
    print('\n20 tuần gần nhất — đối chiếu cột RSI với TradingView:');
    print('tuần mở (UTC)        giá đóng        RSI    trạng thái');
    for (final point in rsi.sublist(rsi.length - 20)) {
      final candle = candles[point.candleIndex];
      final status = RsiStatus.from(point.value).name;
      print('${candle.openTime.toIso8601String().substring(0, 10)}  '
          '${candle.close.toStringAsFixed(2).padLeft(12)}  '
          '${point.value.toStringAsFixed(2).padLeft(6)}  '
          '$status${candle.isClosed ? '' : '  (TẠM TÍNH)'}');
    }

    final signals = detectSignals(symbol, candles);
    final threeYearsAgo = DateTime.now().toUtc().subtract(
          const Duration(days: 365 * 3),
        );
    final recent =
        signals.where((s) => s.weekOpenTime.isAfter(threeYearsAgo)).toList();
    print('\nTín hiệu trong toàn bộ dữ liệu: ${signals.length} '
        '· trong 3 năm gần nhất: ${recent.length}');
    for (final signal in recent) {
      print('  ${signal.weekOpenTime.toIso8601String().substring(0, 10)}  '
          '${signal.type.name.padRight(11)} '
          'RSI ${signal.rsiValue.toStringAsFixed(2).padLeft(6)}  '
          'đóng ${signal.closePrice.toStringAsFixed(2)}');
    }
  }
}
