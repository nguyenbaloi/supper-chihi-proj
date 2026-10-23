/// Chuẩn hoá chuỗi số người dùng gõ về dạng máy đọc được.
///
/// Cần lớp này vì ứng dụng **hiển thị** số kiểu Việt Nam — dấu phẩy thập
/// phân, dấu chấm ngăn nghìn — nên người dùng gõ lại đúng như thế. Bàn phím
/// số trên máy đặt ngôn ngữ tiếng Việt cũng cho ra dấu phẩy. Chỉ nhận dấu
/// chấm là bắt người dùng gõ ngược với thứ chính ứng dụng vừa dạy họ.
///
/// Nguyên tắc: chỗ nào thật sự nhập nhằng thì **từ chối**, tuyệt đối không
/// đoán. Đoán sai ở đây biến `10,5` cổ phiếu thành `105` cổ mà không báo gì.
class DecimalInput {
  const DecimalInput._();

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  /// Nhóm nghìn hợp lệ: `1.234`, `12.345.678` — nhóm đầu 1..3 chữ số, các
  /// nhóm sau đúng 3 chữ số.
  static final RegExp _grouped = RegExp(r'^\d{1,3}([.,]\d{3})+$');

  /// Trả về chuỗi dạng `123.45` để [Decimal] đọc, hoặc `null` nếu không đọc
  /// được hay nhập nhằng.
  ///
  /// [allowedDecimals] là số chữ số thập phân loại tài sản cho phép. Con số
  /// này giải quyết phần lớn nhập nhằng: với loại chỉ nhận số nguyên thì mọi
  /// dấu phân cách chỉ có thể là ngăn nghìn.
  static String? normalize(String raw, {required int allowedDecimals}) {
    final text = raw.replaceAll(RegExp(r'[\s ]'), '');
    if (text.isEmpty) return null;

    final negative = text.startsWith('-');
    final body = negative ? text.substring(1) : text;
    if (body.isEmpty) return null;

    final normalized = _normalizeUnsigned(body, allowedDecimals);
    if (normalized == null) return null;
    return negative ? '-$normalized' : normalized;
  }

  static String? _normalizeUnsigned(String body, int allowedDecimals) {
    final separators = <int>[];
    for (var i = 0; i < body.length; i++) {
      if (body[i] == '.' || body[i] == ',') separators.add(i);
    }

    if (separators.isEmpty) {
      return _digitsOnly.hasMatch(body) ? body : null;
    }

    // Loại chỉ nhận số nguyên: `10.000` chỉ có một cách đọc hợp lý là mười
    // nghìn, nên nhận ngay khi đúng hình dạng nhóm nghìn.
    //
    // Không xét nhóm nghìn trước với loại có phần thập phân: `1.234` BTC
    // hầu như luôn là một phẩy hai ba bốn, không phải một nghìn hai trăm ba
    // mươi tư đồng bitcoin.
    if (allowedDecimals == 0 && _grouped.hasMatch(body)) {
      return body.replaceAll(RegExp(r'[.,]'), '');
    }

    // Dấu phân cách **cuối cùng** là dấu thập phân, mọi dấu trước nó là ngăn
    // nghìn.
    //
    // Nhánh này cũng nhận `10,5` của loại chỉ nhận số nguyên — cố tình như
    // vậy. Trả về `10.5` để phép kiểm độ chính xác phía sau báo đúng câu
    // "loại này chỉ nhận số nguyên", thay vì một câu "số không hợp lệ" chung
    // chung không nói được người dùng sai ở đâu.
    final decimalAt = separators.last;
    final integerPart = body.substring(0, decimalAt);
    final fractionPart = body.substring(decimalAt + 1);

    if (fractionPart.isEmpty || !_digitsOnly.hasMatch(fractionPart)) {
      return null;
    }

    if (integerPart.isEmpty) return '0.$fractionPart';

    if (_digitsOnly.hasMatch(integerPart)) return '$integerPart.$fractionPart';

    // Phần nguyên còn dấu phân cách thì phải đúng dạng nhóm nghìn.
    if (!_grouped.hasMatch(integerPart)) return null;
    return '${integerPart.replaceAll(RegExp(r'[.,]'), '')}.$fractionPart';
  }
}
