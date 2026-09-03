import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/project_action.dart';
import '../../domain/rules/stats.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/layout.dart';

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

    if (actions.isEmpty) {
      return const EmptyState(
        icon: Icons.insert_chart_outlined,
        title: S.statsEmpty,
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg,
              AppSpacing.gutter, AppSpacing.xs),
          // `IntrinsicHeight` để hai thẻ cao bằng nhau dù một thẻ có dòng chú
          // thích: `CrossAxisAlignment.stretch` trong Row nằm trong ListView
          // sẽ kéo chiều cao ra vô hạn và làm hỏng cả màn hình.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _BigNumber(
                    label: S.statsCompletionRatio,
                    value: VnFormat.percent(overall.completionRatio,
                        fractionDigits: 0),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _BigNumber(
                    label: S.statsOnTimeRatio,
                    value: VnFormat.percent(overall.onTimeRatio,
                        fractionDigits: 0),
                    hint: overall.finishedWithDueDate == 0
                        ? S.statsOutcomeNoDueDate
                        : S.finishedWithDueDate(overall.finishedWithDueDate),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionHeader(title: S.statsByOutcome),
        SectionCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          child: _OutcomeBars(stats: overall),
        ),
        const SectionHeader(title: S.statsByArea),
        GroupedCard(
          dividerIndent: 48,
          children: [
            for (final entry in byArea.entries)
              _AreaRow(
                name: entry.key,
                colorValue: areaColor[entry.key] ?? 0xFF90A4AE,
                stats: computeStats(entry.value, now),
              ),
          ],
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
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.9)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.displaySmall),
          if (hint != null)
            Text(hint!, style: theme.textTheme.bodySmall, maxLines: 2),
        ],
      ),
    );
  }
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
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 132,
                    child: Text(_label(o), style: theme.textTheme.bodySmall),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0 : stats[o] / max,
                        minHeight: 10,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
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
