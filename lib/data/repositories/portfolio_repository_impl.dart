import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/holding.dart';
import '../../domain/models/portfolio_valuation.dart';
import '../../domain/models/price_quote.dart';
import '../../domain/models/valued_holding.dart';
import '../../domain/repositories/asset_class_repository.dart';
import '../../domain/repositories/holding_repository.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../domain/repositories/price_quote_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/rules/holding_value.dart';
import '../../domain/rules/portfolio_math.dart';
import '../db/database.dart';

/// Cài đặt [PortfolioRepository].
///
/// Chỉ làm ba việc: đọc dữ liệu thô, gọi công thức trong `domain`, trả kết
/// quả. Không có phép tính tài chính nào viết ở đây — chúng nằm trong
/// `domain/rules` để test được mà không cần cơ sở dữ liệu.
class PortfolioRepositoryImpl implements PortfolioRepository {
  final AppDatabase _db;
  final AssetClassRepository _assetClasses;
  final HoldingRepository _holdings;
  final PriceQuoteRepository _prices;
  final SettingsRepository _settings;

  PortfolioRepositoryImpl({
    required AppDatabase db,
    required AssetClassRepository assetClasses,
    required HoldingRepository holdings,
    required PriceQuoteRepository prices,
    required SettingsRepository settings,
  })  : _db = db,
        _assetClasses = assetClasses,
        _holdings = holdings,
        _prices = prices,
        _settings = settings;

  @override
  Future<PortfolioValuation> valuation() async {
    final classes = await _assetClasses.all();
    final holdings = await _holdings.all();
    final context = await _valuationContext(holdings);

    final valueByClass = <int, Money>{};
    final unpricedByClass = <int, int>{};

    for (final holding in holdings) {
      final value = _valueOf(holding, context);
      final amount = value.amountOrNull;
      if (amount == null) {
        unpricedByClass.update(
          holding.assetClassId,
          (n) => n + 1,
          ifAbsent: () => 1,
        );
        continue;
      }
      valueByClass.update(
        holding.assetClassId,
        (current) => current + amount,
        ifAbsent: () => amount,
      );
    }

    return PortfolioMath.valuation(
      classes,
      valueByClass,
      unpricedByAssetClassId: unpricedByClass,
    );
  }

  @override
  Stream<PortfolioValuation> watchValuation() {
    // Bất kỳ bảng nào trong bốn bảng này đổi đều làm số liệu tổng hợp đổi
    // theo. Nghe cả bốn để màn hình không bao giờ hiện số cũ.
    final trigger = _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.assetClassesTable,
        _db.holdingsTable,
        _db.priceQuotesTable,
        _db.settingsTable,
      ]),
    );

    late StreamController<PortfolioValuation> controller;
    StreamSubscription<void>? subscription;

    Future<void> emit() async {
      final next = await valuation();
      if (!controller.isClosed) controller.add(next);
    }

    controller = StreamController<PortfolioValuation>(
      onListen: () {
        unawaited(emit());
        subscription = trigger.listen((_) => unawaited(emit()));
      },
      onCancel: () async => subscription?.cancel(),
    );

    return controller.stream;
  }

  @override
  Future<List<ValuedHolding>> valuedHoldings(int assetClassId) async {
    final holdings = await _holdings.byAssetClass(assetClassId);
    final context = await _valuationContext(holdings);

    return holdings
        .map(
          (holding) => ValuedHolding(
            holding: holding,
            effectivePrice: context.priceFor(holding),
            value: _valueOf(holding, context),
          ),
        )
        .toList(growable: false);
  }

  HoldingValue _valueOf(Holding holding, _ValuationContext context) =>
      HoldingValuation.of(
        holding,
        price: context.priceFor(holding),
        usdToVndRate: context.usdToVndRate,
      );

  Future<_ValuationContext> _valuationContext(List<Holding> holdings) async {
    final symbols = holdings
        .where((h) => h.inputMode == InputMode.quantity)
        .map((h) => h.symbol)
        .toSet();

    return _ValuationContext(
      pricesBySymbol: await _prices.effectivePricesFor(symbols),
      usdToVndRate: (await _settings.current())?.fxRateManualAmount,
    );
  }
}

class _ValuationContext {
  final Map<String, PriceQuote> pricesBySymbol;
  final Money? usdToVndRate;

  const _ValuationContext({
    required this.pricesBySymbol,
    required this.usdToVndRate,
  });

  PriceQuote? priceFor(Holding holding) =>
      holding.inputMode == InputMode.quantity
          ? pricesBySymbol[holding.symbol]
          : null;
}
