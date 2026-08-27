import 'package:drift/drift.dart';

import '../../domain/models/action_note.dart';
import '../../domain/repositories/action_note_repository.dart';
import '../db/database.dart';

class ActionNoteRepositoryImpl implements ActionNoteRepository {
  final AppDatabase _db;
  final DateTime Function() _now;

  ActionNoteRepositoryImpl(this._db, {DateTime Function()? now})
      : _now = now ?? _utcNow;

  static DateTime _utcNow() => DateTime.now().toUtc();

  @override
  Future<List<ActionNote>> all() => _ordered().get();

  @override
  Stream<List<ActionNote>> watchAll() => _ordered().watch();

  @override
  Future<ActionNote> add(String body) async {
    final text = body.trim();
    if (text.isEmpty) {
      throw ArgumentError.value(body, 'body', 'ghi chú không được rỗng');
    }
    final id = await _db.into(_db.actionNotesTable).insert(
          ActionNotesTableCompanion.insert(body: text, createdAt: _now()),
        );
    return (await _byId(id))!;
  }

  @override
  Future<ActionNote?> updateBody(int id, String body) async {
    final text = body.trim();
    if (text.isEmpty) {
      throw ArgumentError.value(body, 'body', 'ghi chú không được rỗng');
    }
    final updated = await (_db.update(_db.actionNotesTable)
          ..where((t) => t.id.equals(id)))
        .write(ActionNotesTableCompanion(body: Value(text)));
    return updated == 0 ? null : await _byId(id);
  }

  @override
  Future<ActionNote?> setCompleted(int id, {required bool completed}) async {
    final updated = await (_db.update(_db.actionNotesTable)
          ..where((t) => t.id.equals(id)))
        .write(
      ActionNotesTableCompanion(
        completedAt: Value(completed ? _now() : null),
      ),
    );
    return updated == 0 ? null : await _byId(id);
  }

  @override
  Future<bool> remove(int id) async =>
      await (_db.delete(_db.actionNotesTable)..where((t) => t.id.equals(id)))
              .go() >
          0;

  Future<ActionNote?> _byId(int id) =>
      (_db.select(_db.actionNotesTable)..where((t) => t.id.equals(id)))
          .map(_toDomain)
          .getSingleOrNull();

  /// Mới nhất lên trên. Xem FR-37.
  Selectable<ActionNote> _ordered() => (_db.select(_db.actionNotesTable)
        ..orderBy([
          (t) => OrderingTerm.desc(t.createdAt),
          (t) => OrderingTerm.desc(t.id),
        ]))
      .map(_toDomain);

  static ActionNote _toDomain(ActionNotesTableData row) => ActionNote(
        id: row.id,
        body: row.body,
        createdAt: row.createdAt,
        completedAt: row.completedAt,
      );
}
