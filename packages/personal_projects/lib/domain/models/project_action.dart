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
    required this.priority,
    required this.sortOrder,
    this.pinned = false,
    this.pinnedAt,
    this.pinnedOrder = 0,
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

  /// Độ ưu tiên riêng của Hành động — FR-41.
  final Priority priority;

  /// Người dùng tự ghim vào danh sách "làm ngay" — FR-42.
  final bool pinned;

  /// Thời điểm ghim, dùng để xếp thứ tự màn hình Hôm nay.
  final DateTime? pinnedAt;

  /// Chỗ người dùng **tự đẩy** việc này tới trong danh sách Làm ngay — nhỏ
  /// hơn thì nằm trên, `0` là chưa can thiệp. Không phải dấu thời gian, nên
  /// xếp lại thoải mái mà không làm sai [pinnedAt].
  final int pinnedOrder;

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
    Priority? priority,
    bool? pinned,
    DateTime? pinnedAt,
    bool clearPinnedAt = false,
    int? pinnedOrder,
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
        priority: priority ?? this.priority,
        pinned: pinned ?? this.pinned,
        pinnedAt: clearPinnedAt ? null : (pinnedAt ?? this.pinnedAt),
        pinnedOrder: pinnedOrder ?? this.pinnedOrder,
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
