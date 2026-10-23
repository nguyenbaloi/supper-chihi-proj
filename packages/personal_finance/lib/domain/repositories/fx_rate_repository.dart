import '../models/fx_rate.dart';

/// Tỷ giá USD sang VND.
abstract interface class FxRateRepository {
  /// Tỷ giá lấy tự động gần nhất, `null` nếu chưa từng lấy được.
  Future<FxRate?> fetchedRate();

  /// Tỷ giá đang thực sự dùng, đã qua thứ tự ưu tiên của [EffectiveFxRate].
  Future<FxRate> effectiveRate();

  Future<void> saveFetchedRate(FxRate rate);
}
