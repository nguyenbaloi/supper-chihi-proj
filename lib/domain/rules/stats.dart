/// Thống kê đầu việc theo hạn — FR-44.
///
/// Câu hỏi mà thống kê này trả lời: *"việc đến hạn thì mình có làm xong không,
/// hay để trôi?"* Nên trục phân loại không phải là `Xong`/`Chưa` mà là **quan
/// hệ giữa lúc xong và hạn đã đặt**.
library;

import 'package:decimal/decimal.dart';

import '../models/enums.dart';
import '../models/project_action.dart';
import 'day.dart';

enum DueOutcome {
  /// Đã xong, và xong không muộn hơn hạn.
  onTime,

  /// Đã xong, nhưng xong sau hạn.
  late,

  /// Chưa xong và đã quá hạn.
  overdue,

  /// Chưa xong nhưng còn hạn.
  pending,

  /// Không đặt hạn — không xếp vào đâu được, và nói thẳng là vậy.
  noDueDate,

  /// Đã bỏ.
  dropped,
}

final class ActionStats {
  const ActionStats({
    required this.counts,
    required this.total,
    required this.doneWithoutDueDate,
  });

  final Map<DueOutcome, int> counts;
  final int total;

  /// Việc đã xong nhưng không đặt hạn. Nằm trong `noDueDate`, đếm riêng để
  /// tính tỷ lệ hoàn thành cho đúng.
  final int doneWithoutDueDate;

  int operator [](DueOutcome outcome) => counts[outcome] ?? 0;

  /// Số việc **có đặt hạn** và đã kết thúc — mẫu số của tỷ lệ đúng hạn.
  int get finishedWithDueDate => this[DueOutcome.onTime] + this[DueOutcome.late];

  /// Tỷ lệ đúng hạn. `null` khi chưa có việc nào có hạn mà đã xong — nơi gọi
  /// phải hiện `—`, tuyệt đối không hiện `0%`.
  Decimal? get onTimeRatio => finishedWithDueDate == 0
      ? null
      : (Decimal.fromInt(this[DueOutcome.onTime]) /
              Decimal.fromInt(finishedWithDueDate))
          .toDecimal(scaleOnInfinitePrecision: 12);

  /// Tỷ lệ hoàn thành trên tổng số việc không bị bỏ.
  Decimal? get completionRatio {
    final counted = total - this[DueOutcome.dropped];
    if (counted == 0) return null;
    final done =
        this[DueOutcome.onTime] + this[DueOutcome.late] + doneWithoutDueDate;
    return (Decimal.fromInt(done) / Decimal.fromInt(counted))
        .toDecimal(scaleOnInfinitePrecision: 12);
  }
}

DueOutcome outcomeOf(ProjectAction a, DateTime now) {
  if (a.status == ActionStatus.dropped) return DueOutcome.dropped;
  final due = a.dueDate;

  if (a.status == ActionStatus.done) {
    if (due == null) return DueOutcome.noDueDate;
    final finishedAt = a.completedAt;
    if (finishedAt == null) return DueOutcome.onTime;
    return daysBetween(due, finishedAt) > 0 ? DueOutcome.late : DueOutcome.onTime;
  }

  if (due == null) return DueOutcome.noDueDate;
  return isOverdue(dueDate: due, now: now) ? DueOutcome.overdue : DueOutcome.pending;
}

ActionStats computeStats(Iterable<ProjectAction> actions, DateTime now) {
  final counts = {for (final o in DueOutcome.values) o: 0};
  var total = 0;
  var doneNoDue = 0;
  for (final a in actions) {
    total++;
    final o = outcomeOf(a, now);
    counts[o] = counts[o]! + 1;
    if (o == DueOutcome.noDueDate && a.status == ActionStatus.done) doneNoDue++;
  }
  return ActionStats(counts: counts, total: total, doneWithoutDueDate: doneNoDue);
}
