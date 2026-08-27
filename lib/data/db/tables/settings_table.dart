import 'package:drift/drift.dart';

import '../converters.dart';

/// Thiết lập toàn cục. Luôn đúng một dòng, khoá chính cố định bằng 1.
///
/// Không có cột `portfolioId` ở bảng này hay bất kỳ bảng nào khác — ứng dụng
/// chỉ có một Danh mục duy nhất, vĩnh viễn. Xem AD-9.
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  IntColumn get id => integer().withDefault(const Constant(1))();

  /// Tổng số tiền ròng đã bỏ vào Nhóm đầu tư tính đến [startDate].
  ///
  /// Bắt buộc phải có. Đây là điểm neo cho mọi phép tính Lãi lỗ về sau: người
  /// dùng bỏ toàn bộ lịch sử quá khứ và bắt đầu từ hiện tại, nên không có con
  /// số này thì ứng dụng sẽ hiểu là chưa bỏ đồng nào vào và báo lãi bằng đúng
  /// toàn bộ giá trị danh mục. Xem AD-4 và FR-3.
  IntColumn get initialContributionAmount =>
      integer().map(const MoneyConverter())();

  /// Ngày bắt đầu dùng ứng dụng, mốc gắn với [initialContributionAmount].
  DateTimeColumn get startDate => dateTime()();

  /// Tỷ giá USD sang VND do người dùng nhập tay, `null` nếu dùng tỷ giá tự lấy.
  IntColumn get fxRateManualAmount =>
      integer().map(const MoneyConverter()).nullable()();

  /// Ngưỡng cảnh báo lệch so với Tỷ trọng mục tiêu, đơn vị phần vạn.
  /// Mặc định 500 tương đương 5%.
  IntColumn get driftThresholdBp => integer().withDefault(const Constant(500))();

  /// Lần xuất dữ liệu gần nhất, dùng để nhắc sao lưu.
  DateTimeColumn get lastExportedAt => dateTime().nullable()();

  /// Đã hoàn tất luồng khởi tạo lần đầu chưa.
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
