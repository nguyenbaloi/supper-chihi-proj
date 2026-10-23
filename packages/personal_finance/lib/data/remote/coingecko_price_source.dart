import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/money/money.dart';
import '../../core/result/result.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/price_quote.dart';
import 'remote_price_source.dart';

/// Nguồn giá crypto công khai, không cần khoá API và không cần tài khoản.
///
/// **Nội dung gửi đi chỉ gồm ký hiệu tài sản và mã tiền tệ.** Không số lượng,
/// không giá trị, không định danh người dùng, không cookie, không header nhận
/// dạng. Đây là ràng buộc tuyệt đối của sản phẩm, xem AD-8 và FR-10.
class CoinGeckoPriceSource implements RemotePriceSource {
  static final Uri _endpoint =
      Uri.parse('https://api.coingecko.com/api/v3/simple/price');

  /// Ánh xạ ký hiệu người dùng nhập sang mã của nhà cung cấp.
  static const Map<String, String> _idBySymbol = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'USDT': 'tether',
    'BNB': 'binancecoin',
    'SOL': 'solana',
    'XRP': 'ripple',
    'ADA': 'cardano',
    'DOGE': 'dogecoin',
  };

  final http.Client _client;
  final Duration _timeout;

  CoinGeckoPriceSource({http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 10);

  @override
  String get name => 'CoinGecko';

  /// Các ký hiệu nguồn này biết giá.
  static Set<String> get supportedSymbols => _idBySymbol.keys.toSet();

  @override
  Future<Result<List<PriceQuote>>> fetchPrices(Iterable<String> symbols) async {
    final wanted = <String, String>{};
    for (final symbol in symbols) {
      final normalized = symbol.trim().toUpperCase();
      final id = _idBySymbol[normalized];
      if (id != null) wanted[id] = normalized;
    }
    if (wanted.isEmpty) return const Result.ok([]);

    final uri = _endpoint.replace(
      queryParameters: {
        'ids': wanted.keys.join(','),
        'vs_currencies': 'usd',
      },
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        return Result.failure('CoinGecko trả mã ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const Result.failure('CoinGecko trả về nội dung không đọc được');
      }

      final fetchedAt = DateTime.now().toUtc();
      final quotes = <PriceQuote>[];
      for (final entry in wanted.entries) {
        final priceNode = decoded[entry.key];
        if (priceNode is! Map) continue;
        final cents = _toCents(priceNode['usd']);
        if (cents == null) continue;

        quotes.add(
          PriceQuote(
            symbol: entry.value,
            priceAmount: Money(cents),
            currency: Currency.usd,
            source: PriceSource.api,
            fetchedAt: fetchedAt,
          ),
        );
      }
      return Result.ok(quotes);
    } on Object catch (error) {
      // Không để ngoại lệ nào lọt qua ranh giới tầng: lấy giá thất bại là
      // chuyện bình thường và tuyệt đối không được chặn thao tác. Xem AD-11.
      return Result.failure('không lấy được giá từ $name', cause: error);
    }
  }

  /// Đổi giá JSON sang **xu** mà không đi qua phép toán dấu phẩy động.
  ///
  /// JSON trả về số thực; chuyển thẳng sang chuỗi rồi tách phần thập phân
  /// giữ nguyên đúng chữ số nhà cung cấp gửi, thay vì nhân với 100 trên
  /// `double` và nhận về `6743217.999999999`.
  static int? _toCents(Object? raw) {
    if (raw == null) return null;
    final text = raw.toString();
    final parts = text.split('.');
    if (parts.length > 2) return null;

    final negative = parts.first.startsWith('-');
    final whole = parts.first.replaceFirst('-', '');
    if (whole.isEmpty || !RegExp(r'^\d+$').hasMatch(whole)) return null;

    var fraction = parts.length > 1 ? parts[1] : '';
    if (fraction.contains(RegExp(r'[^\d]'))) return null;
    if (fraction.length > 2) {
      fraction = fraction.substring(0, 2);
    } else {
      fraction = fraction.padRight(2, '0');
    }

    final cents = int.tryParse('$whole$fraction');
    if (cents == null) return null;
    return negative ? -cents : cents;
  }
}
