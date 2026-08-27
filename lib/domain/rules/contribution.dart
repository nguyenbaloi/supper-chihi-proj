import '../../core/money/money.dart';
import '../models/cash_flow.dart';

/// Vốn góp lũy kế tại một mốc, kèm Dòng vốn sinh ra mốc đó.
class ContributionPoint {
  final CashFlow cashFlow;

  /// Vốn góp lũy kế **sau khi** tính cả [cashFlow].
  final Money cumulative;

  const ContributionPoint(this.cashFlow, this.cumulative);
}

/// Công thức Vốn góp lũy kế.
///
/// **Không có cột nào trong cơ sở dữ liệu lưu con số này.** Nó luôn được tính
/// bằng tổng chạy trên chuỗi Dòng vốn đã sắp theo ngày:
///
/// ```
/// vốn_góp_lũy_kế(t) = vốn_góp_khởi_điểm + tổng(CashFlow có ngày ≤ t)
/// ```
///
/// Lý do là thứ Excel làm được mà cơ sở dữ liệu thì không, nếu lưu cứng: sửa
/// một Dòng vốn từ nhiều tháng trước phải làm mọi giá trị phía sau tự đúng
/// theo. Kể cả khi người dùng đổi **ngày** của dòng đó. Xem AD-4.
class Contribution {
  const Contribution._();

  /// Vốn góp lũy kế tính đến hết ngày [asOf].
  ///
  /// Dòng vốn có ngày đúng bằng [asOf] **được tính vào** — mốc thời gian ở
  /// đây là "tính đến hết ngày", không phải "trước ngày".
  static Money cumulativeAt({
    required Money initialContribution,
    required Iterable<CashFlow> cashFlows,
    required DateTime asOf,
  }) {
    var total = initialContribution;
    for (final flow in cashFlows) {
      if (!flow.date.isAfter(asOf)) total += flow.amount;
    }
    return total;
  }

  /// Vốn góp lũy kế tại **mọi** mốc trong chuỗi, sắp theo ngày tăng dần.
  ///
  /// Trả về một điểm cho mỗi Dòng vốn. Đây là dữ liệu của màn hình Lãi lỗ chi
  /// tiết, nơi mỗi dòng hiện lũy kế tại chính nó. Xem FR-26.
  static List<ContributionPoint> series({
    required Money initialContribution,
    required Iterable<CashFlow> cashFlows,
  }) {
    final ordered = sortedByDate(cashFlows);
    var running = initialContribution;
    return ordered.map((flow) {
      running += flow.amount;
      return ContributionPoint(flow, running);
    }).toList(growable: false);
  }

  /// Vốn góp lũy kế sau toàn bộ chuỗi.
  static Money total({
    required Money initialContribution,
    required Iterable<CashFlow> cashFlows,
  }) =>
      initialContribution + Money.sum(cashFlows.map((f) => f.amount));

  /// Sắp Dòng vốn theo ngày tăng dần, `id` phá thế hoà.
  ///
  /// Phải có thứ tự xác định: hai Dòng vốn cùng ngày mà xếp khác nhau giữa
  /// hai lần đọc sẽ cho hai chuỗi lũy kế khác nhau trên màn hình.
  static List<CashFlow> sortedByDate(Iterable<CashFlow> cashFlows) {
    final list = cashFlows.toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });
    return list;
  }
}
