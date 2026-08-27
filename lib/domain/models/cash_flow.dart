import 'package:meta/meta.dart';

import '../../core/money/money.dart';

/// Dòng vốn — một lần nạp thêm tiền vào hoặc rút tiền ra khỏi Nhóm đầu tư.
///
/// Không thuộc Lớp tài sản nào: người dùng nghĩ về việc bỏ tiền vào đầu tư
/// như một hành động duy nhất. Xem FR-22.
@immutable
class CashFlow {
  final int id;

  /// Ngày đã cắt về đầu ngày UTC.
  final DateTime date;

  /// Dương là nạp vào, âm là rút ra.
  final Money amount;

  final String? note;

  const CashFlow({
    required this.id,
    required this.date,
    required this.amount,
    this.note,
  });

  bool get isDeposit => amount.isPositive;
  bool get isWithdrawal => amount.isNegative;

  @override
  bool operator ==(Object other) =>
      other is CashFlow &&
      other.id == id &&
      other.date == date &&
      other.amount == amount &&
      other.note == note;

  @override
  int get hashCode => Object.hash(id, date, amount, note);

  @override
  String toString() => 'CashFlow($id, $date, $amount)';
}
