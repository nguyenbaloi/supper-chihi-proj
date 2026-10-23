import 'package:meta/meta.dart';

/// Một mảng trách nhiệm phải giữ, **không bao giờ kết thúc** — FR-1, FR-47.
///
/// Khác Dự án ở chỗ không có trạng thái và không có hạn chót. Cái kết thúc
/// được là Dự án nằm trong nó.
@immutable
final class Area {
  const Area({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconKey,
    required this.sortOrder,
    required this.createdAt,
    this.standard = '',
    this.reviewCadenceDays,
    this.isSystemFallback = false,
  });

  final int id;
  final String name;

  /// Màu dạng ARGB. `int` chứ không phải kiểu của Flutter — `domain` không
  /// được biết gì về Flutter (AD-1).
  final int colorValue;

  /// Khoá biểu tượng; ánh xạ sang icon thật ở tầng `presentation`.
  final String iconKey;

  final int sortOrder;

  /// FR-47: *"mức tôi muốn giữ ở mảng này là gì"*. Rỗng là hợp lệ — ứng dụng
  /// không tự nghĩ hộ nội dung này.
  final String standard;

  /// FR-48: `null` nghĩa là **không nhắc gì cả**, không phải "chưa cấu hình".
  final int? reviewCadenceDays;

  /// Mốc tính hạn xem lại đầu tiên khi chưa có Đợt nào — FR-48.
  final DateTime createdAt;

  /// Lĩnh vực `Khác` — không xoá được, là nơi Dự án chuyển về khi Lĩnh vực cũ
  /// bị xoá (FR-1).
  final bool isSystemFallback;

  Area copyWith({
    String? name,
    int? colorValue,
    String? iconKey,
    int? sortOrder,
    String? standard,
    int? reviewCadenceDays,
    bool clearReviewCadence = false,
  }) =>
      Area(
        id: id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        iconKey: iconKey ?? this.iconKey,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
        standard: standard ?? this.standard,
        reviewCadenceDays: clearReviewCadence
            ? null
            : (reviewCadenceDays ?? this.reviewCadenceDays),
        isSystemFallback: isSystemFallback,
      );

  @override
  bool operator ==(Object other) => other is Area && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
