import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../core/money/scaled_value.dart';
import '../../domain/models/goal.dart';
import '../../domain/rules/pace.dart';
import '../../domain/rules/progress.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/chips.dart';
import '../projects/project_detail_screen.dart';
import 'goal_edit_sheet.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(goalProvider(goalId)).value;
    if (goal == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final now = ref.watch(nowProvider)();
    final updates = ref.watch(goalUpdatesProvider(goalId)).value ?? const [];
    final linkedIds =
        ref.watch(goalLinkedProjectIdsProvider(goalId)).value ?? const [];
    final allProjects =
        ref.watch(allProjectSummariesProvider).value ?? const [];
    final theme = Theme.of(context);

    final ratio = progressRatio(goal, updates, now);
    final current = currentValue(updates, now);
    final pace = computePace(goal: goal, updates: updates, now: now);

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showGoalEditSheet(context, existing: goal),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(goalRepositoryProvider).delete(goalId);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          if (goal.isNumeric) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    VnFormat.percent(ratio),
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${current == null ? VnFormat.emptyValue : VnFormat.scaled(current, goal.unit)}'
                    ' / ${goal.target == null ? VnFormat.emptyValue : VnFormat.scaled(goal.target!, goal.unit)}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio == null ? 0 : ratio.toDouble().clamp(0.0, 1.0),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            _PaceCard(goal: goal, pace: pace),
            _ProgressChart(goal: goal, updates: updates),
          ] else
            const ListTile(
              leading: Icon(Icons.flag_outlined),
              title: Text(S.goalQualitative),
            ),

          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(S.projectLinkedGoals, style: theme.textTheme.titleMedium),
          ),
          if (linkedIds.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(S.goalNoProjects,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error)),
            ),
          for (final s in allProjects.where((s) => linkedIds.contains(s.project.id)))
            ListTile(
              title: Text(s.project.name),
              subtitle: Wrap(
                spacing: 6,
                children: [
                  StatusChip.project(s.project.status),
                  Text(
                    s.countedTotal == 0
                        ? VnFormat.emptyValue
                        : '${s.doneCount}/${s.countedTotal}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.link_off),
                onPressed: () => ref
                    .read(goalRepositoryProvider)
                    .unlinkProject(s.project.id, goalId),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProjectDetailScreen(projectId: s.project.id),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_link),
              label: const Text(S.add),
              onPressed: () => _pickProject(context, ref, linkedIds),
            ),
          ),

          if (goal.isNumeric) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(S.goalMarks, style: theme.textTheme.titleMedium),
            ),
            if (updates.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(S.goalNoMarks, style: theme.textTheme.bodySmall),
              ),
            for (final u in updates.reversed)
              ListTile(
                dense: true,
                leading: const Icon(Icons.flag_circle_outlined),
                title: Text(VnFormat.scaled(u.value, goal.unit)),
                subtitle: Text(
                  u.note.isEmpty
                      ? VnFormat.date(u.date)
                      : '${VnFormat.date(u.date)} · ${u.note}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      ref.read(goalRepositoryProvider).deleteMark(u.id),
                ),
                onTap: () => _editMark(context, ref, goal, existing: u),
              ),
          ],
        ],
      ),
      floatingActionButton: goal.isNumeric
          ? FloatingActionButton.extended(
              onPressed: () => _editMark(context, ref, goal),
              icon: const Icon(Icons.add),
              label: const Text(S.goalMarkNew),
            )
          : null,
    );
  }

  Future<void> _pickProject(
      BuildContext context, WidgetRef ref, List<int> linkedIds) async {
    final all = ref.read(allProjectSummariesProvider).value ?? const [];
    final candidates =
        all.where((s) => !linkedIds.contains(s.project.id)).toList();
    if (candidates.isEmpty) return;

    final chosen = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      builder: (ctx) => ListView(
        children: [
          for (final s in candidates)
            ListTile(
              title: Text(s.project.name),
              onTap: () => Navigator.of(ctx).pop(s.project.id),
            ),
        ],
      ),
    );
    if (chosen != null) {
      await ref.read(goalRepositoryProvider).linkProject(chosen, goalId);
    }
  }

  Future<void> _editMark(BuildContext context, WidgetRef ref, Goal goal,
      {GoalUpdate? existing}) async {
    final value = TextEditingController(
      text: existing == null
          ? ''
          : VnFormat.groupDigits(existing.valueRaw.toString()),
    );
    final note = TextEditingController(text: existing?.note ?? '');
    var date = existing?.date ?? DateTime.now();
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? S.goalMarkNew : S.edit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: value,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: S.goalMarkValue, errorText: error),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(S.goalMarkDate),
                subtitle: Text(VnFormat.date(date)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: date,
                    firstDate: DateTime(date.year - 10),
                    lastDate: DateTime(date.year + 10),
                  );
                  if (picked != null) setState(() => date = picked);
                },
              ),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: S.goalMarkNote),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(S.cancel)),
            FilledButton(
              onPressed: () {
                if (ScaledValue.tryParse(value.text, goal.decimals) == null) {
                  setState(() => error = S.goalTargetRequired);
                  return;
                }
                Navigator.of(ctx).pop(true);
              },
              child: const Text(S.save),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final parsed = ScaledValue.tryParse(value.text, goal.decimals)!;
    final repo = ref.read(goalRepositoryProvider);
    if (existing == null) {
      await repo.addUpdate(
        goalId: goal.id,
        date: date,
        valueRaw: parsed.raw,
        note: note.text.trim(),
      );
    } else {
      await repo.updateMark(existing.copyWith(
        date: date,
        valueRaw: parsed.raw,
        note: note.text.trim(),
      ));
    }
  }
}

