import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';

/// Bảng màu và chủ đề.
///
/// Màu lãi lỗ tách riêng khỏi `colorScheme.error` vì hai thứ khác nhau: lỗ là
/// một trạng thái bình thường của danh mục, không phải lỗi của ứng dụng.
class AppTheme {
  const AppTheme._();

  static const Color profitLight = Color(0xFF1B7F3B);
  static const Color profitDark = Color(0xFF5FD787);
  static const Color lossLight = Color(0xFFC62828);
  static const Color lossDark = Color(0xFFFF8A80);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: brightness,
    );
    // Lấy sẵn kiểu chữ mặc định để kế thừa họ font, chỉ đổi cỡ và độ đậm.
    // Dựng `TextStyle` trần thì mất họ font và rơi vào font dự phòng.
    final baseTextTheme =
        ThemeData(colorScheme: scheme, useMaterial3: true).textTheme;
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        // Tiêu đề màn hình đậm và lớn hơn mặc định M3 (`titleLarge`: 22, w400).
        // Phải ghi luôn màu: khi `titleTextStyle` bị ghi đè, AppBar không còn
        // áp màu mặc định nữa.
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        ),
      ),
      // Nhãn thanh điều hướng đậm hơn mặc định M3 (`labelMedium`, w500). Phải
      // ghi luôn màu: khi `labelTextStyle` bị ghi đè, NavigationBar không còn
      // áp màu mặc định theo trạng thái nữa.
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.5,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeMode toThemeMode(ThemeModeSetting setting) => switch (setting) {
        ThemeModeSetting.light => ThemeMode.light,
        ThemeModeSetting.dark => ThemeMode.dark,
        ThemeModeSetting.system => ThemeMode.system,
      };
}

extension ProfitLossColors on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get profitColor =>
      _isDark ? AppTheme.profitDark : AppTheme.profitLight;

  Color get lossColor => _isDark ? AppTheme.lossDark : AppTheme.lossLight;

  /// Màu cho một con số lãi lỗ. Hoà vốn dùng màu chữ thường — tô xanh một số 0
  /// là nói rằng có lãi.
  Color colorForAmount(int amount) {
    if (amount > 0) return profitColor;
    if (amount < 0) return lossColor;
    return Theme.of(this).colorScheme.onSurface;
  }
}
