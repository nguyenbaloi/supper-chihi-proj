import 'package:meta/meta.dart';

import '../../core/money/money.dart';
import '../../core/money/quantity.dart';
import 'enums.dart';

/// Khoản nắm giữ — một tài sản cụ thể bên trong một Lớp tài sản.
///
/// Hai chế độ khai báo loại trừ nhau, xem [InputMode]:
///   * [InputMode.quantity] — có [quantity], Giá trị quy đổi tính bằng số
///     lượng nhân Giá hiệu lực. Giá hiệu lực đến từ Epic 2, nên ở Epic 1
///     những khoản này chưa có giá trị.
///   * [InputMode.value] — có [manualValueAmount], chính là Giá trị quy đổi.
///
/// Cố tình **không có** trường giá trị đã tính sẵn. Xem AD-5.
@immutable
class Holding {
  final int id;
  final int assetClassId;

  /// Ký hiệu đã chuẩn hoá về chữ hoa: BTC, ETH, FPT, HCM.
  /// Duy nhất trong phạm vi một Lớp tài sản.
  final String symbol;

  final String? displayName;

  final InputMode inputMode;

  /// Số lượng kèm độ chính xác. `null` khi [inputMode] là [InputMode.value].
  final Quantity? quantity;

  /// Giá trị nhập thẳng. `null` khi [inputMode] là [InputMode.quantity].
  final Money? manualValueAmount;

  /// Đơn vị tiền của khoản này. Không quy đổi ở bước lưu — quy đổi là việc
  /// của tầng tính toán, và tỷ giá thay đổi theo thời gian. Xem FR-4.
  final Currency currency;

  final String? note;
  final DateTime updatedAt;

  const Holding({
    required this.id,
    required this.assetClassId,
    required this.symbol,
    required this.inputMode,
    required this.currency,
    required this.updatedAt,
    this.displayName,
    this.quantity,
    this.manualValueAmount,
    this.note,
  });

  /// Tên hiển thị nếu có, ngược lại dùng ký hiệu.
  String get label => displayName ?? symbol;

  @override
  bool operator ==(Object other) =>
      other is Holding &&
      other.id == id &&
      other.assetClassId == assetClassId &&
      other.symbol == symbol &&
      other.displayName == displayName &&
      other.inputMode == inputMode &&
      other.quantity == quantity &&
      other.manualValueAmount == manualValueAmount &&
      other.currency == currency &&
      other.note == note &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        assetClassId,
        symbol,
        displayName,
        inputMode,
        quantity,
        manualValueAmount,
        currency,
        note,
        updatedAt,
      );

  @override
  String toString() => 'Holding($id, $symbol, $inputMode)';
}
