import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/price_quote_repository_impl.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/models/price_quote.dart';
import 'package:personal_finance/domain/repositories/price_quote_repository.dart';

void main() {
  late AppDatabase db;
  late PriceQuoteRepository prices;

  final clock = DateTime.utc(2026, 8, 27, 10);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    prices = PriceQuoteRepositoryImpl(db, now: () => clock);
  });
  tearDown(() => db.close());

  PriceQuote marketQuote(String symbol, int amount, {DateTime? at}) =>
      PriceQuote(
        symbol: symbol,
        priceAmount: Money(amount),
        currency: Currency.usd,
        source: PriceSource.api,
        fetchedAt: at ?? DateTime.utc(2026, 8, 27, 9),
      );

  group('Giá nhập tay đè giá thị trường', () {
    test('nhập tay xong thì giá hiệu lực là giá nhập tay', () async {
      await prices.saveMarketPrices([marketQuote('BTC', 6000000)]);
      await prices.saveManualPrice(
        symbol: 'BTC',
        price: const Money(6500000),
        currency: Currency.usd,
      );

      final effective = await prices.effectivePriceFor('BTC');
      expect(effective!.source, PriceSource.manual);
      expect(effective.priceAmount, const Money(6500000));
    });

    test('xóa giá nhập tay thì quay lại dùng giá thị trường', () async {
      await prices.saveMarketPrices([marketQuote('BTC', 6000000)]);
      await prices.saveManualPrice(symbol: 'BTC', price: const Money(6500000));

      await prices.clearManualPrice('BTC');

      final effective = await prices.effectivePriceFor('BTC');
      expect(effective!.source, PriceSource.api);
      expect(effective.priceAmount, const Money(6000000));
    });

    test('lấy giá thị trường mới không xoá mất giá nhập tay', () async {
      await prices.saveManualPrice(symbol: 'BTC', price: const Money(6500000));
      await prices.saveMarketPrices([marketQuote('BTC', 7000000)]);

      expect(await prices.quotesFor('BTC'), hasLength(2));
      expect((await prices.effectivePriceFor('BTC'))!.source,
          PriceSource.manual);
    });

    test('nhập tay lần hai ghi đè lần một, không sinh dòng thứ ba', () async {
      await prices.saveManualPrice(symbol: 'BTC', price: const Money(1));
      await prices.saveManualPrice(symbol: 'BTC', price: const Money(2));

      final quotes = await prices.quotesFor('BTC');
      expect(quotes, hasLength(1));
      expect(quotes.single.priceAmount, const Money(2));
    });

    test('xoá giá nhập tay của ký hiệu này không đụng ký hiệu khác', () async {
      await prices.saveManualPrice(symbol: 'BTC', price: const Money(1));
      await prices.saveManualPrice(symbol: 'ETH', price: const Money(2));

      await prices.clearManualPrice('BTC');

      expect(await prices.effectivePriceFor('BTC'), isNull);
      expect((await prices.effectivePriceFor('ETH'))!.priceAmount,
          const Money(2));
    });
  });

  group('Chưa có giá', () {
    test('ký hiệu chưa từng có giá trả về null', () async {
      expect(await prices.effectivePriceFor('FPT'), isNull);
    });

    test('ký hiệu chưa có giá vắng mặt khỏi bản đồ, không ánh xạ sang 0',
        () async {
      await prices.saveManualPrice(symbol: 'BTC', price: const Money(1));

      final map = await prices.effectivePricesFor(['BTC', 'FPT']);
      expect(map.keys, ['BTC']);
      expect(map.containsKey('FPT'), isFalse);
    });

    test('hỏi danh sách rỗng trả về bản đồ rỗng', () async {
      expect(await prices.effectivePricesFor(const []), isEmpty);
    });
  });

  group('Ghi kèm nguồn và thời điểm', () {
    test('giá nhập tay mang thời điểm lúc nhập', () async {
      final quote = await prices.saveManualPrice(
        symbol: 'SJC',
        price: const Money(13142857),
      );
      expect(quote.fetchedAt, clock);
      expect(quote.source, PriceSource.manual);
      expect((await prices.quotesFor('SJC')).single.fetchedAt, clock);
    });

    test('giá thị trường giữ đúng thời điểm lấy được, không phải lúc ghi',
        () async {
      final fetchedAt = DateTime.utc(2026, 8, 27, 8, 15);
      await prices.saveMarketPrices([
        marketQuote('BTC', 6000000, at: fetchedAt),
      ]);
      expect((await prices.quotesFor('BTC')).single.fetchedAt, fetchedAt);
    });

    test('thời điểm đọc lại vẫn là UTC', () async {
      await prices.saveManualPrice(symbol: 'BTC', price: const Money(1));
      expect((await prices.quotesFor('BTC')).single.fetchedAt.isUtc, isTrue);
    });
  });

  group('Chuẩn hoá ký hiệu', () {
    test('chữ thường và khoảng trắng tìm đúng giá đã lưu', () async {
      await prices.saveManualPrice(symbol: 'btc ', price: const Money(5));

      expect((await prices.effectivePriceFor(' BTC'))!.priceAmount,
          const Money(5));
      expect((await prices.quotesFor('BTC')).single.symbol, 'BTC');
    });
  });

  group('Hỏi giá nhiều ký hiệu cùng lúc', () {
    test('mỗi ký hiệu nhận đúng giá hiệu lực của nó', () async {
      await prices.saveMarketPrices([
        marketQuote('BTC', 6000000),
        marketQuote('ETH', 300000),
      ]);
      await prices.saveManualPrice(
        symbol: 'BTC',
        price: const Money(6500000),
        currency: Currency.usd,
      );

      final map = await prices.effectivePricesFor(['BTC', 'ETH']);

      expect(map['BTC']!.source, PriceSource.manual);
      expect(map['BTC']!.priceAmount, const Money(6500000));
      expect(map['ETH']!.source, PriceSource.api);
      expect(map['ETH']!.priceAmount, const Money(300000));
    });
  });
}
