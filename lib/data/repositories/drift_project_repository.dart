import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/note.dart' show StatusEvent;
import '../../domain/models/project.dart';
import '../../domain/models/area.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/slugify.dart';
import '../db/database.dart';
import 'mappers.dart';

class DriftProjectRepository implements ProjectRepository {
  DriftProjectRepository(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Một câu lệnh duy nhất trả về Dự án, Lĩnh vực và ba giá trị suy ra.
  ///
  /// Không N+1 (NFR-1): số Hành động và mốc hoạt động gần nhất được tính
  /// bằng truy vấn con tương quan, không bằng một vòng lặp truy vấn.
  static const String _summarySql = '''
SELECT
  p.*,
  t.name              AS t_name,
  t.color_value       AS t_color_value,
  t.icon_key          AS t_icon_key,
  t.sort_order        AS t_sort_order,
  t.is_system_fallback AS t_is_system_fallback,
  t.created_at          AS t_created_at,
  t.standard            AS t_standard,
  t.review_cadence_days AS t_review_cadence_days,
  (SELECT COUNT(*) FROM actions a
     WHERE a.project_id = p.id AND a.status <> 'dropped')     AS counted_total,
  (SELECT COUNT(*) FROM actions a
     WHERE a.project_id = p.id AND a.status = 'done')          AS done_count,
  (SELECT MAX(se.at) FROM status_events se
     JOIN actions a ON a.id = se.entity_id
    WHERE se.entity_type = 'action' AND a.project_id = p.id)   AS last_activity
FROM projects p
JOIN areas t ON t.id = p.area_id
''';

  @override
  Stream<List<ProjectSummary>> watchSummaries(ProjectFilter filter) => _db
      .customSelect(
        _summarySql,
        readsFrom: {_db.projects, _db.areas, _db.actions, _db.statusEvents},
      )
      .watch()
      .map((rows) => _applyFilter(rows.map(_toSummary).toList(), filter));

  ProjectSummary _toSummary(QueryRow row) {
    final lastActivityText = row.data['last_activity'] as String?;
    return ProjectSummary(
      project: Project(
        id: row.read<int>('id'),
        areaId: row.read<int>('area_id'),
        name: row.read<String>('name'),
        description: row.read<String>('description'),
        status: ProjectStatus.fromWire(row.read<String>('status')),
        priority: Priority.fromWire(row.read<String>('priority')),
        dueDate: row.readNullable<DateTime>('due_date'),
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
        startedAt: row.readNullable<DateTime>('started_at'),
        completedAt: row.readNullable<DateTime>('completed_at'),
      ),
      area: Area(
        id: row.read<int>('area_id'),
        name: row.read<String>('t_name'),
        colorValue: row.read<int>('t_color_value'),
        iconKey: row.read<String>('t_icon_key'),
        sortOrder: row.read<int>('t_sort_order'),
        createdAt: row.read<DateTime>('t_created_at'),
        standard: row.read<String>('t_standard'),
        reviewCadenceDays: row.readNullable<int>('t_review_cadence_days'),
        isSystemFallback: row.read<int>('t_is_system_fallback') == 1,
      ),
      doneCount: row.read<int>('done_count'),
      countedTotal: row.read<int>('counted_total'),
      lastActivityAt:
          lastActivityText == null ? null : DateTime.parse(lastActivityText),
    );
  }

  List<ProjectSummary> _applyFilter(List<ProjectSummary> all, ProjectFilter f) {
    final filtered = all.where((s) {
      final status = s.project.status;
      if (!f.includeClosed && !status.isOpen) return false;
      if (f.statuses.isNotEmpty && !f.statuses.contains(status)) return false;
      if (f.areaIds.isNotEmpty && !f.areaIds.contains(s.project.areaId)) {
        return false;
      }
      return true;
    }).toList();

    int byActivity(ProjectSummary a, ProjectSummary b) {
      final av = a.lastActivityAt ?? a.project.createdAt;
      final bv = b.lastActivityAt ?? b.project.createdAt;
      return bv.compareTo(av); // gần nhất lên đầu
    }

    switch (f.sort) {
      case ProjectSort.priority:
        filtered.sort((a, b) {
          final byRank =
              a.project.priority.sortRank.compareTo(b.project.priority.sortRank);
          return byRank != 0 ? byRank : byActivity(a, b);
        });
      case ProjectSort.lastActivity:
        filtered.sort(byActivity);
      case ProjectSort.name:
        filtered.sort((a, b) =>
            slugify(a.project.name).compareTo(slugify(b.project.name)));
      case ProjectSort.dueDate:
        filtered.sort((a, b) {
          final ad = a.project.dueDate;
          final bd = b.project.dueDate;
          if (ad == null && bd == null) return byActivity(a, b);
          if (ad == null) return 1; // không hạn thì xuống cuối
          if (bd == null) return -1;
          return ad.compareTo(bd);
        });
    }
    return filtered;
  }

  @override
  Stream<Project?> watchById(int id) =>
      (_db.select(_db.projects)..where((p) => p.id.equals(id)))
          .watchSingleOrNull()
          .map((r) => r?.toModel());

  @override
  Future<Project?> getById(int id) async {
    final row = await (_db.select(_db.projects)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row?.toModel();
  }

  @override
  Future<Project> create({
    required String name,
    String description = '',
    int? areaId,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) async {
    final now = _now().toUtc();
    final resolvedAreaId = areaId ?? await _fallbackAreaId();
    final id = await _db.into(_db.projects).insert(
          ProjectsCompanion.insert(
            areaId: resolvedAreaId,
            name: name,
            description: Value(description),
            status: ProjectStatus.notStarted.wire,
            priority: priority.wire,
            dueDate: Value(dueDate),
            createdAt: now,
            updatedAt: now,
            searchText: Value(buildSearchText([name, description])),
          ),
        );
    return Project(
      id: id,
      areaId: resolvedAreaId,
      name: name,
      description: description,
      status: ProjectStatus.notStarted,
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<int> _fallbackAreaId() async {
    final row = await (_db.select(_db.areas)
          ..where((t) => t.isSystemFallback.equals(true))
          ..limit(1))
        .getSingleOrNull();
    if (row != null) return row.id;
    final any = await (_db.select(_db.areas)..limit(1)).getSingle();
    return any.id;
  }

  /// AD-5: `updatedAt` do repository ghi. Giao diện không có ô nhập cho nó,
  /// và giá trị truyền vào từ model bị bỏ qua có chủ đích.
  @override
  Future<void> update(Project project) async {
    await (_db.update(_db.projects)..where((p) => p.id.equals(project.id))).write(
      ProjectsCompanion(
        areaId: Value(project.areaId),
        name: Value(project.name),
        description: Value(project.description),
        priority: Value(project.priority.wire),
        dueDate: Value(project.dueDate),
        updatedAt: Value(_now().toUtc()),
        searchText: Value(buildSearchText([project.name, project.description])),
      ),
    );
  }

  /// AD-5: `startedAt` ghi một lần và không bao giờ xoá; `completedAt` xoá khi
  /// rời `Xong`. Mỗi lần đổi sinh một `StatusEvent` (FR-8).
  @override
  Future<void> changeStatus(int projectId, ProjectStatus next) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.projects)
            ..where((p) => p.id.equals(projectId)))
          .getSingleOrNull();
      if (row == null) return;
      final current = ProjectStatus.fromWire(row.status);
      if (current == next) return;

      final now = _now().toUtc();
      await (_db.update(_db.projects)..where((p) => p.id.equals(projectId))).write(
        ProjectsCompanion(
          status: Value(next.wire),
          updatedAt: Value(now),
          startedAt: next == ProjectStatus.active && row.startedAt == null
              ? Value(now)
              : const Value.absent(),
          completedAt: next == ProjectStatus.done
              ? Value(now)
              : (current == ProjectStatus.done ? const Value(null) : const Value.absent()),
        ),
      );
      await _db.into(_db.statusEvents).insert(
            StatusEventsCompanion.insert(
              entityType: StatusEntityType.project.wire,
              entityId: projectId,
              fromStatus: current.wire,
              toStatus: next.wire,
              at: now,
            ),
          );
    });
  }

