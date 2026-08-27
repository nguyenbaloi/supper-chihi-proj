import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/core/money/quantity.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/models/holding.dart';
import 'package:personal_finance/domain/models/price_quote.dart';
import 'package:personal_finance/domain/rules/holding_value.dart';

Holding _quantityHolding(String symbol, Quantity quantity, Currency currency) =>
    Holding(
      id: 1,
      assetClassId: 1,
      symbol: symbol,
      inputMode: InputMode.quantity,
      currency: currency,
      updatedAt: DateTime.utc(2026, 8, 27),
      quantity: quantity,
    );

Holding _valueHolding(Money? amount, Currency currency) => Holding(
      id: 2,
      assetClassId: 2,
      symbol: 'TK VCB',
      inputMode: InputMode.value,
      currency: currency,
      updatedAt: DateTime.utc(2026, 8, 27),
      manualValueAmount: amount,
    );

PriceQuote _price(int amount, Currency currency) => PriceQuote(
      symbol: 'X',
      priceAmount: Money(amount),
      currency: currency,
      source: PriceSource.manual,
      fetchedAt: DateTime.utc(2026, 8, 27),
    );

void main() {
  group('Khoản nhập theo giá trị', () {
    test('tiền VND lấy thẳng số đã nhập', () {
      final value = HoldingValuation.of(
        _valueHolding(const Money(92000000), Currency.vnd),
      );
      expect(value.amountOrNull, const Money(92000000));
    });

    test('chưa nhập số tiền thì chưa tính được', () {
      final value = HoldingValuation.of(_valueHolding(null, Currency.vnd));
      expect(value, isA<HoldingValueUnknown>());
      expect(
        (value as HoldingValueUnknown).reason,
        MissingValueReason.noAmount,
      );
    });
  });

  group('Khoản nhập theo số lượng', () {
    test('100 cổ FPT giá 150.000 đ ra đúng 15 triệu', () {
      final value = HoldingValuation.of(
        _quantityHolding('FPT', const Quantity(100, 0), Currency.vnd),
        price: _price(150000, Currency.vnd),
      );
      expect(value.amountOrNull, const Money(15000000));
    });

    test('7 chỉ vàng giá 13.142.857 đ mỗi chỉ', () {
      final value = HoldingValuation.of(
        _quantityHolding('SJC', Quantity.parse('7', 2), Currency.vnd),
        price: _price(13142857, Currency.vnd),
      );
      expect(value.amountOrNull, const Money(91999999));
    });

    test('chưa có giá thì chưa tính được, không phải 0 đồng', () {
      final value = HoldingValuation.of(
        _quantityHolding('BTC', Quantity.parse('0.5', 8), Currency.usd),
      );
      expect(value, isA<HoldingValueUnknown>());
      expect((value as HoldingValueUnknown).reason, MissingValueReason.noPrice);
      expect(value.amountOrNull, isNull);
    });
  });

  group('Quy đổi USD sang VND', () {
    test('0,5 BTC giá 60.000 USD, tỷ giá 25.000 ra 750 triệu', () {
      // Giá USD lưu bằng xu: 60.000 USD là 6.000.000 xu.
      final value = HoldingValuation.of(
        _quantityHolding('BTC', Quantity.parse('0.5', 8), Currency.usd),
        price: _price(6000000, Currency.usd),
        usdToVndRate: const Money(25000),
      );
      expect(value.amountOrNull, const Money(750000000));
    });

    test('giữ nguyên phần xu lẻ của giá', () {
      // 1 BTC giá 67.432,18 USD, tỷ giá 25.000 đ.
      final value = HoldingValuation.of(
        _quantityHolding('BTC', Quantity.parse('1', 8), Currency.usd),
        price: _price(6743218, Currency.usd),
        usdToVndRate: const Money(25000),
      );
      expect(value.amountOrNull, const Money(1685804500));
    });

    test('làm tròn đúng một lần ở bước cuối', () {
      // 0,12345678 BTC × 67.432,18 USD × 25.000 đ.
      //
      // Con số này phân biệt được hai cách tính: giữ nguyên độ chính xác tới
      // cuối cho 208.123.995 đ, còn làm tròn về xu nguyên ở bước giữa cho
      // 208.124.000 đ. Lệch 5 đồng trên một khoản; nhân với vài chục khoản và
      // cộng dồn qua nhiều tháng thì thành đúng loại sai số làm hỏng Excel.
      final value = HoldingValuation.of(
        _quantityHolding('BTC', Quantity.parse('0.12345678', 8), Currency.usd),
        price: _price(6743218, Currency.usd),
        usdToVndRate: const Money(25000),
      );
      expect(value.amountOrNull, const Money(208123995));
    });

    test('có giá USD nhưng chưa có tỷ giá thì chưa tính được', () {
      final value = HoldingValuation.of(
        _quantityHolding('BTC', Quantity.parse('0.5', 8), Currency.usd),
        price: _price(6000000, Currency.usd),
      );
      expect(value, isA<HoldingValueUnknown>());
      expect((value as HoldingValueUnknown).reason, MissingValueReason.noFxRate);
    });

    test('tiền gửi tính bằng USD cũng quy đổi được', () {
      // 1.000 USD là 100.000 xu, tỷ giá 25.000.
      final value = HoldingValuation.of(
        _valueHolding(const Money(100000), Currency.usd),
        usdToVndRate: const Money(25000),
      );
      expect(value.amountOrNull, const Money(25000000));
    });
  });
}
