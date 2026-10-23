import '../../core/result/result.dart';
import '../../domain/models/price_quote.dart';

/// Hợp đồng của một nguồn giá bên ngoài.
///
/// **Mọi lời gọi mạng của ứng dụng nằm trong thư mục này và chỉ ở đây.** Có
/// một bài test kiểm tra ràng buộc đó trên toàn bộ mã nguồn. Xem AD-8.
///
/// Nội dung gửi đi chỉ gồm ký hiệu tài sản và mã tiền tệ. Cấm gửi Số lượng,
/// Giá trị quy đổi, hay bất kỳ định danh người dùng nào — không có backend,
/// không tài khoản, không đồng bộ.
abstract interface class RemotePriceSource {
  /// Tên nguồn, dùng cho log và cho màn hình cài đặt.
  String get name;

  /// Hỏi giá của [symbols].
  ///
  /// Trả về [Result] chứ không ném ngoại lệ: lấy giá thất bại là chuyện bình
  /// thường, không phải sự cố, và tuyệt đối không được chặn thao tác của
  /// người dùng. Bên gọi xử lý thất bại bằng cách dùng giá lưu gần nhất kèm
  /// nhãn thời gian. Xem AD-11.
  Future<Result<List<PriceQuote>>> fetchPrices(Iterable<String> symbols);
}
