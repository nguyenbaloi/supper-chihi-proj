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
import '../../presentation/widgets/layout.dart';
import '../projects/project_detail_screen.dart';
import 'action_edit_sheet.dart';

/// Chi tiết một Hành động — FR-14, FR-16.
///
/// Trạng thái, độ ưu tiên và hạn sửa được ngay tại đây, mỗi thứ một chạm.
/// Bốn mốc thời gian ở cuối màn hình chỉ để **đọc**: AD-5 nói chúng do tầng
/// dữ liệu ghi, không có ô nhập nào cho chúng ở bất kỳ đâu.
class ActionDetailScreen extends ConsumerWidget {
  const ActionDetailScreen({super.key, required this.actionId});

  final int actionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(actionProvider(actionId));
    final action = async.value;

    if (action == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(S.actionDetail)),
        body: Center(
          child: async.isLoading
              ? const CircularProgressIndicator()
              : Text(S.actionGone, style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }

    final now = ref.watch(nowProvider)();
    final theme = Theme.of(context);
    final repo = ref.read(actionRepositoryProvider);
    final overdue = action.dueDate != null &&
        action.status.isOpen &&
        isOverdue(dueDate: action.dueDate!, now: now);
    final project = ref.watch(projectProvider(action.projectId)).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.actionDetail),
        actions: [
          IconButton(
            tooltip: action.pinned ? S.unpin : S.pin,
            icon: Icon(action.pinned ? Icons.push_pin : Icons.push_pin_outlined),
            color: action.pinned ? theme.colorScheme.primary : null,
            onPressed: () async {
              await HapticFeedback.selectionClick();
              await repo.setPinned(action.id, !action.pinned);
            },
          ),
          IconButton(
            tooltip: S.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showActionForm(context, existing: action),
          ),
          IconButton(
            tooltip: S.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, action),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl * 2),
        children: [
          SectionCard(
            margin: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm,
                AppSpacing.gutter, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    decoration: action.status == ActionStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: theme.colorScheme.outline,
                    color:
                        action.status.isOpen ? null : theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip.action(action.status),
                    PriorityChip(action.priority),
                    if (overdue)
                      _Warning(
                        text: VnFormat.daysOverdue(
                            overdueDays(dueDate: action.dueDate!, now: now)),
                      ),
                  ],
                ),
                if (project != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(height: 1),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ProjectDetailScreen(projectId: project.id),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.folder_outlined,
                            size: 18, color: theme.colorScheme.outline),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.actionProject,
                                  style: theme.textTheme.bodySmall),
                              Text(project.name,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 18, color: theme.colorScheme.outline),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Trạng thái — FR-16. Đổi ở đây đi qua đúng `changeStatus`, nên
          // `startedAt` và `completedAt` vẫn được ghi theo đúng quy tắc AD-5.
          SectionHeader(
            title: S.actionStatusLabel,
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm,
                AppSpacing.gutter, AppSpacing.sm),
          ),
          SectionCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final st in ActionStatus.values)
                      ChoiceChip(
                        label: Text(S.actionStatus(st)),
                        selected: action.status == st,
                        onSelected: (_) async {
                          await HapticFeedback.selectionClick();
                          await repo.changeStatus(action.id, st);
                        },
                      ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(height: 1),
                ),
                Text(S.actionPriority, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                ActionPrioritySelector(
                  value: action.priority,
                  onChanged: (p) => repo.update(action.copyWith(priority: p)),
                ),
                ActionDueDateField(
                  value: action.dueDate,
                  onChanged: (d) => repo.update(
                    action.copyWith(dueDate: d, clearDueDate: d == null),
                  ),
                ),
              ],
            ),
          ),

          SectionHeader(
            title: S.actionNote,
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm,
                AppSpacing.gutter, AppSpacing.sm),
          ),
          SectionCard(
            child: action.note.isEmpty
                ? Text(S.actionNoteEmpty, style: theme.textTheme.bodySmall)
                : Text(action.note, style: theme.textTheme.bodyMedium),
          ),

          SectionHeader(
            title: S.actionTimeline,
            subtitle: S.actionTimelineHint,
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm,
                AppSpacing.gutter, AppSpacing.sm),
          ),
          SectionCard(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              children: [
                _TimeRow(label: S.actionCreatedAt, at: action.createdAt),
                _TimeRow(label: S.actionStartedAt, at: action.startedAt),
                _TimeRow(label: S.actionCompletedAt, at: action.completedAt),
                _TimeRow(label: S.actionUpdatedAt, at: action.updatedAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ProjectAction action,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.actionDeleteTitle),
        content: const Text(S.actionDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(S.cancel)),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(S.delete)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final repo = ref.read(actionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await repo.delete(action.id);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: const Text(S.actionDeleted),
        action: SnackBarAction(
          label: S.undo,
          onPressed: () => repo.restore(action),
        ),
      ),
    );
  }
}

/// Nhãn cảnh báo trễ hạn — màu đỏ kèm chữ, không chỉ màu (NFR-7).
class _Warning extends StatelessWidget {
  const _Warning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 13, color: theme.colorScheme.error),
        const SizedBox(width: 3),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Một mốc thời gian chỉ đọc. Chưa có thì hiện `—`, không hiện ngày giả.
class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.at});

  final String label;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            at == null ? VnFormat.emptyValue : VnFormat.dateTime(at!),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
