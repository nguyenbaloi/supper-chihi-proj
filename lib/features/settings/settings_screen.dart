import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/rules/stale.dart';
import '../../presentation/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final repo = ref.read(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(S.settings)),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: const Text(S.settingsStaleDays),
                  subtitle: Text('${settings.staleDays} ngày · ${S.settingsStaleRange}'),
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
            ),
    );
  }
}
