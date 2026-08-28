import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/rules/stale.dart';
import '../../presentation/providers/providers.dart';
import 'backup_actions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final repo = ref.read(settingsRepositoryProvider);

    return settings == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(
              children: [
                ListTile(
                  title: const Text(S.settingsStaleDays),
                  subtitle: Text(
                      '${S.days(settings.staleDays)} · ${S.settingsStaleRange}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: settings.staleDays.toDouble(),
                    min: minStaleDays.toDouble(),
                    max: maxStaleDays.toDouble(),
                    divisions: maxStaleDays - minStaleDays,
                    label: '${settings.staleDays}',
                    onChanged: (v) =>
                        repo.save(settings.copyWith(staleDays: v.round())),
                  ),
                ),
                const Divider(),
                const ListTile(title: Text(S.settingsTheme)),
                RadioGroup<AppThemeMode>(
                  groupValue: settings.themeMode,
                  onChanged: (v) => v == null
                      ? null
                      : repo.save(settings.copyWith(themeMode: v)),
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
                const Divider(),
                const ListTile(title: Text(S.backupSection)),
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
                  leading: Icon(Icons.delete_forever_outlined,
                      color: Theme.of(context).colorScheme.error),
                  title: const Text(S.backupWipe),
                  subtitle: const Text(S.backupWipeStep1),
                  onTap: () => runWipe(context, ref),
                ),
                const Divider(),
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
            ],
          );
  }
}
