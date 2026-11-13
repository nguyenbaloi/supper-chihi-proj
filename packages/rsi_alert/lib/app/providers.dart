import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/binance_source.dart';
import '../data/candle_store.dart';
import '../data/fear_greed_source.dart';
import '../data/market_data_source.dart';
import '../data/market_repository.dart';
import '../data/ssi_source.dart';
import '../data/vndirect_source.dart';
import '../domain/weekly_reminder.dart';
import '../domain/market_symbol.dart';

export 'overview_controller.dart' show marketRepositoryProvider, overviewControllerProvider;

/// Dựng repository thật với thứ tự nguồn ưu tiên của từng Mã.
///
/// BTC chỉ có một nguồn; VNINDEX có SSI làm chính và VNDirect làm dự phòng.
/// TCBS không có mặt ở đây: nó bị Cloudflare chặn với HTTP client thuần.
MarketRepository buildRepository(CandleStore store) => MarketRepository(
      store: store,
      sources: <MarketSymbol, List<MarketDataSource>>{
        MarketSymbol.btc: [BinanceSource()],
        MarketSymbol.vnindex: [SsiSource(), VndirectSource()],
      },
      fearGreedSource: FearGreedSource(),
    );

/// Lời nhắc sáng thứ Hai (FR-19). Mặc định không làm gì — để test và mọi
/// môi trường không có plugin thông báo chạy được; app thật ghi đè ở
/// `RsiMiniApp.createContainer`.
final weeklyReminderProvider =
    Provider<WeeklyReminder>((ref) => const NoopWeeklyReminder());

/// Kho chứa nến và cấu hình.
final candleStoreProvider = Provider<CandleStore>((ref) {
  throw UnimplementedError('candleStoreProvider chưa được override');
});

/// Cấu hình chế độ giao diện (Hệ thống / Sáng / Tối).
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    try {
      final store = ref.watch(candleStoreProvider);
      return store.loadThemeMode();
    } catch (_) {
      return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    try {
      ref.read(candleStoreProvider).saveThemeMode(mode);
    } catch (_) {}
  }
}

/// Chỉ số tab đang mở. Giữ ở đây để chuyển tab qua lại không dựng lại màn hình.
final selectedTabProvider = NotifierProvider<SelectedTab, int>(SelectedTab.new);

class SelectedTab extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

/// Mã đang xem ở tab Biểu đồ.
final selectedSymbolProvider =
    NotifierProvider<SelectedSymbol, MarketSymbol>(SelectedSymbol.new);

class SelectedSymbol extends Notifier<MarketSymbol> {
  @override
  MarketSymbol build() => MarketSymbol.btc;

  void select(MarketSymbol symbol) => state = symbol;
}
