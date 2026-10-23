import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/asset_class.dart';
import '../../domain/models/portfolio_valuation.dart';
import '../../domain/models/target_group.dart';
import '../../domain/rules/rebalancing.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/percent_field.dart';

/// Đặt Tỷ trọng mục tiêu cho từng Lớp tài sản, và gộp lớp vào Nhóm mục tiêu.
/// Xem FR-19.
Future<void> showTargetEditor(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Không đi qua `showFormSheet` vì tấm này cao cố định và đã tự cuộn
      // bên trong; bọc thêm một lớp cuộn nữa sẽ làm `FractionallySizedBox`
      // mất chiều cao tham chiếu. Phần đệm bàn phím thì vẫn phải đọc từ
      // context của chính tấm trượt.
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: const FractionallySizedBox(
          heightFactor: 0.9,
          child: _TargetEditor(),
        ),
      ),
    );

class _TargetEditor extends ConsumerWidget {
  const _TargetEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final valuation = ref.watch(portfolioValuationProvider).value;
    final classes = valuation?.entries.map((e) => e.assetClass).toList() ??
        const <AssetClass>[];
    final groups = ref.watch(targetGroupsProvider).value ??
        const <TargetGroup>[];

    final totalBp = Rebalancing.totalTargetBp([
      ...classes
          .where((c) => c.targetGroupId == null && c.targetWeightBp != null)
          .map((c) => c.targetWeightBp!),
      ...groups.map((g) => g.targetWeightBp),
    ]);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.targetWeight,
                      style: theme.textTheme.titleLarge),
                ),
                // Cảnh báo khi tổng khác 100% nhưng vẫn cho lưu. Xem FR-19.
                Text(
                  VnFormat.percent(
                    (Decimal.fromInt(totalBp) / Decimal.fromInt(10000))
                        .toDecimal(scaleOnInfinitePrecision: 6),
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: totalBp == 10000
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final assetClass in classes)
                  _ClassRow(
                    key: ValueKey(assetClass.id),
                    assetClass: assetClass,
                    groups: groups,
                    valuation: valuation,
                  ),
                const Divider(height: 32),
                Text(l10n.targetGroup, style: theme.textTheme.titleMedium),
                for (final group in groups)
                  _GroupRow(
                    key: ValueKey(group.id),
                    group: group,
                    valuation: valuation,
                  ),
                TextButton.icon(
                  onPressed: () => _addGroup(context, ref),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addTargetGroup),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addGroup(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final nameController = TextEditingController();
    int? targetBp = 2000;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addTargetGroup),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.targetGroup),
            ),
            const SizedBox(height: 12),
            PercentField(
              label: l10n.targetWeight,
              initialBp: targetBp,
              onChanged: (bp) => targetBp = bp,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );

    if (saved != true || nameController.text.trim().isEmpty) return;
    await ref.read(targetRepositoryProvider).addGroup(
          name: nameController.text,
          targetWeightBp: targetBp ?? 0,
        );
  }
}

class _ClassRow extends ConsumerWidget {
  final AssetClass assetClass;
  final List<TargetGroup> groups;
  final PortfolioValuation? valuation;

  const _ClassRow({
    super.key,
    required this.assetClass,
    required this.groups,
    required this.valuation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final repo = ref.read(targetRepositoryProvider);
    final inGroup = assetClass.targetGroupId != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(assetClass.name)),
              // Lớp thuộc nhóm thì mục tiêu đặt ở cấp nhóm, không đặt riêng.
              if (!inGroup)
                SizedBox(
                  width: 132,
                  // Nhãn ngắn: ô nằm trong hàng nên "Tỷ trọng mục tiêu" bị
                  // cắt cụt lúc chưa nổi lên. Tiêu đề tấm trượt đã nói đủ.
                  child: PercentField(
                    label: l10n.targetWeightShort,
                    initialBp: assetClass.targetWeightBp,
                    onChanged: (bp) => repo.setClassTarget(assetClass.id, bp),
                  ),
                ),
            ],
          ),
          if (!inGroup)
            _TargetProgress(
              actualWeight: valuation?.weightOf(assetClass.id),
              targetWeightBp: assetClass.targetWeightBp,
            ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            initialValue: assetClass.targetGroupId,
            isDense: true,
            decoration: InputDecoration(labelText: l10n.targetGroup),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(l10n.targetNoneSet)),
              for (final group in groups)
                DropdownMenuItem<int?>(
                  value: group.id,
                  child: Text(group.name),
                ),
            ],
            onChanged: (value) => repo.setClassGroup(assetClass.id, value),
          ),
        ],
      ),
    );
  }
}

