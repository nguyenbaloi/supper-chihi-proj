import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/format/vn_format.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/models/fx_rate.dart';
import 'package:personal_finance/domain/rules/effective_fx_rate.dart';
import 'package:personal_finance/domain/rules/rebalancing.dart';

void main() {
  group('Khoảng lệch so với mục tiêu', () {
    // Crypto 390 triệu trên tổng 680 triệu là 57,4%, mục tiêu 50%.
    final drift = TargetDrift(
      label: 'Crypto',
      currentValue: const Money(390000000),
      actualWeight: const Money(390000000)
          .ratioTo(const Money(680000000)),
      targetWeightBp: 5000,
      totalAssets: const Money(680000000),
    );

    test('lệch +7,4% và khoảng 50 triệu', () {
      expect(VnFormat.percent(drift.weightDrift!), '7,4%');
      // 0,0735294... × 680 triệu ≈ 50 triệu.
      expect(drift.amountDrift!.amount, closeTo(50000000, 100000));
      expect(VnFormat.moneyCompact(drift.amountDrift!), '50 tr');
    });

    test('đang thừa chứ không thiếu', () {
      expect(drift.isOver, isTrue);
      expect(drift.isUnder, isFalse);
    });

    test('khoảng lệch quy ra tiền bằng hiệu tỷ trọng nhân tổng tài sản', () {
      final expected = Money.fromDecimal(
        drift.weightDrift! * const Money(680000000).asDecimal,
      );
      expect(drift.amountDrift, expected);
    });

    test('lớp đang thiếu cho giá trị âm', () {
      final under = TargetDrift(
        label: 'Vàng',
        currentValue: const Money(92000000),
        actualWeight:
            const Money(92000000).ratioTo(const Money(680000000)),
        targetWeightBp: 2000,
        totalAssets: const Money(680000000),
      );
      expect(under.isUnder, isTrue);
      expect(under.amountDrift!.isNegative, isTrue);
      expect(VnFormat.percent(under.weightDrift!), '-6,5%');
    });

    test('tổng tài sản bằng 0 thì không có khoảng lệch', () {
      const empty = TargetDrift(
        label: 'Crypto',
        currentValue: Money.zero,
        actualWeight: null,
        targetWeightBp: 5000,
        totalAssets: Money.zero,
      );
      expect(empty.weightDrift, isNull);
      expect(empty.amountDrift, isNull);
      expect(empty.isOver, isFalse);
      expect(empty.isUnder, isFalse);
    });
  });

  group('Ngưỡng cảnh báo', () {
    TargetDrift driftOf(int valueMillions, int targetBp) => TargetDrift(
          label: 'X',
          currentValue: Money(valueMillions * 1000000),
          actualWeight: Money(valueMillions * 1000000)
              .ratioTo(const Money(680000000)),
          targetWeightBp: targetBp,
          totalAssets: const Money(680000000),
        );

    test('lệch 7,4% vượt ngưỡng 5%', () {
      expect(driftOf(390, 5000).exceedsThreshold(500), isTrue);
    });

    test('lệch dưới ngưỡng thì không cảnh báo', () {
      // 340/680 là đúng 50%, lệch 0.
      expect(driftOf(340, 5000).exceedsThreshold(500), isFalse);
    });

    test('lệch âm quá ngưỡng cũng cảnh báo', () {
      expect(driftOf(92, 2000).exceedsThreshold(500), isTrue);
    });

    test('chưa tính được tỷ trọng thì không cảnh báo', () {
      const empty = TargetDrift(
        label: 'X',
        currentValue: Money.zero,
        actualWeight: null,
        targetWeightBp: 5000,
        totalAssets: Money.zero,
      );
      expect(empty.exceedsThreshold(500), isFalse);
    });
  });

  group('Tổng tỷ trọng mục tiêu', () {
    test('BTC 50%, Tiền mặt & Cho vay 30%, Vàng & Chứng khoán 20% là đủ 100%',
        () {
      expect(Rebalancing.totalTargetBp([5000, 3000, 2000]), 10000);
      expect(Rebalancing.isBalanced([5000, 3000, 2000]), isTrue);
    });

    test('khác 100% vẫn nhận biết được để cảnh báo', () {
      expect(Rebalancing.isBalanced([5000, 3000]), isFalse);
      expect(Rebalancing.totalTargetBp([5000, 3000]), 8000);
    });
  });

  group('Tỷ giá đang dùng', () {
    final fetched = FxRate(
      rateAmount: const Money(25400),
      source: PriceSource.api,
      fetchedAt: DateTime.utc(2026, 8, 27),
    );

    test('tỷ giá nhập tay thắng tỷ giá lấy tự động', () {
      final rate = EffectiveFxRate.resolve(
        manualRate: const Money(25000),
        fetchedRate: fetched,
      );
      expect(rate.rateAmount, const Money(25000));
      expect(rate.source, PriceSource.manual);
      expect(rate.isFallback, isFalse);
    });

    test('không nhập tay thì dùng tỷ giá lấy tự động', () {
      final rate = EffectiveFxRate.resolve(fetchedRate: fetched);
      expect(rate.rateAmount, const Money(25400));
      expect(rate.fetchedAt, DateTime.utc(2026, 8, 27));
    });

    test('chưa có gì thì dùng dự phòng và ghi rõ là dự phòng', () {
      final rate = EffectiveFxRate.resolve();
      expect(rate.rateAmount, EffectiveFxRate.fallbackRate);
      expect(rate.isFallback, isTrue);
    });
  });
}
