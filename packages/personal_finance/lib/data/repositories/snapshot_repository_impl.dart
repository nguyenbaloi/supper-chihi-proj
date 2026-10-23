import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/snapshot.dart';
import '../../domain/repositories/cash_flow_repository.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/snapshot_repository.dart';
import '../../domain/rules/contribution.dart';
import '../db/database.dart';
import 'date_utils.dart';

class SnapshotRepositoryImpl implements SnapshotRepository {
  final AppDatabase _db;
  final PortfolioRepository _portfolio;
  final CashFlowRepository _cashFlows;
  final SettingsRepository _settings;

  SnapshotRepositoryImpl({
    required AppDatabase db,
    required PortfolioRepository portfolio,
    required CashFlowRepository cashFlows,
    required SettingsRepository settings,
  })  : _db = db,
        _portfolio = portfolio,
        _cashFlows = cashFlows,
        _settings = settings;

  @override
  Future<List<Snapshot>> all() async {
    final rows = await (_db.select(_db.snapshotsTable)
          ..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
    if (rows.isEmpty) return const [];

    final details = await (_db.select(_db.snapshotDetailsTable)
          ..where((t) => t.snapshotId.isIn(rows.map((r) => r.id))))
        .get();
    final grouped = <int, List<SnapshotDetail>>{};
    for (final detail in details) {
      grouped.putIfAbsent(detail.snapshotId, () => []).add(
            SnapshotDetail(
              id: detail.id,
              snapshotId: detail.snapshotId,
              assetClassId: detail.assetClassId,
              assetClassName: detail.assetClassName,
              valueAmount: detail.valueAmount,
            ),
          );
    }

    return rows
        .map((row) => _toDomain(row, grouped[row.id] ?? const []))
        .toList(growable: false);
  }

  @override
  Stream<List<Snapshot>> watchAll() => _db
      .tableUpdates(
        TableUpdateQuery.onAllTables([
          _db.snapshotsTable,
          _db.snapshotDetailsTable,
        ]),
      )
      .asyncMap((_) => all());

  @override
  Future<Snapshot?> byId(int id) async {
    final all_ = await all();
    for (final snapshot in all_) {
      if (snapshot.id == id) return snapshot;
    }
    return null;
  }

  @override
  Future<Snapshot?> automaticOn(DateTime day) async {
    final start = startOfDayUtc(day);
    final row = await (_db.select(_db.snapshotsTable)
          ..where((t) =>
              t.date.equals(start) & t.kind.equalsValue(SnapshotKind.auto)))
        .getSingleOrNull();
    return row == null ? null : await byId(row.id);
  }

  @override
  Future<Snapshot?> captureAutomatic(DateTime today) async {
    // Chỉ chốt cho hôm nay. Người dùng không mở ứng dụng ba ngày thì ba ngày
    // đó không có dữ liệu — lấp bằng giá trị nội suy là bịa ra lịch sử chưa
    // từng xảy ra. Xem FR-28.
    if (await automaticOn(today) != null) return null;
    return _capture(today, SnapshotKind.auto, null);
  }

  @override
  Future<Snapshot> captureManual(DateTime at, {String? note}) =>
      _capture(at, SnapshotKind.manual, note);

  @override
  Future<bool> removeManual(int id) async {
    // Bản chốt tự động không có thao tác sửa hay xoá nào. Xem FR-28.
    final deleted = await (_db.delete(_db.snapshotsTable)
          ..where((t) =>
              t.id.equals(id) & t.kind.equalsValue(SnapshotKind.manual)))
        .go();
    return deleted > 0;
  }

  /// Vốn góp lũy kế và Lãi lỗ của từng Bản chốt, **tính lại lúc đọc**.
  Future<List<SnapshotPoint>> series() async {
    final snapshots = await all();
    if (snapshots.isEmpty) return const [];

    final settings = await _settings.current();
    final initial = settings?.initialContributionAmount ?? Money.zero;
    final flows = await _cashFlows.all();

    return snapshots
        .map(
          (snapshot) => SnapshotPoint(
            snapshot: snapshot,
            cumulativeContribution: Contribution.cumulativeAt(
              initialContribution: initial,
              cashFlows: flows,
              asOf: snapshot.date,
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<Snapshot> _capture(
    DateTime at,
    SnapshotKind kind,
    String? note,
  ) async {
    final valuation = await _portfolio.valuation();
    final date = startOfDayUtc(at);

    return _db.transaction(() async {
      final id = await _db.into(_db.snapshotsTable).insert(
            SnapshotsTableCompanion.insert(
              date: date,
              totalAssetsAmount: valuation.totalAssets,
              investmentGroupAmount: valuation.investmentGroupValue,
              kind: kind,
              note: Value(trimToNull(note)),
            ),
            mode: InsertMode.insertOrReplace,
          );

      await _db.batch((b) {
        b.insertAll(
          _db.snapshotDetailsTable,
          valuation.visible.map(
            (entry) => SnapshotDetailsTableCompanion.insert(
              snapshotId: id,
              assetClassId: Value(entry.assetClass.id),
              // Ghi lại tên tại thời điểm chốt: đổi tên lớp ở hiện tại không
              // được làm biến dạng cách đọc lịch sử.
              assetClassName: entry.assetClass.name,
              valueAmount: entry.value,
            ),
          ),
        );
      });

      return (await byId(id))!;
    });
  }

  static Snapshot _toDomain(
    SnapshotsTableData row,
    List<SnapshotDetail> details,
  ) =>
      Snapshot(
        id: row.id,
        date: row.date,
        totalAssetsAmount: row.totalAssetsAmount,
        investmentGroupAmount: row.investmentGroupAmount,
        kind: row.kind,
        note: row.note,
        details: details,
      );
}
