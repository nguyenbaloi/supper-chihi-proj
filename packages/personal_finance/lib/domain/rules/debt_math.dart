import '../../core/money/money.dart';
import '../models/debt.dart';

/// Tổng hợp Sổ nợ.
class DebtTotals {
  /// Tổng các khoản mình cho vay.
  final Money lent;

  /// Tổng các khoản mình đi vay, luôn là số dương.
  final Money borrowed;

  const DebtTotals({required this.lent, required this.borrowed});

  /// Tổng ròng — chính là Giá trị của Lớp tài sản `lending`.
  Money get net => lent - borrowed;

  @override
  String toString() => 'DebtTotals(lent: $lent, borrowed: $borrowed)';
}

/// Công thức Sổ nợ.
///
/// Giá trị lớp Cho vay = tổng ròng các Khoản nợ **đang hiệu lực**. Không có
/// đường nào nhập tay con số này. Đây chính là phép cộng thủ công
/// `133 + 50 = 183` giữa hai sheet trong Excel gốc. Xem AD-5 và FR-35.
class DebtMath {
  const DebtMath._();

  /// Chỉ tính khoản đang hiệu lực — khoản đã tất toán rời khỏi tài sản hiện
  /// tại nhưng vẫn tra cứu lại được. Xem FR-33.
  static DebtTotals totals(Iterable<Debt> debts) {
    var lent = Money.zero;
    var borrowed = Money.zero;
    for (final debt in debts) {
      if (debt.isSettled) continue;
      if (debt.amount.isNegative) {
        borrowed += debt.amount.abs();
      } else {
        lent += debt.amount;
      }
    }
    return DebtTotals(lent: lent, borrowed: borrowed);
  }

  /// Giá trị Lớp tài sản `lending`.
  static Money lendingClassValue(Iterable<Debt> debts) => totals(debts).net;
}
