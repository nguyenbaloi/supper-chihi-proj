import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format/vn_format.dart';
import '../../core/money/money.dart';

/// Ô nhập số tiền kiểu Việt Nam.
///
/// Chỉ nhận chữ số và tự chèn dấu chấm ngăn nghìn khi gõ. Không dùng
/// `double.parse` ở bất kỳ đâu: chuỗi chữ số đi thẳng sang `int` đơn vị đồng.
/// Xem AD-3.
class MoneyField extends StatefulWidget {
  final String label;
  final Money initial;
  final ValueChanged<Money> onChanged;
  final bool allowNegative;
  final String? helperText;

  const MoneyField({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
    this.allowNegative = false,
    this.helperText,
  });

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initial.isZero
          ? ''
          : VnFormat.money(widget.initial.abs()).replaceAll(' đ', ''),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [_ThousandsFormatter()],
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: VnFormat.dongSymbol,
          helperText: widget.helperText,
        ),
        onChanged: (text) {
          final digits = text.replaceAll('.', '');
          widget.onChanged(Money(int.tryParse(digits) ?? 0));
        },
      );
}

/// Chèn dấu chấm ngăn nghìn ngay khi gõ, giữ con trỏ ở cuối phần vừa nhập.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final formatted = VnFormat.money(Money(int.parse(digits)))
        .replaceAll(' ${VnFormat.dongSymbol}', '');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
