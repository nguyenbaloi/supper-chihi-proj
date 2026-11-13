import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/fear_greed.dart';
import 'market_data_source.dart';

/// Fear & Greed Index crypto theo ngày từ alternative.me (FR-15, AD-13).
///
/// Host thứ tư và là host duy nhất ngoài ba nguồn nến. Chỉ dùng cho BTC:
/// không có nguồn F&G công khai nào cho VNINDEX, nên VNINDEX xếp vùng chỉ
/// bằng RSI. API không chính thức, không cần khoá — có lịch sử từ 2018-02-01.
class FearGreedSource {
  FearGreedSource({http.Client? client, this.limit = 400})
      : _client = client ?? http.Client();

  static final Uri _base = Uri.parse('https://api.alternative.me/fng/');

  final http.Client _client;

  /// Số ngày gần nhất cần lấy. 400 ngày đủ cho mọi tuần app xếp vùng trong
  /// hơn một năm, mà phản hồi vẫn nhỏ.
  final int limit;

  String get name => 'alternative.me';

  /// Trả về chuỗi điểm F&G xếp theo ngày **tăng dần**. Ném
  /// [MarketDataException] khi hỏng — repository là nơi bắt (AD-6).
  Future<List<FearGreedPoint>> fetchDaily() async {
    final uri = _base.replace(queryParameters: {
      'limit': '$limit',
      'format': 'json',
    });

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (error) {
      throw MarketDataException(MarketDataErrorKind.network, '$error',
          source: name);
    }
    if (response.statusCode != 200) {
      throw MarketDataException(
          MarketDataErrorKind.http, 'HTTP ${response.statusCode}',
          source: name);
    }
    return parse(response.body);
  }

  /// `{"data":[{"value":"20","timestamp":"1762992000",...}, ...]}` — mới
  /// nhất đứng đầu; giá trị và mốc thời gian đều là chuỗi.
  static List<FearGreedPoint> parse(String body) {
    final List<dynamic> rows;
    try {
      rows = (jsonDecode(body) as Map<String, dynamic>)['data'] as List<dynamic>;
    } catch (error) {
      throw MarketDataException(
          MarketDataErrorKind.parse, 'không đúng hình dạng: $error',
          source: 'alternative.me');
    }

    final points = <FearGreedPoint>[];
    try {
      for (final row in rows.cast<Map<String, dynamic>>()) {
        final seconds = int.parse('${row['timestamp']}');
        final at = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
        points.add(FearGreedPoint(
          day: DateTime.utc(at.year, at.month, at.day),
          value: int.parse('${row['value']}'),
        ));
      }
    } catch (error) {
      throw MarketDataException(
          MarketDataErrorKind.parse, 'phần tử hỏng: $error',
          source: 'alternative.me');
    }

    if (points.isEmpty) {
      throw MarketDataException(MarketDataErrorKind.empty, 'không có điểm nào',
          source: 'alternative.me');
    }
    points.sort((a, b) => a.day.compareTo(b.day));
    return points;
  }
}
