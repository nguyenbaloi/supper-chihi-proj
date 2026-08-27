import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ô nhập số lượng tài sản.
///
/// Ràng buộc ngay lúc gõ thay vì chỉ báo lỗi lúc lưu: chặn được chữ cái, chặn
/// dấu thập phân thứ hai, và chặn luôn dấu thập phân với loại tài sản chỉ
/// nhận số nguyên. Nhờ vậy chuỗi gõ ra không bao giờ nhập nhằng giữa dấu ngăn
/// nghìn và dấu thập phân.
class QuantityField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  /// Số chữ số thập phân loại tài sản này cho phép.
  final int allowedDecimals;

  final String? suffixText;
  final String? helperText;
  final ValueChanged<String>? onChanged;

  const QuantityField({
    super.key,
    required this.controller,
    required this.label,
    required this.allowedDecimals,
    this.suffixText,
    this.helperText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(
          decimal: allowedDecimals > 0,
        ),
        inputFormatters: [
          _QuantityFormatter(allowedDecimals: allowedDecimals),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffixText,
          helperText: helperText,
        ),
        onChanged: onChanged,
      );
}

class _QuantityFormatter extends TextInputFormatter {
  final int allowedDecimals;

  const _QuantityFormatter({required this.allowedDecimals});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    var separatorSeen = false;
    var decimalsWritten = 0;

    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);

      if (ch == '.' || ch == ',') {
        // Loại chỉ nhận số nguyên thì bỏ hẳn dấu thập phân, và chỉ cho đúng
        // một dấu với các loại còn lại.
        if (allowedDecimals == 0 || separatorSeen) continue;
        separatorSeen = true;
        buffer.write(',');
        continue;
      }

      if (ch.codeUnitAt(0) < 0x30 || ch.codeUnitAt(0) > 0x39) continue;

      if (separatorSeen) {
        // Cắt ở đúng số chữ số cho phép — gõ tiếp cũng không nhận thêm, thay
        // vì để tới lúc lưu mới báo là quá mịn.
        if (decimalsWritten >= allowedDecimals) continue;
        decimalsWritten++;
      }
      buffer.write(ch);
    }

    final result = buffer.toString();
    if (result == text) return newValue;

    // Giữ con trỏ ở cuối phần vừa gõ, tránh nhảy về đầu sau mỗi ký tự bị bỏ.
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
