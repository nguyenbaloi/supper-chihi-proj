import 'package:drift/drift.dart';

import '../../../domain/models/enums.dart';

/// Lớp tài sản — nhóm phân loại cấp một của Danh mục.
///
/// Cố tình **không có** cột lưu tổng giá trị. Giá trị một Lớp tài sản luôn
/// được suy ra từ các Khoản nắm giữ thuộc nó, riêng lớp `lending` suy ra từ
/// tổng ròng Sổ nợ. Đây là ràng buộc triệt tiêu lỗi cộng thủ công giữa hai
/// sheet trong Excel gốc. Xem AD-5 và FR-8.
class AssetClassesTable extends Table {
  @override
  String get tableName => 'asset_classes';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 60)();

  TextColumn get kind => textEnum<AssetKind>()();

  /// Tỷ trọng mục tiêu, đơn vị phần vạn — 5000 tương đương 50%.
  ///
  /// Dùng phần vạn thay vì số thực để giữ nguyên tắc cấm dấu phẩy động,
  /// và đủ mịn cho mọi mục tiêu người dùng đặt ra.
  IntColumn get targetWeightBp => integer().nullable()();

  /// Lớp này có tham gia tính Lãi lỗ không.
  ///
  /// Mặc định chỉ Chứng khoán và Crypto — đây là hai lớp người dùng coi là
  /// tài sản đầu tư thật sự. Xem FR-25 và FR-27.
  BoolColumn get inInvestmentGroup =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get hidden => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Màu hiển thị trên biểu đồ tròn, dạng ARGB.
  IntColumn get colorValue => integer()();

  /// Điểm mã của biểu tượng trong bộ Material Icons.
  IntColumn get iconCodePoint => integer()();
}
