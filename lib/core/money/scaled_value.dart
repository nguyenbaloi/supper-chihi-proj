import 'package:decimal/decimal.dart';

/// Biểu diễn một con số chính xác dưới dạng số nguyên đã nhân hệ số.
///
/// AD-4: giá trị Mục tiêu lưu bằng `int` — tiền là đơn vị đồng (`decimals = 0`),
/// các đơn vị khác nhân theo `decimals`. `double` không bao giờ được dùng.
///
/// Ví dụ: 12,5 kg với `decimals = 1` được lưu là `raw = 125`.
final class ScaledValue {
  const ScaledValue(this.raw, this.decimals)
      : assert(decimals >= 0 && decimals <= 8, 'decimals phải trong khoảng 0..8');

  /// Số nguyên đã nhân hệ số. Đây là thứ duy nhất được lưu xuống cơ sở dữ liệu.
  final int raw;

  /// Số chữ số thập phân của đơn vị. VND luôn là 0.
  final int decimals;

  static const ScaledValue zeroDong = ScaledValue(0, 0);

  /// Giá trị thật, dùng cho mọi phép nhân chia. Không bao giờ trả `double`.
  Decimal get decimal =>
      (Decimal.fromInt(raw) / Decimal.fromInt(_pow10(decimals))).toDecimal();

  bool get isZero => raw == 0;
  bool get isNegative => raw < 0;

  ScaledValue operator +(ScaledValue other) {
    _assertSameScale(other);
    return ScaledValue(raw + other.raw, decimals);
  }

  ScaledValue operator -(ScaledValue other) {
    _assertSameScale(other);
    return ScaledValue(raw - other.raw, decimals);
  }

  /// Tỷ lệ giữa hai giá trị cùng đơn vị. Trả `null` khi mẫu số bằng 0 —
  /// nơi gọi phải hiển thị `—`, tuyệt đối không hiển thị `0%`.
  Decimal? ratioTo(ScaledValue target) {
    _assertSameScale(target);
    if (target.raw == 0) return null;
    return (Decimal.fromInt(raw) / Decimal.fromInt(target.raw)).toDecimal(scaleOnInfinitePrecision: 12);
  }

  void _assertSameScale(ScaledValue other) {
    assert(
      decimals == other.decimals,
      'Không được cộng trừ hai ScaledValue khác decimals ($decimals vs ${other.decimals})',
    );
  }

  /// Đọc từ chuỗi người dùng gõ. Chấp nhận cả `,` lẫn `.` làm dấu thập phân
  /// và bỏ qua dấu phân cách nghìn. Trả `null` nếu không đọc được.
  static ScaledValue? tryParse(String input, int decimals) {
    var s = input.trim().replaceAll(RegExp(r'[\s\u00a0]'), '');
    if (s.isEmpty) return null;

    final negative = s.startsWith('-');
    if (negative || s.startsWith('+')) s = s.substring(1);
    if (!RegExp(r'^[0-9.,]+$').hasMatch(s)) return null;

    final lastSep = s.lastIndexOf(RegExp(r'[.,]'));
    ScaledValue? result;
    if (lastSep >= 0) {
      final tail = s.substring(lastSep + 1);
      final head = s.substring(0, lastSep);
      final looksLikeGrouping = tail.length == 3 &&
          RegExp(r'^\d{3}$').hasMatch(tail) &&
          RegExp(r'^\d{1,3}([.,]\d{3})*$').hasMatch(head);
      // Dấu phân cách cuối là dấu thập phân, trừ khi nó rõ ràng là phân
      // cách nghìn. Không có đường lui: chuỗi ghi rõ phần thập phân mà phần
      // đó chi tiết hơn đơn vị cho phép thì phải bị từ chối, không được âm
      // thầm hiểu lại thành phân cách nghìn.
      if (!looksLikeGrouping) return _build(head, tail, decimals, negative);
    }
    // Không có dấu thập phân: mọi dấu phân cách là phân cách nghìn.
    result = _build(s, '', decimals, negative);
    return result;
  }

  static ScaledValue? _build(String rawIntPart, String fracPart, int decimals, bool negative) {
    var intPart = rawIntPart.replaceAll(RegExp(r'[.,]'), '');
    if (intPart.isEmpty) intPart = '0';
    if (!RegExp(r'^\d+$').hasMatch(intPart)) return null;
    if (fracPart.isNotEmpty && !RegExp(r'^\d+$').hasMatch(fracPart)) return null;
    if (fracPart.length > decimals) return null; // nhập chi tiết hơn đơn vị cho phép

    final padded = fracPart.padRight(decimals, '0');
    final combined = int.tryParse('$intPart$padded');
    if (combined == null) return null;
    return ScaledValue(negative ? -combined : combined, decimals);
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  @override
  bool operator ==(Object other) =>
      other is ScaledValue && other.raw == raw && other.decimals == decimals;

  @override
  int get hashCode => Object.hash(raw, decimals);

  @override
  String toString() => 'ScaledValue($raw, decimals: $decimals)';
}
