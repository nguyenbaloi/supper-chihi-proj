import 'package:drift/drift.dart';

import '../converters.dart';

/// Dòng vốn — một lần người dùng nạp thêm tiền vào hoặc rút tiền ra khỏi
/// Nhóm đầu tư. Số dương là nạp, số âm là rút.
///
/// Cố tình **không có cột chia theo Lớp tài sản**: người dùng nghĩ về việc bỏ
/// tiền vào đầu tư như một hành động duy nhất, không phân biệt bỏ vào lớp
/// nào. Xem FR-22.
///
/// Cũng **không có cột vốn góp lũy kế**. Lũy kế luôn tính bằng tổng chạy trên
/// chuỗi này, để sửa một dòng cũ là mọi giá trị phía sau tự đúng theo. Xem
/// AD-4.
class CashFlowsTable extends Table {
  @override
  String get tableName => 'cash_flows';

  IntColumn get id => integer().autoIncrement()();

  /// Ngày đã cắt về đầu ngày UTC, để so sánh không bị lệch bởi giờ phút.
  DateTimeColumn get date => dateTime()();

  /// Số tiền: dương là nạp vào, âm là rút ra.
  IntColumn get amount => integer().map(const MoneyConverter())();

  TextColumn get note => text().withLength(max: 500).nullable()();
}
