import 'package:meta/meta.dart';

import 'enums.dart';

/// Một hướng đi người dùng đang triển khai — đơn vị trung tâm của sản phẩm.
///
/// **Không có** trường `completionRatio`, `completionPercent` hay `actionCount`.
/// Tỷ lệ hoàn thành luôn được tính từ danh sách Hành động (AD-3).
@immutable
final class Project {
  const Project({
    required this.id,
    required this.areaId,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.startedAt,
    this.completedAt,
  });

  final int id;
  final int areaId;
  final String name;
  final String description;
  final ProjectStatus status;
  final Priority priority;

  /// Hạn chót do người dùng chọn — một trong hai trường thời gian duy nhất
  /// người dùng được nhập (AD-5).
  final DateTime? dueDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Ghi một lần duy nhất ở lần đầu vào `Đang làm`, không bao giờ xoá — AD-5.
  final DateTime? startedAt;

  /// Ghi khi vào `Xong`, xoá khi rời `Xong` — AD-5.
  final DateTime? completedAt;

  Project copyWith({
    int? areaId,
    String? name,
    String? description,
    ProjectStatus? status,
    Priority? priority,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) =>
      Project(
        id: id,
        areaId: areaId ?? this.areaId,
        name: name ?? this.name,
        description: description ?? this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        startedAt: startedAt ?? this.startedAt,
        completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      );

  @override
  bool operator ==(Object other) => other is Project && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
