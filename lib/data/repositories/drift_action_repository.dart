import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/project_action.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/slugify.dart';
import '../db/database.dart';
import 'mappers.dart';

class DriftActionRepository implements ActionRepository {
  DriftActionRepository(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Stream<List<ProjectAction>> watchByProject(int projectId) =>
      (_db.select(_db.actions)
            ..where((a) => a.projectId.equals(projectId))
            ..orderBy([
              (a) => OrderingTerm(expression: a.sortOrder),
              (a) => OrderingTerm(expression: a.id),
            ]))
          .watch()
          .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Stream<ProjectAction?> watchById(int id) =>
      (_db.select(_db.actions)..where((a) => a.id.equals(id)))
          .watchSingleOrNull()
          .map((row) => row?.toModel());

  @override
  Future<ProjectAction> create({
    required int projectId,
    required String title,
    String note = '',
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) async {
    final now = _now().toUtc();
    final next = await _nextSortOrder(projectId);
    final id = await _db.into(_db.actions).insert(
          ActionsCompanion.insert(
            projectId: projectId,
            title: title,
            note: Value(note),
            status: ActionStatus.todo.wire,
            priority: Value(priority.wire),
            dueDate: Value(dueDate),
            sortOrder: Value(next),
            createdAt: now,
            updatedAt: now,
            searchText: Value(buildSearchText([title, note])),
          ),
        );
    return ProjectAction(
      id: id,
      projectId: projectId,
      title: title,
      note: note,
      status: ActionStatus.todo,
      priority: priority,
      sortOrder: next,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
    );
  }

  Future<int> _nextSortOrder(int projectId) async {
    final row = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), -1) AS m FROM actions WHERE project_id = ?',
      variables: [Variable<int>(projectId)],
      readsFrom: {_db.actions},
    ).getSingle();
    return row.read<int>('m') + 1;
  }

  @override
  Future<void> update(ProjectAction action) async {
    await (_db.update(_db.actions)..where((a) => a.id.equals(action.id))).write(
      ActionsCompanion(
        title: Value(action.title),
        note: Value(action.note),
        priority: Value(action.priority.wire),
        dueDate: Value(action.dueDate),
        updatedAt: Value(_now().toUtc()),
        searchText: Value(buildSearchText([action.title, action.note])),
      ),
    );
  }

  /// AD-5 + FR-16: `startedAt` ghi một lần, `completedAt` xoá khi rời `Xong`.
  @override
  Future<void> changeStatus(int actionId, ActionStatus next) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.actions)..where((a) => a.id.equals(actionId)))
          .getSingleOrNull();
      if (row == null) return;
      final current = ActionStatus.fromWire(row.status);
      if (current == next) return;

      final now = _now().toUtc();
      await (_db.update(_db.actions)..where((a) => a.id.equals(actionId))).write(
        ActionsCompanion(
          status: Value(next.wire),
          updatedAt: Value(now),
          startedAt: next == ActionStatus.doing && row.startedAt == null
              ? Value(now)
              : const Value.absent(),
          completedAt: next == ActionStatus.done
              ? Value(now)
              : (current == ActionStatus.done ? const Value(null) : const Value.absent()),
        ),
      );
      // Việc đã xong hoặc đã bỏ thì tự rời danh sách "làm ngay" — để lại đó
      // chỉ làm màn hình Hôm nay dài ra mà không mang thêm thông tin gì.
      if (!next.isOpen && row.pinned) {
        await (_db.update(_db.actions)..where((a) => a.id.equals(actionId)))
            .write(const ActionsCompanion(
                pinned: Value(false), pinnedAt: Value(null)));
      }
      await _db.into(_db.statusEvents).insert(
            StatusEventsCompanion.insert(
              entityType: StatusEntityType.action.wire,
              entityId: actionId,
              fromStatus: current.wire,
              toStatus: next.wire,
              at: now,
            ),
          );
    });
  }

  /// FR-15: chuyển sang Dự án khác — tỷ lệ hoàn thành của cả hai Dự án được
  /// tính lại, vì cả hai đều suy ra từ bảng này (AD-3).
  @override
  Future<void> moveToProject(int actionId, int targetProjectId) async {
    await _db.transaction(() async {
      final next = await _nextSortOrder(targetProjectId);
      await (_db.update(_db.actions)..where((a) => a.id.equals(actionId))).write(
        ActionsCompanion(
          projectId: Value(targetProjectId),
          sortOrder: Value(next),
          updatedAt: Value(_now().toUtc()),
        ),
      );
    });
  }

  @override
  Future<void> reorder(int projectId, List<int> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.actions)
              ..where((a) => a.id.equals(orderedIds[i]) & a.projectId.equals(projectId)))
            .write(ActionsCompanion(sortOrder: Value(i)));
      }
    });
  }

  @override
  Future<void> delete(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.statusEvents)
            ..where((e) =>
                e.entityType.equals(StatusEntityType.action.wire) & e.entityId.equals(id)))
          .go();
      await (_db.delete(_db.actions)..where((a) => a.id.equals(id))).go();
    });
  }

  /// Hoàn tác xoá — ghi lại đúng bản ghi cũ, giữ nguyên id và mốc thời gian.
  @override
  Future<void> restore(ProjectAction action) async {
    await _db.into(_db.actions).insert(
          ActionsCompanion.insert(
            id: Value(action.id),
            projectId: action.projectId,
            title: action.title,
            note: Value(action.note),
            status: action.status.wire,
            priority: Value(action.priority.wire),
            pinned: Value(action.pinned),
            pinnedAt: Value(action.pinnedAt),
            dueDate: Value(action.dueDate),
            sortOrder: Value(action.sortOrder),
            createdAt: action.createdAt,
            updatedAt: action.updatedAt,
            startedAt: Value(action.startedAt),
            completedAt: Value(action.completedAt),
            searchText: Value(buildSearchText([action.title, action.note])),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// FR-42: ghim là hành động **của người dùng**. Không chỗ nào trong ứng dụng
  /// được tự ghim hộ — đó là điều giữ cho màn hình Hôm nay không phình ra.
  @override
  Future<void> setPinned(int actionId, bool pinned) async {
    await (_db.update(_db.actions)..where((a) => a.id.equals(actionId))).write(
      ActionsCompanion(
        pinned: Value(pinned),
        pinnedAt: pinned ? Value(_now().toUtc()) : const Value(null),
        updatedAt: Value(_now().toUtc()),
      ),
    );
  }

  @override
  Stream<List<ProjectAction>> watchPinned() => (_db.select(_db.actions)
        ..where((a) => a.pinned.equals(true))
        ..orderBy([
          (a) => OrderingTerm(expression: a.pinnedAt),
          (a) => OrderingTerm(expression: a.id),
        ]))
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Stream<List<ProjectAction>> watchAllOpen() => (_db.select(_db.actions)
        ..where((a) => a.status.isIn([ActionStatus.todo.wire, ActionStatus.doing.wire])))
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Stream<List<ProjectAction>> watchAll() => _db
      .select(_db.actions)
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());
}
