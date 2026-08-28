import 'package:drift/drift.dart';

import '../../domain/models/topic.dart';
import '../../domain/repositories/repositories.dart';
import '../db/database.dart';
import 'mappers.dart';

class DriftTopicRepository implements TopicRepository {
  DriftTopicRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Topic>> watchAll() => (_db.select(_db.topics)
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Future<List<Topic>> getAll() async {
    final rows = await (_db.select(_db.topics)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    return rows.map((r) => r.toModel()).toList();
  }

  @override
  Future<Topic> create({
    required String name,
    required int colorValue,
    required String iconKey,
  }) async {
    final maxOrder = await _db
        .customSelect('SELECT COALESCE(MAX(sort_order), -1) AS m FROM topics')
        .getSingle();
    final id = await _db.into(_db.topics).insert(
          TopicsCompanion.insert(
            name: name,
            colorValue: colorValue,
            iconKey: iconKey,
            sortOrder: Value(maxOrder.read<int>('m') + 1),
          ),
        );
    return Topic(
      id: id,
      name: name,
      colorValue: colorValue,
      iconKey: iconKey,
      sortOrder: maxOrder.read<int>('m') + 1,
    );
  }

  @override
  Future<void> update(Topic topic) async {
    await (_db.update(_db.topics)..where((t) => t.id.equals(topic.id))).write(
      TopicsCompanion(
        name: Value(topic.name),
        colorValue: Value(topic.colorValue),
        iconKey: Value(topic.iconKey),
        sortOrder: Value(topic.sortOrder),
      ),
    );
  }

  /// FR-1: Dự án thuộc Chủ đề bị xoá chuyển về Chủ đề `Khác`, không bị xoá theo.
  /// Chủ đề `Khác` không xoá được.
  @override
  Future<void> delete(int id) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.topics)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null || row.isSystemFallback) return;

      final fallback = await (_db.select(_db.topics)
            ..where((t) => t.isSystemFallback.equals(true))
            ..limit(1))
          .getSingleOrNull();
      if (fallback == null) return;

      await (_db.update(_db.projects)..where((p) => p.topicId.equals(id)))
          .write(ProjectsCompanion(topicId: Value(fallback.id)));
      await (_db.delete(_db.topics)..where((t) => t.id.equals(id))).go();
    });
  }
}
