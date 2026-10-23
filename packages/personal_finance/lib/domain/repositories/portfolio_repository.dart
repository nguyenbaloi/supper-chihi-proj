import '../models/portfolio_valuation.dart';
import '../models/valued_holding.dart';

/// Đọc giá trị Danh mục đã tính xong.
///
/// **Không có bảng nào lưu các con số này.** Mỗi lần đọc là một lần tính lại
/// từ Khoản nắm giữ, Giá hiệu lực và Tỷ giá hiện hành. Đây là ràng buộc triệt
/// tiêu lỗi cộng thủ công giữa hai sheet trong Excel gốc. Xem AD-5.
abstract interface class PortfolioRepository {
  /// Giá trị từng Lớp tài sản và Tổng tài sản ở thời điểm hiện tại.
  Future<PortfolioValuation> valuation();

  /// Theo dõi để màn hình tự vẽ lại khi Khoản nắm giữ, giá hay tỷ giá đổi.
  Stream<PortfolioValuation> watchValuation();

  /// Các Khoản nắm giữ của một Lớp tài sản, kèm giá và giá trị. Xem FR-7.
  Future<List<ValuedHolding>> valuedHoldings(int assetClassId);
}
