import '../data/market_repository.dart';
import '../domain/candle.dart';
import '../domain/constants.dart';
import '../domain/market_symbol.dart';
import '../domain/rsi.dart';
import '../domain/rsi_status.dart';
import '../domain/signal.dart';

/// Toàn bộ những gì giao diện cần biết về một Mã, suy ra **tại thời điểm dựng**
/// từ chuỗi nến (AD-2). Không trường nào ở đây được đọc lên từ kho lưu trữ.
class SymbolView {
  SymbolView._({
    required this.data,
    required this.rsiPoints,
    required this.signals,
    required this.newSignal,
  });

  /// Dựng từ kết quả tải và mốc Tín hiệu người dùng đã xem.
  ///
  /// [lastSeenSignal] là mốc tuần của Tín hiệu cuối cùng đã xem cho Mã này;
  /// `null` nghĩa là chưa từng xem — lần chạy đầu sau khi cài app.
  factory SymbolView.from(SymbolData data, {required DateTime? lastSeenSignal}) {
    final rsiPoints = computeRsi([for (final c in data.candles) c.close]);
    final signals = detectSignals(data.symbol, data.candles);

    final latest = signals.isEmpty ? null : signals.last;
    final isNew = latest != null &&
        lastSeenSignal != null &&
        latest.weekOpenTime.isAfter(lastSeenSignal);

    return SymbolView._(
      data: data,
      rsiPoints: rsiPoints,
      signals: signals,
      newSignal: isNew ? latest : null,
    );
  }

  final SymbolData data;

  /// RSI của **toàn bộ** chuỗi, kể cả nến đang chạy — dùng để vẽ và hiển thị.
  /// Việc lọc nến đã đóng chỉ áp cho phần sinh Tín hiệu (AD-5).
  final List<RsiPoint> rsiPoints;

  final List<Signal> signals;

  /// Tín hiệu mới kể từ lần người dùng xem gần nhất; `null` khi không có.
  final Signal? newSignal;

  MarketSymbol get symbol => data.symbol;
  List<Candle> get candles => data.candles;
  Staleness get staleness => data.staleness;
  DateTime? get fetchedAt => data.fetchedAt;

  Candle? get latestCandle => candles.isEmpty ? null : candles.last;

  /// RSI của nến mới nhất. `null` khi chuỗi chưa đủ [minCandlesForRsi] nến.
  double? get latestRsi {
    if (rsiPoints.isEmpty) return null;
    final last = rsiPoints.last;
    return last.candleIndex == candles.length - 1 ? last.value : null;
  }

  /// `true` khi giá trị đang hiển thị thuộc về Nến đang chạy — phải kèm nhãn
  /// *tạm tính* ở mọi nơi hiển thị (AD-5).
  bool get isProvisional => latestCandle?.isClosed == false;

  RsiStatus get status => RsiStatus.from(latestRsi);

  /// Mốc tuần cần ghi lại khi người dùng đã xem cảnh báo.
  DateTime? get latestSignalWeek =>
      signals.isEmpty ? null : signals.last.weekOpenTime;
}
