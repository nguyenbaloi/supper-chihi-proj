import 'package:drift/drift.dart';

import '../../../domain/models/enums.dart';
import '../converters.dart';

/// Bản chốt — ảnh chụp bất biến giá trị Danh mục tại một ngày.
///
/// Lưu giá trị **đã tính sẵn**, không lưu tham chiếu tới Khoản nắm giữ. Xoá
/// một Khoản nắm giữ ở hiện tại không làm đổi Bản chốt cũ. Xem AD-12.
///
/// Cố tình **không có cột vốn góp lũy kế và cột lãi lỗ**. Hai con số đó được
/// tính lại từ chuỗi Dòng vốn mỗi lần đọc, vì sửa một Dòng vốn quá khứ chính
/// là sửa lịch sử. Đây là ngoại lệ có chủ đích của tính bất biến, xem AD-12.
class SnapshotsTable extends Table {
  @override
  String get tableName => 'snapshots';

  IntColumn get id => integer().autoIncrement()();

  /// Ngày đã cắt về đầu ngày UTC. Mỗi ngày nhiều nhất một bản chốt tự động.
  DateTimeColumn get date => dateTime()();

  IntColumn get totalAssetsAmount => integer().map(const MoneyConverter())();

  /// Giá trị Nhóm đầu tư tại thời điểm chốt, để tính Lãi lỗ về sau mà không
  /// phải dựng lại từ chi tiết.
  IntColumn get investmentGroupAmount =>
      integer().map(const MoneyConverter())();

  TextColumn get kind => textEnum<SnapshotKind>()();

  TextColumn get note => text().withLength(max: 500).nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date, kind},
      ];
}
