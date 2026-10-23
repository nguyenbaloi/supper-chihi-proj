import 'package:flutter_test/flutter_test.dart';
import 'package:rsi_alert/domain/candle.dart';
import 'package:rsi_alert/domain/market_symbol.dart';

Candle sample({DateTime? openTime}) => Candle(
      openTime: openTime ?? DateTime.utc(2026, 8, 31),
      open: 100,
      high: 110,
      low: 95,
      close: 105,
      volume: 1234,
      isClosed: true,
    );

void main() {
  group('Candle — AD-3', () {
    test('từ chối openTime không phải UTC', () {
      expect(
        () => sample(openTime: DateTime(2026, 8, 31)),
        throwsA(isA<AssertionError>()),
      );
    });

    test('đi qua toJson/fromJson giữ nguyên mọi trường và tính UTC', () {
      final original = sample();
      final restored = Candle.fromJson(original.toJson());

      expect(restored, original);
      expect(restored.openTime.isUtc, isTrue);
    });

    test('AD-2: JSON không chứa trường suy ra', () {
      final json = sample().toJson();
      for (final banned in ['rsi', 'status', 'signals', 'lastRsi']) {
        expect(json.containsKey(banned), isFalse, reason: 'AD-2: bỏ "$banned"');
      }
    });

    test('isUp đúng ở biên close == open', () {
      expect(sample().isUp, isTrue);
      final flat = Candle(
        openTime: DateTime.utc(2026, 8, 31),
        open: 100,
        high: 100,
        low: 100,
        close: 100,
        volume: 0,
        isClosed: true,
      );
      expect(flat.isUp, isTrue);
    });
  });

  group('MarketSymbol', () {
    test('v1 có đúng hai Mã', () {
      expect(MarketSymbol.values.length, 2);
    });

    test('tra ngược từ khoá kho lưu trữ', () {
      expect(MarketSymbol.fromStorageKey('BTC'), MarketSymbol.btc);
      expect(MarketSymbol.fromStorageKey('VNINDEX'), MarketSymbol.vnindex);
      expect(MarketSymbol.fromStorageKey('ETH'), isNull);
    });
  });
}
