import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/models/debt.dart';
import 'package:personal_finance/domain/rules/debt_math.dart';

Money _m(int millions) => Money(millions * 1000000);

Debt _debt(int id, String name, int millions, {DateTime? settledAt}) => Debt(
      id: id,
      personName: name,
      amount: _m(millions),
      date: DateTime.utc(2026, 8, 27),
      settledAt: settledAt,
    );

void main() {
  group('Tổng hợp sổ nợ theo đúng số liệu Excel gốc', () {
    // 63, 30, 30, 0, 20 cho vay và −10 đi vay.
    final debts = [
      _debt(1, 'Anh Thắng', 63),
      _debt(2, 'Chị Hà', 30),
      _debt(3, 'Anh Dũng', 30),
      _debt(4, 'Cô Lan', 0),
      _debt(5, 'Anh Nam', 20),
      _debt(6, 'Ngân hàng', -10),
    ];

    test('tổng cho vay 143, tổng đi vay 10, tổng ròng 133', () {
      final totals = DebtMath.totals(debts);
      expect(totals.lent, _m(143));
      expect(totals.borrowed, _m(10));
      expect(totals.net, _m(133));
    });

    test('giá trị lớp Cho vay bằng đúng tổng ròng', () {
      expect(DebtMath.lendingClassValue(debts), _m(133));
    });

    test('khoản 0 đồng không làm hỏng tổng', () {
      expect(DebtMath.totals([_debt(1, 'Cô Lan', 0)]).net, Money.zero);
    });

    test('sổ nợ rỗng cho tổng ròng 0', () {
      expect(DebtMath.lendingClassValue(const []), Money.zero);
    });
  });

  group('Khoản đã tất toán', () {
    test('rời khỏi tổng ròng', () {
      final debts = [
        _debt(1, 'Anh Thắng', 63, settledAt: DateTime.utc(2026, 9, 1)),
        _debt(2, 'Chị Hà', 30),
        _debt(3, 'Anh Dũng', 30),
        _debt(4, 'Cô Lan', 0),
        _debt(5, 'Anh Nam', 20),
        _debt(6, 'Ngân hàng', -10),
      ];

      // 133 trừ đi đúng 63 của anh Thắng.
      expect(DebtMath.lendingClassValue(debts), _m(70));
      expect(DebtMath.totals(debts).lent, _m(80));
    });

    test('khoản đi vay đã tất toán cũng rời khỏi tổng', () {
      final debts = [
        _debt(1, 'Chị Hà', 30),
        _debt(2, 'Ngân hàng', -10, settledAt: DateTime.utc(2026, 9, 1)),
      ];
      expect(DebtMath.totals(debts).borrowed, Money.zero);
      expect(DebtMath.lendingClassValue(debts), _m(30));
    });

    test('bỏ đánh dấu tất toán thì khoản quay lại tổng', () {
      final settled = _debt(1, 'Anh Thắng', 63,
          settledAt: DateTime.utc(2026, 9, 1));
      final reopened = _debt(1, 'Anh Thắng', 63);

      expect(DebtMath.lendingClassValue([settled]), Money.zero);
      expect(DebtMath.lendingClassValue([reopened]), _m(63));
    });
  });

  group('Chỉ đi vay', () {
    test('tổng ròng là số âm', () {
      final debts = [_debt(1, 'Ngân hàng', -50)];
      expect(DebtMath.totals(debts).net, _m(-50));
      expect(debts.single.isBorrowed, isTrue);
      expect(debts.single.isLent, isFalse);
    });
  });
}
