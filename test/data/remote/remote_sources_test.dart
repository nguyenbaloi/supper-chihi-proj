import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/core/result/result.dart';
import 'package:personal_finance/data/remote/coingecko_price_source.dart';
import 'package:personal_finance/data/remote/exchange_rate_source.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/models/price_quote.dart';

void main() {
  group('Nguồn giá crypto', () {
    late List<Uri> requested;
    late List<Map<String, String>> headers;

    MockClient respondWith(String body, {int status = 200}) =>
        MockClient((request) async {
          requested.add(request.url);
          headers.add(request.headers);
          return http.Response(body, status, headers: {
            'content-type': 'application/json',
          });
        });

    setUp(() {
      requested = [];
      headers = [];
    });

    test('chỉ gửi đi ký hiệu tài sản và mã tiền tệ', () async {
      // Đây là ràng buộc tuyệt đối của sản phẩm: ứng dụng chỉ hỏi ra ngoài
      // "BTC giá bao nhiêu". Xem AD-8 và FR-10.
      final source = CoinGeckoPriceSource(
        client: respondWith(jsonEncode({
          'bitcoin': {'usd': 67432.18},
          'ethereum': {'usd': 2500.0},
        })),
      );

      await source.fetchPrices(['BTC', 'ETH']);

      final uri = requested.single;
      expect(uri.queryParameters['ids'], 'bitcoin,ethereum');
      expect(uri.queryParameters['vs_currencies'], 'usd');
      expect(uri.queryParameters.keys, hasLength(2));
      expect(uri.query, isNot(contains('0.12345678')));
    });

    test('không gửi số lượng, giá trị hay định danh người dùng', () async {
      final source = CoinGeckoPriceSource(
        client: respondWith(jsonEncode({
          'bitcoin': {'usd': 67432.18},
        })),
      );

      await source.fetchPrices(['BTC']);

      final everythingSent =
          '${requested.single}${headers.single.entries.join()}'.toLowerCase();
      for (final forbidden in [
        'quantity',
        'amount',
        'holding',
        'value',
        'user',
        'device',
        'portfolio',
        'cookie',
      ]) {
        expect(everythingSent, isNot(contains(forbidden)),
            reason: 'lời gọi mạng mang theo "$forbidden"');
      }
    });

    test('đổi giá sang xu mà không đi qua số thực', () async {
      // 67.432,18 USD phải ra đúng 6.743.218 xu. Nhân 100 trên double cho
      // 6743217.999999999 rồi cắt xuống 6743217 — lệch một xu.
      final source = CoinGeckoPriceSource(
        client: respondWith(jsonEncode({
          'bitcoin': {'usd': 67432.18},
        })),
      );

      final result = await source.fetchPrices(['BTC']);
      final quote = (result as Ok<List<PriceQuote>>).value.single;

      expect(quote.priceAmount, const Money(6743218));
      expect(quote.currency, Currency.usd);
      expect(quote.source, PriceSource.api);
    });

    test('giá nguyên không có phần thập phân vẫn đúng', () async {
      final source = CoinGeckoPriceSource(
        client: respondWith(jsonEncode({
          'tether': {'usd': 1},
        })),
      );
      final result = await source.fetchPrices(['USDT']);
      expect((result as Ok).value.single.priceAmount, const Money(100));
    });

    test('giá nhiều hơn hai chữ số thập phân bị cắt chứ không làm tròn lên',
        () async {
      final source = CoinGeckoPriceSource(
        client: respondWith(jsonEncode({
          'bitcoin': {'usd': 67432.189},
        })),
      );
      final result = await source.fetchPrices(['BTC']);
      expect((result as Ok).value.single.priceAmount, const Money(6743218));
    });

    test('ký hiệu nguồn không biết thì bỏ qua, không gọi mạng vô ích',
        () async {
      final source = CoinGeckoPriceSource(client: respondWith('{}'));
      final result = await source.fetchPrices(['FPT', 'SJC']);

      expect(result.isOk, isTrue);
      expect((result as Ok).value, isEmpty);
      expect(requested, isEmpty);
    });

    test('máy chủ trả mã lỗi thì báo thất bại, không ném ngoại lệ', () async {
      final source = CoinGeckoPriceSource(
        client: respondWith('rate limited', status: 429),
      );
      final result = await source.fetchPrices(['BTC']);

      expect(result.isFailure, isTrue);
      expect((result as Failure).reason, contains('429'));
    });

    test('mất mạng thì báo thất bại kèm lý do, không ném ngoại lệ', () async {
      final source = CoinGeckoPriceSource(
        client: MockClient((_) => throw const SocketExceptionStub()),
      );

      final result = await source.fetchPrices(['BTC']);

      expect(result.isFailure, isTrue);
      expect((result as Failure).cause, isA<SocketExceptionStub>());
    });

    test('nội dung trả về hỏng thì báo thất bại', () async {
      final source = CoinGeckoPriceSource(client: respondWith('không phải json'));
      expect((await source.fetchPrices(['BTC'])).isFailure, isTrue);
    });
  });

  group('Nguồn tỷ giá', () {
    test('đọc đúng tỷ giá VND và làm tròn về đồng', () async {
      final source = ExchangeRateSource(
        client: MockClient((_) async => http.Response(
              jsonEncode({
                'rates': {'VND': 25432.6, 'EUR': 0.92},
              }),
              200,
            )),
      );

      final result = await source.fetchUsdToVnd();
      final rate = (result as Ok).value;

      expect(rate.rateAmount, const Money(25433));
      expect(rate.source, PriceSource.api);
      expect(rate.fetchedAt!.isUtc, isTrue);
      expect(rate.isFallback, isFalse);
    });

    test('yêu cầu gửi đi không mang dữ liệu người dùng', () async {
      Uri? sent;
      final source = ExchangeRateSource(
        client: MockClient((request) async {
          sent = request.url;
          return http.Response(jsonEncode({'rates': {'VND': 25000}}), 200);
        }),
      );

      await source.fetchUsdToVnd();

      expect(sent!.queryParameters, isEmpty);
      expect(sent!.path, contains('USD'));
    });

    test('thiếu mục VND thì báo thất bại', () async {
      final source = ExchangeRateSource(
        client: MockClient((_) async =>
            http.Response(jsonEncode({'rates': {'EUR': 0.92}}), 200)),
      );
      expect((await source.fetchUsdToVnd()).isFailure, isTrue);
    });

    test('mất mạng thì báo thất bại, không ném ngoại lệ', () async {
      final source = ExchangeRateSource(
        client: MockClient((_) => throw const SocketExceptionStub()),
      );
      expect((await source.fetchUsdToVnd()).isFailure, isTrue);
    });
  });
}

/// Giả lập lỗi mạng mà không cần `dart:io` trong tệp test.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
  @override
  String toString() => 'SocketExceptionStub';
}
