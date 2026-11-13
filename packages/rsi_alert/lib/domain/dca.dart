import 'dart:math' as math;

import 'candle.dart';
import 'constants.dart';
import 'fear_greed.dart';
import 'market_symbol.dart';
import 'rsi.dart';

/// Năm Vùng DCA theo Cẩm nang của người dùng (FR-14).
///
/// App chỉ **xếp vùng** và **trích lại luật** người dùng tự viết cho vùng đó;
/// nó không tự đưa lời khuyên (PRD §5).
enum DcaZone {
  strongBuy,
  probeBuy,
  hold,
  probeSell,
  strongSell;

  bool get isBuy => this == strongBuy || this == probeBuy;
  bool get isSell => this == probeSell || this == strongSell;
}

DcaThresholds dcaThresholdsOf(MarketSymbol symbol) => switch (symbol) {
      MarketSymbol.btc => btcDcaThresholds,
      MarketSymbol.vnindex => vnindexDcaThresholds,
    };

DcaZone dcaZoneOf(MarketSymbol symbol, double rsi) {
  final t = dcaThresholdsOf(symbol);
  if (rsi <= t.strongBuyMax) return DcaZone.strongBuy;
  if (rsi <= t.probeBuyMax) return DcaZone.probeBuy;
  if (rsi <= t.holdMax) return DcaZone.hold;
  if (rsi <= t.probeSellMax) return DcaZone.probeSell;
  return DcaZone.strongSell;
}

/// Một tuần đã đóng, đã xếp Vùng (FR-14). Luôn suy ra, không bao giờ lưu (AD-2).
class DcaWeek {
  const DcaWeek({
    required this.symbol,
    required this.candleIndex,
    required this.weekOpenTime,
    required this.close,
    required this.rsi,
    required this.zone,
    required this.weeksInZone,
    required this.fearGreed,
    required this.bearishDivergence,
  });

  final MarketSymbol symbol;

  /// Chỉ số trong chuỗi nến đã lọc `isClosed` — cùng quy ước với `Signal`.
  final int candleIndex;
  final DateTime weekOpenTime;
  final double close;
  final double rsi;
  final DcaZone zone;

  /// Số tuần đã đóng liên tiếp nằm trong [zone], tính cả tuần này (≥ 1).
  final int weeksInZone;

  /// F&G crypto tại ngày đóng nến; luôn `null` với VNINDEX vì không có nguồn.
  final int? fearGreed;

  /// Phân kỳ giảm khung tuần vừa được xác nhận ở tuần này (FR-16).
  final bool bearishDivergence;

  /// F&G cùng chiều và ở mức cực độ với Vùng — mức "tăng cường" (FR-15).
  ///
  /// F&G **không** chặn Vùng: đáy BTC 11/2022 ($15.5k) có F&G 22–26, một cổng
  /// "F&G < 20" bắt buộc sẽ bỏ lỡ đúng đáy đó.
  bool get fearGreedConfirms {
    final fg = fearGreed;
    if (fg == null) return false;
    if (zone.isBuy) return fg <= fearGreedExtremeFearMax;
    if (zone.isSell) return fg >= fearGreedExtremeGreedMin;
    return false;
  }

  /// Tuần này có điều gì để báo không — Vùng khác Nắm giữ, hoặc có phân kỳ.
  bool get isNotable => zone != DcaZone.hold || bearishDivergence;
}

/// Xếp Vùng cho mọi Nến đã đóng có RSI (FR-14, FR-15, FR-16).
///
/// Chỉ nhận Nến đã đóng (AD-5): nến đang chạy bị bỏ qua dù có trong [candles].
/// Kết quả xếp theo thời gian tăng dần.
List<DcaWeek> classifyDcaWeeks(
  MarketSymbol symbol,
  List<Candle> candles, {
  List<FearGreedPoint> fearGreed = const [],
}) {
  final closed = candles.where((c) => c.isClosed).toList(growable: false);
  final points = computeRsi([for (final c in closed) c.close]);
  if (points.isEmpty) return const [];

  final rsi = List<double?>.filled(closed.length, null);
  for (final p in points) {
    rsi[p.candleIndex] = p.value;
  }
  final closes = [for (final c in closed) c.close];
  final fgIndex = symbol == MarketSymbol.btc ? indexFearGreed(fearGreed) : null;
  final thresholds = dcaThresholdsOf(symbol);

  final weeks = <DcaWeek>[];
  for (final p in points) {
    final i = p.candleIndex;
    final zone = dcaZoneOf(symbol, p.value);
    final previous = weeks.isEmpty ? null : weeks.last;
    weeks.add(
      DcaWeek(
        symbol: symbol,
        candleIndex: i,
        weekOpenTime: closed[i].openTime,
        close: closed[i].close,
        rsi: p.value,
        zone: zone,
        weeksInZone:
            previous != null && previous.zone == zone ? previous.weeksInZone + 1 : 1,
        fearGreed: fgIndex == null
            ? null
            : fearGreedAtWeekClose(fgIndex, closed[i].openTime),
        bearishDivergence: _bearishDivergenceAt(i, closes, rsi, thresholds),
      ),
    );
  }
  return weeks;
}

