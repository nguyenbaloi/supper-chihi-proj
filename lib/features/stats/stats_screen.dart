import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/project_action.dart';
import '../../domain/rules/stats.dart';
import '../../presentation/providers/providers.dart';

/// Thống kê đầu việc theo hạn — FR-44.
///
/// Trục phân loại là **quan hệ giữa lúc xong và hạn đã đặt**, không phải
/// `Xong`/`Chưa`. Câu hỏi cần trả lời là *"việc đến hạn thì mình có làm xong
/// không, hay để trôi?"*.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider)();
    final actions = ref.watch(allActionsProvider).value ?? const [];
    final summaries = ref.watch(allProjectSummariesProvider).value ?? const [];
    final theme = Theme.of(context);

    if (actions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(S.statsEmpty,
              style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
        ),
      );
    }

    final overall = computeStats(actions, now);
    final byProject = {for (final s in summaries) s.project.id: s};

    // Gom theo Lĩnh vực: đây là cách người dùng nghĩ về đời sống dự án của mình.
    final byArea = <String, List<ProjectAction>>{};
    final areaColor = <String, int>{};
    for (final a in actions) {
      final s = byProject[a.projectId];
      if (s == null) continue;
      byArea.putIfAbsent(s.area.name, () => []).add(a);
      areaColor[s.area.name] = s.area.colorValue;
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _BigNumber(
                  label: S.statsCompletionRatio,
                  value: VnFormat.percent(overall.completionRatio, fractionDigits: 0),
                ),
              ),
              Expanded(
                child: _BigNumber(
                  label: S.statsOnTimeRatio,
                  value: VnFormat.percent(overall.onTimeRatio, fractionDigits: 0),
                  hint: overall.finishedWithDueDate == 0
                      ? S.statsOutcomeNoDueDate
                      : S.finishedWithDueDate(overall.finishedWithDueDate),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 8),
        _Section(title: S.statsByOutcome),
        _OutcomeBars(stats: overall),
        const Divider(height: 24),
        _Section(title: S.statsByArea),
        for (final entry in byArea.entries)
          _AreaRow(
            name: entry.key,
            colorValue: areaColor[entry.key] ?? 0xFF90A4AE,
            stats: computeStats(entry.value, now),
          ),
      ],
    );
  }
}

class _BigNumber extends StatelessWidget {
  const _BigNumber({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(value, style: theme.textTheme.headlineMedium),
        if (hint != null)
          Text(hint!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

/// Thanh ngang cho từng loại kết quả. Mỗi loại luôn kèm **nhãn chữ và con số**,
/// không chỉ phân biệt bằng màu — NFR-7.
class _OutcomeBars extends StatelessWidget {
  const _OutcomeBars({required this.stats});

  final ActionStats stats;

  static const _order = [
    DueOutcome.onTime,
    DueOutcome.late,
    DueOutcome.overdue,
    DueOutcome.pending,
    DueOutcome.noDueDate,
    DueOutcome.dropped,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = _order.map((o) => stats[o]).fold<int>(0, (a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final o in _order)
          if (stats[o] > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(_label(o), style: theme.textTheme.bodySmall),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0 : stats[o] / max,
                        minHeight: 12,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(_color(theme, o)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    child: Text('${stats[o]}',
                        textAlign: TextAlign.end, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  static String _label(DueOutcome o) => switch (o) {
        DueOutcome.onTime => S.statsOutcomeOnTime,
        DueOutcome.late => S.statsOutcomeLate,
        DueOutcome.overdue => S.statsOutcomeOverdue,
        DueOutcome.pending => S.statsOutcomePending,
        DueOutcome.noDueDate => S.statsOutcomeNoDueDate,
        DueOutcome.dropped => S.statsOutcomeDropped,
      };

  static Color _color(ThemeData theme, DueOutcome o) => switch (o) {
        DueOutcome.onTime => const Color(0xFF2E7D32),
        DueOutcome.late => const Color(0xFFEF6C00),
        DueOutcome.overdue => theme.colorScheme.error,
        DueOutcome.pending => const Color(0xFF1565C0),
        DueOutcome.noDueDate => const Color(0xFF90A4AE),
        DueOutcome.dropped => const Color(0xFF757575),
      };
}

class _AreaRow extends StatelessWidget {
  const _AreaRow({
    required this.name,
    required this.colorValue,
    required this.stats,
  });

  final String name;
  final int colorValue;
  final ActionStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = stats[DueOutcome.onTime] +
        stats[DueOutcome.late] +
        stats.doneWithoutDueDate;
    final counted = stats.total - stats[DueOutcome.dropped];

    return ListTile(
      dense: true,
      leading: CircleAvatar(radius: 8, backgroundColor: Color(colorValue)),
      title: Text(name),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: counted == 0 ? 0 : done / counted,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(Color(colorValue)),
          ),
        ),
      ),
      trailing: Text(
        counted == 0
            ? VnFormat.emptyValue
            : '$done/$counted · ${VnFormat.percent(stats.completionRatio, fractionDigits: 0)}',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
