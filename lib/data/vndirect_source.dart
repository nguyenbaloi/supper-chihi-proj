import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/candle.dart';
import 'market_data_source.dart';
import 'udf_parser.dart';

/// Nến tuần VNINDEX dựng từ nến ngày của VNDirect — nguồn **dự phòng** khi SSI
/// hỏng (FR-11).
///
/// VNDirect không hỗ trợ `resolution=W`: gọi với W thì nó trả nguyên văn
/// `"Not support resolution W"` kèm mã 200. Nên adapter này lấy nến ngày rồi
/// tự gộp thành tuần.
class VndirectSource implements MarketDataSource {
  VndirectSource({http.Client? client, this.historyYears = 20})
      : _client = client ?? http.Client();

  static final Uri _base =
      Uri.parse('https://dchart-api.vndirect.com.vn/dchart/history');

  /// Múi giờ Việt Nam. Tuần giao dịch bắt đầu thứ Hai theo giờ này, khớp với
  /// cách SSI đánh mốc nến tuần (thứ Hai 09:00 giờ Việt Nam).
  static const Duration _vnOffset = Duration(hours: 7);

  final http.Client _client;
  final int historyYears;

  @override
  String get name => 'VNDirect';

  @override
  Future<List<Candle>> fetchWeekly() async {
    final now = DateTime.now().toUtc();
    final uri = _base.replace(queryParameters: {
      'symbol': 'VNINDEX',
      'resolution': 'D',
      'from': '${now.subtract(Duration(days: 365 * historyYears)).millisecondsSinceEpoch ~/ 1000}',
      'to': '${now.millisecondsSinceEpoch ~/ 1000}',
    });

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (error) {
      throw MarketDataException(
        MarketDataErrorKind.network,
        '$error',
        source: name,
      );
    }

    if (response.statusCode != 200) {
      throw MarketDataException(
        MarketDataErrorKind.http,
        'HTTP ${response.statusCode}',
        source: name,
      );
    }

    return parseBody(response.body, now: now);
  }

  static List<Candle> parseBody(String body, {required DateTime now}) {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(body) as Map<String, dynamic>;
    } catch (error) {
      // VNDirect trả lỗi dưới dạng chuỗi thuần, không phải JSON.
      throw MarketDataException(
        MarketDataErrorKind.http,
        'phản hồi không phải JSON: ${body.length > 80 ? '${body.substring(0, 80)}…' : body}',
        source: 'VNDirect',
      );
    }

    final daily = parseUdfSeries(
      json,
      sourceName: 'VNDirect',
      barDuration: const Duration(days: 1),
      now: now,
    );

    return groupDailyIntoWeekly(daily, now: now);
  }

  /// Gộp nến ngày thành nến tuần theo tuần giao dịch Việt Nam.
  ///
  /// Mở = giá mở của ngày giao dịch **đầu tiên** có mặt trong tuần; đóng = giá
  /// đóng của ngày **cuối cùng**; cao/thấp là max/min; khối lượng là tổng. Một
  /// tuần nghỉ lễ chỉ có hai phiên vẫn tạo ra đúng một nến từ hai phiên đó —
  /// không chèn ngày rỗng, không bỏ tuần.
  static List<Candle> groupDailyIntoWeekly(
    List<Candle> daily, {
    required DateTime now,
  }) {
    if (daily.isEmpty) {
      throw MarketDataException(
        MarketDataErrorKind.empty,
        'không có nến ngày nào để gộp',
        source: 'VNDirect',
      );
    }

    final buckets = <DateTime, List<Candle>>{};
    for (final candle in daily) {
      buckets.putIfAbsent(_weekStart(candle.openTime), () => []).add(candle);
    }

    final weeks = buckets.keys.toList()..sort();
    return [
      for (final weekStart in weeks)
        _mergeWeek(weekStart, buckets[weekStart]!, now),
    ];
  }

  /// Mốc thứ Hai 00:00 giờ Việt Nam của tuần chứa [utcTime], trả về dưới dạng
  /// UTC (AD-3 — mọi mốc lưu trữ đều là UTC).
  static DateTime _weekStart(DateTime utcTime) {
    final local = utcTime.add(_vnOffset);
    final midnight = DateTime.utc(local.year, local.month, local.day);
    final monday = midnight.subtract(Duration(days: local.weekday - 1));
    return monday.subtract(_vnOffset);
  }

  static Candle _mergeWeek(
    DateTime weekStart,
    List<Candle> days,
    DateTime now,
  ) {
    days.sort((a, b) => a.openTime.compareTo(b.openTime));
    var high = days.first.high;
    var low = days.first.low;
    var volume = 0.0;
    for (final day in days) {
      if (day.high > high) high = day.high;
      if (day.low < low) low = day.low;
      volume += day.volume;
    }
    return Candle(
      openTime: weekStart,
      open: days.first.open,
      high: high,
      low: low,
      close: days.last.close,
      volume: volume,
      isClosed: weekStart.add(const Duration(days: 7)).isBefore(now),
    );
  }
}
