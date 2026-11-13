import 'package:flutter/foundation.dart';

import '../domain/candle.dart';
import '../domain/fear_greed.dart';
import '../domain/market_symbol.dart';
import 'candle_store.dart';
import 'fear_greed_source.dart';
import 'market_data_source.dart';

/// Độ tươi của dữ liệu đang cầm trên tay.
enum Staleness {
  /// Vừa lấy được từ một Nguồn dữ liệu trong lần gọi này.
  fresh,

  /// Mọi Nguồn đều hỏng; đây là dữ liệu đã lưu từ lần thành công trước.
  stale,

  /// Mọi Nguồn đều hỏng và kho cục bộ cũng không có gì.
  empty,
}

/// Kết quả một lần tải cho một Mã. Không mang RSI hay Tín hiệu — tầng trên tự
/// tính từ [candles] (AD-2).
class SymbolData {
  const SymbolData({
    required this.symbol,
    required this.candles,
    required this.fetchedAt,
    required this.staleness,
    this.errorKind,
    this.sourceName,
  });

  final MarketSymbol symbol;
  final List<Candle> candles;

  /// Thời điểm lần lấy dữ liệu thành công gần nhất; `null` khi chưa từng có.
  final DateTime? fetchedAt;
  final Staleness staleness;

  /// Lỗi cuối cùng gặp phải, khi [staleness] khác [Staleness.fresh].
  final MarketDataErrorKind? errorKind;

  /// Tên Nguồn đã cho ra dữ liệu này, khi tải thành công.
  final String? sourceName;

  bool get hasCandles => candles.isNotEmpty;
}

/// Kết quả tải Fear & Greed (AD-13). Rỗng không phải lỗi: Vùng vẫn xếp được
/// bằng RSI, chỉ thiếu mức "tăng cường".
class FearGreedData {
  const FearGreedData({
    required this.points,
    required this.fetchedAt,
    required this.staleness,
  });

  final List<FearGreedPoint> points;
  final DateTime? fetchedAt;
  final Staleness staleness;
}

/// Điều phối giữa các Nguồn dữ liệu và Kho cục bộ.
///
/// **Không bao giờ ném lỗi ra ngoài** (AD-6). Mọi hỏng hóc đều được diễn dịch
/// thành một [SymbolData] có [Staleness] tương ứng, để không widget nào phải
/// bắt exception và không màn hình nào bị trắng.
class MarketRepository {
  MarketRepository({
    required CandleStore store,
    required Map<MarketSymbol, List<MarketDataSource>> sources,
    FearGreedSource? fearGreedSource,
  })  : _store = store,
        _sources = sources,
        _fearGreedSource = fearGreedSource;

  final CandleStore _store;

  /// Thứ tự trong danh sách là thứ tự ưu tiên: phần tử đầu là Nguồn chính.
  final Map<MarketSymbol, List<MarketDataSource>> _sources;

  /// `null` thì app chạy như trước khi có F&G — Vùng BTC chỉ dựa vào RSI.
  final FearGreedSource? _fearGreedSource;

  /// Dữ liệu đã lưu, đọc được ngay lập tức để hiển thị trước khi mạng xong
  /// (NFR-1).
  SymbolData cached(MarketSymbol symbol) {
    final stored = _store.load(symbol);
    if (stored == null || stored.candles.isEmpty) {
      return SymbolData(
        symbol: symbol,
        candles: const [],
        fetchedAt: null,
        staleness: Staleness.empty,
      );
    }
    return SymbolData(
      symbol: symbol,
      candles: stored.candles,
      fetchedAt: stored.fetchedAt,
      staleness: Staleness.stale,
    );
  }

  Future<SymbolData> load(MarketSymbol symbol) async {
    MarketDataException? lastError;

    for (final source in _sources[symbol] ?? const <MarketDataSource>[]) {
      try {
        final candles = await source.fetchWeekly();
        if (candles.isEmpty) {
          lastError = MarketDataException(
            MarketDataErrorKind.empty,
            'nguồn trả về chuỗi rỗng',
            source: source.name,
          );
          continue;
        }
        final fetchedAt = DateTime.now().toUtc();
        await _store.save(symbol, candles, fetchedAt);
        return SymbolData(
          symbol: symbol,
          candles: candles,
          fetchedAt: fetchedAt,
          staleness: Staleness.fresh,
          sourceName: source.name,
        );
      } on MarketDataException catch (error) {
        debugPrint('MarketRepository: ${symbol.storageKey} qua ${source.name} hỏng — $error');
        lastError = error;
      } catch (error) {
        // Lỗi ngoài dự kiến từ adapter vẫn không được vượt qua biên này.
        debugPrint('MarketRepository: ${symbol.storageKey} qua ${source.name} lỗi lạ — $error');
        lastError = MarketDataException(
          MarketDataErrorKind.network,
          '$error',
          source: source.name,
        );
      }
    }

    final fallback = cached(symbol);
    return SymbolData(
      symbol: symbol,
      candles: fallback.candles,
      fetchedAt: fallback.fetchedAt,
      staleness: fallback.hasCandles ? Staleness.stale : Staleness.empty,
      errorKind: lastError?.kind,
    );
  }

  /// Chuỗi F&G đã lưu, đọc ngay để hiển thị trước khi mạng xong.
  FearGreedData cachedFearGreed() {
    final stored = _store.loadFearGreed();
    return stored == null
        ? const FearGreedData(points: [], fetchedAt: null, staleness: Staleness.empty)
        : FearGreedData(
            points: stored.points,
            fetchedAt: stored.fetchedAt,
            staleness: Staleness.stale,
          );
  }

  /// Tải F&G. Cũng **không bao giờ ném** (AD-6): hỏng thì rơi về kho.
  Future<FearGreedData> loadFearGreed() async {
    final source = _fearGreedSource;
    if (source == null) return cachedFearGreed();
    try {
      final points = await source.fetchDaily();
      final fetchedAt = DateTime.now().toUtc();
      await _store.saveFearGreed(points, fetchedAt);
      return FearGreedData(
        points: points,
        fetchedAt: fetchedAt,
        staleness: Staleness.fresh,
      );
    } catch (error) {
      debugPrint('MarketRepository: F&G qua ${source.name} hỏng — $error');
      return cachedFearGreed();
    }
  }

  DateTime? lastSeenDca(MarketSymbol symbol) => _store.loadLastSeenDca(symbol);

  Future<void> markDcaSeen(MarketSymbol symbol, DateTime weekOpenTime) =>
      _store.saveLastSeenDca(symbol, weekOpenTime);

  DateTime? lastSeenSignal(MarketSymbol symbol) =>
      _store.loadLastSeenSignal(symbol);

  Future<void> markSignalSeen(MarketSymbol symbol, DateTime weekOpenTime) =>
      _store.saveLastSeenSignal(symbol, weekOpenTime);
}
