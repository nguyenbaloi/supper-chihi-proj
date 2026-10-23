import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/asset_class_repository_impl.dart';
import 'package:personal_finance/data/repositories/debt_repository_impl.dart';
import 'package:personal_finance/data/repositories/fx_rate_repository_impl.dart';
import 'package:personal_finance/data/repositories/holding_repository_impl.dart';
import 'package:personal_finance/data/repositories/portfolio_repository_impl.dart';
import 'package:personal_finance/data/repositories/price_quote_repository_impl.dart';
import 'package:personal_finance/data/repositories/settings_repository_impl.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/repositories/holding_repository.dart';

void main() {
  late AppDatabase db;
  late HoldingRepositoryImpl holdings;
  late PriceQuoteRepositoryImpl prices;
  late PortfolioRepositoryImpl portfolio;
  late AssetClassRepositoryImpl classes;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    classes = AssetClassRepositoryImpl(db);
    holdings = HoldingRepositoryImpl(db);
    prices = PriceQuoteRepositoryImpl(db);
    final settings = SettingsRepositoryImpl(db);
    portfolio = PortfolioRepositoryImpl(
      db: db,
      assetClasses: classes,
      holdings: holdings,
      prices: prices,
      debts: DebtRepositoryImpl(db),
      fxRates: FxRateRepositoryImpl(db, settings),
    );
  });
  tearDown(() => db.close());

  Future<int> idOf(AssetKind kind) async =>
      (await classes.all()).firstWhere((c) => c.kind == kind).id;

  group('Nhập số lượng cùng giá trong một lần', () {
    test('100 cổ FPT giá 150.000 đ ra đúng 15 triệu', () async {
      final stockId = await idOf(AssetKind.stock);

      final saved = await holdings.add(
        assetClassId: stockId,
        symbol: 'FPT',
        quantityText: '100',
      );
      await prices.saveManualPrice(
        symbol: (saved as HoldingSaved).holding.symbol,
        price: const Money(150000),
      );

      final valued = await portfolio.valuedHoldings(stockId);
      expect(valued.single.amountOrNull, const Money(15000000));
      expect(valued.single.usesManualPrice, isTrue);
    });

    test('ký hiệu gõ thường vẫn khớp giá đã lưu', () async {
      // Giá phải ghi theo ký hiệu đã chuẩn hoá mà repository trả về, không
      // phải chuỗi thô trong ô nhập.
      final stockId = await idOf(AssetKind.stock);
      final saved = await holdings.add(
        assetClassId: stockId,
        symbol: '  fpt ',
        quantityText: '100',
      );
      await prices.saveManualPrice(
        symbol: (saved as HoldingSaved).holding.symbol,
        price: const Money(150000),
      );

      final valued = await portfolio.valuedHoldings(stockId);
      expect(valued.single.amountOrNull, const Money(15000000));
    });

    test('xoá giá nhập tay thì khoản quay lại chưa có giá', () async {
      final stockId = await idOf(AssetKind.stock);
      await holdings.add(
        assetClassId: stockId,
        symbol: 'FPT',
        quantityText: '100',
      );
      await prices.saveManualPrice(symbol: 'FPT', price: const Money(150000));
      expect(
        (await portfolio.valuedHoldings(stockId)).single.amountOrNull,
        const Money(15000000),
      );

      await prices.clearManualPrice('FPT');

      expect(
        (await portfolio.valuedHoldings(stockId)).single.amountOrNull,
        isNull,
      );
    });

    test('7 chỉ vàng giá 13.142.857 đ mỗi chỉ', () async {
      final goldId = await idOf(AssetKind.gold);
      await holdings.add(
        assetClassId: goldId,
        symbol: 'SJC',
        quantityText: '7',
      );
      await prices.saveManualPrice(
        symbol: 'SJC',
        price: const Money(13142857),
      );

      expect(
        (await portfolio.valuedHoldings(goldId)).single.amountOrNull,
        const Money(91999999),
      );
    });
  });
}
