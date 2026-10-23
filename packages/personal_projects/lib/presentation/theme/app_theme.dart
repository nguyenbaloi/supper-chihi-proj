/// Hệ thống thiết kế của ứng dụng — **nơi duy nhất** quyết định cỡ chữ, màu
/// nền và hình dáng của mọi thành phần dùng lại.
///
/// Widget không tự đặt `fontSize` hay `Color` nền: chúng đọc `Theme.of` và
/// `AppSpacing`. Đặt rải rác là cách chắc chắn nhất để mỗi màn hình một kiểu.
///
/// Ba điều chỉnh quan trọng so với theme mặc định của Material:
///
/// 1. **Chiều cao dòng tối thiểu 1.3.** Tiếng Việt có dấu chồng hai tầng
///    (`ế`, `ộ`, `ỹ`); `height` mặc định của Material cắt mất phần trên của
///    dấu ở cỡ chữ tiêu đề.
/// 2. **Chữ to hơn một bậc.** Body 15.5 thay vì 14 — danh sách việc là thứ
///    đọc lướt hàng ngày, không phải bảng dữ liệu.
/// 3. **Nền xám rất nhạt, thẻ trắng, viền tóc.** Thay cho đổ bóng: bóng làm
///    danh sách dài trông bẩn, viền 1px thì không.
library;

import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Lề ngang chuẩn của mọi màn hình. Mọi thứ thẳng hàng theo cột này.
  static const double gutter = 16;
}

abstract final class AppRadius {
  static const double field = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;
}

/// Bảng màu nền và chữ. Giữ riêng khỏi `ColorScheme` sinh từ hạt giống vì
/// `fromSeed` cho ra nền hơi ngả tím, không hợp với một app đọc nhiều chữ.
abstract final class AppColors {
  static const seed = Color(0xFF3F6FB5);

  static const lightBackground = Color(0xFFF5F6F8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceMuted = Color(0xFFEEF0F4);
  static const lightBorder = Color(0xFFE2E5EA);
  static const lightText = Color(0xFF14171C);
  static const lightTextMuted = Color(0xFF6A727E);

  static const darkBackground = Color(0xFF0E1013);
  static const darkSurface = Color(0xFF171A1F);
  static const darkSurfaceMuted = Color(0xFF20242B);
  static const darkBorder = Color(0xFF2A2F37);
  static const darkText = Color(0xFFE9EBEE);
  static const darkTextMuted = Color(0xFF98A0AC);
}

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  final background = dark ? AppColors.darkBackground : AppColors.lightBackground;
  final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
  final surfaceMuted =
      dark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted;
  final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
  final text = dark ? AppColors.darkText : AppColors.lightText;
  final muted = dark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: brightness,
  ).copyWith(
    surface: background,
    onSurface: text,
    surfaceContainerLowest: surface,
    surfaceContainerLow: surface,
    surfaceContainer: surfaceMuted,
    surfaceContainerHigh: surfaceMuted,
    surfaceContainerHighest: surfaceMuted,
    outline: muted,
    outlineVariant: border,
  );

  final textTheme = _textTheme(text, muted);

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: AppSpacing.gutter,
      titleTextStyle: textTheme.headlineSmall,
      toolbarHeight: 58,
    ),

    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: border),
      ),
    ),

    listTileTheme: ListTileThemeData(
      minVerticalPadding: 12,
      horizontalTitleGap: 12,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: 2,
      ),
      titleTextStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      subtitleTextStyle: textTheme.bodySmall,
      iconColor: muted,
    ),

    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceMuted,
      selectedColor: scheme.primary.withValues(alpha: dark ? 0.24 : 0.14),
      side: BorderSide(color: border),
      labelStyle: textTheme.labelMedium,
      secondaryLabelStyle: textTheme.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      showCheckmark: false,
      shape: const StadiumBorder(),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
      labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 50),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 46),
        textStyle: textTheme.labelLarge,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
    ),

    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        textStyle: textTheme.labelMedium,
        side: BorderSide(color: border),
        selectedBackgroundColor:
            scheme.primary.withValues(alpha: dark ? 0.26 : 0.14),
        selectedForegroundColor: dark ? scheme.onSurface : scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: scheme.primary.withValues(alpha: dark ? 0.26 : 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => textTheme.labelSmall?.copyWith(
          color: states.contains(WidgetState.selected) ? scheme.primary : muted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected) ? scheme.primary : muted,
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      highlightElevation: 3,
      extendedTextStyle: textTheme.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelStyle: textTheme.titleSmall,
      unselectedLabelStyle: textTheme.titleSmall,
      labelColor: scheme.primary,
      unselectedLabelColor: muted,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: border,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sheet),
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      textStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        side: BorderSide(color: border),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearMinHeight: 7,
      linearTrackColor: surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
  );
}

/// Thang chữ. Bốn bậc tiêu đề, ba bậc thân, ba bậc nhãn — không hơn.
TextTheme _textTheme(Color text, Color muted) => TextTheme(
      displaySmall: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.25,
          color: text),
      headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          height: 1.3,
          color: text),
      headlineSmall: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.3,
          color: text),
      titleLarge: TextStyle(
          fontSize: 18.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          height: 1.32,
          color: text),
      titleMedium: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: 1.35,
          color: text),
      titleSmall: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: text),
      bodyLarge: TextStyle(fontSize: 15.5, height: 1.42, color: text),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: text),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: muted),
      labelLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, height: 1.3, color: text),
      labelMedium: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0.1,
          color: text),
      labelSmall: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 0.3,
          color: muted),
    );
