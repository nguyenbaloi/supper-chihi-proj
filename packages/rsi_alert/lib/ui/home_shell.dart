import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/market_symbol.dart';
import '../domain/weekly_reminder.dart';
import 'detail/detail_screen.dart';
import 'history/history_screen.dart';
import 'overview/overview_screen.dart';
import 'strings.dart';

/// Khung ba tab (Story 6.1).
///
/// Dùng [IndexedStack] để chuyển tab qua lại không dựng lại màn hình — nhờ vậy
/// vị trí đang xem trên biểu đồ được giữ nguyên.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int? _focusCandleIndex;

  @override
  void initState() {
    super.initState();
    // Đặt (lại) lời nhắc sáng thứ Hai mỗi lần mở — idempotent, không ném
    // (FR-19). Không chờ: xin quyền thông báo không được chặn màn hình đầu.
    ref.read(weeklyReminderProvider).ensureScheduled(
          const ReminderText(
            title: S.reminderTitle,
            body: S.reminderBody,
            channelName: S.reminderChannel,
            channelDescription: S.reminderChannelDescription,
          ),
        );
  }

  void _openChart(MarketSymbol symbol, {int? candleIndex}) {
    ref.read(selectedSymbolProvider.notifier).select(symbol);
    setState(() => _focusCandleIndex = candleIndex);
    ref.read(selectedTabProvider.notifier).select(1);
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(selectedTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          OverviewScreen(onOpenChart: (symbol) => _openChart(symbol)),
          DetailScreen(
            // Khoá theo nến đang nhắm tới, để mỗi lần nhảy từ Lịch sử sang là
            // một lần dựng lại viewport quanh đúng tuần đó.
            key: ValueKey(_focusCandleIndex),
            focusCandleIndex: _focusCandleIndex,
          ),
          HistoryScreen(
            onOpenChart: (symbol, candleIndex) =>
                _openChart(symbol, candleIndex: candleIndex),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (next) {
          if (next != 1) setState(() => _focusCandleIndex = null);
          ref.read(selectedTabProvider.notifier).select(next);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: S.tabOverview,
          ),
          NavigationDestination(
            icon: Icon(Icons.candlestick_chart_outlined),
            selectedIcon: Icon(Icons.candlestick_chart),
            label: S.tabChart,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: S.tabHistory,
          ),
        ],
      ),
    );
  }
}
