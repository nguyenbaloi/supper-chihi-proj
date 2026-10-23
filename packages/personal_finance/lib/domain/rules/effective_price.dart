import '../models/enums.dart';
import '../models/price_quote.dart';

/// Quyết định Giá hiệu lực của một tài sản.
///
/// **Đây là nơi duy nhất trong toàn bộ mã nguồn được phép quyết định điều
/// này.** Hai chỗ tự chọn giá là hai màn hình hiện hai con số khác nhau cho
/// cùng một tài sản, và người dùng không có cách nào biết chỗ nào đúng.
/// Xem AD-6.
class EffectivePrice {
  const EffectivePrice._();

  /// Chọn Giá hiệu lực từ các bản ghi giá của cùng một ký hiệu, theo đúng thứ
  /// tự: Giá nhập tay, rồi Giá thị trường lưu gần nhất, rồi `null`.
  ///
  /// Trả về `null` khi không có giá nào — **tuyệt đối không trả về 0**. Số 0
  /// trông y hệt một tài sản mất sạch giá trị, còn `null` buộc tầng hiển thị
  /// phải nói rõ là chưa có giá. Xem FR-14.
  static PriceQuote? from(Iterable<PriceQuote> quotes) {
    PriceQuote? market;
    for (final quote in quotes) {
      if (quote.source == PriceSource.manual) return quote;
      if (market == null || quote.fetchedAt.isAfter(market.fetchedAt)) {
        market = quote;
      }
    }
    return market;
  }

  /// Loại tài sản này ở bản đầu chưa có nguồn giá tự động, nên Giá nhập tay
  /// là cách duy nhất.
  ///
  /// Giao diện phải nói rõ điều đó thay vì để trống không giải thích — người
  /// dùng nhìn một ô rỗng sẽ tưởng ứng dụng hỏng. Xem FR-12.
  static bool requiresManualPrice(AssetKind kind) => switch (kind) {
        AssetKind.stock || AssetKind.gold => true,
        AssetKind.crypto => false,
        AssetKind.cashSavings || AssetKind.lending => false,
      };
}
