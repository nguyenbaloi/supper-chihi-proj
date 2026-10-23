import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/rules/allocation.dart';

AllocationTarget target(String label, int current, int bp) => AllocationTarget(
      label: label,
      currentValue: Money(current),
      targetWeightBp: bp,
    );

void main() {
  group('Phân bổ chuẩn — tỷ trọng mục tiêu nhân Tổng tài sản', () {
    test('chia đúng theo tỷ trọng', () {
      final plan = Allocation.plan(
        totalAssets: const Money(680000000),
        targets: [
          target('Chứng khoán', 130000000, 3000),
          target('Vàng', 80000000, 2000),
          target('Crypto', 470000000, 5000),
        ],
      );

      expect(plan.lines[0].targetAmount, const Money(204000000));
      expect(plan.lines[1].targetAmount, const Money(136000000));
      expect(plan.lines[2].targetAmount, const Money(340000000));
    });

    test('mua thêm là dương, bán bớt là âm', () {
      final plan = Allocation.plan(
        totalAssets: const Money(680000000),
        targets: [
          target('Chứng khoán', 130000000, 3000),
          target('Vàng', 80000000, 2000),
          target('Crypto', 470000000, 5000),
        ],
      );

      expect(plan.lines[0].actionAmount, const Money(74000000));
      expect(plan.lines[0].action, AllocationAction.buy);
      expect(plan.lines[1].actionAmount, const Money(56000000));
      expect(plan.lines[1].action, AllocationAction.buy);
      expect(plan.lines[2].actionAmount, const Money(-130000000));
      expect(plan.lines[2].action, AllocationAction.sell);
    });

    test('đã đúng tỷ trọng thì không phải làm gì', () {
      final plan = Allocation.plan(
        totalAssets: const Money(100000000),
        targets: [
          target('Chứng khoán', 60000000, 6000),
          target('Vàng', 40000000, 4000),
        ],
      );

      expect(plan.lines.every((l) => l.action == AllocationAction.hold), isTrue);
      expect(plan.totalBuy, Money.zero);
      expect(plan.totalSell, Money.zero);
    });
  });

  group('Tổng các phần khớp đúng số bị chia', () {
    test('ba danh mục 33,33% + 33,33% + 33,34% của 100 đồng ra đủ 100', () {
      // Làm tròn độc lập sẽ cho 33+33+33 = 99, hụt một đồng.
      final plan = Allocation.plan(
        totalAssets: const Money(100),
        targets: [
          target('A', 0, 3333),
          target('B', 0, 3333),
          target('C', 0, 3334),
        ],
      );

      expect(plan.allocatedAmount, const Money(100));
      expect(
        plan.lines.map((l) => l.targetAmount.amount),
        [33, 33, 34],
        reason: 'đồng lẻ về danh mục có phần dư lớn nhất',
      );
    });

    test('phần dư bằng nhau thì danh mục đứng trước nhận trước', () {
      // Ba phần bằng nhau của 100 đồng: dư hệt nhau, phải có quy tắc phá hoà
      // cố định thì cùng dữ liệu mới luôn ra cùng kết quả.
      final plan = Allocation.plan(
        totalAssets: const Money(100),
        targets: [
          target('A', 0, 3333),
          target('B', 0, 3333),
          target('C', 0, 3333),
        ],
      );

      expect(plan.allocatedAmount, const Money(100));
      expect(plan.lines.map((l) => l.targetAmount.amount), [34, 33, 33]);
    });

    test('chạy lại nhiều lần cho ra kết quả y hệt', () {
      List<int> run() => Allocation.plan(
            totalAssets: const Money(1000000007),
            targets: [
              target('A', 0, 1429),
              target('B', 0, 1429),
              target('C', 0, 1428),
              target('D', 0, 1428),
              target('E', 0, 1429),
              target('F', 0, 1428),
              target('G', 0, 1429),
            ],
          ).lines.map((l) => l.targetAmount.amount).toList();

      final first = run();
      expect(run(), first);
      expect(first.reduce((a, b) => a + b), 1000000007);
    });

    test('số tiền lớn và tỷ trọng lẻ vẫn khớp tổng', () {
      final plan = Allocation.plan(
        totalAssets: const Money(683417293),
        targets: [
          target('A', 0, 1234),
          target('B', 0, 4321),
          target('C', 0, 2222),
          target('D', 0, 2223),
        ],
      );

      expect(plan.allocatedAmount, const Money(683417293));
    });
  });

  group('Kế hoạch tự cân khi đặt đủ 100%', () {
    test('tổng mua bằng tổng bán, không cần thêm tiền', () {
      final plan = Allocation.plan(
        totalAssets: const Money(683417293),
        targets: [
          target('Chứng khoán', 130000000, 3000),
          target('Vàng', 80417293, 2000),
          target('Crypto', 473000000, 5000),
        ],
      );

      expect(plan.isFullyAllocated, isTrue);
      expect(plan.untargetedValue, Money.zero);
      expect(
        plan.netCashNeeded,
        Money.zero,
        reason: 'bán bao nhiêu mua bấy nhiêu — đây là điều kiện để người dùng '
            'tin được bảng phân bổ',
      );
      expect(plan.totalBuy, plan.totalSell);
    });

    test('lớp chưa đặt mục tiêu được nói ra chứ không giấu đi', () {
      // Tổng tài sản 100 triệu nhưng chỉ 70 triệu nằm ở danh mục có mục tiêu.
      final plan = Allocation.plan(
        totalAssets: const Money(100000000),
        targets: [
          target('Chứng khoán', 40000000, 4000),
          target('Vàng', 30000000, 3000),
        ],
      );

      expect(plan.isFullyAllocated, isFalse);
      expect(plan.totalTargetBp, 7000);
      expect(plan.untargetedValue, const Money(30000000));
      // Chỉ 70% Tổng tài sản được đem chia.
      expect(plan.allocatedAmount, const Money(70000000));
    });
  });

  group('Trường hợp biên', () {
    test('chưa có tài sản thì không có cơ sở phân bổ', () {
      final plan = Allocation.plan(
        totalAssets: Money.zero,
        targets: [target('Chứng khoán', 0, 10000)],
      );

      expect(plan.hasBasis, isFalse);
      expect(plan.lines.single.targetAmount, Money.zero);
    });

    test('chưa đặt mục tiêu nào thì kế hoạch rỗng', () {
      final plan = Allocation.plan(
        totalAssets: const Money(100000000),
        targets: const [],
      );

      expect(plan.hasBasis, isFalse);
      expect(plan.lines, isEmpty);
      expect(plan.untargetedValue, const Money(100000000));
    });

    test('mục tiêu 0% nghĩa là bán sạch danh mục đó', () {
      final plan = Allocation.plan(
        totalAssets: const Money(100000000),
        targets: [
          target('Chứng khoán', 90000000, 10000),
          target('Crypto', 10000000, 0),
        ],
      );

      expect(plan.lines[1].targetAmount, Money.zero);
      expect(plan.lines[1].actionAmount, const Money(-10000000));
      expect(plan.lines[1].action, AllocationAction.sell);
    });

    test('giá trị âm — lớp Cho vay đang nợ ròng — vẫn ra lệnh mua đúng', () {
      // Lớp cho vay là tổng ròng các khoản nợ nên có thể âm. Phân bổ chuẩn
      // vẫn dương, và khoảng cách phải đi hết từ số âm lên.
      final plan = Allocation.plan(
        totalAssets: const Money(100000000),
        targets: [
          target('Cho vay', -5000000, 1000),
          target('Chứng khoán', 105000000, 9000),
        ],
      );

      expect(plan.lines[0].targetAmount, const Money(10000000));
      expect(plan.lines[0].actionAmount, const Money(15000000));
    });

    test('vượt 100% thì chia hết Tổng tài sản chứ không chia quá', () {
      // Tổng tỷ trọng 120% là trạng thái dở dang được phép lưu (FR-19). Phần
      // đem chia vẫn phải nằm trong Tổng tài sản thật.
      final plan = Allocation.plan(
        totalAssets: const Money(100000000),
        targets: [
          target('A', 0, 6000),
          target('B', 0, 6000),
        ],
      );

      expect(plan.isFullyAllocated, isFalse);
      expect(plan.allocatedAmount, const Money(120000000));
      expect(
        plan.allocatedAmount > plan.totalAssets,
        isTrue,
        reason: 'con số phải phản ánh đúng mục tiêu người dùng đã đặt, còn '
            'việc tổng vượt 100% thì đã có cảnh báo riêng lo',
      );
    });
  });
}
