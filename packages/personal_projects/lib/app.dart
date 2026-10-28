import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app_core/mini_app_core.dart';

import 'core/l10n/strings.dart';
import 'domain/models/enums.dart';
import 'features/notes/resources_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/projects/projects_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/today/today_screen.dart';
import 'presentation/providers/providers.dart';
import 'presentation/theme/app_theme.dart';

class PersonalProjectsApp extends ConsumerWidget {
  const PersonalProjectsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = settings.value?.themeMode ?? AppThemeMode.system;

    return MaterialApp(
      title: S.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: switch (themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _Root(),
    );
  }
}

/// Quyết định màn hình đầu: chưa nạp hạt giống thì mời nạp (FR-2, FR-4).
class _Root extends ConsumerStatefulWidget {
  const _Root();

  @override
  ConsumerState<_Root> createState() => _RootState();
}

/// Nút trên thanh tiêu đề: đặt trong một ô tròn nhạt để tách khỏi nền, thay
/// vì icon trơ nổi giữa khoảng trắng.
class _AppBarAction extends StatelessWidget {
  const _AppBarAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 21),
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceContainerLowest,
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          shape: const CircleBorder(),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _RootState extends ConsumerState<_Root> {
  late final Future<void> _bootstrap;

  @override
  void initState() {
    super.initState();
    // FR-1: sáu Lĩnh vực luôn tồn tại, kể cả sau khi xoá sạch dữ liệu.
    _bootstrap = ref.read(seederProvider).ensureAreas();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final settings = ref.watch(settingsProvider);
        return settings.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
          data: (data) => data.seedApplied ? const HomeShell() : const OnboardingScreen(),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    ProjectsScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: MiniAppScope.exitButtonOf(context),
        title: Text(switch (_index) {
          0 => S.tabToday,
          1 => S.tabProjects,
          2 => S.tabStats,
          _ => S.settings,
        }),
        actions: [
          // Kho Tư liệu — FR-50. Vào từ tab Dự án vì đó là nơi người dùng đang
          // nghĩ về nội dung; không chiếm một ô trên thanh dưới, vốn chỉ dành
          // cho bốn màn hình chính.
          if (_index == 1)
            _AppBarAction(
              tooltip: S.resources,
              icon: Icons.folder_outlined,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ResourcesScreen()),
              ),
            ),
          // Cài đặt đã xuống thanh dưới nên chỉ còn tìm kiếm ở đây.
          if (_index != 3)
            _AppBarAction(
              tooltip: S.search,
              icon: Icons.search,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: S.tabToday,
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: S.tabProjects,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: S.tabStats,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: S.settings,
          ),
        ],
      ),
    );
  }
}
