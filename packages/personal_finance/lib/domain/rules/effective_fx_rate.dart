import '../../core/money/money.dart';
import '../models/enums.dart';
import '../models/fx_rate.dart';

/// Quyết định Tỷ giá đang dùng để quy đổi USD sang VND.
///
/// Cùng nguyên tắc với [EffectivePrice]: **đúng một hàm** quyết định, theo
/// thứ tự Tỷ giá nhập tay, rồi Tỷ giá lấy tự động, rồi giá trị dự phòng.
/// Xem FR-11 và AD-6.
class EffectiveFxRate {
  const EffectiveFxRate._();

  /// Tỷ giá dự phòng khi chưa từng lấy được lần nào và người dùng chưa nhập.
  ///
  /// Có giá trị này để ứng dụng không bao giờ đứng im chờ mạng. Đổi lại, mọi
  /// con số tính từ nó phải được ghi rõ là đang dùng tỷ giá dự phòng — người
  /// dùng cần biết mình đang nhìn một phỏng đoán.
  static const Money fallbackRate = Money(26000);

  static FxRate resolve({Money? manualRate, FxRate? fetchedRate}) {
    if (manualRate != null) {
      return FxRate(rateAmount: manualRate, source: PriceSource.manual);
    }
    if (fetchedRate != null) return fetchedRate;
    return const FxRate(
      rateAmount: fallbackRate,
      source: PriceSource.api,
      isFallback: true,
    );
  }
}
