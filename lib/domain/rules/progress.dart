/// Tiến độ Mục tiêu — FR-22, AD-3.
///
/// **Luôn tính, không bao giờ lưu.** Không có cột `currentValue` hay
/// `progress` ở bất kỳ bảng nào. Người dùng sửa, xoá hay đổi ngày một Mốc quá
/// khứ thì mọi con số phía sau tự đúng theo.
library;

import 'package:decimal/decimal.dart';

import '../../core/money/scaled_value.dart';
import '../models/goal.dart';
import 'day.dart';

/// Mốc có ngày lớn nhất **không vượt quá** [asOf].
///
/// Mốc có ngày trong tương lai không được tính vào giá trị hiện tại.
/// Nhiều Mốc trùng ngày thì Mốc nhập sau thắng — FR-21.
GoalUpdate? latestUpdate(Iterable<GoalUpdate> updates, DateTime asOf) {
  final cutoff = startOfDay(asOf);
  GoalUpdate? best;
  for (final u in updates) {
    if (startOfDay(u.date).isAfter(cutoff)) continue;
    if (best == null || _isLater(u, best)) best = u;
  }
  return best;
}

bool _isLater(GoalUpdate a, GoalUpdate b) {
  final byDate = startOfDay(a.date).compareTo(startOfDay(b.date));
  if (byDate != 0) return byDate > 0;
  final byCreated = a.createdAt.compareTo(b.createdAt);
  if (byCreated != 0) return byCreated > 0;
  return a.id > b.id;
}

/// Giá trị hiện tại của Mục tiêu. `null` khi chưa có Mốc nào — nơi gọi phải
/// hiển thị `—`, tuyệt đối không hiển thị `0`.
ScaledValue? currentValue(Iterable<GoalUpdate> updates, DateTime asOf) =>
    latestUpdate(updates, asOf)?.value;

/// Tiến độ = giá trị hiện tại ÷ giá trị đích.
///
/// `null` khi Mục tiêu định tính, chưa có đích, chưa có Mốc, hoặc đích bằng 0.
/// Vượt 100% được trả về đúng như vậy, không bị chặn.
Decimal? progressRatio(Goal goal, Iterable<GoalUpdate> updates, DateTime asOf) {
  if (!goal.isNumeric) return null;
  final target = goal.target;
  if (target == null || target.isZero) return null;
  final current = currentValue(updates, asOf);
  if (current == null) return null;
  return current.ratioTo(target);
}

/// Khoảng còn thiếu để đạt đích. Âm nghĩa là đã vượt đích.
ScaledValue? remainingToTarget(
  Goal goal,
  Iterable<GoalUpdate> updates,
  DateTime asOf,
) {
  final target = goal.target;
  if (!goal.isNumeric || target == null) return null;
  final current = currentValue(updates, asOf) ?? ScaledValue(0, goal.decimals);
  return target - current;
}
