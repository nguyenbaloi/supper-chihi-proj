import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/project_action.dart';
import '../../domain/rules/day.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/chips.dart';

/// FR-19: đánh dấu Xong bằng đúng một chạm, không mở màn hình nào khác.
class ActionTile extends ConsumerWidget {
  const ActionTile({
    super.key,
    required this.action,
    this.subtitleOverride,
    this.onTap,
    this.trailing,
    this.showPriority = false,
  });

  final ProjectAction action;
  final String? subtitleOverride;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Hiện nhãn độ ưu tiên. Bật ở màn hình Hôm nay, tắt trong danh sách của
  /// một Dự án nơi độ ưu tiên đã được nhóm sẵn.
  final bool showPriority;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider)();
    final theme = Theme.of(context);
    final isDone = action.status == ActionStatus.done;
    final overdue = action.dueDate != null &&
        action.status.isOpen &&
        isOverdue(dueDate: action.dueDate!, now: now);

    final parts = <String>[
      if (subtitleOverride != null) subtitleOverride!,
      if (overdue)
        VnFormat.daysOverdue(overdueDays(dueDate: action.dueDate!, now: now))
      else if (action.dueDate != null)
        VnFormat.date(action.dueDate!),
      if (action.status == ActionStatus.doing && action.startedAt != null)
        S.actionDoingFor(daysBetween(action.startedAt!, now)),
    ];

    return ListTile(
      onTap: onTap,
      leading: IconButton(
        tooltip: S.actionStatus(ActionStatus.done),
        icon: Icon(isDone ? Icons.check_circle : Icons.circle_outlined),
        color: isDone ? theme.colorScheme.primary : theme.colorScheme.outline,
        onPressed: () async {
          await HapticFeedback.selectionClick();
          await ref.read(actionRepositoryProvider).changeStatus(
                action.id,
                isDone ? ActionStatus.todo : ActionStatus.done,
              );
        },
      ),
      title: Text(
        action.title,
        style: isDone
            ? theme.textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.outline,
              )
            : theme.textTheme.bodyLarge,
      ),
      subtitle: parts.isEmpty && !showPriority
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (showPriority) PriorityChip(action.priority),
                  if (parts.isNotEmpty)
                    Text(
                      parts.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: overdue ? theme.colorScheme.error : null,
                      ),
                    ),
                ],
              ),
            ),
      trailing: trailing,
    );
  }
}
