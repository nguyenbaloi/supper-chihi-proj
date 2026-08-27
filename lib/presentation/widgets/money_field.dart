import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format/vn_format.dart';
import '../../core/money/money.dart';

/// Ô nhập số tiền kiểu Việt Nam: dấu chấm ngăn nghìn, dấu phẩy thập phân.
///
/// [decimals] là số chữ số thập phân của **đơn vị tiền đang nhập** — 0 với
/// VND, 2 với USD. Con số này bắt buộc phải đúng: mọi số tiền lưu bằng đơn vị
/// nhỏ nhất, nên nhập giá `67.432` USD mà coi như 0 chữ số thập phân sẽ ra
/// 674,32 USD — sai đúng một trăm lần và không báo gì.
///
/// Không dùng `double` ở bất kỳ đâu: chuỗi chữ số đi thẳng qua [Decimal] rồi
/// về `int`. Xem AD-3.
class MoneyField extends StatefulWidget {
  final String label;
  final Money initial;
  final ValueChanged<Money> onChanged;
  final int decimals;
  final String? suffixText;
  final String? helperText;

  const MoneyField({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
    this.decimals = 0,
    this.suffixText,
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
      text: formatAmount(widget.initial, widget.decimals),
    );
  }

  @override
  void didUpdateWidget(MoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Đổi đơn vị tiền là đổi cả thang số: cùng một dãy chữ số mang nghĩa khác
    // hẳn. Viết lại ô nhập theo giá trị hiện có thay vì để nguyên chuỗi cũ.
    if (oldWidget.decimals != widget.decimals) {
      final current = parseAmount(_controller.text, oldWidget.decimals);
      final text = formatAmount(current, widget.decimals);
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      widget.onChanged(current);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(
          decimal: widget.decimals > 0,
        ),
        inputFormatters: [_MoneyFormatter(decimals: widget.decimals)],
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: widget.suffixText ?? VnFormat.dongSymbol,
          helperText: widget.helperText,
        ),
        onChanged: (text) =>
            widget.onChanged(parseAmount(text, widget.decimals)),
      );
}

/// Đổi chuỗi trong ô nhập thành số tiền theo đơn vị nhỏ nhất.
///
/// Chuỗi luôn ở dạng chuẩn do [_MoneyFormatter] sinh ra — dấu chấm là ngăn
/// nghìn, dấu phẩy là thập phân — nên không có chỗ nào nhập nhằng.
@visibleForTesting
Money parseAmount(String text, int decimals) {
  final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
  if (cleaned.isEmpty || cleaned == '.') return Money.zero;

  final value = Decimal.tryParse(cleaned);
  if (value == null) return Money.zero;
  return Money(value.shift(decimals).round().toBigInt().toInt());
}

/// Đổi số tiền thành chuỗi hiển thị trong ô nhập. Rỗng khi bằng 0 để nhãn
/// gợi ý của ô nhập còn chỗ hiện ra.
@visibleForTesting
String formatAmount(Money amount, int decimals) =>
    amount.isZero ? '' : VnFormat.amount(amount, decimals: decimals);

String _group(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Định dạng ngay khi gõ: chỉ nhận chữ số, đúng một dấu thập phân, và chèn
/// dấu ngăn nghìn cho phần nguyên.
class _MoneyFormatter extends TextInputFormatter {
  final int decimals;

  const _MoneyFormatter({required this.decimals});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final source = newValue.text;
    if (source.isEmpty) return newValue;

    final integerDigits = StringBuffer();
    final fractionDigits = StringBuffer();
    var separatorSeen = false;

    for (final rune in source.runes) {
      final ch = String.fromCharCode(rune);

      if (ch == '.' || ch == ',') {
        // Dấu chấm khi gõ là ngăn nghìn, ứng dụng tự chèn — bỏ qua. Dấu phẩy
        // là dấu thập phân, và chỉ nhận đúng một dấu.
        if (ch == ',' && decimals > 0 && !separatorSeen) separatorSeen = true;
        continue;
      }

      final code = ch.codeUnitAt(0);
      if (code < 0x30 || code > 0x39) continue;

      if (separatorSeen) {
        if (fractionDigits.length >= decimals) continue;
        fractionDigits.write(ch);
      } else {
        integerDigits.write(ch);
      }
    }

    final grouped = _group(integerDigits.toString());
    final result = StringBuffer(grouped);
    if (separatorSeen) result.write(',$fractionDigits');

    final text = result.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
