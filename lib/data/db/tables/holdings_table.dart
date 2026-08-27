import 'package:drift/drift.dart';

import '../../../domain/models/enums.dart';
import '../converters.dart';
import 'asset_classes_table.dart';

/// Khoản nắm giữ — một tài sản cụ thể bên trong một Lớp tài sản.
///
/// Số lượng lưu bằng số nguyên đã nhân hệ số ([quantityRaw]) kèm số chữ số
/// thập phân ([decimals]). Không có cột kiểu số thực nào. Xem AD-3.
class HoldingsTable extends Table {
  @override
  String get tableName => 'holdings';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get assetClassId =>
      integer().references(AssetClassesTable, #id, onDelete: KeyAction.cascade)();

  /// Ký hiệu: BTC, ETH, FPT, HCM. Duy nhất trong phạm vi một Lớp tài sản.
  TextColumn get symbol => text().withLength(min: 1, max: 20)();

  TextColumn get displayName => text().withLength(max: 100).nullable()();

  TextColumn get inputMode => textEnum<InputMode>()();

  /// Số lượng đã nhân `10^decimals`. Chỉ dùng khi [inputMode] là `quantity`.
  IntColumn get quantityRaw => integer().nullable()();

  /// Số chữ số thập phân của [quantityRaw].
  IntColumn get decimals => integer().withDefault(const Constant(0))();

  /// Giá trị nhập thẳng. Chỉ dùng khi [inputMode] là `value`.
  IntColumn get manualValueAmount =>
      integer().map(const MoneyConverter()).nullable()();

  TextColumn get currency => textEnum<Currency>()();

  TextColumn get note => text().withLength(max: 500).nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {assetClassId, symbol},
      ];
}
