import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../debts/debts_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../targets/targets_screen.dart';
import 'dashboard_screen.dart';

/// Khung điều hướng năm tab.
///
/// Khi mở lên, ứng dụng làm hai việc nền nhẹ: sinh Bản chốt tự động cho hôm
/// nay nếu chưa có, và làm mới giá. **Không có tác vụ nền nào đăng ký với hệ
/// điều hành** — cả hai chỉ chạy khi người dùng thực sự mở ứng dụng. Xem AD-7.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onOpen());
  }

  Future<void> _onOpen() async {
    // Lấy giá trước để Bản chốt ghi lại con số mới nhất. Thất bại không chặn
    // gì — Bản chốt vẫn được sinh từ giá lưu lần cuối. Xem FR-14.
    await ref.read(priceRefreshServiceProvider).refresh();
    if (!mounted) return;
    await ref
        .read(snapshotRepositoryProvider)
        .captureAutomatic(DateTime.now().toUtc());
    if (mounted) ref.invalidate(snapshotSeriesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          TargetsScreen(),
          DebtsScreen(),
          HistoryScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.track_changes_outlined),
            selectedIcon: const Icon(Icons.track_changes),
            label: l10n.navTargets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.handshake_outlined),
            selectedIcon: const Icon(Icons.handshake),
            label: l10n.navDebts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
