import '../domain/candle.dart';

/// Phân loại lỗi khi lấy dữ liệu. Repository dựa vào đây để quyết định có
/// chuyển sang nguồn dự phòng hay không.
enum MarketDataErrorKind {
  /// Không ra được tới máy chủ: mất mạng, DNS hỏng, hết thời gian chờ.
  network,

  /// Máy chủ trả lời nhưng từ chối: mã HTTP khác 200, hoặc thân trả về báo lỗi.
  http,

  /// Máy chủ trả 200 nhưng nội dung không đúng hình dạng đã thoả thuận.
  parse,

  /// Máy chủ trả về hợp lệ nhưng không có nến nào.
  empty,
}

class MarketDataException implements Exception {
  MarketDataException(this.kind, this.message, {this.source});

  final MarketDataErrorKind kind;
  final String message;

  /// Tên nguồn đã ném ra lỗi — để chú thích lỗi hiển thị cho người dùng.
  final String? source;

  @override
  String toString() => 'MarketDataException(${kind.name}, $source: $message)';
}

/// Một dịch vụ HTTP công khai trả về chuỗi Nến tuần cho một Mã.
///
/// Cả ba cài đặt hiện có đều là API **không chính thức** — không nhà cung cấp
/// nào cam kết gì với app này. Interface tồn tại để việc một bên đổi đường dẫn
/// hay chặn truy cập không lan ra ngoài tầng `data/` (AD-6).
abstract class MarketDataSource {
  /// Tên ngắn để ghi nhật ký và hiển thị nguồn đang dùng.
  String get name;

  /// Trả về chuỗi Nến tuần xếp theo thời gian **tăng dần**.
  ///
  /// Ném [MarketDataException] khi hỏng. Không bao giờ trả danh sách rỗng để
  /// biểu đạt lỗi — dùng [MarketDataErrorKind.empty] thay cho việc đó.
  Future<List<Candle>> fetchWeekly();
}
