import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ô nhập Tỷ trọng mục tiêu, tính bằng phần trăm.
///
/// Giá trị vào ra là **phần vạn** (basis point) — đúng đơn vị đang lưu trong
/// DB. Một phần vạn là 0,01% nên ô nhập cho tối đa hai chữ số thập phân: mịn
/// hơn nữa là gõ được con số mà DB không giữ nổi.
///
/// Không đi qua `double` ở bất kỳ đâu: chuỗi chữ số vào thẳng [Decimal] rồi
/// dịch hai chữ số thành `int`. Xem AD-3.
///
/// Rỗng nghĩa là **chưa đặt mục tiêu**, khác hẳn 0%. Người dùng xoá trắng ô
/// là muốn bỏ mục tiêu chứ không phải đặt mục tiêu bằng không, nên [onChanged]
/// nhận `null` chứ không nhận 0.
class PercentField extends StatefulWidget {
  final String label;
  final int? initialBp;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  const PercentField({
    super.key,
    required this.label,
    required this.initialBp,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<PercentField> createState() => _PercentFieldState();
}

class _PercentFieldState extends State<PercentField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: formatBp(widget.initialBp));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Cố ý không đồng bộ lại nội dung ô theo `initialBp` ở `didUpdateWidget`.
  // Mỗi lần gõ là một lần ghi DB, ghi xong luồng dữ liệu phát lại và widget
  // dựng lại — đồng bộ ngược lúc đó sẽ ghi đè đúng chữ người dùng vừa gõ và
  // đẩy con trỏ về cuối. Ô này là nơi duy nhất sửa con số nên không có nguồn
  // thay đổi nào khác cần theo.

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        enabled: widget.enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.end,
        inputFormatters: const [_PercentFormatter()],
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: '%',
          isDense: true,
        ),
        onChanged: (text) => widget.onChanged(parseBp(text)),
      );
}

/// Số chữ số thập phân của phần trăm mà đơn vị phần vạn giữ được.
const int _percentDecimals = 2;

/// Đổi chuỗi trong ô nhập thành phần vạn. `null` khi ô rỗng.
///
/// Chuỗi luôn ở dạng chuẩn do [_PercentFormatter] sinh ra — chỉ chữ số và
/// nhiều nhất một dấu phẩy thập phân — nên không có chỗ nào nhập nhằng.
@visibleForTesting
int? parseBp(String text) {
  final cleaned = text.replaceAll(',', '.');
  if (cleaned.isEmpty || cleaned == '.') return null;

  final percent = Decimal.tryParse(cleaned);
  if (percent == null) return null;
  return percent.shift(_percentDecimals).round().toBigInt().toInt();
}

/// Đổi phần vạn thành chuỗi hiển thị trong ô nhập, dấu phẩy thập phân kiểu
/// Việt Nam. Bỏ chữ số 0 thừa: `4000` phần vạn hiện thành `40`, không phải
/// `40,00`.
@visibleForTesting
String formatBp(int? bp) {
  if (bp == null) return '';
  final percent = Decimal.fromInt(bp).shift(-_percentDecimals);
  final parts = percent.toStringAsFixed(_percentDecimals).split('.');
  final fraction = parts[1].replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? parts.first : '${parts.first},$fraction';
}

/// Ràng buộc ngay lúc gõ: chỉ chữ số, đúng một dấu thập phân, tối đa hai chữ
/// số thập phân, và không quá 100%.
///
/// Chặn tại chỗ thay vì báo lỗi lúc lưu — một Lớp tài sản chiếm hơn toàn bộ
/// danh mục là con số vô nghĩa, không đáng để người dùng gõ xong mới biết.
class _PercentFormatter extends TextInputFormatter {
  const _PercentFormatter();

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
        if (separatorSeen) continue;
        separatorSeen = true;
        continue;
      }

      final code = ch.codeUnitAt(0);
      if (code < 0x30 || code > 0x39) continue;

      if (separatorSeen) {
        if (fractionDigits.length >= _percentDecimals) continue;
        fractionDigits.write(ch);
      } else {
        // Bỏ số 0 vô nghĩa đứng đầu, nhưng giữ lại số 0 của `0,5`.
        if (integerDigits.isEmpty && ch == '0') {
          integerDigits.write(ch);
          continue;
        }
        if (integerDigits.toString() == '0') integerDigits.clear();
        integerDigits.write(ch);
      }
    }

    final text = StringBuffer(integerDigits.toString());
    if (separatorSeen) text.write(',$fractionDigits');
    final result = text.toString();

    // Vượt 100% thì giữ nguyên chuỗi cũ — phím vừa bấm không được nhận.
    final bp = parseBp(result);
    if (bp != null && bp > 10000) return oldValue;

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
