import '../../core/money/money.dart';
import '../models/enums.dart';
import '../models/price_quote.dart';

/// Bộ nhớ đệm giá. Mọi nguồn giá đều đổ vào đây, và mọi nơi cần giá đều đọc
/// ra từ đây — không tầng nào gọi thẳng nguồn giá để lấy số về dùng ngay.
///
/// Nhờ lớp trung gian này, đổi nhà cung cấp giá về sau không lan tới tầng
/// giao diện. Xem AD-6 và AD-8.
abstract interface class PriceQuoteRepository {
  /// Mọi bản ghi giá của một ký hiệu, cả nhập tay lẫn thị trường.
  Future<List<PriceQuote>> quotesFor(String symbol);

  /// Giá hiệu lực của một ký hiệu, `null` nếu chưa có giá nào.
  Future<PriceQuote?> effectivePriceFor(String symbol);

  /// Giá hiệu lực của nhiều ký hiệu cùng lúc.
  ///
  /// Ký hiệu chưa có giá thì vắng mặt trong kết quả — không có khóa nào ánh
  /// xạ sang 0 đồng.
  Future<Map<String, PriceQuote>> effectivePricesFor(Iterable<String> symbols);

  Stream<List<PriceQuote>> watchAll();

  /// Ghi Giá nhập tay. Ghi đè giá nhập tay cũ của cùng ký hiệu. Xem FR-12.
  Future<PriceQuote> saveManualPrice({
    required String symbol,
    required Money price,
    Currency currency = Currency.vnd,
  });

  /// Xóa Giá nhập tay, quay lại dùng Giá thị trường nếu có. Xem FR-12.
  Future<void> clearManualPrice(String symbol);

  /// Ghi Giá thị trường vừa lấy được, kèm thời điểm lấy.
  Future<void> saveMarketPrices(Iterable<PriceQuote> quotes);
}
