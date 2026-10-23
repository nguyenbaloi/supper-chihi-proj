import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_date.dart';
import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/enums.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/confirm_dialog.dart';
import '../../presentation/widgets/money_field.dart';
import '../../presentation/widgets/price_freshness_label.dart';
import 'backup_service.dart';
import 'export_service.dart';

/// Màn hình Cài đặt. Xem FR-39 và FR-41.
///
/// Mọi thiết lập ảnh hưởng tới lịch sử đều cảnh báo trước khi áp dụng.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).value;
    final fxRate = ref.watch(effectiveFxRateProvider).value;
    final classes = ref.watch(assetClassesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (settings != null) ...[
            ListTile(
              title: Text(l10n.initialContribution),
              subtitle: Text(VnFormat.money(settings.initialContributionAmount)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editInitialContribution(context, ref),
            ),
            ListTile(
              title: Text(l10n.settingsStartDate),
              subtitle: Text(VnDate.full(settings.startDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editStartDate(context, ref, settings.startDate),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.settingsFxRate),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fxRate == null
                        ? l10n.loading
                        : '${VnFormat.money(fxRate.rateAmount)} / USD'
                            ' · ${fxRate.source == PriceSource.manual ? l10n.settingsFxRateManual : l10n.settingsFxRateAuto}',
                  ),
                  if (fxRate != null && fxRate.isFallback)
                    Text(
                      l10n.fallbackFxRateNotice,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    )
                  else if (fxRate?.fetchedAt != null)
                    PriceFreshnessLabel(fetchedAt: fxRate!.fetchedAt),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editFxRate(
                context,
                ref,
                settings.fxRateManualAmount,
              ),
            ),
            ListTile(
              title: Text(l10n.driftThreshold),
              subtitle: Text('${settings.driftThresholdBp / 100}%'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editThreshold(context, ref, settings.driftThresholdBp),
            ),
            const Divider(),
            ExpansionTile(
              title: Text(l10n.settingsInvestmentGroup),
              subtitle: Text(
                classes
                    .where((c) => c.inInvestmentGroup)
                    .map((c) => c.name)
                    .join(' · '),
              ),
              children: [
                for (final assetClass in classes)
                  CheckboxListTile(
                    title: Text(assetClass.name),
                    value: assetClass.inInvestmentGroup,
                    onChanged: (checked) async {
                      final confirmed = await confirmAction(
                        context,
                        title: l10n.recalcWarningTitle,
                        body: l10n.recalcWarningBody,
                        confirmLabel: l10n.actionApply,
                        destructive: false,
                      );
                      if (!confirmed) return;
                      final selected = classes
                          .where((c) => c.inInvestmentGroup)
                          .map((c) => c.id)
                          .toSet();
                      if (checked ?? false) {
                        selected.add(assetClass.id);
                      } else {
                        selected.remove(assetClass.id);
                      }
                      await ref
                          .read(targetRepositoryProvider)
                          .setInvestmentGroup(selected);
                    },
                  ),
              ],
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.settingsThemeMode),
              subtitle: Text(_themeLabel(l10n, settings.themeModeSetting)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editTheme(context, ref, settings.themeModeSetting),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.settingsExport),
              subtitle: Text(
                settings.lastExportedAt == null
                    ? l10n.settingsNeverExported
                    : l10n.settingsLastExported(
                        VnDate.full(settings.lastExportedAt!),
                      ),
              ),
              trailing: const Icon(Icons.ios_share),
              onTap: () => exportAndShare(context, ref),
            ),
            ListTile(
              title: Text(l10n.settingsBackup),
              subtitle: Text(l10n.settingsBackupSubtitle),
              trailing: const Icon(Icons.save_alt),
              onTap: () => backupAndShare(context, ref),
            ),
            ListTile(
              title: Text(l10n.settingsRestore),
              subtitle: Text(l10n.settingsRestoreSubtitle),
              trailing: const Icon(Icons.settings_backup_restore),
              onTap: () => restoreFromBackup(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  static String _themeLabel(AppL10n l10n, ThemeModeSetting setting) =>
      switch (setting) {
        ThemeModeSetting.light => l10n.themeLight,
        ThemeModeSetting.dark => l10n.themeDark,
        ThemeModeSetting.system => l10n.themeSystem,
      };

  Future<void> _editInitialContribution(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppL10n.of(context);
    var amount = ref.read(settingsProvider).value!.initialContributionAmount;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.initialContribution),
        content: MoneyField(
          label: l10n.initialContribution,
          initial: amount,
          onChanged: (value) => amount = value,
          helperText: l10n.onboardingCapitalExplain,
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
    if (saved != true || !context.mounted) return;

    // Cảnh báo trước khi áp dụng: con số này neo toàn bộ lịch sử Lãi lỗ.
    final confirmed = await confirmAction(
      context,
      title: l10n.recalcWarningTitle,
      body: l10n.recalcWarningBody,
      confirmLabel: l10n.actionApply,
      destructive: false,
    );
    if (!confirmed) return;
    await ref.read(settingsRepositoryProvider).setInitialContribution(amount);
  }

  Future<void> _editStartDate(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final l10n = AppL10n.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: current.toLocal(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !context.mounted) return;

    final confirmed = await confirmAction(
      context,
      title: l10n.recalcWarningTitle,
      body: l10n.recalcWarningBody,
      confirmLabel: l10n.actionApply,
      destructive: false,
    );
    if (!confirmed) return;
    await ref.read(settingsRepositoryProvider).setStartDate(picked);
  }

  Future<void> _editFxRate(
    BuildContext context,
    WidgetRef ref,
    Money? current,
  ) async {
    final l10n = AppL10n.of(context);
    var rate = current ?? Money.zero;

    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsFxRate),
        content: MoneyField(
          label: l10n.settingsFxRateManual,
          initial: rate,
          onChanged: (value) => rate = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('auto'),
            child: Text(l10n.settingsFxRateAuto),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('manual'),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );

    final repo = ref.read(settingsRepositoryProvider);
    if (action == 'auto') {
      await repo.setFxRate(null);
    } else if (action == 'manual' && rate.isPositive) {
      await repo.setFxRate(rate);
    }
  }

  Future<void> _editThreshold(
    BuildContext context,
    WidgetRef ref,
    int currentBp,
  ) async {
    final l10n = AppL10n.of(context);
    var bp = currentBp;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.driftThreshold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${bp / 100}%'),
              Slider(
                value: bp.toDouble(),
                min: 100,
                max: 2000,
                divisions: 19,
                onChanged: (value) => setState(() => bp = value.round()),
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
    if (saved != true) return;
    await ref.read(settingsRepositoryProvider).setDriftThreshold(bp);
  }

  Future<void> _editTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeModeSetting current,
  ) async {
    final l10n = AppL10n.of(context);
    final picked = await showDialog<ThemeModeSetting>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsThemeMode),
        children: [
          for (final setting in ThemeModeSetting.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(setting),
              child: Row(
                children: [
                  Icon(
                    setting == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(_themeLabel(l10n, setting)),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked == null) return;
    await ref.read(settingsRepositoryProvider).setThemeMode(picked);
  }
}