  /// FR-7: xoá theo tầng Hành động, Ghi chú, Liên kết, mối nối — nhưng
  /// **không** xoá Mục tiêu đã nối.
  @override
  Future<AttachedContentCount> attachedContentCount(int projectId) async {
    final notes = await (_db.selectOnly(_db.notes)
          ..addColumns([_db.notes.id.count()])
          ..where(_db.notes.projectId.equals(projectId)))
        .map((r) => r.read(_db.notes.id.count())!)
        .getSingle();
    final links = await (_db.selectOnly(_db.links)
          ..addColumns([_db.links.id.count()])
          ..where(_db.links.projectId.equals(projectId)))
        .map((r) => r.read(_db.links.id.count())!)
        .getSingle();
    return (notes: notes, links: links);
  }

  @override
  Future<void> delete(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.statusEvents)
            ..where((e) =>
                e.entityType.equals(StatusEntityType.project.wire) &
                e.entityId.equals(id)))
          .go();
      final actionIds = await (_db.selectOnly(_db.actions)
            ..addColumns([_db.actions.id])
            ..where(_db.actions.projectId.equals(id)))
          .map((r) => r.read(_db.actions.id)!)
          .get();
      if (actionIds.isNotEmpty) {
        await (_db.delete(_db.statusEvents)
              ..where((e) =>
                  e.entityType.equals(StatusEntityType.action.wire) &
                  e.entityId.isIn(actionIds)))
            .go();
      }
      // FR-50, AD-18: Ghi chú và Liên kết **không** chết theo Dự án. Chúng
      // chuyển sang Lĩnh vực của Dự án, nơi vẫn tìm lại được.
      //
      // Phải làm ở đây chứ không dựa vào `onDelete: setNull` của khoá ngoại:
      // setNull chỉ thả chúng vào kho chung, mất luôn manh mối chúng từng
      // thuộc mảng nào. setNull là lưới an toàn, không phải hành vi mong muốn.
      final project = await (_db.select(_db.projects)..where((p) => p.id.equals(id)))
          .getSingleOrNull();
      if (project != null) {
        await (_db.update(_db.notes)..where((n) => n.projectId.equals(id)))
            .write(NotesCompanion(
          projectId: const Value(null),
          areaId: Value(project.areaId),
        ));
        await (_db.update(_db.links)..where((l) => l.projectId.equals(id)))
            .write(LinksCompanion(
          projectId: const Value(null),
          areaId: Value(project.areaId),
        ));
      }

      await (_db.delete(_db.projects)..where((p) => p.id.equals(id))).go();
    });
  }

  @override
  Stream<List<StatusEvent>> watchStatusHistory(int projectId) =>
      (_db.select(_db.statusEvents)
            ..where((e) =>
                e.entityType.equals(StatusEntityType.project.wire) &
                e.entityId.equals(projectId))
            // Hai sự kiện có thể trùng mốc thời gian tới từng giây; `id`
            // giảm dần là thứ tự ghi thật, đảm bảo kết quả xác định.
            ..orderBy([
              (e) => OrderingTerm.desc(e.at),
              (e) => OrderingTerm.desc(e.id),
            ]))
          .watch()
          .map((rows) => rows.map((r) => r.toModel()).toList());
}
