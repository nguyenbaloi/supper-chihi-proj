import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/core/money/quantity.dart';

void main() {
  group('Quantity — không mất chữ số thập phân', () {
    test('BTC giữ đủ 8 chữ số', () {
      final q = Quantity.parse('0.12345678', 8);
      expect(q.raw, 12345678);
      expect(q.toPlainString(), '0.12345678');
    });

    test('một satoshi vẫn phân biệt được với 0', () {
      final one = Quantity.parse('0.00000001', 8);
      expect(one.raw, 1);
      expect(one.isZero, isFalse);
    });

    test('vàng tính theo chỉ với 2 chữ số', () {
      final q = Quantity.parse('7.25', 2);
      expect(q.raw, 725);
      expect(q.toPlainString(), '7.25');
    });

    test('cổ phiếu là số nguyên', () {
      final q = Quantity.parse('100', 0);
      expect(q.raw, 100);
      expect(q.toPlainString(), '100');
    });

    test('bỏ chữ số 0 thừa ở cuối', () {
      expect(Quantity.parse('0.12000000', 8).toPlainString(), '0.12');
      expect(Quantity.parse('7.00', 2).toPlainString(), '7');
    });

    test('từ chối số vượt quá độ chính xác thay vì lặng lẽ làm tròn', () {
      // Người dùng gõ 9 chữ số vào tài sản chỉ nhận 8 — cắt bớt âm thầm là
      // thay đổi số lượng họ khai báo, nên phải báo lỗi.
      expect(
        () => Quantity.parse('0.123456789', 8),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => Quantity.parse('7.255', 2),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('chuỗi sai định dạng bị từ chối', () {
      expect(() => Quantity.parse('abc', 8), throwsFormatException);
    });
  });

  group('Quantity — phép toán', () {
    test('cộng trừ cùng độ chính xác', () {
      final a = Quantity.parse('0.12', 8);
      final b = Quantity.parse('0.01', 8);
      expect((a + b).toPlainString(), '0.13');
      expect((a - b).toPlainString(), '0.11');
    });

    test('từ chối cộng hai số lượng khác độ chính xác', () {
      expect(
        () => Quantity.parse('1', 8) + Quantity.parse('1', 2),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Quantity — quy đổi ra tiền', () {
    test('nhân số lượng với đơn giá', () {
      // 0,13 BTC x 2.600.000.000 đ/BTC = 338.000.000 đ
      final btc = Quantity.parse('0.13', 8);
      expect(btc.valueAt(const Money(2600000000)), const Money(338000000));
    });

    test('100 cổ FPT giá 150.000 đ ra đúng 15 triệu', () {
      final fpt = Quantity.parse('100', 0);
      expect(fpt.valueAt(const Money(150000)), const Money(15000000));
    });

    test('7 chỉ vàng giá 13.142.857 đ/chỉ', () {
      final gold = Quantity.parse('7', 2);
      expect(gold.valueAt(const Money(13142857)), const Money(91999999));
    });

    test('làm tròn chỉ xảy ra một lần ở bước cuối', () {
      // Ba khoản, mỗi khoản có phần lẻ 0,5 đồng. Nếu làm tròn từng khoản rồi
      // cộng lại sẽ ra 3; tính đúng phải cho từng khoản ra 1 (nửa lên) — điểm
      // mấu chốt là phép nhân giữ nguyên độ chính xác trước khi làm tròn.
      final q = Quantity.parse('0.5', 1);
      expect(q.valueAt(const Money(1)), const Money(1));
    });

    test('số lượng rất nhỏ nhân giá rất lớn không tràn', () {
      // 0,00000001 BTC x 2.600.000.000 đ = 26 đồng
      final tiny = Quantity.parse('0.00000001', 8);
      expect(tiny.valueAt(const Money(2600000000)), const Money(26));
    });

    test('asDecimal cho đúng giá trị thập phân', () {
      expect(
        Quantity.parse('0.12345678', 8).asDecimal,
        Decimal.parse('0.12345678'),
      );
    });
  });
}
