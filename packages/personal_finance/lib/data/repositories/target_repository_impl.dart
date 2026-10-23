import 'package:drift/drift.dart';

import '../../domain/models/target_group.dart';
import '../../domain/repositories/target_repository.dart';
import '../db/database.dart';

class TargetRepositoryImpl implements TargetRepository {
  final AppDatabase _db;

  TargetRepositoryImpl(this._db);

  @override
  Future<List<TargetGroup>> groups() => _ordered().get();

  @override
  Stream<List<TargetGroup>> watchGroups() => _ordered().watch();

  @override
  Future<TargetGroup> addGroup({
    required String name,
    required int targetWeightBp,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'tên nhóm không được rỗng');
    }
    final id = await _db.into(_db.targetGroupsTable).insert(
          TargetGroupsTableCompanion.insert(
            name: trimmed,
            targetWeightBp: targetWeightBp,
          ),
        );
    return (await _byId(id))!;
  }

  @override
  Future<TargetGroup?> updateGroup(
    int id, {
    String? name,
    int? targetWeightBp,
  }) async {
    final updated = await (_db.update(_db.targetGroupsTable)
          ..where((t) => t.id.equals(id)))
        .write(
      TargetGroupsTableCompanion(
        name: name == null ? const Value.absent() : Value(name.trim()),
        targetWeightBp: targetWeightBp == null
            ? const Value.absent()
            : Value(targetWeightBp),
      ),
    );
    return updated == 0 ? null : await _byId(id);
  }

  @override
  Future<bool> removeGroup(int id) async =>
      await (_db.delete(_db.targetGroupsTable)..where((t) => t.id.equals(id)))
              .go() >
          0;

  @override
  Future<void> setClassTarget(int assetClassId, int? targetWeightBp) async {
    await (_db.update(_db.assetClassesTable)
          ..where((t) => t.id.equals(assetClassId)))
        .write(AssetClassesTableCompanion(targetWeightBp: Value(targetWeightBp)));
  }

  @override
  Future<void> setClassGroup(int assetClassId, int? targetGroupId) async {
    await (_db.update(_db.assetClassesTable)
          ..where((t) => t.id.equals(assetClassId)))
        .write(AssetClassesTableCompanion(targetGroupId: Value(targetGroupId)));
  }

  @override
  Future<void> setInvestmentGroup(Set<int> assetClassIds) =>
      // Một giao dịch duy nhất: nếu tắt hết rồi mới bật lại từng lớp mà đứt
      // giữa chừng, Nhóm đầu tư sẽ rỗng và lãi lỗ bằng đúng âm vốn góp.
      _db.transaction(() async {
        await _db.update(_db.assetClassesTable).write(
              const AssetClassesTableCompanion(inInvestmentGroup: Value(false)),
            );
        if (assetClassIds.isEmpty) return;
        await (_db.update(_db.assetClassesTable)
              ..where((t) => t.id.isIn(assetClassIds)))
            .write(
          const AssetClassesTableCompanion(inInvestmentGroup: Value(true)),
        );
      });

  Future<TargetGroup?> _byId(int id) =>
      (_db.select(_db.targetGroupsTable)..where((t) => t.id.equals(id)))
          .map(_toDomain)
          .getSingleOrNull();

  Selectable<TargetGroup> _ordered() => (_db.select(_db.targetGroupsTable)
        ..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.id),
        ]))
      .map(_toDomain);

  static TargetGroup _toDomain(TargetGroupsTableData row) => TargetGroup(
        id: row.id,
        name: row.name,
        targetWeightBp: row.targetWeightBp,
        sortOrder: row.sortOrder,
      );
}
