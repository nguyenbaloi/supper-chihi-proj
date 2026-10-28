import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app_core/mini_app_core.dart';

import '../../core/format/vn_date.dart';
import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/snapshot.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/confirm_dialog.dart';
import '../../presentation/widgets/empty_state.dart';
import '../../presentation/widgets/money_text.dart';
import 'snapshot_detail_screen.dart';

/// Khoảng thời gian vẽ biểu đồ. Xem FR-30.
enum HistoryRange { oneMonth, threeMonths, sixMonths, oneYear, all }

extension on HistoryRange {
  Duration? get span => switch (this) {
        HistoryRange.oneMonth => const Duration(days: 30),
        HistoryRange.threeMonths => const Duration(days: 91),
        HistoryRange.sixMonths => const Duration(days: 182),
        HistoryRange.oneYear => const Duration(days: 365),
        HistoryRange.all => null,
      };

  String label(AppL10n l10n) => switch (this) {
        HistoryRange.oneMonth => l10n.rangeOneMonth,
        HistoryRange.threeMonths => l10n.rangeThreeMonths,
        HistoryRange.sixMonths => l10n.rangeSixMonths,
        HistoryRange.oneYear => l10n.rangeOneYear,
        HistoryRange.all => l10n.rangeAll,
      };
}

/// Màn hình Lịch sử — giải quyết khoảng đứt bốn tháng trong Excel gốc.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryRange _range = HistoryRange.threeMonths;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final seriesAsync = ref.watch(snapshotSeriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: MiniAppScope.exitButtonOf(context),
        title: Text(l10n.history),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _captureManual,
        icon: const Icon(Icons.bookmark_add_outlined),
        label: Text(l10n.captureSnapshot),
      ),
      body: seriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.errorGeneric,
          body: '$error',
        ),
        data: (series) {
          // Chưa đủ dữ liệu thì giải thích, không vẽ một biểu đồ trống.
          // Xem FR-30.
          if (series.length < 2) {
            return EmptyState(
              icon: Icons.show_chart,
              title: l10n.history,
              body: l10n.snapshotNotEnoughData,
            );
          }

          final visible = _within(series, _range);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              SegmentedButton<HistoryRange>(
                showSelectedIcon: false,
                segments: [
                  for (final range in HistoryRange.values)
                    ButtonSegment(
                      value: range,
                      label: Text(range.label(l10n)),
                    ),
                ],
                selected: {_range},
                onSelectionChanged: (s) => setState(() => _range = s.first),
              ),
              const SizedBox(height: 20),
              Text(l10n.chartTotalAssets,
                  style: Theme.of(context).textTheme.titleSmall),
              _LineChart(
                points: visible,
                valueOf: (p) => p.totalAssets,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(l10n.chartProfitLoss,
                  style: Theme.of(context).textTheme.titleSmall),
              _LineChart(
                points: visible,
                valueOf: (p) => p.profitLoss,
                color: context.profitColor,
              ),
              const SizedBox(height: 24),
              for (final point in visible.reversed)
                _SnapshotTile(point: point),
            ],
          );
        },
      ),
    );
  }

  static List<SnapshotPoint> _within(
    List<SnapshotPoint> series,
    HistoryRange range,
  ) {
    final span = range.span;
    if (span == null) return series;
    final cutoff = DateTime.now().toUtc().subtract(span);
    final filtered =
        series.where((p) => !p.date.isBefore(cutoff)).toList(growable: false);
    // Dưới hai điểm thì vẽ ra một đường thẳng vô nghĩa — giữ lại toàn bộ.
    return filtered.length >= 2 ? filtered : series;
  }

  Future<void> _captureManual() async {
    final l10n = AppL10n.of(context);
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.captureSnapshot),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.snapshotNote),
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
    if (note == null) return;
    await ref.read(snapshotRepositoryProvider).captureManual(
          DateTime.now().toUtc(),
          note: note,
        );
    ref.invalidate(snapshotSeriesProvider);
  }
}

class _LineChart extends StatelessWidget {
  final List<SnapshotPoint> points;
  final Money Function(SnapshotPoint) valueOf;
  final Color color;

  const _LineChart({
    required this.points,
    required this.valueOf,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: points.length <= 1
                    ? 1
                    : (points.length / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    VnDate.short(points[index].date),
                    style: theme.textTheme.labelSmall,
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final point = points[spot.spotIndex];
                return LineTooltipItem(
                  '${VnDate.full(point.date)}\n'
                  '${VnFormat.moneyCompact(valueOf(point))}',
                  theme.textTheme.bodySmall ?? const TextStyle(),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              // Nối thẳng giữa hai bản chốt liền kề, không tạo điểm giả cho
              // những ngày người dùng không mở ứng dụng. Xem FR-30.
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), _toChartY(valueOf(points[i]))),
              ],
              isCurved: false,
              color: color,
              barWidth: 2,
              dotData: FlDotData(show: points.length <= 30),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toạ độ vẽ, đơn vị triệu đồng cho gọn trục. Ngoại lệ duy nhất được dùng
  /// số thực. Xem AD-3.
  static double _toChartY(Money amount) => amount.amount / 1000000;
}

class _SnapshotTile extends ConsumerWidget {
  final SnapshotPoint point;

  const _SnapshotTile({required this.point});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final snapshot = point.snapshot;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SnapshotDetailScreen(point: point),
          ),
        ),
        leading: Icon(
          snapshot.isAutomatic ? Icons.schedule : Icons.bookmark,
          color: theme.colorScheme.primary,
        ),
        title: Text(VnDate.full(snapshot.date)),
        subtitle: Text(
          snapshot.note ??
              (snapshot.isAutomatic ? l10n.snapshotAuto : l10n.snapshotManual),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MoneyText(
              snapshot.totalAssetsAmount,
              compact: true,
              style: theme.textTheme.titleMedium,
            ),
            MoneyText(
              point.profitLoss,
              compact: true,
              colorBySign: true,
              showPlusSign: true,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        onLongPress: snapshot.isAutomatic
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.snapshotAutoCannotDelete)),
                )
            : () => _delete(context, ref, snapshot),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Snapshot snapshot,
  ) async {
    final l10n = AppL10n.of(context);
    final confirmed = await confirmAction(
      context,
      title: l10n.snapshotDeleteConfirm,
      confirmLabel: l10n.actionDelete,
    );
    if (!confirmed) return;
    await ref.read(snapshotRepositoryProvider).removeManual(snapshot.id);
    ref.invalidate(snapshotSeriesProvider);
  }
}
