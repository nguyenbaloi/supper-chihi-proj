import 'package:meta/meta.dart';

/// Nhóm phân loại Dự án — FR-1.
@immutable
final class Area {
  const Area({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconKey,
    required this.sortOrder,
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

  /// Lĩnh vực `Khác` — không xoá được, là nơi Dự án chuyển về khi Lĩnh vực cũ
  /// bị xoá (FR-1).
  final bool isSystemFallback;

  Area copyWith({
    String? name,
    int? colorValue,
    String? iconKey,
    int? sortOrder,
  }) =>
      Area(
        id: id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        iconKey: iconKey ?? this.iconKey,
        sortOrder: sortOrder ?? this.sortOrder,
        isSystemFallback: isSystemFallback,
      );

  @override
  bool operator ==(Object other) => other is Area && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
