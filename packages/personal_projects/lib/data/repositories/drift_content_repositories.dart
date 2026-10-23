import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/note.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/slugify.dart';
import '../../domain/rules/stale.dart';
import '../db/database.dart';
import 'mappers.dart';

class DriftNoteRepository implements NoteRepository {
  DriftNoteRepository(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Stream<List<Note>> _watch(Expression<bool> Function($NotesTable n) filter) =>
      (_db.select(_db.notes)
            ..where(filter)
            ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
          .watch()
          .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Stream<List<Note>> watchByProject(int projectId) =>
      _watch((n) => n.projectId.equals(projectId));

  @override
  Stream<List<Note>> watchByArea(int areaId) =>
      _watch((n) => n.areaId.equals(areaId));

  @override
  Stream<List<Note>> watchUnattached() =>
      _watch((n) => n.projectId.isNull() & n.areaId.isNull());

  @override
  Stream<List<Note>> watchAll() => _watch((n) => const Constant(true));

  @override
  Future<Note> create({
    int? projectId,
    int? areaId,
    required String title,
    String bodyMarkdown = '',
  }) async {
    assert(projectId == null || areaId == null, 'AD-18');
    final now = _now().toUtc();
    final id = await _db.into(_db.notes).insert(
          NotesCompanion.insert(
            projectId: Value(projectId),
            areaId: Value(areaId),
            title: title,
            bodyMarkdown: Value(bodyMarkdown),
            createdAt: now,
            updatedAt: now,
            searchText: Value(buildSearchText([title, bodyMarkdown])),
          ),
        );
    return Note(
      id: id,
      projectId: projectId,
      areaId: areaId,
      title: title,
      bodyMarkdown: bodyMarkdown,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> move(int id, {int? projectId, int? areaId}) async {
    assert(projectId == null || areaId == null, 'AD-18');
    final row =
        await (_db.select(_db.notes)..where((n) => n.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        projectId: Value(projectId),
        areaId: Value(areaId),
        updatedAt: Value(_now().toUtc()),
        // Dẫn xuất, phải sinh lại sau mỗi lần đụng vào bản ghi — AD-12.
        searchText: Value(buildSearchText([row.title, row.bodyMarkdown])),
      ),
    );
  }

  @override
  Future<void> update(Note note) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(note.id))).write(
      NotesCompanion(
        title: Value(note.title),
        bodyMarkdown: Value(note.bodyMarkdown),
        updatedAt: Value(_now().toUtc()),
        searchText: Value(buildSearchText([note.title, note.bodyMarkdown])),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
  }
}

class DriftLinkRepository implements LinkRepository {
  DriftLinkRepository(this._db);

  final AppDatabase _db;

  Stream<List<Link>> _watch(Expression<bool> Function($LinksTable l) filter) =>
      (_db.select(_db.links)
            ..where(filter)
            ..orderBy([
              (l) => OrderingTerm(expression: l.sortOrder),
              (l) => OrderingTerm(expression: l.id),
            ]))
          .watch()
          .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Stream<List<Link>> watchByProject(int projectId) =>
      _watch((l) => l.projectId.equals(projectId));

  @override
  Stream<List<Link>> watchByArea(int areaId) =>
      _watch((l) => l.areaId.equals(areaId));

  @override
  Stream<List<Link>> watchUnattached() =>
      _watch((l) => l.projectId.isNull() & l.areaId.isNull());

  @override
  Stream<List<Link>> watchAll() => _watch((l) => const Constant(true));

  /// Thứ tự kéo thả là **cục bộ theo chỗ gắn**, nên số kế tiếp phải đếm trong
  /// đúng nhóm đó — kho chung tính là một nhóm riêng.
  Future<int> _nextSortOrder(int? projectId, int? areaId) async {
    final where = projectId != null
        ? 'project_id = ?'
        : areaId != null
            ? 'area_id = ?'
            : 'project_id IS NULL AND area_id IS NULL';
    final row = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), -1) AS m FROM links WHERE $where',
      variables: [
        if (projectId != null) Variable<int>(projectId),
        if (projectId == null && areaId != null) Variable<int>(areaId),
      ],
      readsFrom: {_db.links},
    ).getSingle();
    return row.read<int>('m') + 1;
  }

  @override
  Future<Link> create({
    int? projectId,
    int? areaId,
    required String label,
    required String url,
  }) async {
    assert(projectId == null || areaId == null, 'AD-18');
    final next = await _nextSortOrder(projectId, areaId);
    final id = await _db.into(_db.links).insert(
          LinksCompanion.insert(
            projectId: Value(projectId),
            areaId: Value(areaId),
            label: label,
            url: url,
            sortOrder: Value(next),
            searchText: Value(buildSearchText([label, url])),
          ),
        );
    return Link(
      id: id,
      projectId: projectId,
      areaId: areaId,
      label: label,
      url: url,
      sortOrder: next,
    );
  }

  @override
  Future<void> move(int id, {int? projectId, int? areaId}) async {
    assert(projectId == null || areaId == null, 'AD-18');
    await _db.transaction(() async {
      final row = await (_db.select(_db.links)..where((l) => l.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      await (_db.update(_db.links)..where((l) => l.id.equals(id))).write(
        LinksCompanion(
          projectId: Value(projectId),
          areaId: Value(areaId),
          // Xếp cuối nhóm mới; giữ số cũ sẽ đụng thứ tự của nhóm đích.
          sortOrder: Value(await _nextSortOrder(projectId, areaId)),
          searchText: Value(buildSearchText([row.label, row.url])),
        ),
      );
    });
  }

  @override
  Future<void> update(Link link) async {
    await (_db.update(_db.links)..where((l) => l.id.equals(link.id))).write(
      LinksCompanion(
        label: Value(link.label),
        url: Value(link.url),
        sortOrder: Value(link.sortOrder),
        searchText: Value(buildSearchText([link.label, link.url])),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.links)..where((l) => l.id.equals(id))).go();
  }
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  static const AppSettingsData _defaults = AppSettingsData(
    staleDays: defaultStaleDays,
    themeMode: AppThemeMode.system,
    seedApplied: false,
  );

  @override
  Stream<AppSettingsData> watch() =>
      (_db.select(_db.appSettings)..where((s) => s.id.equals(1)))
          .watchSingleOrNull()
          .map(_toData);

  @override
  Future<AppSettingsData> get() async {
    final row = await (_db.select(_db.appSettings)..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    return _toData(row);
  }

  AppSettingsData _toData(SettingsRow? row) => row == null
      ? _defaults
      : AppSettingsData(
          staleDays:
              isValidStaleDays(row.staleDays) ? row.staleDays : defaultStaleDays,
          themeMode: AppThemeMode.fromWire(row.themeMode),
          seedApplied: row.seedApplied,
        );

  @override
  Future<void> save(AppSettingsData settings) async {
    await _db.into(_db.appSettings).insert(
          AppSettingsCompanion.insert(
            id: const Value(1),
            staleDays: Value(
              isValidStaleDays(settings.staleDays)
                  ? settings.staleDays
                  : defaultStaleDays,
            ),
            themeMode: Value(settings.themeMode.wire),
            seedApplied: Value(settings.seedApplied),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}
