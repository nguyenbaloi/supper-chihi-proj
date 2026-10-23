import 'package:drift/drift.dart';

import '../../../domain/models/enums.dart';
import '../converters.dart';

/// Tỷ giá USD sang VND lấy tự động.
///
/// Tỷ giá người dùng nhập tay nằm ở bảng thiết lập chứ không ở đây, vì nó là
/// một lựa chọn của người dùng chứ không phải dữ liệu lấy về. Thứ tự ưu tiên
/// do `EffectiveFxRate` quyết định. Xem FR-11.
class FxRatesTable extends Table {
  @override
  String get tableName => 'fx_rates';

  TextColumn get source => textEnum<PriceSource>()();

  /// Số đồng cho một đô la.
  IntColumn get rateAmount => integer().map(const MoneyConverter())();

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {source};
}
