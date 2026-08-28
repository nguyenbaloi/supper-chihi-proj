import 'package:meta/meta.dart';

import 'enums.dart';

/// Một việc cụ thể phải làm — thuật ngữ **Hành động** trong PRD.
///
/// Tên lớp là `ProjectAction` chứ không phải `Action` vì `Action` đã là một
/// lớp của `package:flutter/widgets.dart`; đặt trùng sẽ buộc mọi widget phải
/// dùng tiền tố import. Thuật ngữ nghiệp vụ và tên bảng vẫn là `Action`.
///
/// Luôn thuộc đúng một Dự án, không có Hành động con — AD-8.
@immutable
final class ProjectAction {
  const ProjectAction({
    required this.id,
    required this.projectId,
    required this.title,
    required this.note,
    required this.status,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.startedAt,
    this.completedAt,
  });

  final int id;
  final int projectId;
  final String title;
  final String note;
  final ActionStatus status;

  /// Hạn chót là **ngày**, không có giờ — FR-17.
  final DateTime? dueDate;

  /// Thứ tự do người dùng kéo thả — FR-18.
  final int sortOrder;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  ProjectAction copyWith({
    int? projectId,
    String? title,
    String? note,
    ActionStatus? status,
    int? sortOrder,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) =>
      ProjectAction(
        id: id,
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        note: note ?? this.note,
        status: status ?? this.status,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        startedAt: startedAt ?? this.startedAt,
        completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      );

  @override
  bool operator ==(Object other) => other is ProjectAction && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
