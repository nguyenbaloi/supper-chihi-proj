import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rsi_alert/domain/constants.dart';
import 'package:rsi_alert/domain/rsi.dart';

void main() {
  group('computeRsi — FR-13', () {
    test('chuỗi ngắn hơn 15 nến trả về rỗng, không ném lỗi', () {
      for (var n = 0; n <= rsiPeriod; n++) {
        final closes = List<double>.generate(n, (i) => 100.0 + i);
        expect(computeRsi(closes), isEmpty, reason: 'với $n nến');
      }
    });

    test('giá trị đầu tiên nằm tại chỉ số rsiPeriod', () {
      final closes = List<double>.generate(50, (i) => 100.0 + (i % 7) - 3);
      final points = computeRsi(closes);
      expect(points.first.candleIndex, rsiPeriod);
      expect(points.length, closes.length - rsiPeriod);
      expect(points.last.candleIndex, closes.length - 1);
    });

    test('chuỗi chỉ tăng cho RSI 100, không NaN không Infinity', () {
      final closes = List<double>.generate(40, (i) => 100.0 + i);
      final points = computeRsi(closes);
      for (final p in points) {
        expect(p.value, 100.0);
        expect(p.value.isFinite, isTrue);
      }
    });

    test('chuỗi chỉ giảm cho RSI 0', () {
      final closes = List<double>.generate(40, (i) => 200.0 - i);
      for (final p in computeRsi(closes)) {
        expect(p.value, 0.0);
      }
    });

    test('mọi giá trị nằm trong [0, 100]', () {
      final closes = <double>[];
      var price = 1000.0;
      for (var i = 0; i < 300; i++) {
        // Chuỗi giả lập tất định, biên độ đủ rộng để chạm cả hai ngưỡng.
        price += (i % 11) - 5 + (i % 3);
        closes.add(price);
      }
      for (final p in computeRsi(closes)) {
        expect(p.value, inInclusiveRange(0, 100));
      }
    });

    test('hàm thuần: gọi hai lần cho kết quả giống hệt', () {
      final closes = List<double>.generate(60, (i) => 50.0 + (i * 7 % 23));
      expect(computeRsi(closes), computeRsi(closes));
    });
  });

  group('computeRsi — đối chiếu giá trị tham chiếu (SM-1)', () {
    late Map<String, dynamic> reference;

    setUpAll(() {
      reference = jsonDecode(
        File('test/fixtures/rsi_reference.json').readAsStringSync(),
      ) as Map<String, dynamic>;
    });

    for (final key in ['vnindex', 'btc']) {
      test('$key khớp tham chiếu trong ±0.5 điểm', () {
        final data = reference[key] as Map<String, dynamic>;
        final closes = (data['closes'] as List).cast<num>().map((n) => n.toDouble()).toList();
        final expected = (data['rsi'] as List).cast<Map<String, dynamic>>();

        final actual = computeRsi(closes);
        expect(actual.length, expected.length);

        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].candleIndex, expected[i]['i']);
          expect(
            (actual[i].value - (expected[i]['v'] as num).toDouble()).abs(),
            lessThanOrEqualTo(0.5),
            reason: 'lệch quá 0.5 điểm tại nến ${actual[i].candleIndex}',
          );
        }
      });
    }
  });
}
