import 'package:drift/drift.dart';

import '../../domain/models/area.dart';
import '../../domain/repositories/repositories.dart';
import '../db/database.dart';
import 'mappers.dart';

class DriftAreaRepository implements AreaRepository {
  DriftAreaRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Area>> watchAll() => (_db.select(_db.areas)
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Future<List<Area>> getAll() async {
    final rows = await (_db.select(_db.areas)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    return rows.map((r) => r.toModel()).toList();
  }

  @override
  Future<Area> create({
    required String name,
    required int colorValue,
    required String iconKey,
  }) async {
    final maxOrder = await _db
        .customSelect('SELECT COALESCE(MAX(sort_order), -1) AS m FROM areas')
        .getSingle();
    final id = await _db.into(_db.areas).insert(
          AreasCompanion.insert(
            name: name,
            colorValue: colorValue,
            iconKey: iconKey,
            sortOrder: Value(maxOrder.read<int>('m') + 1),
          ),
        );
    return Area(
      id: id,
      name: name,
      colorValue: colorValue,
      iconKey: iconKey,
      sortOrder: maxOrder.read<int>('m') + 1,
    );
  }

  @override
  Future<void> update(Area area) async {
    await (_db.update(_db.areas)..where((t) => t.id.equals(area.id))).write(
      AreasCompanion(
        name: Value(area.name),
        colorValue: Value(area.colorValue),
        iconKey: Value(area.iconKey),
        sortOrder: Value(area.sortOrder),
      ),
    );
  }

  /// FR-1: Dự án thuộc Lĩnh vực bị xoá chuyển về Lĩnh vực `Khác`, không bị xoá theo.
  /// Lĩnh vực `Khác` không xoá được.
  @override
  Future<void> delete(int id) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.areas)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null || row.isSystemFallback) return;

      final fallback = await (_db.select(_db.areas)
            ..where((t) => t.isSystemFallback.equals(true))
            ..limit(1))
          .getSingleOrNull();
      if (fallback == null) return;

      await (_db.update(_db.projects)..where((p) => p.areaId.equals(id)))
          .write(ProjectsCompanion(areaId: Value(fallback.id)));
      await (_db.delete(_db.areas)..where((t) => t.id.equals(id))).go();
    });
  }
}
