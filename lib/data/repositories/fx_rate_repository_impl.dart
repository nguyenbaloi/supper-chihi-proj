
import '../../domain/models/enums.dart';
import '../../domain/models/fx_rate.dart';
import '../../domain/repositories/fx_rate_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/rules/effective_fx_rate.dart';
import '../db/database.dart';

class FxRateRepositoryImpl implements FxRateRepository {
  final AppDatabase _db;
  final SettingsRepository _settings;

  FxRateRepositoryImpl(this._db, this._settings);

  @override
  Future<FxRate?> fetchedRate() async {
    final row = await (_db.select(_db.fxRatesTable)
          ..where((t) => t.source.equalsValue(PriceSource.api)))
        .getSingleOrNull();
    if (row == null) return null;
    return FxRate(
      rateAmount: row.rateAmount,
      source: row.source,
      fetchedAt: row.fetchedAt,
    );
  }

  @override
  Future<FxRate> effectiveRate() async => EffectiveFxRate.resolve(
        manualRate: (await _settings.current())?.fxRateManualAmount,
        fetchedRate: await fetchedRate(),
      );

  @override
  Future<void> saveFetchedRate(FxRate rate) async {
    await _db.into(_db.fxRatesTable).insertOnConflictUpdate(
          FxRatesTableCompanion.insert(
            source: PriceSource.api,
            rateAmount: rate.rateAmount,
            fetchedAt: rate.fetchedAt ?? DateTime.now().toUtc(),
          ),
        );
  }
}
