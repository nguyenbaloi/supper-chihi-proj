import 'package:drift/drift.dart';

import '../converters.dart';
import 'asset_classes_table.dart';
import 'snapshots_table.dart';

/// Giá trị một Lớp tài sản bên trong một Bản chốt.
///
/// Lưu kèm [assetClassName] chứ không chỉ khoá ngoại: đổi tên một Lớp tài sản
/// ở hiện tại không được làm biến dạng cách đọc lịch sử. Đây là thứ Excel gốc
/// không có — nó chỉ ghi mỗi con số tổng.
class SnapshotDetailsTable extends Table {
  @override
  String get tableName => 'snapshot_details';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get snapshotId =>
      integer().references(SnapshotsTable, #id, onDelete: KeyAction.cascade)();

  IntColumn get assetClassId => integer()
      .nullable()
      .references(AssetClassesTable, #id, onDelete: KeyAction.setNull)();

  /// Tên Lớp tài sản tại thời điểm chốt.
  TextColumn get assetClassName => text().withLength(min: 1, max: 60)();

  IntColumn get valueAmount => integer().map(const MoneyConverter())();
}
