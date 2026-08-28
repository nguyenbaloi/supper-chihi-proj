import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/remote/coingecko_price_source.dart';
import '../../data/remote/exchange_rate_source.dart';
import '../../data/remote/remote_price_source.dart';
import '../../data/repositories/action_note_repository_impl.dart';
import '../../data/repositories/asset_class_repository_impl.dart';
import '../../data/repositories/cash_flow_repository_impl.dart';
import '../../data/repositories/debt_repository_impl.dart';
import '../../data/repositories/fx_rate_repository_impl.dart';
import '../../data/repositories/holding_repository_impl.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../data/repositories/price_quote_repository_impl.dart';
import '../../data/repositories/price_refresh_service.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/snapshot_repository_impl.dart';
import '../../domain/repositories/action_note_repository.dart';
import '../../domain/repositories/asset_class_repository.dart';
import '../../domain/repositories/cash_flow_repository.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/fx_rate_repository.dart';
import '../../domain/repositories/holding_repository.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../domain/repositories/price_quote_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/snapshot_repository.dart';
import '../../domain/repositories/target_repository.dart';
import '../../data/repositories/target_repository_impl.dart';

/// Provider khai báo thủ công dưới dạng biến `final` cấp cao nhất.
///
/// Không dùng code generation của Riverpod: `riverpod_generator` cần
/// `analyzer ^9/^12` còn `drift_dev` cần `^10/^13` — loại trừ nhau dưới
/// Dart 3.10.9. Xem AD-2.

/// Chủ sở hữu cơ sở dữ liệu thật.
///
/// Tách khỏi [databaseProvider] để khôi phục dữ liệu thay được tệp nằm dưới:
/// đóng cơ sở dữ liệu, ghi đè tệp `.sqlite`, mở lại. Mọi provider đọc
/// [databaseProvider] tự dựng lại theo, nên không cần khởi động lại ứng dụng
/// — trên iOS thì cũng không có cách nào tự khởi động lại.
final databaseHostProvider = NotifierProvider<DatabaseHost, AppDatabase>(
  DatabaseHost.new,
);

class DatabaseHost extends Notifier<AppDatabase> {
  /// Bản đang mở, giữ riêng để đóng được đúng bản cuối cùng: [state] đổi mỗi
  /// lần khôi phục, còn `onDispose` chỉ đăng ký được một lần.
  AppDatabase? _open;

  @override
  AppDatabase build() {
    final db = AppDatabase.open();
    _open = db;
    ref.onDispose(() {
      _open?.close();
      _open = null;
    });
    return db;
  }

  /// Đóng cơ sở dữ liệu, chạy [whileClosed] trên tệp, rồi mở lại.
  ///
  /// Thao tác tệp bắt buộc phải nằm giữa hai bước này: chép đè lên một tệp
  /// SQLite đang mở là cách chắc chắn nhất để hỏng dữ liệu.
  Future<void> reopen(Future<void> Function() whileClosed) async {
    await _open?.close();
    _open = null;
    try {
      await whileClosed();
    } finally {
      // Mở lại kể cả khi thao tác tệp thất bại: bỏ ứng dụng ở trạng thái
      // không có cơ sở dữ liệu còn hỏng hơn thao tác vừa lỗi.
      final db = AppDatabase.open();
      _open = db;
      state = db;
    }
  }
}

/// Cơ sở dữ liệu. Ghi đè trong test bằng một bản trong bộ nhớ.
final databaseProvider = Provider<AppDatabase>(
  (ref) => ref.watch(databaseHostProvider),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(databaseProvider)),
);

final assetClassRepositoryProvider = Provider<AssetClassRepository>(
  (ref) => AssetClassRepositoryImpl(ref.watch(databaseProvider)),
);

final holdingRepositoryProvider = Provider<HoldingRepository>(
  (ref) => HoldingRepositoryImpl(ref.watch(databaseProvider)),
);

final priceQuoteRepositoryProvider = Provider<PriceQuoteRepository>(
  (ref) => PriceQuoteRepositoryImpl(ref.watch(databaseProvider)),
);

final fxRateRepositoryProvider = Provider<FxRateRepository>(
  (ref) => FxRateRepositoryImpl(
    ref.watch(databaseProvider),
    ref.watch(settingsRepositoryProvider),
  ),
);

final debtRepositoryProvider = Provider<DebtRepository>(
  (ref) => DebtRepositoryImpl(ref.watch(databaseProvider)),
);

final cashFlowRepositoryProvider = Provider<CashFlowRepository>(
  (ref) => CashFlowRepositoryImpl(ref.watch(databaseProvider)),
);

final actionNoteRepositoryProvider = Provider<ActionNoteRepository>(
  (ref) => ActionNoteRepositoryImpl(ref.watch(databaseProvider)),
);

final targetRepositoryProvider = Provider<TargetRepository>(
  (ref) => TargetRepositoryImpl(ref.watch(databaseProvider)),
);

final portfolioRepositoryProvider = Provider<PortfolioRepository>(
  (ref) => PortfolioRepositoryImpl(
    db: ref.watch(databaseProvider),
    assetClasses: ref.watch(assetClassRepositoryProvider),
    holdings: ref.watch(holdingRepositoryProvider),
    prices: ref.watch(priceQuoteRepositoryProvider),
    debts: ref.watch(debtRepositoryProvider),
    fxRates: ref.watch(fxRateRepositoryProvider),
  ),
);

final snapshotRepositoryProvider = Provider<SnapshotRepository>(
  (ref) => SnapshotRepositoryImpl(
    db: ref.watch(databaseProvider),
    portfolio: ref.watch(portfolioRepositoryProvider),
    cashFlows: ref.watch(cashFlowRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
  ),
);

final remotePriceSourceProvider = Provider<RemotePriceSource>(
  (ref) => CoinGeckoPriceSource(),
);

final remoteFxRateSourceProvider = Provider<RemoteFxRateSource>(
  (ref) => ExchangeRateSource(),
);

final priceRefreshServiceProvider = Provider<PriceRefreshService>(
  (ref) => PriceRefreshService(
    priceSource: ref.watch(remotePriceSourceProvider),
    fxSource: ref.watch(remoteFxRateSourceProvider),
    quotes: ref.watch(priceQuoteRepositoryProvider),
    fxRates: ref.watch(fxRateRepositoryProvider),
    holdings: ref.watch(holdingRepositoryProvider),
  ),
);
