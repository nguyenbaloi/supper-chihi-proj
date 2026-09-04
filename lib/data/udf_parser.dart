import '../domain/candle.dart';
import 'market_data_source.dart';

/// Bộ đọc chung cho định dạng TradingView UDF: sáu mảng song song
/// `t, o, h, l, c, v` cùng độ dài, `t` là epoch **giây**.
///
/// Cả SSI lẫn VNDirect đều trả hình dạng này, chỉ khác lớp bọc bên ngoài, nên
/// phần đọc nằm chung một chỗ thay vì chép hai lần.
List<Candle> parseUdfSeries(
  Map<String, dynamic> data, {
  required String sourceName,
  required Duration barDuration,
  required DateTime now,
}) {
  final times = data['t'];
  if (times is! List) {
    throw MarketDataException(
      MarketDataErrorKind.parse,
      'thiếu mảng thời gian "t"',
      source: sourceName,
    );
  }
  if (times.isEmpty) {
    throw MarketDataException(
      MarketDataErrorKind.empty,
      'không có nến nào',
      source: sourceName,
    );
  }

  final series = <String, List<dynamic>>{};
  for (final key in ['o', 'h', 'l', 'c']) {
    final values = data[key];
    if (values is! List || values.length != times.length) {
      throw MarketDataException(
        MarketDataErrorKind.parse,
        'mảng "$key" thiếu hoặc lệch độ dài với "t"',
        source: sourceName,
      );
    }
    series[key] = values;
  }
  final volumes = data['v'] is List ? data['v'] as List : null;

  final candles = <Candle>[];
  try {
    for (var i = 0; i < times.length; i++) {
      final openTime = DateTime.fromMillisecondsSinceEpoch(
        (times[i] as num).toInt() * 1000,
        isUtc: true,
      );
      candles.add(
        Candle(
          openTime: openTime,
          open: (series['o']![i] as num).toDouble(),
          high: (series['h']![i] as num).toDouble(),
          low: (series['l']![i] as num).toDouble(),
          close: (series['c']![i] as num).toDouble(),
          volume: volumes != null && i < volumes.length
              ? (volumes[i] as num).toDouble()
              : 0,
          // UDF không trả thời điểm đóng nến, nên suy từ mốc mở cộng độ dài
          // một nến (AD-4).
          isClosed: openTime.add(barDuration).isBefore(now),
        ),
      );
    }
  } catch (error) {
    if (error is MarketDataException) rethrow;
    throw MarketDataException(
      MarketDataErrorKind.parse,
      'giá trị không phải số: $error',
      source: sourceName,
    );
  }

  candles.sort((a, b) => a.openTime.compareTo(b.openTime));
  return candles;
}
