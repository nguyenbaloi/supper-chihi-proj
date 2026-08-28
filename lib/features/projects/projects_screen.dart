import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/topic.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/completion.dart';
import '../../domain/rules/day.dart';
import '../../domain/rules/stale.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/chips.dart';
import 'project_detail_screen.dart';
import 'project_edit_sheet.dart';

/// Danh sách Dự án **nhóm theo Chủ đề** — FR-45.
///
/// Trước đây đây là một danh sách phẳng, và với bảy dự án trải trên bốn chủ đề
/// thì không nhìn ra được mảng nào đang nặng, mảng nào đang bỏ trống. Nhóm theo
/// Chủ đề trả lại đúng cách người dùng đã tự tổ chức trong hai file gốc.
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(projectSummariesProvider);
    final filter = ref.watch(projectFilterProvider);
    final topics = ref.watch(topicsProvider).value ?? const <Topic>[];

    return Scaffold(
      body: Column(
        children: [
          _FilterBar(filter: filter),
          const Divider(height: 1),
          Expanded(
            child: summaries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => list.isEmpty
                  ? const _EmptyProjects()
                  : _GroupedList(summaries: list, topics: topics),
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
  const _GroupedList({required this.summaries, required this.topics});

  final List<ProjectSummary> summaries;
  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    final byTopic = <int, List<ProjectSummary>>{};
    for (final s in summaries) {
      byTopic.putIfAbsent(s.project.topicId, () => []).add(s);
    }
    // Giữ đúng thứ tự Chủ đề người dùng đã đặt; chủ đề rỗng thì không hiện.
    final ordered = topics.where((t) => byTopic.containsKey(t.id)).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        for (final topic in ordered) ...[
          _TopicHeader(topic: topic, projects: byTopic[topic.id]!),
          for (final s in byTopic[topic.id]!) _ProjectCard(summary: s),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TopicHeader extends StatelessWidget {
  const _TopicHeader({required this.topic, required this.projects});

  final Topic topic;
  final List<ProjectSummary> projects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(topic.colorValue);
    final done = projects.fold<int>(0, (n, s) => n + s.doneCount);
    final total = projects.fold<int>(0, (n, s) => n + s.countedTotal);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              topic.name,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700, color: color),
            ),
          ),
          Text(
            total == 0
                ? S.projectCount(projects.length)
                : S.projectCountWithTally(projects.length, done, total),
            style: theme.textTheme.bodySmall,
          ),
        ],
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
    final highOpen =
        open.where((a) => a.priority == Priority.high).length;
    final overdue = open
        .where((a) => a.dueDate != null && isOverdue(dueDate: a.dueDate!, now: now))
        .length;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProjectDetailScreen(projectId: p.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(p.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  PriorityChip(p.priority),
                ],
              ),
              const SizedBox(height: 8),
              // Thanh tiến độ đọc nhanh hơn con số, nhưng con số vẫn phải có.
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: tally.isEmpty
                            ? 0
                            : tally.doneCount / tally.countedTotal,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tally.isEmpty
                        ? VnFormat.emptyValue
                        : '${tally.doneCount}/${tally.countedTotal}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
        ),
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
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w600)),
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
    final topics = ref.watch(topicsProvider).value ?? const <Topic>[];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          PopupMenuButton<ProjectSort>(
            initialValue: filter.sort,
            onSelected: controller.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: ProjectSort.priority, child: Text(S.sortPriority)),
              PopupMenuItem(
                  value: ProjectSort.lastActivity, child: Text(S.sortLastActivity)),
              PopupMenuItem(value: ProjectSort.name, child: Text(S.sortName)),
              PopupMenuItem(value: ProjectSort.dueDate, child: Text(S.sortDueDate)),
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
          for (final t in topics) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(t.name),
              selected: filter.topicIds.contains(t.id),
              onSelected: (_) => controller.toggleTopic(t.id),
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
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            S.projectEmptyList,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
}
