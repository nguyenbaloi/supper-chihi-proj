import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/models/cash_flow.dart';
import '../../domain/repositories/cash_flow_repository.dart';
import '../db/database.dart';
import 'date_utils.dart';

class CashFlowRepositoryImpl implements CashFlowRepository {
  final AppDatabase _db;

  CashFlowRepositoryImpl(this._db);

  @override
  Future<List<CashFlow>> all() => _ordered().get();

  @override
  Stream<List<CashFlow>> watchAll() => _ordered().watch();

  @override
  Future<CashFlow?> byId(int id) =>
      (_db.select(_db.cashFlowsTable)..where((t) => t.id.equals(id)))
          .map(_toDomain)
          .getSingleOrNull();

  @override
  Future<CashFlow> add({
    required DateTime date,
    required Money amount,
    String? note,
  }) async {
    final id = await _db.into(_db.cashFlowsTable).insert(
          CashFlowsTableCompanion.insert(
            date: startOfDayUtc(date),
            amount: amount,
            note: Value(trimToNull(note)),
          ),
        );
    return (await byId(id))!;
  }

  @override
  Future<CashFlow?> update(
    int id, {
    DateTime? date,
    Money? amount,
    String? note,
  }) async {
    final updated = await (_db.update(_db.cashFlowsTable)
          ..where((t) => t.id.equals(id)))
        .write(
      CashFlowsTableCompanion(
        date: date == null ? const Value.absent() : Value(startOfDayUtc(date)),
        amount: amount == null ? const Value.absent() : Value(amount),
        note: note == null ? const Value.absent() : Value(trimToNull(note)),
      ),
    );
    return updated == 0 ? null : await byId(id);
  }

  @override
  Future<bool> remove(int id) async =>
      await (_db.delete(_db.cashFlowsTable)..where((t) => t.id.equals(id)))
              .go() >
          0;

  /// Sắp theo ngày tăng dần, `id` phá thế hoà — hai Dòng vốn cùng ngày phải
  /// luôn xếp như nhau, nếu không chuỗi lũy kế trên màn hình sẽ nhảy.
  Selectable<CashFlow> _ordered() => (_db.select(_db.cashFlowsTable)
        ..orderBy([
          (t) => OrderingTerm.asc(t.date),
          (t) => OrderingTerm.asc(t.id),
        ]))
      .map(_toDomain);

  static CashFlow _toDomain(CashFlowsTableData row) => CashFlow(
        id: row.id,
        date: row.date,
        amount: row.amount,
        note: row.note,
      );
}
