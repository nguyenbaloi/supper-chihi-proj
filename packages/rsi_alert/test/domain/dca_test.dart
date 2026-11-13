import 'package:flutter_test/flutter_test.dart';
import 'package:rsi_alert/domain/candle.dart';
import 'package:rsi_alert/domain/constants.dart';
import 'package:rsi_alert/domain/dca.dart';
import 'package:rsi_alert/domain/fear_greed.dart';
import 'package:rsi_alert/domain/market_symbol.dart';

import 'signal_test.dart' show candlesWithRsi;

/// F&G hằng số cho mọi ngày phủ chuỗi nến của [candlesWithRsi].
List<FearGreedPoint> constantFearGreed(int value, List<Candle> candles) {
  final first = candles.first.openTime;
  final days = candles.length * 7 + 7;
  return [
    for (var d = 0; d < days; d++)
      FearGreedPoint(
        day: DateTime.utc(first.year, first.month, first.day + d),
        value: value,
      ),
  ];
}

void main() {
  group('dcaZoneOf — FR-14, ranh giới "≤" của Cẩm nang', () {
    test('BTC 35 / 45 / 70 / 82', () {
      expect(dcaZoneOf(MarketSymbol.btc, 35.0), DcaZone.strongBuy);
      expect(dcaZoneOf(MarketSymbol.btc, 35.1), DcaZone.probeBuy);
      expect(dcaZoneOf(MarketSymbol.btc, 45.0), DcaZone.probeBuy);
      expect(dcaZoneOf(MarketSymbol.btc, 45.1), DcaZone.hold);
      expect(dcaZoneOf(MarketSymbol.btc, btcDcaThresholds.holdMax), DcaZone.hold);
      expect(dcaZoneOf(MarketSymbol.btc, 70.1), DcaZone.probeSell);
      expect(dcaZoneOf(MarketSymbol.btc, 82.0), DcaZone.probeSell);
      expect(dcaZoneOf(MarketSymbol.btc, 82.1), DcaZone.strongSell);
    });

    test('VNINDEX dùng bảng riêng 32 / 40 / 68 / 76', () {
      expect(dcaZoneOf(MarketSymbol.vnindex, 32.0), DcaZone.strongBuy);
      expect(dcaZoneOf(MarketSymbol.vnindex, 33.0), DcaZone.probeBuy);
      expect(dcaZoneOf(MarketSymbol.vnindex, 40.1), DcaZone.hold);
      expect(dcaZoneOf(MarketSymbol.vnindex, 68.1), DcaZone.probeSell);
      expect(dcaZoneOf(MarketSymbol.vnindex, 76.1), DcaZone.strongSell);
      // Cùng giá trị, khác Mã, khác Vùng.
      expect(dcaZoneOf(MarketSymbol.btc, 34.0), DcaZone.strongBuy);
      expect(dcaZoneOf(MarketSymbol.vnindex, 34.0), DcaZone.probeBuy);
    });
  });

  group('classifyDcaWeeks — FR-14', () {
    test('đếm số tuần liên tiếp trong cùng Vùng', () {
      final weeks = classifyDcaWeeks(
        MarketSymbol.btc,
        candlesWithRsi([55.0, 42, 40, 33, 30, 41]),
      );
      final tail = weeks.sublist(weeks.length - 6);
      expect(tail.map((w) => w.zone), [
        DcaZone.hold,
        DcaZone.probeBuy,
        DcaZone.probeBuy,
        DcaZone.strongBuy,
        DcaZone.strongBuy,
        DcaZone.probeBuy,
      ]);
      expect(tail.map((w) => w.weeksInZone), [
        // Tuần đầu cũng là Nắm giữ như phần mồi phía trước.
        tail.first.weeksInZone, 1, 2, 1, 2, 1,
      ]);
    });

    test('AD-5: nến đang chạy không được xếp Vùng', () {
      final candles = candlesWithRsi([55.0, 50, 25], lastOpen: true);
      final weeks = classifyDcaWeeks(MarketSymbol.btc, candles);
      expect(weeks.last.weekOpenTime, candles[candles.length - 2].openTime);
      expect(weeks.last.zone, DcaZone.hold);
    });

    test('chưa đủ 15 nến đã đóng thì rỗng, không ném', () {
      final candles = candlesWithRsi([]).sublist(0, 10);
      expect(classifyDcaWeeks(MarketSymbol.btc, candles), isEmpty);
    });
  });

  group('Fear & Greed — FR-15', () {
    test('Sợ hãi cực độ cùng chiều Vùng mua là tăng cường', () {
      final candles = candlesWithRsi([55.0, 40, 30]);
      final weeks = classifyDcaWeeks(
        MarketSymbol.btc,
        candles,
        fearGreed: constantFearGreed(fearGreedExtremeFearMax, candles),
      );
      expect(weeks.last.zone, DcaZone.strongBuy);
      expect(weeks.last.fearGreed, fearGreedExtremeFearMax);
      expect(weeks.last.fearGreedConfirms, isTrue);
    });

    test('F&G không chặn Vùng — đáy 11/2022 có F&G 22–26', () {
      final candles = candlesWithRsi([55.0, 40, 30]);
      final weeks = classifyDcaWeeks(
        MarketSymbol.btc,
        candles,
        fearGreed: constantFearGreed(fearGreedExtremeFearMax + 2, candles),
      );
      expect(weeks.last.zone, DcaZone.strongBuy);
      expect(weeks.last.fearGreedConfirms, isFalse);
    });

    test('VNINDEX không bao giờ gắn F&G', () {
      final candles = candlesWithRsi([55.0, 40, 30]);
      final weeks = classifyDcaWeeks(
        MarketSymbol.vnindex,
        candles,
        fearGreed: constantFearGreed(10, candles),
      );
      expect(weeks.every((w) => w.fearGreed == null), isTrue);
    });

    test('lấy giá trị ngày Chủ nhật đóng nến, lùi tối đa 3 ngày, không nhìn trước',
        () {
      final monday = DateTime.utc(2026, 11, 2);
      int? at(Map<DateTime, int> values) => fearGreedAtWeekClose(
            indexFearGreed([
              for (final e in values.entries)
                FearGreedPoint(day: e.key, value: e.value),
            ]),
            monday,
          );

      expect(at({DateTime.utc(2026, 11, 8): 28}), 28);
      expect(at({DateTime.utc(2026, 11, 6): 31}), 31);
      expect(at({DateTime.utc(2026, 11, 4): 40}), isNull);
      expect(at({DateTime.utc(2026, 11, 9): 20}), isNull,
          reason: 'thứ Hai tuần sau là tương lai so với lúc nến đóng');
    });

    test('FearGreedLevel theo cột Crypto của Cẩm nang', () {
      expect(FearGreedLevel.of(24), FearGreedLevel.extremeFear);
      expect(FearGreedLevel.of(25), FearGreedLevel.fear);
      expect(FearGreedLevel.of(43), FearGreedLevel.neutral);
      expect(FearGreedLevel.of(71), FearGreedLevel.greed);
      expect(FearGreedLevel.of(83), FearGreedLevel.extremeGreed);
    });
  });

  group('Phân kỳ giảm tuần — FR-16', () {
    // Nhịp 1 đẩy RSI lên 88 (Vùng 5), lùi về 60, rồi nhịp 2 kéo giá lên đỉnh
    // mới trong khi RSI chỉ tới ~78.
    final twoWaves = <double>[60, 75, 88, 70, 60, 58, 66, 72, 76, 78];

    test('giá lập đỉnh mới, RSI thấp hơn đỉnh nóng trước → có phân kỳ', () {
      final candles = candlesWithRsi(twoWaves);
      final weeks = classifyDcaWeeks(MarketSymbol.btc, candles);
      final hot = weeks.reduce((a, b) => a.rsi > b.rsi ? a : b);
      final last = weeks.last;

      // Tiền đề của kịch bản: đúng là giá cao hơn, RSI thấp hơn.
      expect(last.close, greaterThan(hot.close));
      expect(last.rsi, lessThan(hot.rsi));
      expect(last.bearishDivergence, isTrue);
      expect(last.isNotable, isTrue);
    });

    test('một nhịp liền mạch (RSI chưa lùi về Nắm giữ) → không phân kỳ', () {
      final weeks = classifyDcaWeeks(
        MarketSymbol.btc,
        candlesWithRsi([60.0, 75, 88, 84, 80, 78]),
      );
      expect(weeks.any((w) => w.bearishDivergence), isFalse);
    });

    test('đỉnh RSI trước chưa vào Vùng 5 → không phân kỳ', () {
      final weeks = classifyDcaWeeks(
        MarketSymbol.btc,
        candlesWithRsi([60.0, 75, 80, 70, 60, 58, 66, 72, 76, 78]),
      );
      expect(weeks.any((w) => w.bearishDivergence), isFalse);
    });
  });

  group('computeZoneStats — FR-18', () {
    test('đếm tuần mỗi Vùng; thiếu dữ liệu phía sau thì không bịa số', () {
      final weeks = classifyDcaWeeks(
        MarketSymbol.btc,
        candlesWithRsi([55.0, 40, 30]),
      );
      final stats = {for (final s in computeZoneStats(weeks)) s.zone: s};

      expect(stats[DcaZone.strongBuy]!.weeks, 1);
      expect(stats[DcaZone.probeBuy]!.weeks, 1);
      expect(stats[DcaZone.strongBuy]!.samples, 0);
      expect(stats[DcaZone.strongBuy]!.medianReturnPct, isNull);
      expect(
        stats.values.fold<int>(0, (sum, s) => sum + s.weeks),
        weeks.length,
      );
    });

    test('đo đúng % thay đổi sau đúng $zoneStatsHorizonWeeks tuần', () {
      final candles = candlesWithRsi([
        30.0,
        for (var i = 0; i < zoneStatsHorizonWeeks; i++) 55,
      ]);
      final weeks = classifyDcaWeeks(MarketSymbol.btc, candles);
      final entry = weeks.firstWhere((w) => w.zone == DcaZone.strongBuy);
      final later = weeks.firstWhere(
        (w) => w.candleIndex == entry.candleIndex + zoneStatsHorizonWeeks,
      );
      final stats = computeZoneStats(weeks)
          .firstWhere((s) => s.zone == DcaZone.strongBuy);

      expect(stats.samples, 1);
      expect(stats.medianReturnPct,
          closeTo((later.close / entry.close - 1) * 100, 1e-9));
    });
  });
}
