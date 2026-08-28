import 'package:meta/meta.dart';

/// Nội dung dài gắn vào một Dự án — nguyên tắc, kiến thức, bài học (FR-27).
///
/// Là bản ghi riêng chứ không phải một trường `notes` một dòng: nội dung thực
/// tế (phần *Nợ tốt / Khi nào nên vay*) dài khoảng một trang và có cấu trúc.
@immutable
final class Note {
  const Note({
    required this.id,
    required this.projectId,
    required this.title,
    required this.bodyMarkdown,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final String title;
  final String bodyMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({String? title, String? bodyMarkdown, DateTime? updatedAt}) => Note(
        id: id,
        projectId: projectId,
        title: title ?? this.title,
        bodyMarkdown: bodyMarkdown ?? this.bodyMarkdown,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) => other is Note && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Một URL ngoài gắn vào Dự án — FR-28.
@immutable
final class Link {
  const Link({
    required this.id,
    required this.projectId,
    required this.label,
    required this.url,
    required this.sortOrder,
  });

  final int id;
  final int projectId;
  final String label;
  final String url;
  final int sortOrder;

  Link copyWith({String? label, String? url, int? sortOrder}) => Link(
        id: id,
        projectId: projectId,
        label: label ?? this.label,
        url: url ?? this.url,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  bool operator ==(Object other) => other is Link && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Một lần đổi trạng thái — bảng chỉ ghi thêm, không sửa.
///
/// Phục vụ FR-8 (xem lại lịch sử) và là nguồn duy nhất để tính "ngày hoạt
/// động gần nhất" của Dự án ở FR-13.
@immutable
final class StatusEvent {
  const StatusEvent({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.fromStatus,
    required this.toStatus,
    required this.at,
  });

  final int id;
  final String entityType;
  final int entityId;
  final String fromStatus;
  final String toStatus;
  final DateTime at;
}
