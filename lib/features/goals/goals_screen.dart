import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/goal.dart';
import '../../domain/rules/progress.dart';
import '../../presentation/providers/providers.dart';
import 'goal_detail_screen.dart';
import 'goal_edit_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(
                child: Text(S.goalEmptyList,
                    style: Theme.of(context).textTheme.bodyLarge))
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) => _GoalRow(goal: list[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showGoalEditSheet(context),
        icon: const Icon(Icons.add),
        label: const Text(S.goalNew),
      ),
    );
  }
}

class _GoalRow extends ConsumerWidget {
  const _GoalRow({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(nowProvider)();
    final updates = ref.watch(goalUpdatesProvider(goal.id)).value ?? const [];
    final linked =
        ref.watch(goalLinkedProjectIdsProvider(goal.id)).value ?? const [];

    final ratio = progressRatio(goal, updates, now);
    final current = currentValue(updates, now);

    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => GoalDetailScreen(goalId: goal.id)),
      ),
      title: Text(goal.name, style: theme.textTheme.titleMedium),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.isNumeric) ...[
              Text(
                '${current == null ? VnFormat.emptyValue : VnFormat.scaled(current, goal.unit)}'
                ' / ${goal.target == null ? VnFormat.emptyValue : VnFormat.scaled(goal.target!, goal.unit)}'
                ' · ${VnFormat.percent(ratio)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio == null
                      ? 0
                      : ratio.toDouble().clamp(0.0, 1.0),
                  minHeight: 6,
                ),
              ),
            ] else
              Text(S.goalQualitative, style: theme.textTheme.bodySmall),
            if (linked.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  S.goalNoProjects,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
