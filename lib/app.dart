import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'domain/models/enums.dart';
import 'features/dashboard/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'presentation/providers/portfolio_providers.dart';
import 'presentation/theme/app_theme.dart';

/// Gốc ứng dụng.
class PersonalFinanceApp extends ConsumerWidget {
  const PersonalFinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = AppTheme.toThemeMode(
      settingsAsync.value?.themeModeSetting ?? ThemeModeSetting.system,
    );

    return MaterialApp(
      onGenerateTitle: (context) => AppL10n.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: settingsAsync.when(
        loading: () => const _Splash(),
        error: (_, __) => const _Splash(),
        // Chưa có bản ghi thiết lập nghĩa là chưa đi qua luồng khởi tạo.
        data: (settings) => settings == null || !settings.onboardingCompleted
            ? const OnboardingScreen()
            : const HomeShell(),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
