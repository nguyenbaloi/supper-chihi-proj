import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/format/vn_format.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/core/money/quantity.dart';

void main() {
  group('Số tiền đầy đủ', () {
    test('680.000.000 đồng hiện đúng dấu chấm ngăn nghìn', () {
      expect(VnFormat.money(const Money(680000000)), '680.000.000 đ');
    });

    test('số nhỏ không bị chèn dấu thừa', () {
      expect(VnFormat.money(const Money(0)), '0 đ');
      expect(VnFormat.money(const Money(7)), '7 đ');
      expect(VnFormat.money(const Money(999)), '999 đ');
      expect(VnFormat.money(const Money(1000)), '1.000 đ');
    });

    test('số âm giữ dấu trừ trước chữ số đầu', () {
      // Lãi lỗ âm là chuyện thường xuyên, xem bộ đối chiếu 10 dòng.
      expect(VnFormat.money(const Money(-39000000)), '-39.000.000 đ');
    });

    test('giá trị lớn cỡ nghìn tỷ vẫn nhóm đúng', () {
      expect(VnFormat.money(const Money(1234567890123)), '1.234.567.890.123 đ');
    });
  });

  group('Số tiền rút gọn', () {
    test('680.000.000 hiện thành 680 tr', () {
      expect(VnFormat.moneyCompact(const Money(680000000)), '680 tr');
    });

    test('1.200.000.000 hiện thành 1,2 tỷ', () {
      expect(VnFormat.moneyCompact(const Money(1200000000)), '1,2 tỷ');
    });

    test('phần thập phân bằng 0 thì không hiện', () {
      expect(VnFormat.moneyCompact(const Money(2000000000)), '2 tỷ');
      expect(VnFormat.moneyCompact(const Money(15000000)), '15 tr');
    });

    test('làm tròn về một chữ số thập phân', () {
      expect(VnFormat.moneyCompact(const Money(1250000000)), '1,3 tỷ');
      expect(VnFormat.moneyCompact(const Money(1240000000)), '1,2 tỷ');
    });

    test('dưới một triệu thì hiện đủ chữ số thay vì rút gọn', () {
      // Rút gọn một con số nhỏ không tiết kiệm chỗ mà lại giấu thông tin.
      expect(VnFormat.moneyCompact(const Money(999999)), '999.999 đ');
      expect(VnFormat.moneyCompact(const Money(0)), '0 đ');
    });

    test('số âm rút gọn vẫn giữ dấu', () {
      expect(VnFormat.moneyCompact(const Money(-168000000)), '-168 tr');
      expect(VnFormat.moneyCompact(const Money(-1200000000)), '-1,2 tỷ');
    });

    test('mốc chuyển đơn vị nằm đúng chỗ', () {
      expect(VnFormat.moneyCompact(const Money(1000000)), '1 tr');
      expect(VnFormat.moneyCompact(const Money(999999999)), '1.000 tr');
      expect(VnFormat.moneyCompact(const Money(1000000000)), '1 tỷ');
    });
  });

  group('Tỷ trọng', () {
    test('0,574 hiện thành 57,4%', () {
      expect(VnFormat.percent(Decimal.parse('0.574')), '57,4%');
    });

    test('luôn hiện đúng một chữ số thập phân, kể cả khi bằng 0', () {
      // Cột tỷ trọng xếp thẳng hàng thì đọc lướt mới nhanh.
      expect(VnFormat.percent(Decimal.parse('0.5')), '50,0%');
      expect(VnFormat.percent(Decimal.one), '100,0%');
      expect(VnFormat.percent(Decimal.zero), '0,0%');
    });

    test('bốn lớp tài sản của Excel gốc ra đúng nhãn biểu đồ tròn', () {
      // Chốt chặn cho FR-16: 15, 92, 390, 183 triệu trên tổng 680 triệu.
      const total = Money(680000000);
      const values = [
        Money(15000000),
        Money(92000000),
        Money(390000000),
        Money(183000000),
      ];

      final labels = values
          .map((v) => VnFormat.percent(v.ratioTo(total)!))
          .toList();

      expect(labels, ['2,2%', '13,5%', '57,4%', '26,9%']);
    });

    test('tổng bốn tỷ trọng không lệch quá một phần mười phần trăm', () {
      const total = Money(680000000);
      const values = [
        Money(15000000),
        Money(92000000),
        Money(390000000),
        Money(183000000),
      ];
      final sum = values
          .map((v) => v.ratioTo(total)!)
          .reduce((a, b) => a + b);
      expect(VnFormat.percent(sum), '100,0%');
    });
  });

  group('Số lượng', () {
    test('0,12000000 BTC hiện thành 0,12 BTC', () {
      final btc = Quantity.parse('0.12000000', 8);
      expect(VnFormat.quantity(btc, unit: 'BTC'), '0,12 BTC');
    });

    test('100 cổ phiếu không có phần thập phân', () {
      expect(VnFormat.quantity(const Quantity(100, 0), unit: 'cổ'), '100 cổ');
    });

    test('vàng tính theo chỉ giữ hai chữ số khi cần', () {
      expect(VnFormat.quantity(Quantity.parse('7', 2), unit: 'chỉ'), '7 chỉ');
      expect(
        VnFormat.quantity(Quantity.parse('7.25', 2), unit: 'chỉ'),
        '7,25 chỉ',
      );
    });

    test('giữ đủ 8 chữ số khi người dùng thực sự nhập tới satoshi', () {
      final btc = Quantity.parse('0.12345678', 8);
      expect(VnFormat.quantity(btc, unit: 'BTC'), '0,12345678 BTC');
    });

    test('số lượng lớn vẫn ngăn nghìn', () {
      expect(
        VnFormat.quantity(const Quantity(10000, 0), unit: 'cổ'),
        '10.000 cổ',
      );
    });

    test('không truyền đơn vị thì chỉ hiện con số', () {
      expect(VnFormat.quantity(const Quantity(100, 0)), '100');
    });

    test('số lượng bằng 0 hiện gọn', () {
      expect(VnFormat.quantity(const Quantity.zero(8), unit: 'BTC'), '0 BTC');
    });
  });
}
