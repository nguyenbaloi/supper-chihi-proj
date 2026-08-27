import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/models/debt.dart';
import '../../domain/repositories/debt_repository.dart';
import '../db/database.dart';
import 'date_utils.dart';

class DebtRepositoryImpl implements DebtRepository {
  final AppDatabase _db;

  DebtRepositoryImpl(this._db);

  @override
  Future<List<Debt>> all() => _ordered().get();

  @override
  Future<List<Debt>> active() =>
      _ordered(settled: false).get();

  @override
  Future<List<Debt>> settled() => _ordered(settled: true).get();

  @override
  Stream<List<Debt>> watchAll() => _ordered().watch();

  @override
  Future<Debt?> byId(int id) =>
      (_db.select(_db.debtsTable)..where((t) => t.id.equals(id)))
          .map(_toDomain)
          .getSingleOrNull();

  @override
  Future<Debt> add({
    required String personName,
    required Money amount,
    required DateTime date,
    String? note,
  }) async {
    final name = personName.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(personName, 'personName', 'tên không được rỗng');
    }
    final id = await _db.into(_db.debtsTable).insert(
          DebtsTableCompanion.insert(
            personName: name,
            amount: amount,
            date: startOfDayUtc(date),
            note: Value(trimToNull(note)),
          ),
        );
    return (await byId(id))!;
  }

  @override
  Future<Debt?> update(
    int id, {
    String? personName,
    Money? amount,
    DateTime? date,
    String? note,
  }) async {
    final updated = await (_db.update(_db.debtsTable)
          ..where((t) => t.id.equals(id)))
        .write(
      DebtsTableCompanion(
        personName: personName == null
            ? const Value.absent()
            : Value(personName.trim()),
        amount: amount == null ? const Value.absent() : Value(amount),
        date: date == null ? const Value.absent() : Value(startOfDayUtc(date)),
        note: note == null ? const Value.absent() : Value(trimToNull(note)),
      ),
    );
    return updated == 0 ? null : await byId(id);
  }

  @override
  Future<Debt?> settle(int id, DateTime settledAt) =>
      _writeSettledAt(id, Value(startOfDayUtc(settledAt)));

  @override
  Future<Debt?> unsettle(int id) =>
      _writeSettledAt(id, const Value(null));

  @override
  Future<bool> remove(int id) async =>
      await (_db.delete(_db.debtsTable)..where((t) => t.id.equals(id))).go() >
          0;

  Future<Debt?> _writeSettledAt(int id, Value<DateTime?> settledAt) async {
    final updated = await (_db.update(_db.debtsTable)
          ..where((t) => t.id.equals(id)))
        .write(DebtsTableCompanion(settledAt: settledAt));
    return updated == 0 ? null : await byId(id);
  }

  Selectable<Debt> _ordered({bool? settled}) {
    final query = _db.select(_db.debtsTable)
      ..orderBy([
        (t) => OrderingTerm.desc(t.date),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (settled == true) query.where((t) => t.settledAt.isNotNull());
    if (settled == false) query.where((t) => t.settledAt.isNull());
    return query.map(_toDomain);
  }

  static Debt _toDomain(DebtsTableData row) => Debt(
        id: row.id,
        personName: row.personName,
        amount: row.amount,
        date: row.date,
        note: row.note,
        settledAt: row.settledAt,
      );
}
