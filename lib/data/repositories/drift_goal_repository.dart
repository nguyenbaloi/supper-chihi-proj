import 'package:drift/drift.dart';

import '../../domain/models/goal.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/day.dart';
import '../../domain/rules/slugify.dart';
import '../db/database.dart';
import 'mappers.dart';

class DriftGoalRepository implements GoalRepository {
  DriftGoalRepository(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Stream<List<Goal>> watchAll() => (_db.select(_db.goals)
        ..orderBy([(g) => OrderingTerm(expression: g.createdAt)]))
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Stream<Goal?> watchById(int id) =>
      (_db.select(_db.goals)..where((g) => g.id.equals(id)))
          .watchSingleOrNull()
          .map((r) => r?.toModel());

  @override
  Stream<List<GoalUpdate>> watchUpdates(int goalId) => (_db.select(_db.goalUpdates)
        ..where((u) => u.goalId.equals(goalId))
        ..orderBy([
          (u) => OrderingTerm(expression: u.date),
          (u) => OrderingTerm(expression: u.createdAt),
        ]))
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Future<List<GoalUpdate>> getUpdates(int goalId) async {
    final rows = await (_db.select(_db.goalUpdates)
          ..where((u) => u.goalId.equals(goalId))
          ..orderBy([(u) => OrderingTerm(expression: u.date)]))
        .get();
    return rows.map((r) => r.toModel()).toList();
  }

  @override
  Future<Goal> create({
    required String name,
    String description = '',
    required bool isNumeric,
    int? targetRaw,
    int decimals = 0,
    String unit = 'VND',
    DateTime? dueDate,
  }) async {
    final now = _now().toUtc();
    final id = await _db.into(_db.goals).insert(
          GoalsCompanion.insert(
            name: name,
            description: Value(description),
            isNumeric: Value(isNumeric),
            targetRaw: Value(isNumeric ? targetRaw : null),
            decimals: Value(decimals),
            unit: Value(unit),
            dueDate: Value(dueDate == null ? null : startOfDay(dueDate)),
            createdAt: now,
            updatedAt: now,
            searchText: Value(buildSearchText([name, description])),
          ),
        );
    return Goal(
      id: id,
      name: name,
      description: description,
      isNumeric: isNumeric,
      targetRaw: isNumeric ? targetRaw : null,
      decimals: decimals,
      unit: unit,
      dueDate: dueDate == null ? null : startOfDay(dueDate),
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> update(Goal goal) async {
    await (_db.update(_db.goals)..where((g) => g.id.equals(goal.id))).write(
      GoalsCompanion(
        name: Value(goal.name),
        description: Value(goal.description),
        isNumeric: Value(goal.isNumeric),
        targetRaw: Value(goal.isNumeric ? goal.targetRaw : null),
        decimals: Value(goal.decimals),
        unit: Value(goal.unit),
        dueDate: Value(goal.dueDate == null ? null : startOfDay(goal.dueDate!)),
        updatedAt: Value(_now().toUtc()),
        searchText: Value(buildSearchText([goal.name, goal.description])),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();
  }

  /// FR-21: thêm một Mốc. Ngày được chuẩn hoá về mốc 00:00 giờ địa phương;
  /// `createdAt` là thứ phân định khi nhiều Mốc trùng ngày.
  @override
  Future<GoalUpdate> addUpdate({
    required int goalId,
    required DateTime date,
    required int valueRaw,
    String note = '',
  }) async {
    final goal = await (_db.select(_db.goals)..where((g) => g.id.equals(goalId)))
        .getSingle();
    final now = _now().toUtc();
    final day = startOfDay(date);
    final id = await _db.into(_db.goalUpdates).insert(
          GoalUpdatesCompanion.insert(
            goalId: goalId,
            date: day,
            valueRaw: valueRaw,
            decimals: Value(goal.decimals),
            note: Value(note),
            createdAt: now,
          ),
        );
    return GoalUpdate(
      id: id,
      goalId: goalId,
      date: day,
      valueRaw: valueRaw,
      decimals: goal.decimals,
      note: note,
      createdAt: now,
    );
  }

  /// Sửa một Mốc, kể cả Mốc ở giữa chuỗi và kể cả đổi ngày. Không có giá trị
  /// dẫn xuất nào phải cập nhật theo, vì không giá trị nào được lưu (AD-3).
  @override
  Future<void> updateMark(GoalUpdate mark) async {
    await (_db.update(_db.goalUpdates)..where((u) => u.id.equals(mark.id))).write(
      GoalUpdatesCompanion(
        date: Value(startOfDay(mark.date)),
        valueRaw: Value(mark.valueRaw),
        note: Value(mark.note),
      ),
    );
  }

  @override
  Future<void> deleteMark(int id) async {
    await (_db.delete(_db.goalUpdates)..where((u) => u.id.equals(id))).go();
  }

  @override
  Future<void> linkProject(int projectId, int goalId) async {
    await _db.into(_db.projectGoals).insert(
          ProjectGoalsCompanion.insert(projectId: projectId, goalId: goalId),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> unlinkProject(int projectId, int goalId) async {
    await (_db.delete(_db.projectGoals)
          ..where((l) => l.projectId.equals(projectId) & l.goalId.equals(goalId)))
        .go();
  }

  @override
  Stream<List<int>> watchLinkedProjectIds(int goalId) =>
      (_db.select(_db.projectGoals)..where((l) => l.goalId.equals(goalId)))
          .watch()
          .map((rows) => rows.map((r) => r.projectId).toList());

  @override
  Stream<List<int>> watchLinkedGoalIds(int projectId) =>
      (_db.select(_db.projectGoals)..where((l) => l.projectId.equals(projectId)))
          .watch()
          .map((rows) => rows.map((r) => r.goalId).toList());
}
