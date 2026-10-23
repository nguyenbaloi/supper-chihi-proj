import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/settings_repository.dart';
import '../db/database.dart';

/// Cài đặt [SettingsRepository] trên drift.
///
/// Bảng thiết lập luôn đúng một dòng với khoá chính cố định bằng 1 — ứng dụng
/// chỉ có một Danh mục duy nhất, vĩnh viễn. Xem AD-9.
class SettingsRepositoryImpl implements SettingsRepository {
  static const int _rowId = 1;

  final AppDatabase _db;

  SettingsRepositoryImpl(this._db);

  @override
  Future<AppSettings?> current() async {
    final row = await _row().getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<AppSettings?> watch() =>
      _row().watchSingleOrNull().map((row) => row == null ? null : _toDomain(row));

  @override
  Future<AppSettings> initialize({
    required Money initialContributionAmount,
    required DateTime startDate,
  }) async {
    await _db.into(_db.settingsTable).insertOnConflictUpdate(
          SettingsTableCompanion.insert(
            id: const Value(_rowId),
            initialContributionAmount: initialContributionAmount,
            startDate: startDate,
            onboardingCompleted: const Value(true),
          ),
        );
    return (await current())!;
  }

  @override
  Future<void> setInitialContribution(Money amount) =>
      _write(SettingsTableCompanion(initialContributionAmount: Value(amount)));

  @override
  Future<void> setStartDate(DateTime date) =>
      _write(SettingsTableCompanion(startDate: Value(date)));

  @override
  Future<void> setFxRate(Money? rate) =>
      _write(SettingsTableCompanion(fxRateManualAmount: Value(rate)));

  @override
  Future<void> setDriftThreshold(int bp) =>
      _write(SettingsTableCompanion(driftThresholdBp: Value(bp)));

  @override
  Future<void> setThemeMode(ThemeModeSetting mode) =>
      _write(SettingsTableCompanion(themeMode: Value(mode)));

  @override
  Future<void> markExported(DateTime at) =>
      _write(SettingsTableCompanion(lastExportedAt: Value(at)));

  Future<void> _write(SettingsTableCompanion changes) async {
    await (_db.update(_db.settingsTable)..where((t) => t.id.equals(_rowId)))
        .write(changes);
  }

  SimpleSelectStatement<$SettingsTableTable, SettingsTableData> _row() =>
      _db.select(_db.settingsTable)..where((t) => t.id.equals(_rowId));

  static AppSettings _toDomain(SettingsTableData row) => AppSettings(
        initialContributionAmount: row.initialContributionAmount,
        startDate: row.startDate,
        fxRateManualAmount: row.fxRateManualAmount,
        driftThresholdBp: row.driftThresholdBp,
        lastExportedAt: row.lastExportedAt,
        onboardingCompleted: row.onboardingCompleted,
        themeModeSetting: row.themeMode,
      );
}
