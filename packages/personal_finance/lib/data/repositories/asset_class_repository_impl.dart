import 'package:drift/drift.dart';

import '../../domain/models/asset_class.dart';
import '../../domain/repositories/asset_class_repository.dart';
import '../db/database.dart';

/// Cài đặt [AssetClassRepository] trên drift.
class AssetClassRepositoryImpl implements AssetClassRepository {
  final AppDatabase _db;

  AssetClassRepositoryImpl(this._db);

  @override
  Future<List<AssetClass>> all() => _ordered().get();

  @override
  Future<List<AssetClass>> visible() => _ordered(onlyVisible: true).get();

  @override
  Stream<List<AssetClass>> watchAll() => _ordered().watch();

  @override
  Future<AssetClass?> byId(int id) => (_db.select(_db.assetClassesTable)
        ..where((t) => t.id.equals(id)))
      .map(_toDomain)
      .getSingleOrNull();

  @override
  Future<void> rename(int id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'tên lớp tài sản không được rỗng');
    }
    await (_db.update(_db.assetClassesTable)..where((t) => t.id.equals(id)))
        .write(AssetClassesTableCompanion(name: Value(trimmed)));
  }

  @override
  Future<HideAssetClassResult> hide(int id) => _db.transaction(() async {
        final existing = await byId(id);
        if (existing == null) return const AssetClassNotFound();

        // Đếm bên trong cùng một giao dịch với lệnh ghi: nếu đếm trước rồi mới
        // ghi ở ngoài, một Khoản nắm giữ thêm vào giữa hai bước sẽ lọt qua và
        // lớp bị ẩn dù đang có tài sản bên trong.
        final holdingCount = await _countHoldings(id);
        if (holdingCount > 0) return AssetClassNotEmpty(holdingCount);

        await _setHidden(id, true);
        return const AssetClassHidden();
      });

  @override
  Future<void> unhide(int id) => _setHidden(id, false);

  Future<void> _setHidden(int id, bool hidden) async {
    await (_db.update(_db.assetClassesTable)..where((t) => t.id.equals(id)))
        .write(AssetClassesTableCompanion(hidden: Value(hidden)));
  }

  Future<int> _countHoldings(int assetClassId) async {
    final count = _db.holdingsTable.id.count();
    final query = _db.selectOnly(_db.holdingsTable)
      ..addColumns([count])
      ..where(_db.holdingsTable.assetClassId.equals(assetClassId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Thứ tự hiển thị cố định: theo `sortOrder`, `id` phá thế hoà để hai lần
  /// đọc liên tiếp không bao giờ trả về thứ tự khác nhau.
  Selectable<AssetClass> _ordered({bool onlyVisible = false}) {
    final query = _db.select(_db.assetClassesTable)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.id),
      ]);
    if (onlyVisible) query.where((t) => t.hidden.equals(false));
    return query.map(_toDomain);
  }

  static AssetClass _toDomain(AssetClassesTableData row) => AssetClass(
        id: row.id,
        name: row.name,
        kind: row.kind,
        targetWeightBp: row.targetWeightBp,
        targetGroupId: row.targetGroupId,
        inInvestmentGroup: row.inInvestmentGroup,
        hidden: row.hidden,
        sortOrder: row.sortOrder,
        colorValue: row.colorValue,
        iconCodePoint: row.iconCodePoint,
      );
}
