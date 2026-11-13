import '../data/market_repository.dart';
import '../domain/candle.dart';
import '../domain/constants.dart';
import '../domain/dca.dart';
import '../domain/fear_greed.dart';
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
    required this.dcaWeeks,
    required this.newDca,
    required this.latestFearGreed,
  });

  /// Dựng từ kết quả tải và mốc Tín hiệu người dùng đã xem.
  ///
  /// [lastSeenSignal] là mốc tuần của Tín hiệu cuối cùng đã xem cho Mã này;
  /// `null` nghĩa là chưa từng xem — lần chạy đầu sau khi cài app.
  ///
  /// [lastSeenDca] là mốc tuần của cảnh báo Vùng DCA cuối cùng đã xem (FR-17);
  /// `null` thì tuần đóng gần nhất — nếu đáng báo — được hiện luôn: đó là trạng
  /// thái hiện tại, không phải một loạt cảnh báo cũ.
  factory SymbolView.from(
    SymbolData data, {
    required DateTime? lastSeenSignal,
    DateTime? lastSeenDca,
    List<FearGreedPoint> fearGreed = const [],
  }) {
    final rsiPoints = computeRsi([for (final c in data.candles) c.close]);
    final signals = detectSignals(data.symbol, data.candles);

    final latest = signals.isEmpty ? null : signals.last;
    final isNew = latest != null &&
        lastSeenSignal != null &&
        latest.weekOpenTime.isAfter(lastSeenSignal);

    final dcaWeeks = classifyDcaWeeks(
      data.symbol,
      data.candles,
      fearGreed: fearGreed,
    );
    final latestDca = dcaWeeks.isEmpty ? null : dcaWeeks.last;
    final isNewDca = latestDca != null &&
        latestDca.isNotable &&
        (lastSeenDca == null || latestDca.weekOpenTime.isAfter(lastSeenDca));

    return SymbolView._(
      data: data,
      rsiPoints: rsiPoints,
      signals: signals,
      newSignal: isNew ? latest : null,
      dcaWeeks: dcaWeeks,
      newDca: isNewDca ? latestDca : null,
      latestFearGreed: data.symbol == MarketSymbol.btc && fearGreed.isNotEmpty
          ? fearGreed.last
          : null,
    );
  }

  final SymbolData data;

  /// RSI của **toàn bộ** chuỗi, kể cả nến đang chạy — dùng để vẽ và hiển thị.
  /// Việc lọc nến đã đóng chỉ áp cho phần sinh Tín hiệu (AD-5).
  final List<RsiPoint> rsiPoints;

  final List<Signal> signals;

  /// Tín hiệu mới kể từ lần người dùng xem gần nhất; `null` khi không có.
  final Signal? newSignal;

  /// Mọi tuần đã đóng đã xếp Vùng DCA, tăng dần (FR-14). Suy ra, không lưu.
  final List<DcaWeek> dcaWeeks;

  /// Tuần đã đóng gần nhất nếu nó đáng báo và chưa được xem (FR-17).
  final DcaWeek? newDca;

  /// Giá trị F&G mới nhất trong ngày — chỉ BTC, chỉ để hiển thị (FR-15).
  final FearGreedPoint? latestFearGreed;

  /// Vùng của tuần đã đóng gần nhất — Vùng chính thức (AD-5).
  DcaWeek? get latestDca => dcaWeeks.isEmpty ? null : dcaWeeks.last;

  /// Vùng theo RSI **tạm tính** của tuần đang chạy; `null` khi nến cuối đã
  /// đóng. Chỉ để hiển thị kèm nhãn tạm tính, không bao giờ sinh cảnh báo.
  DcaZone? get provisionalZone {
    final rsi = latestRsi;
    if (!isProvisional || rsi == null) return null;
    return dcaZoneOf(symbol, rsi);
  }

  /// Thống kê lịch sử theo Vùng trên chuỗi đang có (FR-18).
  late final List<ZoneStats> zoneStats = computeZoneStats(dcaWeeks);

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
