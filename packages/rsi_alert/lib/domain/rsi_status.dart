import 'constants.dart';

/// Trạng thái suy ra từ một giá trị RSI (AD-2 — không bao giờ lưu).
enum RsiStatus {
  oversold,
  neutral,
  overbought,
  insufficientData;

  /// `null` nghĩa là chuỗi chưa đủ nến để có RSI.
  static RsiStatus from(double? rsi) {
    if (rsi == null) return RsiStatus.insufficientData;
    if (rsi < oversoldThreshold) return RsiStatus.oversold;
    if (rsi > overboughtThreshold) return RsiStatus.overbought;
    return RsiStatus.neutral;
  }
}
