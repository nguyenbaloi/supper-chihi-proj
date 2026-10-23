import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/project_action.dart';
import '../../domain/rules/day.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/chips.dart';
import 'action_detail_screen.dart';

/// Một dòng Hành động.
///
/// FR-19: ô tròn bên trái đánh dấu Xong bằng **đúng một chạm**, không mở màn
/// hình nào. Chạm vào phần còn lại của dòng thì mở màn hình chi tiết.
///
/// Bố cục ba tầng cố định — ô tròn · tên việc · thông tin phụ — để mắt lướt
/// dọc danh sách luôn tìm thấy cùng một thứ ở cùng một chỗ.
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

  /// Bỏ trống thì chạm vào dòng sẽ mở màn hình chi tiết của chính Hành động
  /// đó. Ô tròn bên trái vẫn là lối đánh dấu Xong một chạm — FR-19.
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Hiện nhãn độ ưu tiên. Bật ở màn hình Hôm nay, tắt trong danh sách của
  /// một Dự án nơi độ ưu tiên đã được nhóm sẵn.
  final bool showPriority;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider)();
    final theme = Theme.of(context);
    final closed = !action.status.isOpen;
    final isDone = action.status == ActionStatus.done;
    final overdue = action.dueDate != null &&
        action.status.isOpen &&
        isOverdue(dueDate: action.dueDate!, now: now);

    final meta = <Widget>[
      if (showPriority && action.status.isOpen) PriorityChip(action.priority),
      if (action.dueDate != null)
        _MetaChip(
          icon: overdue ? Icons.error_outline : Icons.event_outlined,
          label: overdue
              ? VnFormat.daysOverdue(
                  overdueDays(dueDate: action.dueDate!, now: now))
              : VnFormat.date(action.dueDate!),
          color: overdue ? theme.colorScheme.error : null,
          emphasise: overdue,
        ),
      if (action.status == ActionStatus.doing && action.startedAt != null)
        _MetaText(S.actionDoingFor(daysBetween(action.startedAt!, now))),
      if (subtitleOverride != null) _MetaText(subtitleOverride!),
    ];

    return InkWell(
      onTap: onTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ActionDetailScreen(actionId: action.id),
                ),
              ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CheckCircle(
              done: isDone,
              dropped: action.status == ActionStatus.dropped,
              onPressed: () async {
                await HapticFeedback.selectionClick();
                await ref.read(actionRepositoryProvider).changeStatus(
                      action.id,
                      isDone ? ActionStatus.todo : ActionStatus.done,
                    );
              },
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                      decorationColor: theme.colorScheme.outline,
                      color: closed ? theme.colorScheme.outline : null,
                    ),
                  ),
                  if (meta.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: meta,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Ô tròn đánh dấu Xong. Vùng chạm 44×44 theo NFR-6 dù hình vẽ chỉ 24px.
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({
    required this.done,
    required this.dropped,
    required this.onPressed,
  });

  final bool done;
  final bool dropped;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = done ? theme.colorScheme.primary : theme.colorScheme.outline;
    return Semantics(
      button: true,
      checked: done,
      label: S.actionStatus(ActionStatus.done),
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        containedInkWell: false,
        child: SizedBox(
          width: 26,
          height: 26,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
              child: done
                  ? Icon(Icons.check,
                      size: 15, color: theme.colorScheme.onPrimary)
                  : dropped
                      ? Icon(Icons.remove, size: 13, color: color)
                      : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mẩu thông tin phụ có biểu tượng — hạn, cảnh báo trễ.
class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.color,
    this.emphasise = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: tint),
        const SizedBox(width: 3),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: tint,
            fontWeight: emphasise ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      );
}