class _GroupRow extends ConsumerWidget {
  final TargetGroup group;
  final PortfolioValuation? valuation;

  const _GroupRow({super.key, required this.group, required this.valuation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final repo = ref.read(targetRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(group.name)),
              SizedBox(
                width: 132,
                child: PercentField(
                  label: l10n.targetWeightShort,
                  initialBp: group.targetWeightBp,
                  onChanged: (bp) =>
                      repo.updateGroup(group.id, targetWeightBp: bp ?? 0),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => repo.removeGroup(group.id),
              ),
            ],
          ),
          _TargetProgress(
            actualWeight: _actualWeightOf(group.id, valuation),
            targetWeightBp: group.targetWeightBp,
          ),
        ],
      ),
    );
  }

  /// Tỷ trọng thực tế của cả Nhóm mục tiêu — tổng các Lớp tài sản đang xếp
  /// vào nhóm, chia cho Tổng tài sản. Suy ra từ các lớp thành viên chứ không
  /// lưu ở đâu cả. Xem AD-5.
  static Decimal? _actualWeightOf(int groupId, PortfolioValuation? valuation) {
    if (valuation == null) return null;
    final total = valuation.totalAssets;
    if (total.isZero) return null;
    final value = Money.sum(
      valuation.visible
          .where((e) => e.assetClass.targetGroupId == groupId)
          .map((e) => e.value),
    );
    return value.ratioTo(total);
  }
}

/// Thanh **chỉ đọc** cho biết Tỷ trọng thực tế đã đạt bao nhiêu phần của Tỷ
/// trọng mục tiêu.
///
/// Cố ý không kéo được: con số mục tiêu chỉ sửa ở ô nhập bên trên, còn thanh
/// này là kết quả tính ra từ giá trị thực tế của danh mục. Cho kéo thì hai
/// thứ khác hẳn nhau về bản chất lại trông như một.
class _TargetProgress extends StatelessWidget {
  final Decimal? actualWeight;
  final int? targetWeightBp;

  const _TargetProgress({
    required this.actualWeight,
    required this.targetWeightBp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final targetBp = targetWeightBp;

    // Chưa đặt mục tiêu thì không có gì để so.
    if (targetBp == null || targetBp <= 0) return const SizedBox.shrink();

    final targetWeight = (Decimal.fromInt(targetBp) / Decimal.fromInt(10000))
        .toDecimal(scaleOnInfinitePrecision: 10);
    final actual = actualWeight;

    if (actual == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          l10n.targetProgressNoBase,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final progress = (actual / targetWeight)
        .toDecimal(scaleOnInfinitePrecision: 6);
    // Thừa tô như lỗ, thiếu tô như lãi: cả hai đều là việc cần làm, và dấu
    // cho biết phải bán bớt hay mua thêm. Cùng quy ước với thẻ Khoảng lệch.
    final drift = actual - targetWeight;
    final color = context.colorForAmount(-drift.sign);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.targetActualVsTarget(
                    VnFormat.percent(actual),
                    VnFormat.percent(targetWeight),
                  ),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              Text(
                VnFormat.percent(progress, fractionDigits: 0),
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              // Toạ độ vẽ — ngoại lệ duy nhất được dùng số thực. Xem AD-3.
              // Cắt ở 1: vượt mục tiêu thì thanh đầy, con số bên trên mới là
              // chỗ nói rõ vượt bao nhiêu.
              value: _clampToBar(progress),
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              semanticsLabel: l10n.targetProgress,
            ),
          ),
        ],
      ),
    );
  }

  static double _clampToBar(Decimal progress) {
    if (progress.sign <= 0) return 0;
    if (progress > Decimal.one) return 1;
    return double.parse(progress.toString());
  }
}
