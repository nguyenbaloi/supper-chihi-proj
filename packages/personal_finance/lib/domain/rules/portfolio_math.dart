import 'package:decimal/decimal.dart';

import '../../core/money/money.dart';
import '../models/asset_class.dart';
import '../models/portfolio_valuation.dart';

/// Công thức tổng hợp giá trị Danh mục.
///
/// Toàn bộ giá trị tổng hợp đều **suy ra tại chỗ**, không có cột nào lưu sẵn
/// và không có màn hình nào sửa trực tiếp được. Đây chính là lỗi
/// `133 + 50 = 183` cộng thủ công giữa hai sheet trong Excel gốc — mục đích
/// của ứng dụng là triệt tiêu nó. Xem AD-5.
class PortfolioMath {
  const PortfolioMath._();

  /// Giá trị một Lớp tài sản = tổng Giá trị quy đổi các Khoản nắm giữ thuộc
  /// nó. Dãy rỗng cho 0 đồng.
  ///
  /// Cộng ở đơn vị đồng nguyên: mỗi Khoản nắm giữ đã được làm tròn đúng một
  /// lần khi quy đổi, nên tổng không tích luỹ sai số.
  static Money assetClassValue(Iterable<Money> holdingValues) =>
      Money.sum(holdingValues);

  /// Dựng ảnh chụp giá trị Danh mục từ giá trị từng Lớp tài sản.
  ///
  /// [valueByAssetClassId] thiếu một lớp nào thì lớp đó tính là 0 đồng — một
  /// Lớp tài sản chưa có Khoản nắm giữ nào vẫn là một lớp hợp lệ.
  static PortfolioValuation valuation(
    Iterable<AssetClass> assetClasses,
    Map<int, Money> valueByAssetClassId, {
    Map<int, int> unpricedByAssetClassId = const {},
  }) =>
      PortfolioValuation(
        assetClasses
            .map(
              (c) => AssetClassValuation(
                c,
                valueByAssetClassId[c.id] ?? Money.zero,
                unpricedCount: unpricedByAssetClassId[c.id] ?? 0,
              ),
            )
            .toList(growable: false),
      );

  /// Tổng tài sản — tổng các Lớp tài sản không bị ẩn. Xem FR-8.
  static Money totalAssets(Iterable<AssetClassValuation> valuations) =>
      Money.sum(valuations.where((v) => !v.hidden).map((v) => v.value));

  /// Tỷ trọng thực tế của một giá trị trong tổng.
  ///
  /// `null` khi tổng bằng 0 — chia cho 0 không có nghĩa, và trả về 0 sẽ vẽ ra
  /// một biểu đồ tròn trông như thật.
  static Decimal? weight(Money value, Money total) => value.ratioTo(total);

  /// Khoảng lệch giữa Tỷ trọng thực tế và Tỷ trọng mục tiêu, đơn vị phần vạn.
  ///
  /// `null` khi lớp chưa đặt mục tiêu hoặc chưa tính được tỷ trọng. Xem FR-20.
  static int? driftBp(Decimal? actualWeight, int? targetWeightBp) {
    if (actualWeight == null || targetWeightBp == null) return null;
    final actualBp = (actualWeight * Decimal.fromInt(10000)).round();
    return actualBp.toBigInt().toInt() - targetWeightBp;
  }
}
