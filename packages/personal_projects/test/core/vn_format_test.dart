import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personal_projects/core/format/vn_format.dart';
import 'package:personal_projects/core/money/scaled_value.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('vi_VN'));

  group('Story 1.2 — định dạng tiền', () {
    test('mục tiêu 1 tỷ hiển thị đủ chữ số, không mất chính xác', () {
      expect(VnFormat.currency(1000000000), '1.000.000.000 ₫');
    });

    test('giá trị lớn không mất chữ số', () {
      expect(VnFormat.currency(999999999999), '999.999.999.999 ₫');
    });

    test('rút gọn số lớn', () {
      expect(VnFormat.compactCurrency(1000000000), '1 tỷ');
      expect(VnFormat.compactCurrency(340000000), '340 triệu');
      expect(VnFormat.compactCurrency(1500000), '1,5 triệu');
      expect(VnFormat.compactCurrency(-340000000), '-340 triệu');
    });
  });

  group('Story 1.2 — phần trăm và ngày', () {
    test('0,34 hiển thị 34,0% — không phải 33,9%', () {
      final ratio = ScaledValue(340000000, 0).ratioTo(ScaledValue(1000000000, 0));
      expect(VnFormat.percent(ratio), '34,0%');
    });

    test('tỷ lệ không xác định hiển thị gạch ngang, không phải 0%', () {
      expect(VnFormat.percent(null), '—');
    });

    test('tiến độ vượt 100% không bị chặn — FR-22', () {
      final ratio = ScaledValue(1200000000, 0).ratioTo(ScaledValue(1000000000, 0));
      expect(VnFormat.percent(ratio), '120,0%');
    });

    test('ngày định dạng dd/MM/yyyy', () {
      expect(VnFormat.date(DateTime(2026, 8, 28)), '28/08/2026');
    });
  });

  group('Story 1.3 — số học chính xác', () {
    test('chia 340tr/1tỷ ra đúng 0,34', () {
      final ratio = ScaledValue(340000000, 0).ratioTo(ScaledValue(1000000000, 0));
      expect(ratio, Decimal.parse('0.34'));
    });

    test('cộng trừ giữ nguyên độ chính xác', () {
      final a = ScaledValue(999999999999, 0);
      final b = ScaledValue(1, 0);
      expect((a + b).raw, 1000000000000);
    });

    test('đơn vị có phần thập phân lưu bằng int đã nhân hệ số', () {
      final v = ScaledValue.tryParse('12,5', 1);
      expect(v, ScaledValue(125, 1));
      expect(VnFormat.scaled(v!, 'kg'), '12,5 kg');
    });

    test('đọc chuỗi có dấu phân cách nghìn kiểu Việt Nam', () {
      expect(ScaledValue.tryParse('1.000.000.000', 0), ScaledValue(1000000000, 0));
      expect(ScaledValue.tryParse('340.000.000', 0), ScaledValue(340000000, 0));
    });

    test('từ chối chuỗi chi tiết hơn đơn vị cho phép', () {
      expect(ScaledValue.tryParse('12,55', 1), isNull);
      expect(ScaledValue.tryParse('1.000,5', 0), isNull);
    });

    test('từ chối chuỗi không phải số', () {
      expect(ScaledValue.tryParse('abc', 0), isNull);
      expect(ScaledValue.tryParse('', 0), isNull);
    });

    test('mẫu số bằng 0 trả null, không chia cho 0', () {
      expect(ScaledValue(100, 0).ratioTo(ScaledValue.zeroDong), isNull);
    });
  });
}
