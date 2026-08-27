import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/models/asset_class.dart';
import '../../domain/models/target_group.dart';
import '../../domain/rules/rebalancing.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';

/// Đặt Tỷ trọng mục tiêu cho từng Lớp tài sản, và gộp lớp vào Nhóm mục tiêu.
/// Xem FR-19.
Future<void> showTargetEditor(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: _TargetEditor(),
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
                  _ClassRow(assetClass: assetClass, groups: groups),
                const Divider(height: 32),
                Text(l10n.targetGroup, style: theme.textTheme.titleMedium),
                for (final group in groups)
                  _GroupRow(group: group),
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
    var percent = 20;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
              Text('$percent%'),
              Slider(
                value: percent.toDouble(),
                max: 100,
                divisions: 100,
                onChanged: (v) => setState(() => percent = v.round()),
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
      ),
    );

    if (saved != true || nameController.text.trim().isEmpty) return;
    await ref.read(targetRepositoryProvider).addGroup(
          name: nameController.text,
          targetWeightBp: percent * 100,
        );
  }
}

class _ClassRow extends ConsumerWidget {
  final AssetClass assetClass;
  final List<TargetGroup> groups;

  const _ClassRow({required this.assetClass, required this.groups});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final repo = ref.read(targetRepositoryProvider);
    final inGroup = assetClass.targetGroupId != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(assetClass.name)),
              // Lớp thuộc nhóm thì mục tiêu đặt ở cấp nhóm, không đặt riêng.
              if (!inGroup)
                Text(
                  assetClass.targetWeightBp == null
                      ? '—'
                      : '${assetClass.targetWeightBp! ~/ 100}%',
                  style: theme.textTheme.titleSmall,
                ),
            ],
          ),
          if (!inGroup)
            Slider(
              value: ((assetClass.targetWeightBp ?? 0) / 100).toDouble(),
              max: 100,
              divisions: 100,
              onChanged: (value) => repo.setClassTarget(
                assetClass.id,
                value.round() == 0 ? null : value.round() * 100,
              ),
            ),
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

  const _GroupRow({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(targetRepositoryProvider);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(group.name),
      subtitle: Slider(
        value: (group.targetWeightBp / 100).toDouble(),
        max: 100,
        divisions: 100,
        onChanged: (value) =>
            repo.updateGroup(group.id, targetWeightBp: value.round() * 100),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${group.targetWeightBp ~/ 100}%'),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => repo.removeGroup(group.id),
          ),
        ],
      ),
    );
  }
}
