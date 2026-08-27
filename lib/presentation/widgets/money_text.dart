import 'package:flutter/material.dart';

import '../../core/format/vn_format.dart';
import '../../core/money/money.dart';
import '../theme/app_theme.dart';

/// Hiển thị một khoản tiền theo định dạng Việt Nam.
class MoneyText extends StatelessWidget {
  final Money amount;
  final TextStyle? style;
  final bool compact;

  /// Tô màu theo dấu — chỉ dùng cho Lãi lỗ và Khoảng lệch, không dùng cho giá
  /// trị tài sản (một danh mục 680 triệu không phải "lãi").
  final bool colorBySign;

  /// Thêm dấu `+` phía trước số dương.
  final bool showPlusSign;

  const MoneyText(
    this.amount, {
    super.key,
    this.style,
    this.compact = false,
    this.colorBySign = false,
    this.showPlusSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = compact
        ? VnFormat.moneyCompact(amount)
        : VnFormat.money(amount);
    final prefixed =
        showPlusSign && amount.isPositive ? '+$text' : text;

    return Text(
      prefixed,
      style: (style ?? const TextStyle()).copyWith(
        color: colorBySign
            ? context.colorForAmount(amount.amount)
            : style?.color,
      ),
    );
  }
}
