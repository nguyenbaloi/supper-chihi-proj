import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/binance_source.dart';
import '../data/candle_store.dart';
import '../data/market_data_source.dart';
import '../data/market_repository.dart';
import '../data/ssi_source.dart';
import '../data/vndirect_source.dart';
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
    );

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
