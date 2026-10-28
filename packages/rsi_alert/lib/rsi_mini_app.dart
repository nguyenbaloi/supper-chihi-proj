import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mini_app_core/mini_app_core.dart';

import 'app/providers.dart';
import 'data/candle_store.dart';
import 'ui/home_shell.dart';
import 'ui/strings.dart';
import 'ui/theme.dart';

/// Điểm vào duy nhất của ứng dụng — dùng chung cho `main()` độc lập và super app.
class RsiMiniApp implements MiniApp {
  const RsiMiniApp();

  @override
  String get id => 'rsi_alert';

  @override
  String get title => S.appTitle;

  @override
  IconData get icon => Icons.candlestick_chart;

  @override
  Color get color => const Color(0xFF0F172A);

  @override
  Future<ProviderContainer> createContainer() async {
    await initializeDateFormatting('vi_VN');
    final store = await CandleStore.open();
    return ProviderContainer(
      overrides: [
        candleStoreProvider.overrideWithValue(store),
        marketRepositoryProvider.overrideWithValue(buildRepository(store)),
      ],
    );
  }

  @override
  Widget buildApp() =>
      const RsiAlertApp();

  // Kho chỉ là bộ đệm nến tải lại được từ mạng — không có gì đáng sao lưu.
  @override
  List<BackupSource> get backupSources => const [];
}

class RsiAlertApp extends ConsumerWidget {
  const RsiAlertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: S.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const HomeShell(),
    );
  }
}
