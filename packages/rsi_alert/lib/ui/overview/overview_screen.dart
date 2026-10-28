import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app_core/mini_app_core.dart';

import '../../app/providers.dart';
import '../../domain/market_symbol.dart';
import '../format.dart';
import '../strings.dart';
import 'signal_banner.dart';
import 'symbol_card.dart';

/// Màn hình Tổng quan (FR-1, FR-2, FR-3, FR-5).
///
/// Thiết kế theo UJ-1: phần lớn thời gian màn hình này phải nói "không có gì
/// xảy ra" thật gọn rồi để người dùng đi. Trạng thái Trung tính không được
/// trình bày như một sự thiếu vắng cần lấp đầy.
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key, required this.onOpenChart});

  final void Function(MarketSymbol symbol) onOpenChart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(overviewControllerProvider);
    final controller = ref.read(overviewControllerProvider.notifier);
    final theme = Theme.of(context);

    final banners = state.withNewSignal;
    final latestFetch = [
      for (final view in state.views.values)
        if (view.fetchedAt != null) view.fetchedAt!,
    ]..sort();

    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: MiniAppScope.exitButtonOf(context),
        title: const Text(S.appTitle),
        actions: [
          IconButton(
            icon: Icon(_themeIcon(themeMode)),
            tooltip: S.themeTitle,
            onPressed: () => _showThemeDialog(context, ref, themeMode),
          ),
        ],
        bottom: state.isRefreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (final view in banners)
              SignalBanner(
                signal: view.newSignal!,
                onTap: () {
                  controller.markSignalSeen(view.symbol);
                  onOpenChart(view.symbol);
                },
              ),
            const SizedBox(height: 8),
            for (final symbol in MarketSymbol.values)
              if (state.viewOf(symbol) case final view?)
                SymbolCard(
                  view: view,
                  onTap: () => onOpenChart(symbol),
                  onRetry: controller.refresh,
                ),
            if (latestFetch.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  S.updatedAt(formatTimestamp(latestFetch.last)),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
        ThemeMode.system => Icons.brightness_auto_outlined,
      };

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text(S.themeTitle),
        children: [
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: current,
            title: const Text(S.themeSystem),
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: current,
            title: const Text(S.themeLight),
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: current,
            title: const Text(S.themeDark),
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
