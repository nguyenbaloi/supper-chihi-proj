import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';

void main() {
  group('Money — lưu trữ không mất chính xác', () {
    test('giữ nguyên giá trị lớn cỡ danh mục thật', () {
      const total = Money(680000000);
      expect(total.amount, 680000000);
    });

    test('cộng dồn nhiều khoản không sinh sai số', () {
      // Đây chính là phép cộng mà double làm sai: 0,1 + 0,2 != 0,3.
      // Với đơn vị đồng và kiểu int, phép cộng luôn đúng tuyệt đối.
      final values = List.generate(1000, (_) => const Money(1));
      expect(Money.sum(values), const Money(1000));
    });

    test('tổng bốn lớp tài sản khớp đúng số trong Excel', () {
      const stock = Money(15000000);
      const gold = Money(92000000);
      const bitcoin = Money(390000000);
      const lendingAndCash = Money(183000000);
      expect(
        Money.sum([stock, gold, bitcoin, lendingAndCash]),
        const Money(680000000),
      );
    });

    test('tổng của dãy rỗng là 0', () {
      expect(Money.sum([]), Money.zero);
    });
  });

  group('Money — phép toán', () {
    test('cộng, trừ, đảo dấu', () {
      expect(const Money(300) + const Money(41), const Money(341));
      expect(const Money(341) - const Money(60), const Money(281));
      expect(-const Money(60), const Money(-60));
    });

    test('nhân với hệ số làm tròn nửa lên về đồng', () {
      // 100 x 1,005 = 100,5 -> 101
      expect(
        const Money(100).multiply(Decimal.parse('1.005')),
        const Money(101),
      );
      // 100 x 1,004 = 100,4 -> 100
      expect(
        const Money(100).multiply(Decimal.parse('1.004')),
        const Money(100),
      );
    });

    test('so sánh', () {
      expect(const Money(10) < const Money(20), isTrue);
      expect(const Money(20) >= const Money(20), isTrue);
      expect(const Money(-5).isNegative, isTrue);
      expect(Money.zero.isZero, isTrue);
    });
  });

  group('Money — tỷ trọng', () {
    test('cho ra đúng các tỷ trọng trong Excel', () {
      const total = Money(680000000);
      String weight(int amount) {
        final ratio = Money(amount).ratioTo(total)!;
        return (ratio * Decimal.fromInt(100)).toStringAsFixed(1);
      }

      expect(weight(15000000), '2.2');
      expect(weight(92000000), '13.5');
      expect(weight(390000000), '57.4');
      expect(weight(183000000), '26.9');
    });

    test('tỷ trọng nội bộ lớp crypto khớp Excel', () {
      const total = Money(15000);
      String weight(int amount) {
        final ratio = Money(amount).ratioTo(total)!;
        return (ratio * Decimal.fromInt(100)).toStringAsFixed(1);
      }

      expect(weight(12500), '83.3');
      expect(weight(2500), '16.7');
    });

    test('chia cho 0 trả về null thay vì một con số vô nghĩa', () {
      expect(const Money(100).ratioTo(Money.zero), isNull);
    });
  });
}
