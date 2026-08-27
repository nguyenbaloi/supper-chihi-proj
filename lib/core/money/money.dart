import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';

/// Một khoản tiền, lưu bằng **số nguyên đơn vị đồng**.
///
/// Không dùng [double] ở bất kỳ đâu — cộng dồn số thực dấu phẩy động sinh sai
/// số tích luỹ, và với một danh mục hàng trăm triệu thì sai lệch sẽ hiện ra ở
/// đúng chỗ người dùng nhìn nhiều nhất: con số tổng. Xem AD-3.
///
/// Tiền Việt Nam không có phần thập phân trong thực tế sử dụng nên đơn vị nhỏ
/// nhất là một đồng.
@immutable
class Money implements Comparable<Money> {
  /// Số tiền, đơn vị đồng.
  final int amount;

  const Money(this.amount);

  static const Money zero = Money(0);

  /// Dựng từ [Decimal], làm tròn nửa lên về đồng.
  factory Money.fromDecimal(Decimal value) =>
      Money(value.round().toBigInt().toInt());

  Decimal get asDecimal => Decimal.fromInt(amount);

  bool get isZero => amount == 0;
  bool get isNegative => amount < 0;
  bool get isPositive => amount > 0;

  Money operator +(Money other) => Money(amount + other.amount);
  Money operator -(Money other) => Money(amount - other.amount);
  Money operator -() => Money(-amount);

  /// Nhân với một hệ số. Phép nhân chạy ở độ chính xác đầy đủ của [Decimal],
  /// chỉ làm tròn về đồng ở bước cuối.
  Money multiply(Decimal factor) => Money.fromDecimal(asDecimal * factor);

  Money abs() => Money(amount.abs());

  /// Tỷ lệ giữa hai khoản tiền, ví dụ để tính tỷ trọng.
  ///
  /// Trả về `null` khi [other] bằng 0 — người gọi phải xử lý tường minh thay
  /// vì nhận một con số vô nghĩa.
  Decimal? ratioTo(Money other, {int scale = 10}) {
    if (other.isZero) return null;
    return (asDecimal.toRational() / other.asDecimal.toRational())
        .toDecimal(scaleOnInfinitePrecision: scale);
  }

  /// Tổng của một dãy khoản tiền. Trả về [zero] khi dãy rỗng.
  static Money sum(Iterable<Money> values) =>
      values.fold(Money.zero, (a, b) => a + b);

  @override
  int compareTo(Money other) => amount.compareTo(other.amount);

  bool operator <(Money other) => amount < other.amount;
  bool operator <=(Money other) => amount <= other.amount;
  bool operator >(Money other) => amount > other.amount;
  bool operator >=(Money other) => amount >= other.amount;

  @override
  bool operator ==(Object other) => other is Money && other.amount == amount;

  @override
  int get hashCode => amount.hashCode;

  /// Chỉ dùng cho gỡ lỗi và thông báo lỗi. Hiển thị cho người dùng phải đi qua
  /// lớp định dạng, xem FR-40.
  @override
  String toString() => 'Money($amount)';
}
