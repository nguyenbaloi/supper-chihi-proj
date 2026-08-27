import 'package:drift/drift.dart';

import '../../../domain/models/enums.dart';
import '../converters.dart';

/// Giá một đơn vị tài sản, lưu tách theo nguồn.
///
/// Khóa chính là cặp **(ký hiệu, nguồn)** chứ không phải riêng ký hiệu: một
/// ký hiệu giữ được đồng thời một Giá nhập tay và một Giá thị trường. Nếu chỉ
/// khóa theo ký hiệu thì nhập tay sẽ đè mất giá thị trường đã lưu, và lúc
/// người dùng xóa Giá nhập tay sẽ không còn gì để quay về — trái với FR-12.
///
/// Thứ tự ưu tiên khi chọn Giá hiệu lực do đúng một hàm trong `domain` quyết
/// định, xem AD-6.
class PriceQuotesTable extends Table {
  @override
  String get tableName => 'price_quotes';

  TextColumn get symbol => text().withLength(min: 1, max: 20)();

  TextColumn get source => textEnum<PriceSource>()();

  /// Giá một đơn vị, tính theo đơn vị nhỏ nhất của [currency]: đồng với VND,
  /// xu với USD. Xem `CurrencyX.decimals`.
  IntColumn get priceAmount => integer().map(const MoneyConverter())();

  TextColumn get currency => textEnum<Currency>()();

  /// Thời điểm lấy được giá này. Bắt buộc — không có trạng thái nào mà ứng
  /// dụng hiện số liệu tài chính mà không cho biết nó tính từ giá lúc nào.
  /// Xem FR-13.
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {symbol, source};
}
