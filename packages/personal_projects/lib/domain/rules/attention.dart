/// Cảnh báo trên màn hình Hôm nay — FR-43.
///
/// Tách bạch với danh sách "làm ngay": danh sách đó **chỉ** gồm việc người dùng
/// tự ghim (FR-42), còn khối này là thứ ứng dụng chủ động nhắc. Trộn hai thứ
/// vào nhau là quay lại đúng khuyết tật cũ — một danh sách dài không ai đọc.
library;

import '../models/enums.dart';
import '../models/project_action.dart';
import 'day.dart';

enum AttentionKind {
  /// Quá hạn mà chưa xong.
  overdue,

  /// Đến hạn trong vài ngày tới.
  dueSoon,

  /// Ưu tiên cao nhưng còn nằm im ở `Chưa`.
  highPriorityNotStarted,
}

final class AttentionItem {
  const AttentionItem(this.action, this.kind, {this.days});

  final ProjectAction action;
  final AttentionKind kind;

  /// Số ngày trễ với [AttentionKind.overdue], số ngày còn lại với
  /// [AttentionKind.dueSoon]. `null` với loại còn lại.
  final int? days;
}

/// Mỗi Hành động chỉ xuất hiện **một lần**, ở loại nghiêm trọng nhất.
///
/// Thứ tự nghiêm trọng: quá hạn → sắp đến hạn → ưu tiên cao chưa làm. Một việc
/// vừa quá hạn vừa ưu tiên cao mà hiện hai lần thì khối cảnh báo tự phình ra
/// và mất tác dụng.
List<AttentionItem> buildAttention(
  Iterable<ProjectAction> actions, {
  required DateTime now,
  int dueSoonDays = 7,
}) {
  final items = <AttentionItem>[];

  for (final a in actions) {
    if (!a.status.isOpen) continue;

    final due = a.dueDate;
    if (due != null && isOverdue(dueDate: due, now: now)) {
      items.add(AttentionItem(a, AttentionKind.overdue,
          days: overdueDays(dueDate: due, now: now)));
      continue;
    }
    if (due != null && isDueSoon(dueDate: due, now: now, withinDays: dueSoonDays)) {
      items.add(AttentionItem(a, AttentionKind.dueSoon,
          days: daysBetween(now, due)));
      continue;
    }
    if (a.priority == Priority.high && a.status == ActionStatus.todo) {
      items.add(AttentionItem(a, AttentionKind.highPriorityNotStarted));
    }
  }

  // Xếp theo mức nghiêm trọng, rồi theo độ ưu tiên, rồi theo hạn gần nhất.
  items.sort((x, y) {
    final byKind = x.kind.index.compareTo(y.kind.index);
    if (byKind != 0) return byKind;
    final byPriority =
        x.action.priority.sortRank.compareTo(y.action.priority.sortRank);
    if (byPriority != 0) return byPriority;
    final xd = x.action.dueDate, yd = y.action.dueDate;
    if (xd == null && yd == null) return 0;
    if (xd == null) return 1;
    if (yd == null) return -1;
    return xd.compareTo(yd);
  });
  return items;
}

/// Đếm theo từng loại, để hiện huy hiệu số mà không phải dựng cả danh sách.
Map<AttentionKind, int> countAttention(Iterable<AttentionItem> items) {
  final counts = {for (final k in AttentionKind.values) k: 0};
  for (final i in items) {
    counts[i.kind] = counts[i.kind]! + 1;
  }
  return counts;
}
