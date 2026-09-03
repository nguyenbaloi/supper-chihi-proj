import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/rules/stale.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/layout.dart';
import 'backup_actions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final repo = ref.read(settingsRepositoryProvider);
    final theme = Theme.of(context);

    if (settings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        SectionHeader(
          title: S.settingsStaleDays,
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg,
              AppSpacing.gutter, AppSpacing.sm),
        ),
        SectionCard(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md,
              AppSpacing.lg, AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.days(settings.staleDays),
                      style: theme.textTheme.titleMedium),
                  Text(S.settingsStaleRange, style: theme.textTheme.bodySmall),
                ],
              ),
              Slider(
                value: settings.staleDays.toDouble(),
                min: minStaleDays.toDouble(),
                max: maxStaleDays.toDouble(),
                divisions: maxStaleDays - minStaleDays,
                label: '${settings.staleDays}',
                onChanged: (v) =>
                    repo.save(settings.copyWith(staleDays: v.round())),
              ),
            ],
          ),
        ),
        const SectionHeader(title: S.settingsTheme),
        GroupedCard(
          dividerIndent: AppSpacing.gutter,
          children: [
            RadioGroup<AppThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (v) =>
                  v == null ? null : repo.save(settings.copyWith(themeMode: v)),
              child: Column(
                children: [
                  for (final mode in AppThemeMode.values)
                    RadioListTile<AppThemeMode>(
                      value: mode,
                      title: Text(switch (mode) {
                        AppThemeMode.system => S.settingsThemeSystem,
                        AppThemeMode.light => S.settingsThemeLight,
                        AppThemeMode.dark => S.settingsThemeDark,
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SectionHeader(title: S.backupSection),
        GroupedCard(
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text(S.backupExport),
              subtitle: const Text(S.backupExportHint),
              onTap: () => runExport(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: const Text(S.backupImport),
              subtitle: const Text(S.backupImportHint),
              onTap: () => runImport(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text(S.settingsReseed),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(seederProvider).applyProjectSeed();
                messenger.showSnackBar(
                    const SnackBar(content: Text(S.settingsReseedDone)));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined,
                  color: theme.colorScheme.error),
              title: Text(S.backupWipe,
                  style: TextStyle(color: theme.colorScheme.error)),
              subtitle: const Text(S.backupWipeStep1),
              onTap: () => runWipe(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}
