import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/candle.dart';
import 'market_data_source.dart';

/// Nến tuần BTCUSDT từ máy chủ dữ liệu thị trường công khai của Binance (FR-10).
///
/// Dùng `data-api.binance.vision` chứ **không** dùng `api.binance.com`: kiểm
/// chứng ngày 2026-09-04 cho thấy host chính không thiết lập được kết nối từ
/// mạng của người dùng, còn host này trả dữ liệu bình thường và không cần khoá
/// API.
class BinanceSource implements MarketDataSource {
  BinanceSource({http.Client? client, this.limit = 1000})
      : _client = client ?? http.Client();

  static final Uri _base =
      Uri.parse('https://data-api.binance.vision/api/v3/klines');

  final http.Client _client;
  final int limit;

  @override
  String get name => 'Binance';

  @override
  Future<List<Candle>> fetchWeekly() async {
    final uri = _base.replace(queryParameters: {
      'symbol': 'BTCUSDT',
      'interval': '1w',
      'limit': '$limit',
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

    return parseKlines(response.body, now: DateTime.now().toUtc());
  }

  /// Tách riêng khỏi phần gọi mạng để test được bằng dữ liệu mẫu cố định.
  ///
  /// Mỗi phần tử là một mảng: `[openTime, open, high, low, close, volume,
  /// closeTime, ...]`. Binance trả `closeTime` sẵn nên [Candle.isClosed] suy
  /// thẳng từ đó, không phải đoán lịch thị trường (AD-4).
  static List<Candle> parseKlines(String body, {required DateTime now}) {
    final List<dynamic> rows;
    try {
      rows = jsonDecode(body) as List<dynamic>;
    } catch (error) {
      throw MarketDataException(
        MarketDataErrorKind.parse,
        'thân phản hồi không phải JSON mảng: $error',
        source: 'Binance',
      );
    }

    if (rows.isEmpty) {
      throw MarketDataException(
        MarketDataErrorKind.empty,
        'không có nến nào',
        source: 'Binance',
      );
    }

    final candles = <Candle>[];
    try {
      for (final row in rows.cast<List<dynamic>>()) {
        final closeTime = DateTime.fromMillisecondsSinceEpoch(
          (row[6] as num).toInt(),
          isUtc: true,
        );
        candles.add(
          Candle(
            openTime: DateTime.fromMillisecondsSinceEpoch(
              (row[0] as num).toInt(),
              isUtc: true,
            ),
            open: double.parse(row[1] as String),
            high: double.parse(row[2] as String),
            low: double.parse(row[3] as String),
            close: double.parse(row[4] as String),
            volume: double.parse(row[5] as String),
            isClosed: closeTime.isBefore(now),
          ),
        );
      }
    } catch (error) {
      throw MarketDataException(
        MarketDataErrorKind.parse,
        'mảng kline sai hình dạng: $error',
        source: 'Binance',
      );
    }

    return candles;
  }
}
