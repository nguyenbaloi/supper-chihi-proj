import 'package:meta/meta.dart';

/// Bậc độ mới của một con số giá.
enum FreshnessUnit { justNow, minutes, hours, days, never }

/// Độ mới của giá, đã quy về bậc và số lượng để tầng l10n dựng câu.
///
/// Tách khỏi widget vì đây là quy tắc có thể sai một cách im lặng: hiện
/// "cập nhật 5 phút trước" cho một con số đã cũ hai ngày là đúng loại lỗi
/// khiến người dùng ra quyết định trên số liệu cũ mà tưởng là mới. Xem FR-13.
@immutable
class PriceFreshness {
  final FreshnessUnit unit;
  final int count;

  const PriceFreshness(this.unit, this.count);

  static const PriceFreshness never = PriceFreshness(FreshnessUnit.never, 0);

  /// Ngưỡng cảnh báo dùng chung cho mọi loại tài sản. Xem FR-13.
  static const Duration staleThreshold = Duration(hours: 24);

  /// Giá đã cũ tới mức phải cảnh báo trực quan chưa.
  bool get isStale => unit == FreshnessUnit.never || unit == FreshnessUnit.days;

  static PriceFreshness since(DateTime? fetchedAt, {required DateTime now}) {
    if (fetchedAt == null) return never;

    final elapsed = now.difference(fetchedAt);
    if (elapsed.isNegative || elapsed.inMinutes < 1) {
      return const PriceFreshness(FreshnessUnit.justNow, 0);
    }
    if (elapsed.inMinutes < 60) {
      return PriceFreshness(FreshnessUnit.minutes, elapsed.inMinutes);
    }
    if (elapsed < staleThreshold) {
      return PriceFreshness(FreshnessUnit.hours, elapsed.inHours);
    }
    return PriceFreshness(FreshnessUnit.days, elapsed.inDays);
  }

  @override
  bool operator ==(Object other) =>
      other is PriceFreshness && other.unit == unit && other.count == count;

  @override
  int get hashCode => Object.hash(unit, count);

  @override
  String toString() => 'PriceFreshness($unit, $count)';
}
