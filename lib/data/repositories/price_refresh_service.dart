import '../../core/result/result.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/fx_rate_repository.dart';
import '../../domain/repositories/holding_repository.dart';
import '../../domain/repositories/price_quote_repository.dart';
import '../remote/exchange_rate_source.dart';
import '../remote/remote_price_source.dart';

/// Kết quả một lần làm mới giá.
///
/// Thất bại được **báo cáo chứ không ném ra**: người dùng cần biết giá đang
/// cũ, nhưng không thao tác nào bị chặn và không hộp thoại nào che màn hình.
/// Xem AD-11 và FR-14.
class PriceRefreshOutcome {
  final int updatedQuotes;
  final bool fxUpdated;
  final List<String> failures;

  const PriceRefreshOutcome({
    this.updatedQuotes = 0,
    this.fxUpdated = false,
    this.failures = const [],
  });

  bool get hasFailures => failures.isNotEmpty;
  bool get changedAnything => updatedQuotes > 0 || fxUpdated;
}

/// Làm mới Giá thị trường và Tỷ giá.
///
/// Chỉ hỏi giá của những ký hiệu người dùng **đang thực sự nắm giữ**, và chỉ
/// gửi đi ký hiệu đó. Xem AD-8.
class PriceRefreshService {
  final RemotePriceSource _priceSource;
  final RemoteFxRateSource _fxSource;
  final PriceQuoteRepository _quotes;
  final FxRateRepository _fxRates;
  final HoldingRepository _holdings;

  PriceRefreshService({
    required RemotePriceSource priceSource,
    required RemoteFxRateSource fxSource,
    required PriceQuoteRepository quotes,
    required FxRateRepository fxRates,
    required HoldingRepository holdings,
  })  : _priceSource = priceSource,
        _fxSource = fxSource,
        _quotes = quotes,
        _fxRates = fxRates,
        _holdings = holdings;

  Future<PriceRefreshOutcome> refresh() async {
    final failures = <String>[];

    final symbols = (await _holdings.all())
        .where((h) => h.inputMode == InputMode.quantity)
        .map((h) => h.symbol)
        .toSet();

    var updated = 0;
    if (symbols.isNotEmpty) {
      final result = await _priceSource.fetchPrices(symbols);
      switch (result) {
        case Ok(:final value):
          await _quotes.saveMarketPrices(value);
          updated = value.length;
        case Failure(:final reason):
          failures.add(reason);
      }
    }

    var fxUpdated = false;
    final fxResult = await _fxSource.fetchUsdToVnd();
    switch (fxResult) {
      case Ok(:final value):
        await _fxRates.saveFetchedRate(value);
        fxUpdated = true;
      case Failure(:final reason):
        failures.add(reason);
    }

    return PriceRefreshOutcome(
      updatedQuotes: updated,
      fxUpdated: fxUpdated,
      failures: failures,
    );
  }
}
