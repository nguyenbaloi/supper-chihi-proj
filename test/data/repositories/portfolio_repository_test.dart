import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/asset_class_repository_impl.dart';
import 'package:personal_finance/data/repositories/holding_repository_impl.dart';
import 'package:personal_finance/data/repositories/portfolio_repository_impl.dart';
import 'package:personal_finance/data/repositories/price_quote_repository_impl.dart';
import 'package:personal_finance/data/repositories/settings_repository_impl.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/repositories/asset_class_repository.dart';
import 'package:personal_finance/domain/repositories/holding_repository.dart';
import 'package:personal_finance/domain/repositories/portfolio_repository.dart';
import 'package:personal_finance/domain/repositories/price_quote_repository.dart';
import 'package:personal_finance/domain/repositories/settings_repository.dart';
import 'package:personal_finance/domain/rules/holding_value.dart';

void main() {
  late AppDatabase db;
  late AssetClassRepository classes;
  late HoldingRepository holdings;
  late PriceQuoteRepository prices;
  late SettingsRepository settings;
  late PortfolioRepository portfolio;

  final clock = DateTime.utc(2026, 8, 27, 10);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    classes = AssetClassRepositoryImpl(db);
    holdings = HoldingRepositoryImpl(db, now: () => clock);
    prices = PriceQuoteRepositoryImpl(db, now: () => clock);
    settings = SettingsRepositoryImpl(db);
    portfolio = PortfolioRepositoryImpl(
      db: db,
      assetClasses: classes,
      holdings: holdings,
      prices: prices,
      settings: settings,
    );
    await settings.initialize(
      initialContributionAmount: const Money(333000000),
      startDate: DateTime.utc(2026, 8, 27),
    );
  });
  tearDown(() => db.close());

  Future<int> idOf(AssetKind kind) async =>
      (await classes.all()).firstWhere((c) => c.kind == kind).id;

  Future<void> addValued(AssetKind kind, String symbol, int amount) async {
    final result = await holdings.add(
      assetClassId: await idOf(kind),
      symbol: symbol,
      manualValueAmount: Money(amount),
    );
    expect(result, isA<HoldingSaved>());
  }

  Future<void> addPriced(
    AssetKind kind,
    String symbol,
    String quantity,
    int priceAmount,
  ) async {
    final result = await holdings.add(
      assetClassId: await idOf(kind),
      symbol: symbol,
      quantityText: quantity,
    );
    expect(result, isA<HoldingSaved>());
    await prices.saveManualPrice(symbol: symbol, price: Money(priceAmount));
  }

  group('Dựng lại đúng con số của Excel gốc', () {
    setUp(() async {
      // Chứng khoán 15tr: 100 cổ FPT giá 150.000 đ.
      await addPriced(AssetKind.stock, 'FPT', '100', 150000);
      // Tiền mặt 92tr, Cho vay 183tr: nhập thẳng giá trị.
      await addValued(AssetKind.cashSavings, 'TK VCB', 92000000);
      await addValued(AssetKind.lending, 'Anh Nam', 183000000);
      // Crypto 390tr: 3 chỉ ảo giá 130tr — dùng giá VND cho gọn.
      await addPriced(AssetKind.crypto, 'BTC', '3', 130000000);
    });

    test('giá trị lớp Chứng khoán đúng 15 triệu', () async {
      final valuation = await portfolio.valuation();
      final stock = valuation.entries
          .firstWhere((e) => e.assetClass.kind == AssetKind.stock);
      expect(stock.value, const Money(15000000));
    });

    test('tổng tài sản đúng 680 triệu', () async {
      expect((await portfolio.valuation()).totalAssets,
          const Money(680000000));
    });

    test('bốn tỷ trọng khớp nhãn biểu đồ tròn', () async {
      final valuation = await portfolio.valuation();
      final byKind = {
        for (final e in valuation.visible) e.assetClass.kind: e.assetClass.id,
      };
      expect(valuation.weightOf(byKind[AssetKind.crypto]!).toString(),
          startsWith('0.5735'));
      expect(valuation.weightOf(byKind[AssetKind.lending]!).toString(),
          startsWith('0.2691'));
    });

    test('không lớp nào thiếu giá', () async {
      expect((await portfolio.valuation()).hasUnpricedHoldings, isFalse);
    });

    test('nhóm đầu tư gồm Chứng khoán và Crypto, đúng 405 triệu', () async {
      expect((await portfolio.valuation()).investmentGroupValue,
          const Money(405000000));
    });
  });

  group('Lớp bị ẩn', () {
    test('không cộng vào tổng tài sản', () async {
      await addValued(AssetKind.cashSavings, 'TK VCB', 92000000);
      await addValued(AssetKind.lending, 'Anh Nam', 183000000);

      expect((await portfolio.valuation()).totalAssets,
          const Money(275000000));

      // Lớp Cho vay rỗng thì mới ẩn được; xoá khoản trước.
      final lendingId = await idOf(AssetKind.lending);
      final holding = (await holdings.byAssetClass(lendingId)).single;
      await holdings.remove(holding.id);
      await classes.hide(lendingId);

      expect((await portfolio.valuation()).totalAssets, const Money(92000000));
    });
  });

  group('Khoản chưa có giá', () {
    test('không bị tính thành 0 đồng mà được đếm riêng', () async {
      await addValued(AssetKind.cashSavings, 'TK VCB', 92000000);
      // Thêm cổ phiếu nhưng không nhập giá.
      await holdings.add(
        assetClassId: await idOf(AssetKind.stock),
        symbol: 'HCM',
        quantityText: '1000',
      );

      final valuation = await portfolio.valuation();
      final stock = valuation.entries
          .firstWhere((e) => e.assetClass.kind == AssetKind.stock);

      expect(stock.unpricedCount, 1);
      expect(stock.isComplete, isFalse);
      expect(valuation.hasUnpricedHoldings, isTrue);
      expect(valuation.unpricedCount, 1);
      // Tổng chỉ gồm phần đã tính được, không âm thầm cộng thêm 0.
      expect(valuation.totalAssets, const Money(92000000));
    });

    test('nhập giá tay xong thì lớp trở nên đầy đủ', () async {
      await holdings.add(
        assetClassId: await idOf(AssetKind.stock),
        symbol: 'HCM',
        quantityText: '1000',
      );
      expect((await portfolio.valuation()).hasUnpricedHoldings, isTrue);

      await prices.saveManualPrice(symbol: 'HCM', price: const Money(25000));

      final valuation = await portfolio.valuation();
      expect(valuation.hasUnpricedHoldings, isFalse);
      expect(valuation.totalAssets, const Money(25000000));
    });
  });

  group('Chi tiết một lớp tài sản', () {
    test('mỗi khoản kèm giá hiệu lực và giá trị quy đổi', () async {
      await addPriced(AssetKind.crypto, 'BTC', '0.5', 1000000000);
      final cryptoId = await idOf(AssetKind.crypto);

      final valued = await portfolio.valuedHoldings(cryptoId);

      expect(valued, hasLength(1));
      expect(valued.single.amountOrNull, const Money(500000000));
      expect(valued.single.effectivePrice!.priceAmount,
          const Money(1000000000));
      expect(valued.single.usesManualPrice, isTrue);
    });

    test('khoản chưa có giá nói rõ lý do', () async {
      await holdings.add(
        assetClassId: await idOf(AssetKind.gold),
        symbol: 'SJC',
        quantityText: '7',
      );

      final valued = await portfolio.valuedHoldings(await idOf(AssetKind.gold));
      final value = valued.single.value;

      expect(value, isA<HoldingValueUnknown>());
      expect((value as HoldingValueUnknown).reason, MissingValueReason.noPrice);
      expect(valued.single.effectivePrice, isNull);
    });

    test('khoản nhập theo giá trị không cần giá', () async {
      await addValued(AssetKind.cashSavings, 'TK VCB', 92000000);

      final valued =
          await portfolio.valuedHoldings(await idOf(AssetKind.cashSavings));
      expect(valued.single.amountOrNull, const Money(92000000));
      expect(valued.single.effectivePrice, isNull);
      expect(valued.single.usesManualPrice, isFalse);
    });
  });

  group('Quy đổi USD dùng tỷ giá trong thiết lập', () {
    test('chưa nhập tỷ giá thì khoản USD chưa tính được', () async {
      await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
        quantityText: '0.5',
        currency: Currency.usd,
      );
      await prices.saveManualPrice(
        symbol: 'BTC',
        price: const Money(6000000),
        currency: Currency.usd,
      );

      final valued =
          await portfolio.valuedHoldings(await idOf(AssetKind.crypto));
      expect(
        (valued.single.value as HoldingValueUnknown).reason,
        MissingValueReason.noFxRate,
      );
    });

    test('nhập tỷ giá xong thì quy đổi được', () async {
      await settings.setFxRate(const Money(25000));
      await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
        quantityText: '0.5',
        currency: Currency.usd,
      );
      await prices.saveManualPrice(
        symbol: 'BTC',
        price: const Money(6000000),
        currency: Currency.usd,
      );

      final valued =
          await portfolio.valuedHoldings(await idOf(AssetKind.crypto));
      expect(valued.single.amountOrNull, const Money(750000000));
    });
  });

  group('Theo dõi thay đổi', () {
    test('thêm khoản nắm giữ làm tổng tài sản phát ra giá trị mới', () async {
      final stream = portfolio.watchValuation();

      expect(
        stream.map((v) => v.totalAssets),
        emitsInOrder([Money.zero, const Money(92000000)]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await addValued(AssetKind.cashSavings, 'TK VCB', 92000000);
    });
  });
}
