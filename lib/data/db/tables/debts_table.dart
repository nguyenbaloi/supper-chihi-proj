import 'package:drift/drift.dart';

import '../converters.dart';

/// Khoản nợ — thay thế sheet thứ hai của Excel gốc.
///
/// Giá trị lớp Cho vay bằng tổng ròng các khoản **đang hiệu lực** ở bảng này,
/// không phải một con số nhập tay. Đây chính là phép cộng thủ công
/// `133 + 50 = 183` giữa hai sheet mà ứng dụng sinh ra để triệt tiêu.
/// Xem AD-5 và FR-35.
class DebtsTable extends Table {
  @override
  String get tableName => 'debts';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get personName => text().withLength(min: 1, max: 100)();

  /// Số tiền: dương là mình cho vay, âm là mình đi vay.
  IntColumn get amount => integer().map(const MoneyConverter())();

  DateTimeColumn get date => dateTime()();

  TextColumn get note => text().withLength(max: 500).nullable()();

  /// Ngày tất toán. `null` nghĩa là đang hiệu lực.
  ///
  /// Tất toán không xoá dòng: người dùng vẫn tra cứu lại được, nhưng khoản đó
  /// rời khỏi Tổng tài sản. Xem FR-33.
  DateTimeColumn get settledAt => dateTime().nullable()();
}
