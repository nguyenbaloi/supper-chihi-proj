import 'package:drift/drift.dart';

/// Ghi chú kế hoạch — việc cần làm, đặt ngay cạnh con số sinh ra nó.
///
/// Thay thế những dòng định tính ở cuối sheet Excel: *"mua thêm vàng và chứng
/// khoán"*. Xem FR-36.
class ActionNotesTable extends Table {
  @override
  String get tableName => 'action_notes';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get body => text().withLength(min: 1, max: 1000)();

  DateTimeColumn get createdAt => dateTime()();

  /// `null` nghĩa là chưa hoàn thành.
  DateTimeColumn get completedAt => dateTime().nullable()();
}
