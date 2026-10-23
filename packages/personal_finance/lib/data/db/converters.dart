import 'package:drift/drift.dart';

import '../../core/money/money.dart';

/// Lưu [Money] xuống cột số nguyên đơn vị đồng.
///
/// Ràng buộc AD-3 được thực thi ngay tại ranh giới cơ sở dữ liệu: không có
/// đường nào để một giá trị tiền tệ lọt vào cột kiểu số thực.
class MoneyConverter extends TypeConverter<Money, int>
    with JsonTypeConverter<Money, int> {
  const MoneyConverter();

  @override
  Money fromSql(int fromDb) => Money(fromDb);

  @override
  int toSql(Money value) => value.amount;
}
