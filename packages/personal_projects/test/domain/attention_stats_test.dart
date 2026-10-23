import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/domain/models/enums.dart';
import 'package:personal_projects/domain/models/project_action.dart';
import 'package:personal_projects/domain/rules/attention.dart';
import 'package:personal_projects/domain/rules/stats.dart';

final _now = DateTime(2026, 8, 28, 10);

ProjectAction act({
  required int id,
  ActionStatus status = ActionStatus.todo,
  Priority priority = Priority.medium,
  DateTime? dueDate,
  DateTime? completedAt,
  String title = 'việc',
}) =>
    ProjectAction(
      id: id,
      projectId: 1,
      title: title,
      note: '',
      status: status,
      priority: priority,
      sortOrder: id,
      dueDate: dueDate,
      completedAt: completedAt,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('FR-43 — cảnh báo trên màn hình Hôm nay', () {
    test('quá hạn, sắp đến hạn, ưu tiên cao chưa làm đều được bắt', () {
      final items = buildAttention([
        act(id: 1, dueDate: DateTime(2026, 8, 25)),
        act(id: 2, dueDate: DateTime(2026, 9, 2)),
        act(id: 3, priority: Priority.high),
      ], now: _now);

      expect(items.map((i) => i.kind).toList(), [
        AttentionKind.overdue,
        AttentionKind.dueSoon,
        AttentionKind.highPriorityNotStarted,
      ]);
      expect(items.first.days, 3, reason: 'trễ 3 ngày');
      expect(items[1].days, 5, reason: 'còn 5 ngày');
    });

    test('một việc chỉ xuất hiện MỘT lần, ở loại nghiêm trọng nhất', () {
      // Vừa quá hạn, vừa ưu tiên cao, vừa chưa bắt đầu.
      final items = buildAttention(
        [act(id: 1, priority: Priority.high, dueDate: DateTime(2026, 8, 20))],
        now: _now,
      );
      expect(items.length, 1);
      expect(items.single.kind, AttentionKind.overdue);
    });

    test('việc đã xong hoặc đã bỏ không bao giờ cảnh báo', () {
      final items = buildAttention([
        act(id: 1, status: ActionStatus.done, dueDate: DateTime(2026, 8, 1)),
        act(id: 2, status: ActionStatus.dropped, priority: Priority.high),
      ], now: _now);
      expect(items, isEmpty);
    });

    test('ưu tiên cao nhưng ĐANG LÀM thì không cảnh báo', () {
      final items = buildAttention(
        [act(id: 1, priority: Priority.high, status: ActionStatus.doing)],
        now: _now,
      );
      expect(items, isEmpty, reason: 'đang làm rồi thì không cần nhắc');
    });

    test('đến hạn đúng hôm nay tính là sắp đến hạn, không phải quá hạn', () {
      final items =
          buildAttention([act(id: 1, dueDate: DateTime(2026, 8, 28))], now: _now);
      expect(items.single.kind, AttentionKind.dueSoon);
      expect(items.single.days, 0);
    });

    test('trong cùng một loại, ưu tiên cao lên trước', () {
      final items = buildAttention([
        act(id: 1, priority: Priority.low, dueDate: DateTime(2026, 8, 20)),
        act(id: 2, priority: Priority.high, dueDate: DateTime(2026, 8, 20)),
      ], now: _now);
      expect(items.map((i) => i.action.id).toList(), [2, 1]);
    });

    test('đếm theo loại', () {
      final counts = countAttention(buildAttention([
        act(id: 1, dueDate: DateTime(2026, 8, 20)),
        act(id: 2, dueDate: DateTime(2026, 8, 21)),
        act(id: 3, priority: Priority.high),
      ], now: _now));
      expect(counts[AttentionKind.overdue], 2);
      expect(counts[AttentionKind.highPriorityNotStarted], 1);
      expect(counts[AttentionKind.dueSoon], 0);
    });
  });

  group('FR-44 — thống kê theo hạn', () {
    test('xong trước hạn và xong đúng ngày hạn đều tính đúng hạn', () {
      expect(
        outcomeOf(
          act(
            id: 1,
            status: ActionStatus.done,
            dueDate: DateTime(2026, 8, 20),
            completedAt: DateTime(2026, 8, 18),
          ),
          _now,
        ),
        DueOutcome.onTime,
      );
      expect(
        outcomeOf(
          act(
            id: 2,
            status: ActionStatus.done,
            dueDate: DateTime(2026, 8, 20),
            completedAt: DateTime(2026, 8, 20, 23),
          ),
          _now,
        ),
        DueOutcome.onTime,
        reason: 'xong trong ngày hạn vẫn là đúng hạn',
      );
    });

    test('xong sau hạn là muộn', () {
      expect(
        outcomeOf(
          act(
            id: 1,
            status: ActionStatus.done,
            dueDate: DateTime(2026, 8, 20),
            completedAt: DateTime(2026, 8, 22),
          ),
          _now,
        ),
        DueOutcome.late,
      );
    });

    test('chưa xong: quá hạn hay còn hạn', () {
      expect(outcomeOf(act(id: 1, dueDate: DateTime(2026, 8, 20)), _now),
          DueOutcome.overdue);
      expect(outcomeOf(act(id: 2, dueDate: DateTime(2026, 9, 20)), _now),
          DueOutcome.pending);
    });

    test('không đặt hạn thì nói thẳng, không xếp bừa', () {
      expect(outcomeOf(act(id: 1), _now), DueOutcome.noDueDate);
      expect(outcomeOf(act(id: 2, status: ActionStatus.done), _now),
          DueOutcome.noDueDate);
    });

    test('đã bỏ tách riêng', () {
      expect(
        outcomeOf(
            act(id: 1, status: ActionStatus.dropped, dueDate: DateTime(2026, 1, 1)),
            _now),
        DueOutcome.dropped,
      );
    });

    test('tỷ lệ đúng hạn chỉ tính trên việc CÓ HẠN và ĐÃ XONG', () {
      final stats = computeStats([
        act(id: 1, status: ActionStatus.done, dueDate: DateTime(2026, 8, 10), completedAt: DateTime(2026, 8, 9)),
        act(id: 2, status: ActionStatus.done, dueDate: DateTime(2026, 8, 10), completedAt: DateTime(2026, 8, 9)),
        act(id: 3, status: ActionStatus.done, dueDate: DateTime(2026, 8, 10), completedAt: DateTime(2026, 8, 15)),
        act(id: 4, dueDate: DateTime(2026, 8, 1)), // quá hạn, chưa xong
        act(id: 5), // không hạn
      ], _now);

      expect(stats.finishedWithDueDate, 3);
      // Cắt ở 12 chữ số thập phân, không làm tròn lên — làm tròn chỉ xảy ra một
      // lần duy nhất ở lớp hiển thị (AD-4).
      expect(stats.onTimeRatio, Decimal.parse('0.666666666666'));
      expect(stats[DueOutcome.overdue], 1);
      expect(stats[DueOutcome.noDueDate], 1);
      expect(stats.total, 5);
    });

    test('chưa có việc nào có hạn mà xong thì tỷ lệ đúng hạn là null', () {
      final stats = computeStats([act(id: 1), act(id: 2)], _now);
      expect(stats.onTimeRatio, isNull, reason: 'nơi gọi phải hiện —, không phải 0%');
    });

    test('tỷ lệ hoàn thành không tính việc đã bỏ vào mẫu số', () {
      final stats = computeStats([
        act(id: 1, status: ActionStatus.done),
        act(id: 2),
        act(id: 3, status: ActionStatus.dropped),
      ], _now);
      // 1 xong / 2 việc còn tính = 50%
      expect(stats.completionRatio, Decimal.parse('0.5'));
    });

    test('không có việc nào thì tỷ lệ hoàn thành là null', () {
      expect(computeStats(const [], _now).completionRatio, isNull);
    });
  });
}
