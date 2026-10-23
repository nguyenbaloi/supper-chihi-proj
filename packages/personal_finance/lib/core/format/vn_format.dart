import 'package:decimal/decimal.dart';

import '../money/money.dart';
import '../money/quantity.dart';

/// Định dạng số theo cách người Việt vẫn viết: **dấu chấm ngăn nghìn, dấu
/// phẩy thập phân** — ngược hẳn quy ước mặc định của Dart. Xem FR-40.
///
/// Đây là nơi duy nhất được phép làm tròn. Mọi tầng phía trên giữ nguyên
/// [Money] và [Quantity] ở độ chính xác đầy đủ rồi mới đưa xuống đây, đúng
/// tầng thứ ba của AD-3.
///
/// Tự tách chữ số thay vì gọi `NumberFormat` của `intl`: đường đi từ số
/// nguyên sang chuỗi ở đây không đụng tới một phép toán dấu phẩy động nào,
/// nên không có chỗ nào để sai số lọt vào con số người dùng nhìn thấy.
class VnFormat {
  const VnFormat._();

  /// Ký hiệu tiền đồng. Đứng sau con số, cách một khoảng trắng.
  static const String dongSymbol = 'đ';

  static const int _million = 1000000;
  static const int _billion = 1000000000;

  /// Số tiền đầy đủ: `680.000.000 đ`.
  static String money(Money value) {
    final digits = _groupDigits(value.amount.abs().toString());
    final signed = value.isNegative ? '-$digits' : digits;
    return '$signed $dongSymbol';
  }

  /// Số tiền trần, không kèm ký hiệu tiền tệ: `67.432,18`.
  ///
  /// [decimals] là số chữ số thập phân của **đơn vị tiền đang hiển thị** — 0
  /// với VND, 2 với USD. Mọi số tiền lưu bằng đơn vị nhỏ nhất, nên con số này
  /// quyết định thang: cùng `6743218` là `6.743.218 đ` hoặc `67.432,18 USD`.
  ///
  /// Bỏ chữ số 0 thừa ở cuối phần thập phân.
  static String amount(Money value, {int decimals = 0}) {
    final digits = value.amount.abs();
    if (decimals == 0) {
      final grouped = _groupDigits(digits.toString());
      return value.isNegative ? '-$grouped' : grouped;
    }

    final scaled = Decimal.fromInt(digits).shift(-decimals);
    final parts = scaled.toStringAsFixed(decimals).split('.');
    final buffer = StringBuffer(value.isNegative ? '-' : '')
      ..write(_groupDigits(parts.first));

    final fraction = parts.length > 1
        ? parts[1].replaceFirst(RegExp(r'0+$'), '')
        : '';
    if (fraction.isNotEmpty) buffer.write(',$fraction');
    return buffer.toString();
  }

  /// Số tiền rút gọn: `680 tr`, `1,2 tỷ`.
  ///
  /// Dưới một triệu thì hiện đủ chữ số — rút gọn một con số nhỏ không tiết
  /// kiệm được chỗ nào mà lại giấu mất thông tin.
  static String moneyCompact(Money value) {
    final magnitude = value.amount.abs();
    if (magnitude >= _billion) return _scaled(value.amount, _billion, 'tỷ');
    if (magnitude >= _million) return _scaled(value.amount, _million, 'tr');
    return money(value);
  }

  /// Tỷ trọng: `0,574` thành `57,4%`.
  ///
  /// Luôn hiện đúng [fractionDigits] chữ số thập phân, kể cả khi phần thập
  /// phân bằng 0 — cột tỷ trọng xếp thẳng hàng thì đọc lướt mới nhanh.
  static String percent(Decimal ratio, {int fractionDigits = 1}) {
    final percentage = ratio * Decimal.fromInt(100);
    return '${_decimalToVn(percentage, fractionDigits)}%';
  }

  /// Số lượng: `0,12 BTC`, `100 cổ`.
  ///
  /// Bỏ chữ số 0 thừa phía sau: `0,12000000 BTC` hiện thành `0,12 BTC`.
  static String quantity(Quantity value, {String? unit}) {
    final parts = value.toPlainString().split('.');
    final integerPart = parts.first;
    final negative = integerPart.startsWith('-');
    final grouped = _groupDigits(
      negative ? integerPart.substring(1) : integerPart,
    );

    final buffer = StringBuffer(negative ? '-$grouped' : grouped);
    if (parts.length > 1) buffer.write(',${parts[1]}');
    if (unit != null) buffer.write(' $unit');
    return buffer.toString();
  }

  /// Chia [amount] cho [unit] rồi gắn hậu tố, giữ tối đa một chữ số thập phân.
  static String _scaled(int amount, int unit, String suffix) {
    final scaled = (Decimal.fromInt(amount).toRational() /
            Decimal.fromInt(unit).toRational())
        .toDecimal(scaleOnInfinitePrecision: 4);
    return '${_decimalToVn(scaled, 1, stripTrailingZeros: true)} $suffix';
  }

  /// Đưa [value] về chuỗi kiểu Việt Nam với đúng [fractionDigits] chữ số
  /// thập phân, có ngăn nghìn.
  static String _decimalToVn(
    Decimal value,
    int fractionDigits, {
    bool stripTrailingZeros = false,
  }) {
    final text = value.round(scale: fractionDigits).toStringAsFixed(
          fractionDigits,
        );
    final negative = text.startsWith('-');
    final unsigned = negative ? text.substring(1) : text;

    final parts = unsigned.split('.');
    var fraction = parts.length > 1 ? parts[1] : '';
    if (stripTrailingZeros) {
      fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    }

    final buffer = StringBuffer(negative ? '-' : '')
      ..write(_groupDigits(parts.first));
    if (fraction.isNotEmpty) buffer.write(',$fraction');
    return buffer.toString();
  }

  /// Chèn dấu chấm sau mỗi ba chữ số tính từ phải sang. [digits] chỉ chứa chữ
  /// số, không dấu.
  static String _groupDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
