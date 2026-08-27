import 'package:meta/meta.dart';

/// Nhóm mục tiêu — gộp nhiều Lớp tài sản để đặt chung một Tỷ trọng mục tiêu.
@immutable
class TargetGroup {
  final int id;
  final String name;
  final int targetWeightBp;
  final int sortOrder;

  const TargetGroup({
    required this.id,
    required this.name,
    required this.targetWeightBp,
    this.sortOrder = 0,
  });

  @override
  bool operator ==(Object other) =>
      other is TargetGroup &&
      other.id == id &&
      other.name == name &&
      other.targetWeightBp == targetWeightBp &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(id, name, targetWeightBp, sortOrder);
}
