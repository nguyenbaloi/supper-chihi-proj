import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app_core/mini_app_core.dart';

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
        leading: MiniAppScope.exitButtonOf(context),
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

    // Một nguồn duy nhất cho cả ba phần của màn hình: Kế hoạch phân bổ, thẻ
    // Khoảng lệch và biểu đồ. Ba chỗ cùng nói về một con số mà lấy từ ba phép
    // tính khác nhau thì chỉ cần lệch một đồng do làm tròn là người dùng hết
    // tin cả ba.
    final plan = ref.watch(allocationPlanProvider);
    final totalBp = plan.totalTargetBp;

    return Scaffold(
      appBar: AppBar(
        leading: MiniAppScope.exitButtonOf(context),
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
          if (plan.lines.isEmpty)
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
            for (final line in plan.lines)
              _DriftCard(
                line: line,
                totalAssets: plan.totalAssets,
                thresholdBp: settings?.driftThresholdBp ?? 500,
              ),
            TextButton.icon(
              onPressed: () => showTargetEditor(context, ref),
              icon: const Icon(Icons.tune),
              label: Text(l10n.targetWeight),
            ),
            const SizedBox(height: 16),
            _TargetBarList(plan: plan),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(l10n.actionNotes, style: theme.textTheme.titleMedium),
              ),
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
  final AllocationLine line;
  final Money totalAssets;
  final int thresholdBp;

  const _DriftCard({
    required this.line,
    required this.totalAssets,
    required this.thresholdBp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    // Phần trăm suy ra tại chỗ từ đúng dòng của Kế hoạch phân bổ, không tính
    // song song một đường khác. Xem FR-20 và FR-21.
    final drift = driftOf(line, totalAssets);
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
                  child: Text(line.label, style: theme.textTheme.titleMedium),
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
                const SizedBox(width: 8),
                _Metric(
                  label: l10n.targetWeight,
                  value: VnFormat.percent(drift.targetWeight),
                ),
                const SizedBox(width: 8),
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
            if (totalAssets.isPositive) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(actionLabel(l10n, line), style: theme.textTheme.bodySmall),
                  if (line.action != AllocationAction.hold) ...[
                    const SizedBox(width: 8),
                    // Dấu và màu theo việc phải làm: cần mua là dương và xanh,
                    // cần bán là âm và đỏ. Cùng một quy ước với thẻ Phân bổ
                    // chuẩn ở đầu màn hình và với biểu đồ bên dưới.
                    MoneyText(
                      line.actionAmount,
                      compact: true,
                      colorBySign: true,
                      showPlusSign: true,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Một ô số liệu trong thẻ Khoảng lệch.
///
/// Tự co giãn và cắt bớt khi hết chỗ: ba ô này vừa khít trên máy 360dp với cỡ
/// chữ mặc định, nhưng người dùng tăng cỡ chữ hệ thống lên là tràn ngay.
class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Metric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Dựng Khoảng lệch từ một dòng Kế hoạch phân bổ.
TargetDrift driftOf(AllocationLine line, Money totalAssets) => TargetDrift(
      label: line.label,
      currentValue: line.currentValue,
      actualWeight: line.currentValue.ratioTo(totalAssets),
      targetWeightBp: line.targetWeightBp,
      totalAssets: totalAssets,
    );

/// Nhãn việc cần làm với một danh mục.
String actionLabel(AppL10n l10n, AllocationLine line) => switch (line.action) {
      AllocationAction.buy => l10n.allocationBuy,
      AllocationAction.sell => l10n.allocationSell,
      AllocationAction.hold => l10n.allocationHold,
    };

/// Biểu đồ thanh **nằm ngang** so sánh Tỷ trọng thực tế với chuẩn. Xem FR-20.
///
/// Nằm ngang chứ không phải cột dọc vì tên Lớp tài sản tiếng Việt dài — "Tiền
/// mặt & Tiết kiệm" nằm dưới cột dọc thì chồng lên tên bên cạnh và không đọc
/// nổi. Nằm ngang thì tên có cả chiều rộng dòng, và còn chỗ đặt luôn con số
/// chuẩn với số tiền lệch ngay cạnh thanh.
class _TargetBarList extends StatelessWidget {
  final AllocationPlan plan;

  const _TargetBarList({required this.plan});

  @override
  Widget build(BuildContext context) {
    if (!plan.hasBasis) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    // Thang chung cho mọi hàng. Mỗi hàng tự co giãn theo giá trị của nó thì
    // hai thanh dài bằng nhau lại mang hai ý nghĩa khác nhau — đó là lúc biểu
    // đồ nói dối.
    var scaleMax = Decimal.zero;
    for (final line in plan.lines) {
      final actual = line.currentValue.ratioTo(plan.totalAssets);
      if (actual != null && actual > scaleMax) scaleMax = actual;
      final target = weightOf(line.targetWeightBp);
      if (target > scaleMax) scaleMax = target;
    }
    if (scaleMax.sign <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.targetBarTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        for (final line in plan.lines)
          _TargetBar(
            line: line,
            totalAssets: plan.totalAssets,
            scaleMax: scaleMax,
          ),
      ],
    );
  }
}

/// Tỷ trọng mục tiêu dưới dạng tỷ lệ.
Decimal weightOf(int targetWeightBp) =>
    (Decimal.fromInt(targetWeightBp) / Decimal.fromInt(10000))
        .toDecimal(scaleOnInfinitePrecision: 10);

/// Một hàng: thanh thực tế, vạch đánh dấu mức chuẩn, và số tiền phải mua bán.
class _TargetBar extends StatelessWidget {
  final AllocationLine line;
  final Money totalAssets;
  final Decimal scaleMax;

  const _TargetBar({
    required this.line,
    required this.totalAssets,
    required this.scaleMax,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    final actual = line.currentValue.ratioTo(totalAssets);
    final target = weightOf(line.targetWeightBp);
    // Cùng quy ước với thẻ Phân bổ chuẩn: cần mua là xanh, cần bán là đỏ.
    final color = context.colorForAmount(line.actionAmount.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  line.label,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (line.action == AllocationAction.hold)
                Text(l10n.allocationHold, style: muted?.copyWith(color: color))
              else
                MoneyText(
                  line.actionAmount,
                  compact: true,
                  colorBySign: true,
                  showPlusSign: true,
                  style: theme.textTheme.titleSmall,
                ),
            ],
          ),
          const SizedBox(height: 6),
          _Bar(
            actualRatio: _ratio(actual),
            targetRatio: _ratio(target),
            color: color,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.targetBarActual(
                    actual == null ? '—' : VnFormat.percent(actual),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.targetBarStandard(
                    VnFormat.percent(target),
                    VnFormat.moneyCompact(line.targetAmount),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Vị trí trên thang, từ 0 tới 1.
  ///
  /// Toạ độ vẽ — ngoại lệ duy nhất được dùng số thực. Xem AD-3. Giá trị âm —
  /// lớp Cho vay đang nợ ròng — kẹp về 0 để thanh không vẽ ngược.
  double _ratio(Decimal? value) {
    if (value == null || value.sign <= 0) return 0;
    final ratio = (value / scaleMax).toDecimal(scaleOnInfinitePrecision: 6);
    return double.parse(ratio.toString()).clamp(0.0, 1.0);
  }
}

/// Thanh ngang: nền là thang đo, phần tô là thực tế, vạch đứng là mức chuẩn.
class _Bar extends StatelessWidget {
  final double actualRatio;
  final double targetRatio;
  final Color color;

  static const double _height = 18;
  static const double _trackHeight = 10;
  static const double _markerWidth = 3;

  const _Bar({
    required this.actualRatio,
    required this.targetRatio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const radius = BorderRadius.all(Radius.circular(_trackHeight / 2));

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const top = (_height - _trackHeight) / 2;
          final markerLeft = (width * targetRatio - _markerWidth / 2)
              .clamp(0.0, width - _markerWidth);

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: top,
                height: _trackHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: radius,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: top,
                height: _trackHeight,
                width: width * actualRatio,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: radius,
                  ),
                ),
              ),
              // Vạch chuẩn cao hơn thanh để không lẫn vào phần tô — đây là con
              // số người dùng đang so, phải nhìn ra ngay.
              Positioned(
                left: markerLeft,
                top: 0,
                height: _height,
                width: _markerWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface,
                    borderRadius: const BorderRadius.all(Radius.circular(1.5)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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
