import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/models/price_quote.dart';
import 'package:personal_finance/domain/rules/effective_price.dart';

PriceQuote _quote(
  PriceSource source,
  int amount, {
  DateTime? at,
  Currency currency = Currency.vnd,
}) =>
    PriceQuote(
      symbol: 'BTC',
      priceAmount: Money(amount),
      currency: currency,
      source: source,
      fetchedAt: at ?? DateTime.utc(2026, 8, 27),
    );

void main() {
  group('Thứ tự ưu tiên của Giá hiệu lực', () {
    test('giá nhập tay thắng giá thị trường', () {
      final chosen = EffectivePrice.from([
        _quote(PriceSource.api, 100),
        _quote(PriceSource.manual, 150),
      ]);
      expect(chosen!.priceAmount, const Money(150));
      expect(chosen.source, PriceSource.manual);
    });

    test('thứ tự trong danh sách không ảnh hưởng kết quả', () {
      final chosen = EffectivePrice.from([
        _quote(PriceSource.manual, 150),
        _quote(PriceSource.api, 100),
      ]);
      expect(chosen!.source, PriceSource.manual);
    });

    test('không có giá nhập tay thì dùng giá thị trường', () {
      final chosen = EffectivePrice.from([_quote(PriceSource.api, 100)]);
      expect(chosen!.source, PriceSource.api);
    });

    test('nhiều giá thị trường thì lấy bản mới nhất', () {
      final chosen = EffectivePrice.from([
        _quote(PriceSource.api, 100, at: DateTime.utc(2026, 8, 20)),
        _quote(PriceSource.api, 130, at: DateTime.utc(2026, 8, 27)),
        _quote(PriceSource.api, 110, at: DateTime.utc(2026, 8, 25)),
      ]);
      expect(chosen!.priceAmount, const Money(130));
    });

    test('không có giá nào thì trả về null, tuyệt đối không phải 0', () {
      // Số 0 trông y hệt một tài sản mất sạch giá trị.
      final chosen = EffectivePrice.from(const []);
      expect(chosen, isNull);
    });

    test('giá trả về luôn kèm nguồn và thời điểm', () {
      final at = DateTime.utc(2026, 8, 27, 9, 30);
      final chosen = EffectivePrice.from([_quote(PriceSource.api, 100, at: at)]);
      expect(chosen!.source, PriceSource.api);
      expect(chosen.fetchedAt, at);
    });

    test('giữ nguyên đơn vị tiền của giá', () {
      final chosen = EffectivePrice.from([
        _quote(PriceSource.api, 6743218, currency: Currency.usd),
      ]);
      expect(chosen!.currency, Currency.usd);
    });
  });

  group('Loại tài sản bắt buộc nhập giá tay', () {
    test('chứng khoán và vàng chưa có nguồn tự động', () {
      expect(EffectivePrice.requiresManualPrice(AssetKind.stock), isTrue);
      expect(EffectivePrice.requiresManualPrice(AssetKind.gold), isTrue);
    });

    test('crypto có nguồn tự động', () {
      expect(EffectivePrice.requiresManualPrice(AssetKind.crypto), isFalse);
    });

    test('tiền mặt và cho vay không dùng giá', () {
      expect(EffectivePrice.requiresManualPrice(AssetKind.cashSavings), isFalse);
      expect(EffectivePrice.requiresManualPrice(AssetKind.lending), isFalse);
    });
  });
}
