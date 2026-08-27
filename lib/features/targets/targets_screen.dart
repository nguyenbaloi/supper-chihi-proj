import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/action_note.dart';
import '../../domain/rules/allocation.dart';
import '../../domain/rules/rebalancing.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/confirm_dialog.dart';
import '../../presentation/widgets/money_text.dart';
import 'allocation_plan_card.dart';
import 'target_editor.dart';

/// Màn hình Mục tiêu — biến những dòng ghi chú định tính cuối sheet Excel
/// thành con số cụ thể để hành động. Xem FR-19 tới FR-21, FR-36, FR-37.
class TargetsScreen extends ConsumerWidget {
  const TargetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final valuation = ref.watch(portfolioValuationProvider).value;
    final settings = ref.watch(settingsProvider).value;
    final notes = ref.watch(actionNotesProvider).value ?? const <ActionNote>[];

    if (valuation == null) {
      return Scaffold(
        appBar: AppBar(
        title: Text(l10n.targets),
        actions: [
          IconButton(
            tooltip: l10n.targetWeight,
            icon: const Icon(Icons.tune),
            onPressed: () => showTargetEditor(context, ref),
          ),
        ],
      ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Một nguồn duy nhất cho cả thẻ Khoảng lệch lẫn Kế hoạch phân bổ: hai
    // phần nằm cạnh nhau trên cùng màn hình, lệch nhau một danh mục là người
    // dùng hết tin cả hai.
    final units = ref.watch(targetUnitsProvider);
    final drifts = _driftsOf(units, valuation.totalAssets);
    final totalBp = Rebalancing.totalTargetBp(
      units.map((u) => u.targetWeightBp),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.targets),
        actions: [
          IconButton(
            tooltip: l10n.targetWeight,
            icon: const Icon(Icons.tune),
            onPressed: () => showTargetEditor(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (drifts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    l10n.targetNoneSet,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => showTargetEditor(context, ref),
                    icon: const Icon(Icons.tune),
                    label: Text(l10n.targetWeight),
                  ),
                ],
              ),
            )
          else ...[
            if (totalBp != 10000)
              // Cảnh báo nhưng vẫn cho lưu — người dùng có thể đang đặt mục
              // tiêu dở dang. Xem FR-19.
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.targetSumWarning(
                      VnFormat.percent(
                        (Decimal.fromInt(totalBp) / Decimal.fromInt(10000))
                            .toDecimal(scaleOnInfinitePrecision: 6),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            const AllocationPlanCard(),
            for (final drift in drifts)
              _DriftCard(
                drift: drift,
                thresholdBp: settings?.driftThresholdBp ?? 500,
              ),
            TextButton.icon(
              onPressed: () => showTargetEditor(context, ref),
              icon: const Icon(Icons.tune),
              label: Text(l10n.targetWeight),
            ),
            const SizedBox(height: 16),
            _TargetBarChart(drifts: drifts),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.actionNotes, style: theme.textTheme.titleMedium),
              TextButton.icon(
                onPressed: () => _addNote(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l10n.addActionNote),
              ),
            ],
          ),
          if (notes.isEmpty)
            Text(
              l10n.actionNoteEmpty,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          else ...[
            // Ghi chú chưa hoàn thành nằm ngay dưới phần khoảng lệch. Xem
            // FR-37.
            for (final note in notes.where((n) => !n.isCompleted))
              _NoteTile(note: note),
            if (notes.any((n) => n.isCompleted)) ...[
              const SizedBox(height: 12),
              Text(
                l10n.actionNoteCompleted,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              for (final note in notes.where((n) => n.isCompleted))
                _NoteTile(note: note),
            ],
          ],
        ],
      ),
    );
  }

  /// Khoảng lệch cho từng Lớp tài sản **hoặc Nhóm mục tiêu** có Tỷ trọng mục
  /// tiêu. Xem FR-20.
  static List<TargetDrift> _driftsOf(
    List<AllocationTarget> units,
    Money totalAssets,
  ) =>
      units
          .map(
            (unit) => TargetDrift(
              label: unit.label,
              currentValue: unit.currentValue,
              actualWeight: unit.currentValue.ratioTo(totalAssets),
              targetWeightBp: unit.targetWeightBp,
              totalAssets: totalAssets,
            ),
          )
          .toList(growable: false);

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final controller = TextEditingController();
    final body = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addActionNote),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.actionNotes),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    if (body == null || body.trim().isEmpty) return;
    await ref.read(actionNoteRepositoryProvider).add(body);
  }
}

class _DriftCard extends StatelessWidget {
  final TargetDrift drift;
  final int thresholdBp;

  const _DriftCard({required this.drift, required this.thresholdBp});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final exceeds = drift.exceedsThreshold(thresholdBp);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(drift.label, style: theme.textTheme.titleMedium),
                ),
                if (exceeds)
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Metric(
                  label: l10n.actualWeight,
                  value: drift.actualWeight == null
                      ? '—'
                      : VnFormat.percent(drift.actualWeight!),
                ),
                _Metric(
                  label: l10n.targetWeight,
                  value: VnFormat.percent(drift.targetWeight),
                ),
                _Metric(
                  label: l10n.targetDrift,
                  value: drift.weightDrift == null
                      ? '—'
                      : VnFormat.percent(drift.weightDrift!),
                  // Thừa tô như lỗ, thiếu tô như lãi: cả hai đều là việc cần
                  // làm, và dấu cho biết phải mua thêm hay bán bớt.
                  color: drift.weightDrift == null
                      ? null
                      : context.colorForAmount(-drift.weightDrift!.sign),
                ),
              ],
            ),
            if (drift.amountDrift != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    drift.isOver ? l10n.targetOver : l10n.targetUnder,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  MoneyText(
                    drift.amountDrift!,
                    compact: true,
                    colorBySign: true,
                    showPlusSign: true,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Metric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Biểu đồ cột so sánh thực tế với mục tiêu. Xem FR-20.
class _TargetBarChart extends StatelessWidget {
  final List<TargetDrift> drifts;

  const _TargetBarChart({required this.drifts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (drifts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= drifts.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      drifts[index].label,
                      style: theme.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < drifts.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: _percent(drifts[i].actualWeight),
                    color: drifts[i].isOver
                        ? context.lossColor
                        : context.profitColor,
                    width: 12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  BarChartRodData(
                    toY: _percent(drifts[i].targetWeight),
                    color: theme.colorScheme.outlineVariant,
                    width: 12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Toạ độ vẽ — ngoại lệ duy nhất được dùng số thực. Xem AD-3.
  static double _percent(Object? weight) {
    if (weight == null) return 0;
    return double.parse(weight.toString()) * 100;
  }
}

class _NoteTile extends ConsumerWidget {
  final ActionNote note;

  const _NoteTile({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final repo = ref.read(actionNoteRepositoryProvider);

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmAction(
        context,
        title: l10n.actionNoteDeleteConfirm,
        confirmLabel: l10n.actionDelete,
      ),
      onDismissed: (_) => repo.remove(note.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.errorContainer,
        child: const Icon(Icons.delete_outline),
      ),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: note.isCompleted,
        onChanged: (checked) =>
            repo.setCompleted(note.id, completed: checked ?? false),
        title: Text(
          note.body,
          style: note.isCompleted
              ? theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
