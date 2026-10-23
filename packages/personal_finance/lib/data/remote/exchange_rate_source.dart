import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/money/money.dart';
import '../../core/result/result.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/fx_rate.dart';

/// Hợp đồng của một nguồn Tỷ giá bên ngoài.
abstract interface class RemoteFxRateSource {
  String get name;

  /// Hỏi Tỷ giá USD sang VND.
  Future<Result<FxRate>> fetchUsdToVnd();
}

/// Nguồn tỷ giá công khai, không cần khoá API.
///
/// Yêu cầu gửi đi chỉ chứa mã tiền tệ. Xem AD-8 và FR-11.
class ExchangeRateSource implements RemoteFxRateSource {
  static final Uri _endpoint =
      Uri.parse('https://open.er-api.com/v6/latest/USD');

  final http.Client _client;
  final Duration _timeout;

  ExchangeRateSource({http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 10);

  @override
  String get name => 'open.er-api.com';

  @override
  Future<Result<FxRate>> fetchUsdToVnd() async {
    try {
      final response = await _client.get(_endpoint).timeout(_timeout);
      if (response.statusCode != 200) {
        return Result.failure('$name trả mã ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return Result.failure('$name trả về nội dung không đọc được');
      }

      final rates = decoded['rates'];
      if (rates is! Map) return Result.failure('$name không có mục rates');

      final vnd = _toDong(rates['VND']);
      if (vnd == null || vnd <= 0) {
        return Result.failure('$name không có tỷ giá VND hợp lệ');
      }

      return Result.ok(
        FxRate(
          rateAmount: Money(vnd),
          source: PriceSource.api,
          fetchedAt: DateTime.now().toUtc(),
        ),
      );
    } on Object catch (error) {
      return Result.failure('không lấy được tỷ giá từ $name', cause: error);
    }
  }

  /// Làm tròn tỷ giá về đồng nguyên qua chuỗi, không qua số thực.
  static int? _toDong(Object? raw) {
    if (raw == null) return null;
    final text = raw.toString();
    final parts = text.split('.');
    final whole = int.tryParse(parts.first);
    if (whole == null) return null;
    if (parts.length < 2 || parts[1].isEmpty) return whole;
    // Làm tròn nửa lên dựa trên chữ số thập phân đầu tiên.
    final firstDecimal = int.tryParse(parts[1][0]);
    if (firstDecimal == null) return whole;
    return firstDecimal >= 5 ? whole + 1 : whole;
  }
}
