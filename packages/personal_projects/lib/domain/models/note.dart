import 'package:meta/meta.dart';

/// Nội dung dài — nguyên tắc, kiến thức, bài học (FR-27).
///
/// Là bản ghi riêng chứ không phải một trường `notes` một dòng: nội dung thực
/// tế (phần *Nợ tốt / Khi nào nên vay*) dài khoảng một trang và có cấu trúc.
///
/// Gắn vào một Dự án, **hoặc** một Lĩnh vực, **hoặc** không gắn gì — nhiều
/// nhất một cái khác `null` (AD-18). Ràng buộc thật nằm ở tầng bảng; `assert`
/// ở đây chỉ bắt lỗi sớm lúc phát triển.
@immutable
final class Note {
  const Note({
    required this.id,
    this.projectId,
    this.areaId,
    required this.title,
    required this.bodyMarkdown,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(projectId == null || areaId == null,
            'AD-18: Ghi chú không gắn vào cả Dự án lẫn Lĩnh vực');

  final int id;

  /// `null` nghĩa là không gắn vào Dự án nào — có thể vì gắn vào Lĩnh vực, có
  /// thể vì Dự án cha đã bị xoá và Ghi chú được giữ lại (FR-50).
  final int? projectId;

  final int? areaId;
  final String title;
  final String bodyMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Nằm trong kho chung: không thuộc Dự án nào và cũng chưa thuộc Lĩnh vực nào.
  bool get isUnattached => projectId == null && areaId == null;

  Note copyWith({String? title, String? bodyMarkdown, DateTime? updatedAt}) => Note(
        id: id,
        projectId: projectId,
        areaId: areaId,
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

/// Một URL ngoài — FR-28. Cùng ràng buộc gắn kết với [Note] — AD-18.
@immutable
final class Link {
  const Link({
    required this.id,
    this.projectId,
    this.areaId,
    required this.label,
    required this.url,
    required this.sortOrder,
  }) : assert(projectId == null || areaId == null,
            'AD-18: Liên kết không gắn vào cả Dự án lẫn Lĩnh vực');

  final int id;
  final int? projectId;
  final int? areaId;
  final String label;
  final String url;
  final int sortOrder;

  bool get isUnattached => projectId == null && areaId == null;

  Link copyWith({String? label, String? url, int? sortOrder}) => Link(
        id: id,
        projectId: projectId,
        areaId: areaId,
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