/// FR-24: không có hạn chót thì chỉ nói rõ là chưa tính được — tuyệt đối
/// không suy đoán nhịp.
class _PaceCard extends StatelessWidget {
  const _PaceCard({required this.goal, required this.pace});

  final Goal goal;
  final PaceReport pace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (goal.dueDate == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Text(S.goalNoDueDateHint,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline)),
      );
    }
    if (pace.verdict == PaceVerdict.unknown) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Text(S.goalNeedTwoMarks, style: theme.textTheme.bodySmall),
      );
    }

    final rows = <(String, String)>[
      if (pace.remaining != null)
        (S.goalRemaining, VnFormat.scaled(pace.remaining!, goal.unit)),
      if (pace.daysRemaining != null)
        (S.goalDaysLeft, S.goalDaysLeftValue(pace.daysRemaining!)),
      if (pace.requiredPerMonth != null)
        (S.goalRequiredPerMonth,
            VnFormat.scaled(pace.requiredPerMonth!, goal.unit)),
      if (pace.actualPerMonth != null)
        (S.goalActualPerMonth, VnFormat.scaled(pace.actualPerMonth!, goal.unit)),
    ];

    final verdictText = switch (pace.verdict) {
      PaceVerdict.reached => S.goalReached,
      PaceVerdict.pastDue => S.goalPastDue,
      PaceVerdict.goingBackwards => S.goalGoingBackwards,
      _ => switch (pace.forecastMonthsDelta) {
          null => '',
          0 => S.goalForecastOnTime,
          final d when d > 0 => S.goalForecastLate(d),
          final d => S.goalForecastEarly(-d),
        },
    };

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall),
                    Text(value, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            if (verdictText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                verdictText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: switch (pace.verdict) {
                    PaceVerdict.onTrack || PaceVerdict.reached =>
                      theme.colorScheme.primary,
                    _ => theme.colorScheme.error,
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// FR-23. `double` chỉ xuất hiện ở đây — toạ độ vẽ, đúng ngoại lệ của AD-4.
class _ProgressChart extends StatelessWidget {
  const _ProgressChart({required this.goal, required this.updates});

  final Goal goal;
  final List<GoalUpdate> updates;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (updates.length < 2) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(S.goalNeedTwoMarks, style: theme.textTheme.bodySmall),
      );
    }

    final sorted = [...updates]..sort((a, b) => a.date.compareTo(b.date));
    final spots = [
      for (final u in sorted)
        FlSpot(u.date.millisecondsSinceEpoch.toDouble(), u.valueRaw.toDouble()),
    ];
    final target = goal.targetRaw?.toDouble();

    final idealSpots = <FlSpot>[];
    if (goal.dueDate != null && target != null) {
      idealSpots.addAll([
        spots.first,
        FlSpot(goal.dueDate!.millisecondsSinceEpoch.toDouble(), target),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              topTitles: AxisTitles(),
              rightTitles: AxisTitles(),
              leftTitles: AxisTitles(),
              bottomTitles: AxisTitles(),
            ),
            extraLinesData: target == null
                ? const ExtraLinesData()
                : ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: target,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      dashArray: [6, 4],
                    ),
                  ]),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                barWidth: 3,
                color: theme.colorScheme.primary,
                dotData: const FlDotData(show: true),
              ),
              if (idealSpots.isNotEmpty)
                LineChartBarData(
                  spots: idealSpots,
                  isCurved: false,
                  barWidth: 1.5,
                  dashArray: [4, 4],
                  color: theme.colorScheme.outline,
                  dotData: const FlDotData(show: false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
