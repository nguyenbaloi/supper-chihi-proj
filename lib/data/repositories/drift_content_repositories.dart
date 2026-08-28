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

  @override
  Stream<List<Note>> watchByProject(int projectId) => (_db.select(_db.notes)
        ..where((n) => n.projectId.equals(projectId))
        ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Future<Note> create({
    required int projectId,
    required String title,
    String bodyMarkdown = '',
  }) async {
    final now = _now().toUtc();
    final id = await _db.into(_db.notes).insert(
          NotesCompanion.insert(
            projectId: projectId,
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
      title: title,
      bodyMarkdown: bodyMarkdown,
      createdAt: now,
      updatedAt: now,
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

  @override
  Stream<List<Link>> watchByProject(int projectId) => (_db.select(_db.links)
        ..where((l) => l.projectId.equals(projectId))
        ..orderBy([
          (l) => OrderingTerm(expression: l.sortOrder),
          (l) => OrderingTerm(expression: l.id),
        ]))
      .watch()
      .map((rows) => rows.map((r) => r.toModel()).toList());

  @override
  Future<Link> create({
    required int projectId,
    required String label,
    required String url,
  }) async {
    final row = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), -1) AS m FROM links WHERE project_id = ?',
      variables: [Variable<int>(projectId)],
      readsFrom: {_db.links},
    ).getSingle();
    final next = row.read<int>('m') + 1;
    final id = await _db.into(_db.links).insert(
          LinksCompanion.insert(
            projectId: projectId,
            label: label,
            url: url,
            sortOrder: Value(next),
            searchText: Value(buildSearchText([label, url])),
          ),
        );
    return Link(id: id, projectId: projectId, label: label, url: url, sortOrder: next);
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