/// Phân kỳ giảm khung tuần tại tuần [i] (FR-16).
///
/// Cẩm nang mô tả: "giá vượt đỉnh cũ nhưng RSI tuần tạo đỉnh sau thấp hơn đỉnh
/// trước". Điều kiện xác nhận "RSI cắt xuống dưới 70" của Cẩm nang **không**
/// dùng được: dữ liệu thật cho thấy ở đỉnh cuối chu kỳ RSI không hề vượt 70
/// (BTC 11/2021 đỉnh RSI 68.8; 10/2025 đỉnh RSI 64.3). Vì vậy tín hiệu bật
/// ngay tại tuần giá lập đỉnh mới — "bán trên đường giá tăng":
///
/// 1. Giá đóng tuần [i] cao nhất trong [divergenceLookbackWeeks] tuần.
/// 2. Trước đó trong cửa sổ có một tuần `j` với RSI đã vào Vùng 5, cao nhất cửa
///    sổ, và giá thấp hơn tuần [i].
/// 3. RSI tuần [i] thấp hơn RSI tuần `j`.
/// 4. Giữa `j` và [i], RSI đã có lúc lùi về Vùng Nắm giữ trở xuống — hai nhịp
///    tăng tách biệt, không phải hai tuần của cùng một nhịp.
bool _bearishDivergenceAt(
  int i,
  List<double> closes,
  List<double?> rsi,
  DcaThresholds t,
) {
  final now = rsi[i];
  if (now == null) return false;

  final start = math.max(0, i - divergenceLookbackWeeks);
  for (var x = start; x < i; x++) {
    if (closes[x] >= closes[i]) return false;
  }

  int? j;
  for (var x = start; x < i; x++) {
    final r = rsi[x];
    if (r == null) continue;
    if (j == null || r > rsi[j]!) j = x;
  }
  if (j == null) return false;

  final rj = rsi[j]!;
  if (rj <= t.probeSellMax || now >= rj) return false;

  for (var x = j + 1; x < i; x++) {
    final r = rsi[x];
    if (r != null && r <= t.holdMax) return true;
  }
  return false;
}

/// Thống kê lịch sử của một Vùng trên chính chuỗi dữ liệu đang có (FR-18).
///
/// Để người dùng tự đánh giá luật của mình, không phải tin app.
class ZoneStats {
  const ZoneStats({
    required this.zone,
    required this.weeks,
    required this.samples,
    required this.medianReturnPct,
    required this.positiveSharePct,
  });

  final DcaZone zone;

  /// Tổng số tuần đã đóng từng nằm trong Vùng.
  final int weeks;

  /// Số tuần đủ [zoneStatsHorizonWeeks] tuần dữ liệu phía sau để đo.
  final int samples;

  /// Trung vị % thay đổi giá sau [zoneStatsHorizonWeeks] tuần; `null` khi
  /// chưa có mẫu nào.
  final double? medianReturnPct;

  /// Tỉ lệ % số mẫu có giá cao hơn sau [zoneStatsHorizonWeeks] tuần.
  final double? positiveSharePct;
}

List<ZoneStats> computeZoneStats(List<DcaWeek> weeks) {
  // `weeks` có thể bắt đầu muộn hơn chuỗi nến (14 nến đầu không có RSI), nên
  // tra theo candleIndex chứ không theo vị trí trong danh sách.
  final closeAt = {for (final w in weeks) w.candleIndex: w.close};
  return [
    for (final zone in DcaZone.values)
      () {
        final inZone = weeks.where((w) => w.zone == zone).toList();
        final returns = <double>[
          for (final w in inZone)
            if (closeAt[w.candleIndex + zoneStatsHorizonWeeks] case final later?)
              (later / w.close - 1) * 100,
        ]..sort();
        return ZoneStats(
          zone: zone,
          weeks: inZone.length,
          samples: returns.length,
          medianReturnPct: returns.isEmpty ? null : _median(returns),
          positiveSharePct: returns.isEmpty
              ? null
              : returns.where((r) => r > 0).length / returns.length * 100,
        );
      }(),
  ];
}

double _median(List<double> sorted) {
  final mid = sorted.length ~/ 2;
  return sorted.length.isOdd ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
}
