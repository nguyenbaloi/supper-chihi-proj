import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/completion.dart';
import '../../domain/rules/stale.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/chips.dart';
import 'project_detail_screen.dart';
import 'project_edit_sheet.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(projectSummariesProvider);
    final filter = ref.watch(projectFilterProvider);
    final topics = ref.watch(topicsProvider).value ?? const [];

    return Scaffold(
      body: Column(
        children: [
          _FilterBar(filter: filter, topics: topics),
          const Divider(height: 1),
          Expanded(
            child: summaries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => list.isEmpty
                  ? const _EmptyProjects()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) => _ProjectRow(summary: list[i]),
                    ),
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

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter, required this.topics});

  final ProjectFilter filter;
  final List<dynamic> topics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(projectFilterProvider.notifier);
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
              label: Text(t.name as String),
              selected: filter.topicIds.contains(t.id as int),
              onSelected: (_) => controller.toggleTopic(t.id as int),
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

class _ProjectRow extends ConsumerWidget {
  const _ProjectRow({required this.summary});

  final ProjectSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(nowProvider)();
    final staleDays =
        ref.watch(settingsProvider).value?.staleDays ?? defaultStaleDays;
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

    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProjectDetailScreen(projectId: p.id),
        ),
      ),
      title: Text(p.name, style: theme.textTheme.titleMedium),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TopicChip(name: summary.topic.name, colorValue: summary.topic.colorValue),
            StatusChip.project(p.status),
            PriorityChip(p.priority),
            Text(
              // FR-12: Dự án chưa có Hành động hiện `—`, không hiện `0%`.
              tally.isEmpty
                  ? VnFormat.emptyValue
                  : '${summary.doneCount}/${summary.countedTotal} · ${VnFormat.percent(tally.ratio, fractionDigits: 0)}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              VnFormat.daysAgo(idle),
              style: theme.textTheme.bodySmall?.copyWith(
                color: stale ? theme.colorScheme.error : theme.colorScheme.outline,
                fontWeight: stale ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
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
