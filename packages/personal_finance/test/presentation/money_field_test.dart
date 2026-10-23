import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/presentation/widgets/money_field.dart';

void main() {
  group('Tiền đồng — không có phần thập phân', () {
    test('chuỗi ngăn nghìn ra đúng số đồng', () {
      expect(parseAmount('680.000.000', 0), const Money(680000000));
      expect(parseAmount('341.000.000', 0), const Money(341000000));
    });

    test('hiển thị lại đúng như đã nhập', () {
      expect(formatAmount(const Money(680000000), 0), '680.000.000');
      expect(formatAmount(const Money(1000), 0), '1.000');
    });

    test('0 đồng để ô nhập trống cho nhãn gợi ý hiện ra', () {
      expect(formatAmount(Money.zero, 0), '');
      expect(parseAmount('', 0), Money.zero);
    });
  });

  group('Đô la Mỹ — lưu bằng xu', () {
    test('67.432,18 USD ra đúng 6.743.218 xu', () {
      expect(parseAmount('67.432,18', 2), const Money(6743218));
    });

    test('67.432 USD chẵn ra 6.743.200 xu, không phải 67.432', () {
      // Đây chính là lỗi sai một trăm lần: coi chuỗi chữ số là xu thì
      // 67.432 USD thành 674,32 USD.
      expect(parseAmount('67.432', 2), const Money(6743200));
    });

    test('một xu lẻ vẫn giữ', () {
      expect(parseAmount('0,01', 2), const Money(1));
      expect(parseAmount('1,05', 2), const Money(105));
    });

    test('hiển thị lại bỏ số 0 thừa nhưng giữ xu thật', () {
      expect(formatAmount(const Money(6743218), 2), '67.432,18');
      expect(formatAmount(const Money(6743200), 2), '67.432');
      expect(formatAmount(const Money(105), 2), '1,05');
      expect(formatAmount(const Money(1), 2), '0,01');
    });

    test('đi vòng qua lại không mất giá trị', () {
      for (final cents in [1, 105, 6743218, 100000000]) {
        final amount = Money(cents);
        expect(parseAmount(formatAmount(amount, 2), 2), amount);
      }
    });
  });

  group('Số âm', () {
    test('giữ dấu qua cả hai chiều', () {
      expect(formatAmount(const Money(-60000000), 0), '-60.000.000');
      expect(parseAmount('-60.000.000', 0), const Money(-60000000));
    });
  });
}
