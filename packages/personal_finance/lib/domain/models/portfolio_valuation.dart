import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';

import '../../core/money/money.dart';
import 'asset_class.dart';

/// Giá trị quy đổi của một Lớp tài sản tại một thời điểm.
///
/// Là kết quả tính, không phải dữ liệu lưu trữ — không có bảng nào chứa con
/// số này. Xem AD-5.
@immutable
class AssetClassValuation {
  final AssetClass assetClass;

  /// Tổng giá trị các Khoản nắm giữ **đã tính được** trong lớp.
  final Money value;

  /// Số Khoản nắm giữ chưa tính được giá trị vì chưa có Giá hiệu lực.
  ///
  /// Khác 0 nghĩa là [value] chưa đầy đủ, và giao diện phải nói rõ điều đó
  /// thay vì hiện một con số trông như đã trọn vẹn. Xem FR-14.
  final int unpricedCount;

  const AssetClassValuation(
    this.assetClass,
    this.value, {
    this.unpricedCount = 0,
  });

  bool get hidden => assetClass.hidden;

  /// Giá trị của lớp này đã đầy đủ chưa.
  bool get isComplete => unpricedCount == 0;

  @override
  bool operator ==(Object other) =>
      other is AssetClassValuation &&
      other.assetClass == assetClass &&
      other.value == value &&
      other.unpricedCount == unpricedCount;

  @override
  int get hashCode => Object.hash(assetClass, value, unpricedCount);

  @override
  String toString() => 'AssetClassValuation(${assetClass.name}, $value)';
}

/// Ảnh chụp giá trị toàn Danh mục, dựng từ các Lớp tài sản đã tính xong.
///
/// Giữ cả Lớp tài sản bị ẩn để màn hình cài đặt vẫn xem được, nhưng mọi con
/// số tổng hợp đều chỉ tính trên phần không bị ẩn.
@immutable
class PortfolioValuation {
  /// Mọi Lớp tài sản, kể cả lớp bị ẩn.
  final List<AssetClassValuation> entries;

  const PortfolioValuation(this.entries);

  static const PortfolioValuation empty = PortfolioValuation([]);

  /// Các Lớp tài sản tham gia biểu đồ tròn và Tổng tài sản.
  List<AssetClassValuation> get visible =>
      entries.where((e) => !e.hidden).toList(growable: false);

  /// Tổng tài sản — tổng các Lớp tài sản không bị ẩn. Xem FR-8.
  Money get totalAssets => Money.sum(visible.map((e) => e.value));

  /// Danh sách hiển thị, sắp theo giá trị giảm dần. Xem FR-17.
  List<AssetClassValuation> get byValueDescending {
    final sorted = visible.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return List.unmodifiable(sorted);
  }

  /// Tỷ trọng thực tế của một Lớp tài sản.
  ///
  /// `null` khi Tổng tài sản bằng 0 hoặc lớp không nằm trong phần hiển thị —
  /// người gọi phải xử lý tường minh thay vì nhận một con số vô nghĩa.
  Decimal? weightOf(int assetClassId) {
    final total = totalAssets;
    if (total.isZero) return null;
    for (final entry in visible) {
      if (entry.assetClass.id == assetClassId) {
        return entry.value.ratioTo(total);
      }
    }
    return null;
  }

  /// Có Lớp tài sản nào đang thiếu giá không.
  bool get hasUnpricedHoldings => visible.any((e) => !e.isComplete);

  /// Tổng số Khoản nắm giữ chưa có giá trên toàn Danh mục.
  int get unpricedCount =>
      visible.fold(0, (sum, e) => sum + e.unpricedCount);

  /// Giá trị Nhóm đầu tư — tổng các Lớp tài sản có `inInvestmentGroup`.
  ///
  /// Đây là vế trái của công thức Lãi lỗ ở FR-25. Lớp bị ẩn không tính.
  Money get investmentGroupValue => Money.sum(
        visible
            .where((e) => e.assetClass.inInvestmentGroup)
            .map((e) => e.value),
      );
}
