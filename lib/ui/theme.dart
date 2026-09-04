import 'package:flutter/material.dart';

import '../domain/rsi_status.dart';

/// Bảng màu Trạng thái, đọc được ở cả chế độ sáng lẫn tối.
///
/// Ba trạng thái phải phân biệt được bằng màu **và** bằng chữ — người dùng
/// không nên phải dựa vào màu để biết mình đang nhìn cái gì.
class StatusColors {
  const StatusColors._();

  static Color of(RsiStatus status, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (status) {
      RsiStatus.oversold => dark ? const Color(0xFF4FC3F7) : const Color(0xFF0277BD),
      RsiStatus.overbought => dark ? const Color(0xFFFF8A65) : const Color(0xFFD84315),
      RsiStatus.neutral => dark ? const Color(0xFF9E9E9E) : const Color(0xFF616161),
      RsiStatus.insufficientData =>
        dark ? const Color(0xFF757575) : const Color(0xFF9E9E9E),
    };
  }
}

/// Màu nến. Theo quy ước Việt Nam: xanh lá tăng, đỏ giảm.
class CandleColors {
  const CandleColors._();

  static Color up(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF4CAF50)
      : const Color(0xFF2E7D32);

  static Color down(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFFEF5350)
      : const Color(0xFFC62828);
}

ThemeData buildTheme(Brightness brightness) => ThemeData(
      brightness: brightness,
      colorSchemeSeed: const Color(0xFF1565C0),
      useMaterial3: true,
    );
