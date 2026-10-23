import 'package:meta/meta.dart';

/// Ghi chú kế hoạch — việc cần làm, đặt cạnh con số sinh ra nó. Xem FR-36.
@immutable
class ActionNote {
  final int id;
  final String body;
  final DateTime createdAt;

  /// `null` nghĩa là chưa hoàn thành.
  final DateTime? completedAt;

  const ActionNote({
    required this.id,
    required this.body,
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  @override
  bool operator ==(Object other) =>
      other is ActionNote &&
      other.id == id &&
      other.body == body &&
      other.createdAt == createdAt &&
      other.completedAt == completedAt;

  @override
  int get hashCode => Object.hash(id, body, createdAt, completedAt);
}
