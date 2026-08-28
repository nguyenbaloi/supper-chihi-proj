import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../../domain/rules/slugify.dart';
import '../db/database.dart';
import 'seed_data.dart';

/// Nạp dữ liệu hạt giống — FR-1, FR-2, FR-3, FR-4.
///
/// Chạy lại **không nhân đôi** bản ghi: đối chiếu theo tên Chủ đề và tên Dự án.
class Seeder {
  Seeder(this._db, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// FR-1: sáu Chủ đề chuẩn. Gọi ở mỗi lần mở app — người dùng không bao giờ
  /// gặp danh sách Chủ đề rỗng, kể cả sau khi xoá sạch dữ liệu.
  Future<void> ensureTopics() async {
    await _db.transaction(() async {
      final existing = await _db.select(_db.topics).get();
      final byName = {for (final t in existing) t.name: t};
      for (var i = 0; i < seedTopics.length; i++) {
        final seed = seedTopics[i];
        if (byName.containsKey(seed.name)) continue;
        await _db.into(_db.topics).insert(
              TopicsCompanion.insert(
                name: seed.name,
                colorValue: seed.colorValue,
                iconKey: seed.iconKey,
                sortOrder: Value(i),
                isSystemFallback: Value(seed.isFallback),
              ),
            );
      }
    });
  }

  /// FR-2, FR-3: bảy Dự án cùng Hành động, Ghi chú, Liên kết, và hai Mục tiêu
  /// đã nối sẵn vào Dự án.
  ///
  /// Chạy hai lần liên tiếp cho ra kết quả giống hệt chạy một lần.
  Future<void> applyProjectSeed() async {
    await ensureTopics();
    await _db.transaction(() async {
      final topics = await _db.select(_db.topics).get();
      final topicIdByName = {for (final t in topics) t.name: t.id};
      final topicIdByKey = <String, int>{
        for (final s in seedTopics)
          if (topicIdByName.containsKey(s.name)) s.key: topicIdByName[s.name]!,
      };
      final fallbackId = topicIdByKey['other'] ?? topics.first.id;

      final existingProjects = await _db.select(_db.projects).get();
      final projectIdByName = {for (final p in existingProjects) p.name: p.id};
      final now = _now().toUtc();

      for (final seed in seedProjects) {
        if (projectIdByName.containsKey(seed.name)) continue;

        final projectId = await _db.into(_db.projects).insert(
              ProjectsCompanion.insert(
                topicId: topicIdByKey[seed.topicKey] ?? fallbackId,
                name: seed.name,
                description: Value(seed.description),
                status: ProjectStatus.active.wire,
                priority: seed.priority.wire,
                createdAt: now,
                updatedAt: now,
                startedAt: Value(now),
                searchText: Value(buildSearchText([seed.name, seed.description])),
              ),
            );
        projectIdByName[seed.name] = projectId;

        for (var i = 0; i < seed.actions.length; i++) {
          final a = seed.actions[i];
          await _db.into(_db.actions).insert(
                ActionsCompanion.insert(
                  projectId: projectId,
                  title: a.title,
                  status: a.status.wire,
                  sortOrder: Value(i),
                  createdAt: now,
                  updatedAt: now,
                  // Hành động hạt giống mang sẵn trạng thái từ file gốc; dấu
                  // thời gian tương ứng được ghi để AD-5 không bị hụt dữ liệu.
                  startedAt: Value(a.status == ActionStatus.todo ? null : now),
                  completedAt: Value(a.status == ActionStatus.done ? now : null),
                  searchText: Value(buildSearchText([a.title])),
                ),
              );
        }

        for (final n in seed.notes) {
          await _db.into(_db.notes).insert(
                NotesCompanion.insert(
                  projectId: projectId,
                  title: n.title,
                  bodyMarkdown: Value(n.body),
                  createdAt: now,
                  updatedAt: now,
                  searchText: Value(buildSearchText([n.title, n.body])),
                ),
              );
        }

        for (var i = 0; i < seed.links.length; i++) {
          final l = seed.links[i];
          await _db.into(_db.links).insert(
                LinksCompanion.insert(
                  projectId: projectId,
                  label: l.label,
                  url: l.url,
                  sortOrder: Value(i),
                  searchText: Value(buildSearchText([l.label, l.url])),
                ),
              );
        }
      }

      final existingGoals = await _db.select(_db.goals).get();
      final goalIdByName = {for (final g in existingGoals) g.name: g.id};

      for (final seed in seedGoals) {
        var goalId = goalIdByName[seed.name];
        if (goalId == null) {
          goalId = await _db.into(_db.goals).insert(
                GoalsCompanion.insert(
                  name: seed.name,
                  description: Value(seed.description),
                  isNumeric: Value(seed.isNumeric),
                  targetRaw: Value(seed.targetRaw),
                  unit: Value(seed.unit),
                  createdAt: now,
                  updatedAt: now,
                  searchText: Value(buildSearchText([seed.name, seed.description])),
                ),
              );
          goalIdByName[seed.name] = goalId;
        }
        for (final projectName in seed.linkedProjectNames) {
          final projectId = projectIdByName[projectName];
          if (projectId == null) continue;
          await _db.into(_db.projectGoals).insert(
                ProjectGoalsCompanion.insert(projectId: projectId, goalId: goalId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    });
  }
}
