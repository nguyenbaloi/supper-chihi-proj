import 'package:decimal/decimal.dart';

import '../../core/money/money.dart';
import '../models/cash_flow.dart';
import 'contribution.dart';

/// Kết quả Lãi lỗ tại một thời điểm.
class ProfitLoss {
  /// Giá trị Nhóm đầu tư tại thời điểm đó.
  final Money investmentGroupValue;

  /// Vốn góp lũy kế tại thời điểm đó.
  final Money cumulativeContribution;

  const ProfitLoss({
    required this.investmentGroupValue,
    required this.cumulativeContribution,
  });

  /// Lãi lỗ tuyệt đối.
  Money get amount => investmentGroupValue - cumulativeContribution;

  bool get isProfit => amount.isPositive;
  bool get isLoss => amount.isNegative;

  /// Tỷ lệ Lãi lỗ so với Vốn góp lũy kế.
  ///
  /// `null` khi Vốn góp lũy kế bằng 0 — chia cho 0 không có nghĩa, và trả về
  /// 0% sẽ nói dối rằng danh mục hoà vốn. Xem FR-25.
  Decimal? get ratio => amount.ratioTo(cumulativeContribution);

  @override
  String toString() => 'ProfitLoss($amount)';
}

/// Công thức Lãi lỗ — trái tim sản phẩm.
///
/// ```
/// lãi_lỗ(t) = giá_trị_nhóm_đầu_tư(t) − vốn_góp_lũy_kế(t)
/// ```
///
/// Trừ đi phần tiền người dùng tự bỏ thêm vào chính là điều Excel gốc làm
/// đúng và là lý do sản phẩm này tồn tại: tài sản tăng không có nghĩa là lãi.
class ProfitLossRule {
  const ProfitLossRule._();

  static ProfitLoss at({
    required Money investmentGroupValue,
    required Money initialContribution,
    required Iterable<CashFlow> cashFlows,
    required DateTime asOf,
  }) =>
      ProfitLoss(
        investmentGroupValue: investmentGroupValue,
        cumulativeContribution: Contribution.cumulativeAt(
          initialContribution: initialContribution,
          cashFlows: cashFlows,
          asOf: asOf,
        ),
      );

  static ProfitLoss current({
    required Money investmentGroupValue,
    required Money initialContribution,
    required Iterable<CashFlow> cashFlows,
  }) =>
      ProfitLoss(
        investmentGroupValue: investmentGroupValue,
        cumulativeContribution: Contribution.total(
          initialContribution: initialContribution,
          cashFlows: cashFlows,
        ),
      );
}
