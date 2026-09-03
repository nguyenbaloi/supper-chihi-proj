import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/area.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/completion.dart';
import '../../domain/rules/day.dart';
import '../../domain/rules/stale.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/chips.dart';
import '../../presentation/widgets/layout.dart';
import '../areas/area_detail_screen.dart';
import 'project_detail_screen.dart';
import 'project_edit_sheet.dart';

/// Danh sách Dự án **nhóm theo Lĩnh vực** — FR-45.
///
/// Trước đây đây là một danh sách phẳng, và với bảy dự án trải trên bốn lĩnh vực
/// thì không nhìn ra được mảng nào đang nặng, mảng nào đang bỏ trống. Nhóm theo
/// Lĩnh vực trả lại đúng cách người dùng đã tự tổ chức trong hai file gốc.
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(projectSummariesProvider);
    final filter = ref.watch(projectFilterProvider);
    final areas = ref.watch(areasProvider).value ?? const <Area>[];

    return Scaffold(
      body: Column(
        children: [
          _FilterBar(filter: filter),
          Expanded(
            child: summaries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => list.isEmpty
                  ? const _EmptyProjects()
                  : _GroupedList(summaries: list, areas: areas),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProjectEditSheet(context),
        icon: const Icon(Icons.add),
        label: const Text(S.projectNew),
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.summaries, required this.areas});

  final List<ProjectSummary> summaries;
  final List<Area> areas;

  @override
  Widget build(BuildContext context) {
    final byArea = <int, List<ProjectSummary>>{};
    for (final s in summaries) {
      byArea.putIfAbsent(s.project.areaId, () => []).add(s);
    }
    // Giữ đúng thứ tự Lĩnh vực người dùng đã đặt; lĩnh vực rỗng thì không hiện.
    final ordered = areas.where((t) => byArea.containsKey(t.id)).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final area in ordered) ...[
          _AreaHeader(area: area, projects: byArea[area.id]!),
          for (final s in byArea[area.id]!) _ProjectCard(summary: s),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _AreaHeader extends StatelessWidget {
  const _AreaHeader({required this.area, required this.projects});

  final Area area;
  final List<ProjectSummary> projects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(area.colorValue);
    final done = projects.fold<int>(0, (n, s) => n + s.doneCount);
    final total = projects.fold<int>(0, (n, s) => n + s.countedTotal);

    return InkWell(
      // Lối vào duy nhất tới màn hình Lĩnh vực — nơi có mức cần giữ, nhịp xem
      // lại và Đợt đánh giá của cả mảng (FR-47…FR-49).
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AreaDetailScreen(areaId: area.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter, AppSpacing.xl, AppSpacing.gutter, AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                area.name.toUpperCase(),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: color, letterSpacing: 0.9),
              ),
            ),
            Text(
              total == 0
                  ? S.projectCount(projects.length)
                  : S.projectCountWithTally(projects.length, done, total),
              style: theme.textTheme.bodySmall,
            ),
            Icon(Icons.chevron_right,
                size: 16, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({required this.summary});

  final ProjectSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(nowProvider)();
    final staleDays =
        ref.watch(settingsProvider).value?.staleDays ?? defaultStaleDays;
    final actions =
        ref.watch(projectActionsProvider(summary.project.id)).value ?? const [];
    final p = summary.project;

    final tally = CompletionTally(
      doneCount: summary.doneCount,
      countedTotal: summary.countedTotal,
    );
    final stale = isProjectStale(
      status: p.status,
      lastActivityAt: summary.lastActivityAt,
      createdAt: p.createdAt,
      now: now,
      staleDays: staleDays,
    );
    final idle = idleDays(
      lastActivityAt: summary.lastActivityAt,
      createdAt: p.createdAt,
      now: now,
    );

    final open = actions.where((a) => a.status.isOpen).toList();
    final highOpen = open.where((a) => a.priority == Priority.high).length;
    final overdue = open
        .where(
          (a) => a.dueDate != null && isOverdue(dueDate: a.dueDate!, now: now),
        )
        .length;

    return SectionCard(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProjectDetailScreen(projectId: p.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: PriorityChip(p.priority),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Thanh tiến độ đọc nhanh hơn con số, nhưng con số vẫn phải có.
          ProgressRow(
            ratio: tally.isEmpty
                ? null
                : tally.doneCount / tally.countedTotal,
            label: tally.isEmpty
                ? VnFormat.emptyValue
                : '${tally.doneCount}/${tally.countedTotal}',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip.project(p.status),
              if (overdue > 0)
                _Badge(
                  label: S.overdueCount(overdue),
                  color: theme.colorScheme.error,
                  icon: Icons.error_outline,
                ),
              if (highOpen > 0)
                _Badge(
                  label: S.highPriorityOpen(highOpen),
                  color: const Color(0xFFC62828),
                  icon: Icons.keyboard_double_arrow_up,
                ),
              Text(
                VnFormat.daysAgo(idle),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: stale
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline,
                  fontWeight: stale ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});

  final ProjectFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(projectFilterProvider.notifier);
    final areas = ref.watch(areasProvider).value ?? const <Area>[];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          PopupMenuButton<ProjectSort>(
            initialValue: filter.sort,
            onSelected: controller.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: ProjectSort.priority,
                child: Text(S.sortPriority),
              ),
              PopupMenuItem(
                value: ProjectSort.lastActivity,
                child: Text(S.sortLastActivity),
              ),
              PopupMenuItem(value: ProjectSort.name, child: Text(S.sortName)),
              PopupMenuItem(
                value: ProjectSort.dueDate,
                child: Text(S.sortDueDate),
              ),
            ],
            child: Chip(
              avatar: const Icon(Icons.sort, size: 16),
              label: Text('${S.projectSort}: ${_sortLabel(filter.sort)}'),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text(S.projectShowClosed),
            selected: filter.includeClosed,
            onSelected: (_) => controller.toggleIncludeClosed(),
          ),
          for (final t in areas) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(t.name),
              selected: filter.areaIds.contains(t.id),
              onSelected: (_) => controller.toggleArea(t.id),
            ),
          ],
        ],
      ),
    );
  }

  static String _sortLabel(ProjectSort s) => switch (s) {
    ProjectSort.priority => S.sortPriority,
    ProjectSort.lastActivity => S.sortLastActivity,
    ProjectSort.name => S.sortName,
    ProjectSort.dueDate => S.sortDueDate,
  };
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.folder_open_outlined,
        title: S.projectEmptyList,
        message: S.projectEmptyHint,
      );
}
