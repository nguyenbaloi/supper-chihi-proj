import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

import '../money/scaled_value.dart';

/// Lớp định dạng kiểu Việt Nam.
///
/// AD-4: đây là **nơi duy nhất** được phép làm tròn. Mọi tầng phía trên
/// giữ nguyên độ chính xác bằng `int` và `Decimal`.
abstract final class VnFormat {
  static final DateFormat _date = DateFormat('dd/MM/yyyy', 'vi_VN');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
  static final DateFormat _weekday = DateFormat('EEEE', 'vi_VN');

  /// `1000000000` → `1.000.000.000 ₫`
  static String currency(int amountDong) => '${groupDigits(amountDong.toString())} ₫';

  /// `1000000000` → `1 tỷ` · `340000000` → `340 triệu` · `1500000` → `1,5 triệu`
  ///
  /// Dùng cho nhãn biểu đồ và ô hẹp. Chỗ nào cần con số đúng thì dùng
  /// [currency], không dùng hàm này.
  static String compactCurrency(int amountDong) {
    final negative = amountDong < 0;
    final v = amountDong.abs();
    String body;
    if (v >= 1000000000) {
      body = '${_trimOneDecimal(v, 1000000000)} tỷ';
    } else if (v >= 1000000) {
      body = '${_trimOneDecimal(v, 1000000)} triệu';
    } else if (v >= 1000) {
      body = '${_trimOneDecimal(v, 1000)} nghìn';
    } else {
      body = groupDigits(v.toString());
    }
    return negative ? '-$body' : body;
  }

  /// `ScaledValue(125, 1)` với đơn vị `kg` → `12,5 kg`
  static String scaled(ScaledValue value, String unit) {
    if (unit == 'VND') return currency(value.raw);
    final text = _decimalToVn(value.decimal, value.decimals);
    return unit.isEmpty ? text : '$text $unit';
  }

  /// `Decimal(0.34)` → `34,0%`. Trả `—` khi tỷ lệ không xác định.
  static String percent(Decimal? ratio, {int fractionDigits = 1}) {
    if (ratio == null) return emptyValue;
    final scaled = ratio * Decimal.fromInt(100);
    return '${_decimalToVn(scaled, fractionDigits)}%';
  }

  /// `2026-08-28` → `28/08/2026`
  static String date(DateTime value) => _date.format(value.toLocal());

  /// `2026-09-03` → `Thứ năm, 03/09/2026` — dòng ngày ở đầu màn hình Hôm nay.
  ///
  /// Tên thứ lấy từ dữ liệu locale `vi_VN`, không viết tay, để không phải
  /// bảo trì một bảng bảy phần tử.
  static String weekdayDate(DateTime value) {
    final local = value.toLocal();
    final weekday = _weekday.format(local);
    final capitalised = weekday.isEmpty
        ? weekday
        : weekday[0].toUpperCase() + weekday.substring(1);
    return '$capitalised, ${_date.format(local)}';
  }

  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());

  /// Dấu hiệu "không có giá trị". Không bao giờ được thay bằng `0`.
  static const String emptyValue = '—';

  /// `0` → `hôm nay` · `1` → `hôm qua` · `n` → `n ngày trước`
  static String daysAgo(int days) => switch (days) {
        <= 0 => 'hôm nay',
        1 => 'hôm qua',
        _ => '$days ngày trước',
      };

  /// `3` → `trễ 3 ngày`
  static String daysOverdue(int days) => 'trễ $days ngày';

  static String _trimOneDecimal(int value, int divisor) {
    final whole = value ~/ divisor;
    final tenth = (value % divisor) * 10 ~/ divisor;
    return tenth == 0 ? '$whole' : '$whole,$tenth';
  }

  /// Chèn dấu chấm phân cách nghìn vào một chuỗi chữ số.
  ///
  /// Tự viết thay vì dùng `NumberFormat`: `NumberFormat.format` của intl
  /// 0.20.2 ném lỗi kiểu khi nhận `BigInt`, mà giá trị Mục tiêu có thể vượt
  /// ngưỡng `int` an toàn khi nhân hệ số.
  static String groupDigits(String digits) {
    final negative = digits.startsWith('-');
    final body = negative ? digits.substring(1) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < body.length; i++) {
      if (i > 0 && (body.length - i) % 3 == 0) buffer.write('.');
      buffer.write(body[i]);
    }
    return negative ? '-$buffer' : buffer.toString();
  }

  static String _decimalToVn(Decimal value, int fractionDigits) {
    final fixed = value.toStringAsFixed(fractionDigits);
    final negative = fixed.startsWith('-');
    final body = negative ? fixed.substring(1) : fixed;
    final parts = body.split('.');
    final grouped = groupDigits(parts[0]);
    final text = parts.length > 1 && fractionDigits > 0 ? '$grouped,${parts[1]}' : grouped;
    return negative ? '-$text' : text;
  }
}
