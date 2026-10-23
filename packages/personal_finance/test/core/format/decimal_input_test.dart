import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/format/decimal_input.dart';

String? crypto(String raw) =>
    DecimalInput.normalize(raw, allowedDecimals: 8);
String? gold(String raw) => DecimalInput.normalize(raw, allowedDecimals: 2);
String? stock(String raw) => DecimalInput.normalize(raw, allowedDecimals: 0);

void main() {
  group('Dấu phẩy thập phân kiểu Việt Nam', () {
    test('0,16 BTC đọc được — chính là lỗi người dùng gặp', () {
      // Ứng dụng hiển thị `0,12 BTC` nên người dùng gõ lại `0,16`. Bàn phím
      // số trên máy tiếng Việt cũng cho ra dấu phẩy.
      expect(crypto('0,16'), '0.16');
    });

    test('dấu chấm vẫn đọc được như cũ', () {
      expect(crypto('0.16'), '0.16');
    });

    test('giữ đủ tám chữ số', () {
      expect(crypto('0,12345678'), '0.12345678');
      expect(crypto('0.12345678'), '0.12345678');
    });

    test('vàng hai chữ số', () {
      expect(gold('7,25'), '7.25');
      expect(gold('7.25'), '7.25');
    });

    test('bỏ khoảng trắng thừa', () {
      expect(crypto('  0,16 '), '0.16');
    });

    test('thiếu phần nguyên vẫn hiểu được', () {
      expect(crypto(',16'), '0.16');
      expect(crypto('.16'), '0.16');
    });

    test('số âm giữ dấu', () {
      expect(crypto('-0,16'), '-0.16');
    });
  });

  group('Ngăn nghìn', () {
    test('phần nguyên có ngăn nghìn kèm phần thập phân', () {
      expect(crypto('1.234,5'), '1234.5');
      expect(crypto('1,234.5'), '1234.5');
      expect(crypto('12.345.678,9'), '12345678.9');
    });

    test('loại số nguyên nhận ngăn nghìn', () {
      expect(stock('10.000'), '10000');
      expect(stock('1.234.567'), '1234567');
      expect(stock('10,000'), '10000');
    });

    test('số nguyên không dấu phân cách vẫn đúng', () {
      expect(stock('100'), '100');
      expect(crypto('100'), '100');
    });
  });

  group('Từ chối thay vì đoán', () {
    test('cổ phiếu 10,5 không bao giờ thành 105', () {
      // Đây là chỗ đoán bừa sẽ đổi thẳng con số người dùng vừa gõ. Đọc như
      // số thập phân để tầng trên báo đúng câu "chỉ nhận số nguyên".
      expect(stock('10,5'), '10.5');
      expect(stock('10.5'), '10.5');
    });

    test('nhóm nghìn sai hình dạng bị từ chối', () {
      expect(stock('1.23.456'), isNull);
      expect(crypto('1.23.456,7'), isNull);
    });

    test('chuỗi rỗng và không phải số bị từ chối', () {
      expect(crypto(''), isNull);
      expect(crypto('   '), isNull);
      expect(crypto('một trăm'), isNull);
      expect(crypto('12a3'), isNull);
      expect(crypto('-'), isNull);
    });

    test('dấu phân cách cuối chuỗi bị từ chối', () {
      expect(crypto('0,'), isNull);
      expect(crypto('0.'), isNull);
    });
  });
}
