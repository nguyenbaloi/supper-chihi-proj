import 'package:meta/meta.dart';

import '../../core/money/scaled_value.dart';

/// Đích đến dài hạn — gốc của cây Mục tiêu → Dự án → Hành động.
///
/// **Không có** trường `currentValue`, `progress` hay `progressPercent`.
/// Giá trị hiện tại luôn suy ra từ sổ [GoalUpdate] (AD-3).
@immutable
final class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.isNumeric,
    required this.decimals,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
    this.targetRaw,
    this.dueDate,
  });

  final int id;
  final String name;
  final String description;

  /// `false` với mục tiêu định tính như *"tìm thêm một nguồn thu nhập khác"* —
  /// loại này không có thanh phần trăm và không có sổ Mốc (FR-20).
  final bool isNumeric;

  /// Giá trị đích đã nhân hệ số. `null` với mục tiêu định tính.
  final int? targetRaw;

  /// Số chữ số thập phân của đơn vị. VND luôn 0 — AD-4.
  final int decimals;

  final String unit;

  /// Không có hạn chót thì **tuyệt đối không** hiện nhịp và dự báo — FR-24.
  final DateTime? dueDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  ScaledValue? get target =>
      targetRaw == null ? null : ScaledValue(targetRaw!, decimals);

  bool get isCurrency => unit == 'VND';

  Goal copyWith({
    String? name,
    String? description,
    bool? isNumeric,
    int? targetRaw,
    bool clearTarget = false,
    int? decimals,
    String? unit,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? updatedAt,
  }) =>
      Goal(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        isNumeric: isNumeric ?? this.isNumeric,
        targetRaw: clearTarget ? null : (targetRaw ?? this.targetRaw),
        decimals: decimals ?? this.decimals,
        unit: unit ?? this.unit,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) => other is Goal && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Một lần ghi nhận giá trị của Mục tiêu tại một ngày — FR-21.
///
/// Đây là nguồn dữ liệu duy nhất của tiến độ. Sửa, xoá hay đổi ngày một Mốc
/// quá khứ thì mọi con số phía sau tự đúng theo (AD-3).
@immutable
final class GoalUpdate {
  const GoalUpdate({
    required this.id,
    required this.goalId,
    required this.date,
    required this.valueRaw,
    required this.decimals,
    required this.note,
    required this.createdAt,
  });

  final int id;
  final int goalId;

  /// Ngày do người dùng chọn — AD-5.
  final DateTime date;

  final int valueRaw;
  final int decimals;
  final String note;

  /// Thời điểm nhập. Dùng để phân định khi nhiều Mốc trùng ngày — FR-21.
  final DateTime createdAt;

  ScaledValue get value => ScaledValue(valueRaw, decimals);

  GoalUpdate copyWith({
    DateTime? date,
    int? valueRaw,
    String? note,
  }) =>
      GoalUpdate(
        id: id,
        goalId: goalId,
        date: date ?? this.date,
        valueRaw: valueRaw ?? this.valueRaw,
        decimals: decimals,
        note: note ?? this.note,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) => other is GoalUpdate && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
