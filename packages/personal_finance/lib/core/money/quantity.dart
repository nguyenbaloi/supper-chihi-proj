import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';

import 'money.dart';

/// Số lượng một tài sản đang nắm giữ.
///
/// Khác với [Money] ở chỗ số lượng cần độ chính xác thập phân thay đổi theo
/// loại tài sản: BTC cần 8 chữ số (1 satoshi), vàng 2 chữ số (đơn vị chỉ), cổ
/// phiếu là số nguyên.
///
/// Lưu bằng số nguyên đã nhân hệ số ([raw]) kèm số chữ số thập phân
/// ([decimals]), không dùng [double]. Xem AD-3.
///
/// Ví dụ: `0,12345678 BTC` được lưu thành `raw = 12345678, decimals = 8`.
@immutable
class Quantity implements Comparable<Quantity> {
  /// Giá trị đã nhân với `10^decimals`.
  final int raw;

  /// Số chữ số thập phân của loại tài sản này.
  final int decimals;

  const Quantity(this.raw, this.decimals)
      : assert(decimals >= 0, 'decimals không được âm');

  const Quantity.zero(this.decimals) : raw = 0;

  /// Dựng từ chuỗi người dùng nhập, ví dụ `'0.12345678'`.
  ///
  /// Ném [FormatException] khi chuỗi sai định dạng, hoặc khi phần thập phân
  /// vượt quá [decimals] — im lặng cắt bớt chữ số của người dùng là hành vi
  /// tệ hơn nhiều so với báo lỗi.
  factory Quantity.parse(String source, int decimals) {
    final value = Decimal.parse(source.trim());
    return Quantity.fromDecimal(value, decimals);
  }

  /// Dựng từ [Decimal].
  ///
  /// Ném [ArgumentError] khi [value] có nhiều chữ số thập phân hơn [decimals]
  /// cho phép, vì làm tròn ở đây sẽ âm thầm thay đổi số lượng người dùng nhập.
  factory Quantity.fromDecimal(Decimal value, int decimals) {
    final scaled = value.shift(decimals);
    if (scaled != scaled.truncate()) {
      throw ArgumentError.value(
        value.toString(),
        'value',
        'vượt quá $decimals chữ số thập phân cho phép',
      );
    }
    return Quantity(scaled.toBigInt().toInt(), decimals);
  }

  Decimal get asDecimal => Decimal.fromInt(raw).shift(-decimals);

  bool get isZero => raw == 0;

  Quantity operator +(Quantity other) {
    _assertSameScale(other);
    return Quantity(raw + other.raw, decimals);
  }

  Quantity operator -(Quantity other) {
    _assertSameScale(other);
    return Quantity(raw - other.raw, decimals);
  }

  /// Giá trị quy đổi của khoản nắm giữ: số lượng nhân đơn giá.
  ///
  /// Phép nhân chạy ở độ chính xác đầy đủ, chỉ làm tròn về đồng một lần duy
  /// nhất ở bước cuối. Làm tròn sớm ở từng khoản rồi mới cộng lại sẽ cho tổng
  /// lệch so với Excel gốc.
  Money valueAt(Money pricePerUnit) =>
      Money.fromDecimal(asDecimal * pricePerUnit.asDecimal);

  void _assertSameScale(Quantity other) {
    if (other.decimals != decimals) {
      throw ArgumentError(
        'không cộng trừ được hai số lượng khác độ chính xác '
        '($decimals và ${other.decimals})',
      );
    }
  }

  @override
  int compareTo(Quantity other) {
    _assertSameScale(other);
    return raw.compareTo(other.raw);
  }

  @override
  bool operator ==(Object other) =>
      other is Quantity && other.raw == raw && other.decimals == decimals;

  @override
  int get hashCode => Object.hash(raw, decimals);

  /// Biểu diễn không mất chính xác, dùng để lưu và gỡ lỗi.
  ///
  /// Bỏ các chữ số 0 thừa ở cuối, ví dụ `0,12000000` hiện thành `0.12`.
  /// Hiển thị cho người dùng phải đi qua lớp định dạng, xem FR-40.
  String toPlainString() {
    if (decimals == 0) return raw.toString();
    final text = asDecimal.toStringAsFixed(decimals);
    final trimmed = text.replaceFirst(RegExp(r'\.?0+$'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  @override
  String toString() => 'Quantity(${toPlainString()}, decimals: $decimals)';
}
