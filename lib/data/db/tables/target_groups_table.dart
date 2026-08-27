import 'package:drift/drift.dart';

/// Nhóm mục tiêu — gộp nhiều Lớp tài sản để đặt chung một Tỷ trọng mục tiêu.
///
/// Có nhóm vì người dùng nghĩ theo cụm: *"Vàng và Chứng khoán chung 20%"*.
/// Không có nhóm thì phải chia đôi con số bằng tay, và chia sai lúc nào không
/// biết. Xem FR-19.
class TargetGroupsTable extends Table {
  @override
  String get tableName => 'target_groups';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Tỷ trọng mục tiêu của cả nhóm, đơn vị phần vạn.
  IntColumn get targetWeightBp => integer()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
