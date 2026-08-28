import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../domain/models/project_action.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/attention.dart';
import '../../presentation/providers/providers.dart';
import '../actions/action_tile.dart';
import '../projects/project_detail_screen.dart';

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

    if (pinned.isEmpty && attention.isEmpty) {
      return const _AllClear();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _SectionHeader(title: S.todayDoNow, subtitle: S.todayDoNowHint),
        if (pinned.isEmpty)
          const _EmptyPinned()
        else
          for (final a in pinned)
            _Row(action: a, project: projectById[a.projectId]),
        if (attention.isNotEmpty) ...[
          const Divider(height: 32),
          _SectionHeader(
            title: S.todayAttention,
            subtitle: S.attentionCount(attention.length),
            emphasise: true,
          ),
          for (final kind in AttentionKind.values)
            ..._groupFor(context, attention, kind, projectById),
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
    final theme = Theme.of(context);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
        child: Text(
          '${_label(kind)} · ${S.attentionCount(items.length)}',
          style: theme.textTheme.labelLarge?.copyWith(color: _color(theme, kind)),
        ),
      ),
      for (final i in items)
        _Row(
          action: i.action,
          project: projectById[i.action.projectId],
          note: _note(i),
        ),
    ];
  }

  static String _label(AttentionKind k) => switch (k) {
        AttentionKind.overdue => S.attentionOverdue,
        AttentionKind.dueSoon => S.attentionDueSoon,
        AttentionKind.highPriorityNotStarted => S.attentionHighPriority,
      };

  static Color _color(ThemeData theme, AttentionKind k) => switch (k) {
        AttentionKind.overdue => theme.colorScheme.error,
        AttentionKind.dueSoon => const Color(0xFFEF6C00),
        AttentionKind.highPriorityNotStarted => theme.colorScheme.primary,
      };

  static String? _note(AttentionItem i) => switch (i.kind) {
        AttentionKind.dueSoon when i.days != null => S.dueInDays(i.days!),
        _ => null,
      };
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
        icon: Icon(action.pinned ? Icons.push_pin : Icons.push_pin_outlined),
        color: action.pinned ? Theme.of(context).colorScheme.primary : null,
        onPressed: () => ref
            .read(actionRepositoryProvider)
            .setPinned(action.id, !action.pinned),
      ),
      onTap: project == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ProjectDetailScreen(projectId: project!.project.id),
                ),
              ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.emphasise = false,
  });

  final String title;
  final String subtitle;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: emphasise ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
          ),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyPinned extends StatelessWidget {
  const _EmptyPinned();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(S.todayEmpty, style: Theme.of(context).textTheme.bodyMedium),
      );
}

class _AllClear extends StatelessWidget {
  const _AllClear();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(S.todayAllClear,
                style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(S.todayGoToProjects,
                style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
