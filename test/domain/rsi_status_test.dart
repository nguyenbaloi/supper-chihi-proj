import 'package:flutter_test/flutter_test.dart';
import 'package:rsi_alert/domain/rsi_status.dart';

void main() {
  group('RsiStatus.from', () {
    test('null là chưa đủ dữ liệu', () {
      expect(RsiStatus.from(null), RsiStatus.insufficientData);
    });

    test('biên dưới: 29.9 quá bán, đúng 30 là trung tính', () {
      expect(RsiStatus.from(29.9), RsiStatus.oversold);
      expect(RsiStatus.from(30), RsiStatus.neutral);
    });

    test('biên trên: đúng 70 là trung tính, 70.1 quá mua', () {
      expect(RsiStatus.from(70), RsiStatus.neutral);
      expect(RsiStatus.from(70.1), RsiStatus.overbought);
    });

    test('hai cực', () {
      expect(RsiStatus.from(0), RsiStatus.oversold);
      expect(RsiStatus.from(100), RsiStatus.overbought);
    });
  });
}
