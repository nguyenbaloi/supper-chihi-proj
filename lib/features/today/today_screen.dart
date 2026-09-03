import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/project_action.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/attention.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/layout.dart';
import '../actions/action_tile.dart';

/// Màn hình Hôm nay — FR-42, FR-43.
///
/// Hai khối tách bạch, và ranh giới giữa chúng là điều quan trọng nhất ở đây:
///
/// **Làm ngay** chỉ gồm việc người dùng **tự ghim**. Ứng dụng không bao giờ tự
/// thêm gì vào đó. Trước đây màn này tự suy ra danh sách từ trạng thái và hạn,
/// và kết quả là một danh sách dài không ai đọc.
///
/// **Cần chú ý** là phần ứng dụng chủ động nhắc: quá hạn, sắp đến hạn, ưu tiên
/// cao mà chưa bắt đầu. Nó nằm dưới, và nó là *thông tin*, không phải danh sách
/// việc phải làm.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider)();
    final pinned = ref.watch(pinnedActionsProvider).value ?? const [];
    final open = ref.watch(openActionsProvider).value ?? const [];
    final summaries = ref.watch(allProjectSummariesProvider).value ?? const [];
    final projectById = {for (final s in summaries) s.project.id: s};

    // Việc đã ghim không lặp lại ở khối cảnh báo — người dùng đã thấy nó rồi.
    final pinnedIds = pinned.map((a) => a.id).toSet();
    final attention = buildAttention(
      open.where((a) => !pinnedIds.contains(a.id)),
      now: now,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl * 2),
      children: [
        _DateHeader(now: now, pinnedCount: pinned.length),
        if (pinned.isEmpty && attention.isEmpty)
          const _AllClear()
        else ...[
          // Không lặp lại nhãn "Làm ngay": thanh tiêu đề và thanh dưới đã nói
          // hai lần rồi. Ở đây chỉ còn câu nhắc về luật của khối này.
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xs,
                AppSpacing.gutter, AppSpacing.md),
            child: Text(S.todayDoNowHint,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          if (pinned.isEmpty)
            const _EmptyPinned()
          else
            GroupedCard(
              children: [
                for (final a in pinned)
                  _Row(action: a, project: projectById[a.projectId]),
              ],
            ),
          if (attention.isNotEmpty) ...[
            SectionHeader(
              title: S.todayAttention,
              subtitle: S.attentionCount(attention.length),
              color: Theme.of(context).colorScheme.error,
            ),
            for (final kind in AttentionKind.values)
              ..._groupFor(context, attention, kind, projectById),
          ],
        ],
      ],
    );
  }

  List<Widget> _groupFor(
    BuildContext context,
    List<AttentionItem> all,
    AttentionKind kind,
    Map<int, ProjectSummary> projectById,
  ) {
    final items = all.where((i) => i.kind == kind).toList();
    if (items.isEmpty) return const [];
    return [
      _KindHeader(kind: kind, count: items.length),
      GroupedCard(
        children: [
          for (final i in items)
            _Row(
              action: i.action,
              project: projectById[i.action.projectId],
              note: _note(i),
            ),
        ],
      ),
    ];
  }

  static String label(AttentionKind k) => switch (k) {
        AttentionKind.overdue => S.attentionOverdue,
        AttentionKind.dueSoon => S.attentionDueSoon,
        AttentionKind.highPriorityNotStarted => S.attentionHighPriority,
      };

  static Color color(ThemeData theme, AttentionKind k) => switch (k) {
        AttentionKind.overdue => theme.colorScheme.error,
        AttentionKind.dueSoon => const Color(0xFFEF6C00),
        AttentionKind.highPriorityNotStarted => theme.colorScheme.primary,
      };

  static String? _note(AttentionItem i) => switch (i.kind) {
        AttentionKind.dueSoon when i.days != null => S.dueInDays(i.days!),
        _ => null,
      };
}

/// Dòng ngày ở đầu màn hình. Ngắn, nhạt, không cạnh tranh với tên việc —
/// nhưng đủ để biết "hôm nay" trong app là ngày nào.
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.now, required this.pinnedCount});

  final DateTime now;
  final int pinnedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              VnFormat.weekdayDate(now),
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (pinnedCount > 0)
            Text(
              S.attentionCount(pinnedCount),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// Nhãn một loại cảnh báo: chấm màu, tên loại, số việc. Chấm màu là thứ mắt
/// bắt trước, nhãn chữ là thứ NFR-7 bắt buộc phải có kèm.
class _KindHeader extends StatelessWidget {
  const _KindHeader({required this.kind, required this.count});

  final AttentionKind kind;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = TodayScreen.color(theme, kind);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            TodayScreen.label(kind),
            style: theme.textTheme.labelMedium?.copyWith(color: tint),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('$count', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.action, this.project, this.note});

  final ProjectAction action;
  final ProjectSummary? project;
  final String? note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = [
      if (project != null) project!.project.name,
      if (note != null) note!,
    ].join(' · ');

    return ActionTile(
      action: action,
      subtitleOverride: subtitle.isEmpty ? null : subtitle,
      showPriority: true,
      trailing: IconButton(
        tooltip: action.pinned ? S.unpin : S.pin,
        icon: Icon(action.pinned ? Icons.push_pin : Icons.push_pin_outlined,
            size: 20),
        color: action.pinned
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
        onPressed: () => ref
            .read(actionRepositoryProvider)
            .setPinned(action.id, !action.pinned),
      ),
    );
  }
}

class _EmptyPinned extends StatelessWidget {
  const _EmptyPinned();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
        child: DottedHint(text: S.todayEmpty, icon: Icons.push_pin_outlined),
      );
}

class _AllClear extends StatelessWidget {
  const _AllClear();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl * 2),
        child: EmptyState(
          icon: Icons.check_circle_outline,
          title: S.todayAllClear,
          message: S.todayGoToProjects,
        ),
      );
}
