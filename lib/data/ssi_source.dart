import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/candle.dart';
import 'market_data_source.dart';
import 'udf_parser.dart';

/// Nến tuần VNINDEX từ SSI iBoard — nguồn chính cho chỉ số Việt Nam (FR-11).
///
/// SSI hỗ trợ thẳng `resolution=W` nên không phải gộp nến ngày. Kiểm chứng
/// ngày 2026-09-04: trả 908 nến tuần từ 2016, mốc mở tuần là **thứ Hai 02:00
/// UTC** tức 09:00 giờ Việt Nam — đúng giờ mở cửa phiên.
///
/// TCBS (`apipubaws.tcbs.com.vn`) đã bị loại: nó trả HTTP 403 kèm trang thử
/// thách Cloudflare kể cả với đầy đủ header trình duyệt, nên một HTTP client
/// trong Flutter cũng sẽ không qua được.
class SsiSource implements MarketDataSource {
  SsiSource({http.Client? client, this.historyYears = 20})
      : _client = client ?? http.Client();

  static final Uri _base =
      Uri.parse('https://iboard-api.ssi.com.vn/statistics/charts/history');

  final http.Client _client;

  /// Lùi đủ xa để lấy vài trăm nến tuần — RSI(14) cần tối thiểu 15 nến, còn
  /// tab Lịch sử tín hiệu thì càng nhiều càng dùng được.
  final int historyYears;

  @override
  String get name => 'SSI';

  @override
  Future<List<Candle>> fetchWeekly() async {
    final now = DateTime.now().toUtc();
    final uri = _base.replace(queryParameters: {
      'symbol': 'VNINDEX',
      'resolution': 'W',
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
      throw MarketDataException(
        MarketDataErrorKind.parse,
        'thân phản hồi không phải JSON đối tượng: $error',
        source: 'SSI',
      );
    }

    // SSI báo lỗi nghiệp vụ bằng trường `code` chứ không bằng mã HTTP. Xếp nó
    // vào `http` để repository chuyển sang nguồn dự phòng.
    if (json['code'] != 'SUCCESS') {
      throw MarketDataException(
        MarketDataErrorKind.http,
        'code=${json['code']} message=${json['message']}',
        source: 'SSI',
      );
    }

    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw MarketDataException(
        MarketDataErrorKind.parse,
        'thiếu đối tượng "data"',
        source: 'SSI',
      );
    }

    return parseUdfSeries(
      data,
      sourceName: 'SSI',
      barDuration: const Duration(days: 7),
      now: now,
    );
  }
}
