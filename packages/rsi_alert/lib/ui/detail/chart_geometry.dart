import 'dart:ui';

import 'chart_viewport.dart';

/// Phép chiếu từ chỉ số nến sang toạ độ ngang, dùng chung cho hai painter.
///
/// Cả khung giá lẫn khung RSI đều tính vị trí cột qua đây, nên một nến luôn
/// rơi vào cùng toạ độ x ở cả hai khung (AD-7).
class ChartGeometry {
  const ChartGeometry({
    required this.viewport,
    required this.width,
    required this.leftPadding,
    required this.rightPadding,
  });

  /// Chừa chỗ bên phải cho nhãn trục dọc.
  static const double axisLabelWidth = 44;

  final ChartViewport viewport;
  final double width;
  final double leftPadding;
  final double rightPadding;

  double get plotWidth => width - leftPadding - rightPadding;

  double get columnWidth =>
      viewport.visibleCount == 0 ? 0 : plotWidth / viewport.visibleCount;

  /// Tâm cột của nến thứ [index] trong chuỗi gốc.
  double xOf(int index) =>
      leftPadding + (index - viewport.startIndex + 0.5) * columnWidth;

  /// Chỉ số nến gần toạ độ [x] nhất, đã kẹp vào cửa sổ đang xem.
  int indexAt(double x) {
    if (columnWidth <= 0) return viewport.startIndex;
    final raw = ((x - leftPadding) / columnWidth).floor() + viewport.startIndex;
    if (raw < viewport.startIndex) return viewport.startIndex;
    if (raw >= viewport.endIndex) return viewport.endIndex - 1;
    return raw;
  }

  /// Bề rộng thân nến: chừa khe giữa các cột, và không mảnh hơn một điểm ảnh.
  double get bodyWidth {
    final w = columnWidth * 0.68;
    return w < 1 ? 1 : w;
  }
}

/// Phép chiếu giá trị sang toạ độ dọc trong một khung.
class VerticalScale {
  VerticalScale({
    required this.min,
    required this.max,
    required this.top,
    required this.height,
  });

  final double min;
  final double max;
  final double top;
  final double height;

  double yOf(double value) {
    final span = max - min;
    if (span <= 0) return top + height / 2;
    return top + height * (1 - (value - min) / span);
  }

  Offset pointAt(double x, double value) => Offset(x, yOf(value));
}
