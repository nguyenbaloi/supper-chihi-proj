import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/market_repository.dart';
import '../domain/fear_greed.dart';
import '../domain/market_symbol.dart';
import 'symbol_view.dart';

class OverviewState {
  const OverviewState({
    required this.views,
    required this.isRefreshing,
  });

  const OverviewState.initial()
      : views = const {},
        isRefreshing = false;

  /// Thứ tự hiển thị lấy từ [MarketSymbol.values], không sắp xếp lại theo
  /// trạng thái — thẻ phải luôn ở đúng chỗ người dùng quen nhìn.
  final Map<MarketSymbol, SymbolView> views;
  final bool isRefreshing;

  SymbolView? viewOf(MarketSymbol symbol) => views[symbol];

  /// Các cảnh báo Vùng DCA chưa xem, theo thứ tự Mã cố định (FR-17).
  List<SymbolView> get withNewDca => [
        for (final symbol in MarketSymbol.values)
          if (views[symbol]?.newDca != null) views[symbol]!,
      ];

  /// Các Tín hiệu mới cần hiện dải cảnh báo, theo thứ tự Mã cố định (FR-5).
  List<SymbolView> get withNewSignal => [
        for (final symbol in MarketSymbol.values)
          if (views[symbol]?.newSignal != null) views[symbol]!,
      ];

  OverviewState copyWith({
    Map<MarketSymbol, SymbolView>? views,
    bool? isRefreshing,
  }) =>
      OverviewState(
        views: views ?? this.views,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );
}

/// Điều phối màn hình Tổng quan (FR-1, FR-2, FR-5).
///
/// Trình tự khi mở app: phát ngay trạng thái dựng từ Kho cục bộ (NFR-1), rồi
/// tải cả hai Mã **song song** và phát lại. Một Mã hỏng không chặn Mã còn lại
/// (NFR-3) vì repository không bao giờ ném (AD-6).
class OverviewController extends Notifier<OverviewState> {
  MarketRepository get _repository => ref.read(marketRepositoryProvider);

  /// F&G đang cầm — chỉ BTC dùng (AD-13).
  List<FearGreedPoint> _fearGreed = const [];

  SymbolView _view(SymbolData data, {DateTime? lastSeenSignal}) =>
      SymbolView.from(
        data,
        lastSeenSignal: lastSeenSignal ?? _repository.lastSeenSignal(data.symbol),
        lastSeenDca: _repository.lastSeenDca(data.symbol),
        fearGreed: _fearGreed,
      );

  @override
  OverviewState build() {
    // Dựng ngay từ Kho cục bộ để màn hình có số hiển thị trước khi mạng xong
    // (NFR-1). Việc tải mới phải hoãn sang microtask kế tiếp: gán `state`
    // trong lúc `build()` còn đang chạy sẽ đọc phải provider chưa khởi tạo.
    _fearGreed = _repository.cachedFearGreed().points;
    final cached = _buildViews(_repository.cached);
    Future.microtask(refresh);
    return OverviewState(views: cached, isRefreshing: true);
  }

  /// Tải lại cả hai Mã. Gọi khi mở app và khi người dùng kéo xuống.
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);

    final fearGreed = _repository.loadFearGreed();
    final results = await Future.wait(
      [for (final symbol in MarketSymbol.values) _repository.load(symbol)],
    );
    _fearGreed = (await fearGreed).points;

    final views = <MarketSymbol, SymbolView>{};
    for (final data in results) {
      final lastSeen = _repository.lastSeenSignal(data.symbol);
      final view = _view(data);

      // Lần chạy đầu sau khi cài app: đặt mốc đã xem bằng Tín hiệu cuối cùng
      // tìm thấy, để người dùng không bị dội một loạt cảnh báo từ quá khứ
      // (FR-5, giả định đã ghi ở §10 của PRD).
      if (lastSeen == null && view.latestSignalWeek != null) {
        await _repository.markSignalSeen(data.symbol, view.latestSignalWeek!);
      }

      views[data.symbol] = view;
    }

    state = OverviewState(views: views, isRefreshing: false);
  }

  /// Ghi nhận người dùng đã xem cảnh báo của [symbol] và bỏ dải đi (FR-5).
  Future<void> markSignalSeen(MarketSymbol symbol) async {
    final view = state.views[symbol];
    final week = view?.newSignal?.weekOpenTime;
    if (view == null || week == null) return;

    await _repository.markSignalSeen(symbol, week);
    state = state.copyWith(
      views: {
        ...state.views,
        symbol: _view(view.data, lastSeenSignal: week),
      },
    );
  }

  /// Ghi nhận người dùng đã xem cảnh báo Vùng DCA của [symbol] (FR-17).
  Future<void> markDcaSeen(MarketSymbol symbol) async {
    final view = state.views[symbol];
    final week = view?.newDca?.weekOpenTime;
    if (view == null || week == null) return;

    await _repository.markDcaSeen(symbol, week);
    state = state.copyWith(
      views: {...state.views, symbol: _view(view.data)},
    );
  }

  Map<MarketSymbol, SymbolView> _buildViews(
    SymbolData Function(MarketSymbol) source,
  ) =>
      {
        for (final symbol in MarketSymbol.values)
          symbol: _view(source(symbol)),
      };
}

/// Khai báo ở đây để controller không phải import ngược `providers.dart`.
final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => throw UnimplementedError('phải ghi đè ở main.dart hoặc trong test'),
);

final overviewControllerProvider =
    NotifierProvider<OverviewController, OverviewState>(
  OverviewController.new,
);
