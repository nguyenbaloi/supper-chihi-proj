import 'package:flutter/material.dart';

import '../domain/dca.dart';
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
      RsiStatus.oversold =>
        dark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
      RsiStatus.overbought =>
        dark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
      RsiStatus.neutral =>
        dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      RsiStatus.insufficientData =>
        dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
    };
  }
}

/// Màu Vùng DCA: vùng mua dùng màu Quá bán, vùng bán dùng màu Quá mua, vùng
/// thăm dò nhạt hơn vùng mạnh. Luôn đi kèm tên vùng — không chỉ dựa vào màu.
class DcaColors {
  const DcaColors._();

  static Color of(DcaZone zone, Brightness brightness) => switch (zone) {
        DcaZone.strongBuy => StatusColors.of(RsiStatus.oversold, brightness),
        DcaZone.probeBuy => StatusColors.of(RsiStatus.oversold, brightness)
            .withValues(alpha: 0.75),
        DcaZone.hold => StatusColors.of(RsiStatus.neutral, brightness),
        DcaZone.probeSell => StatusColors.of(RsiStatus.overbought, brightness)
            .withValues(alpha: 0.75),
        DcaZone.strongSell => brightness == Brightness.dark
            ? const Color(0xFFF87171)
            : const Color(0xFFB91C1C),
      };

  static Color divergence(Brightness brightness) =>
      of(DcaZone.strongSell, brightness);
}

/// Màu nến. Theo quy ước Việt Nam: xanh lá tăng, đỏ giảm.
class CandleColors {
  const CandleColors._();

  static Color up(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF22C55E)
      : const Color(0xFF16A34A);

  static Color down(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFFEF4444)
      : const Color(0xFFDC2626);
}

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
    brightness: brightness,
    surface: isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC),
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor:
          isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? Colors.black45 : Colors.black.withValues(alpha: 0.05),
      color: isDark ? const Color(0xFF161E2E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      indicatorColor: isDark
          ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
          : const Color(0xFF0F172A).withValues(alpha: 0.12),
    ),
  );
}
