import 'package:flutter/material.dart';

import '../../domain/candle.dart';
import '../theme.dart';
import 'chart_geometry.dart';
import 'chart_viewport.dart';

/// Vẽ khung nến tuần (FR-6).
///
/// Trục dọc co giãn theo **khoảng giá của các nến đang trong cửa sổ**, không
/// theo toàn chuỗi — nếu không, một đợt tăng mười lần trong quá khứ sẽ ép mọi
/// biến động gần đây thành một đường thẳng.
class CandlePainter extends CustomPainter {
  CandlePainter({
    required this.candles,
    required this.viewport,
    required this.brightness,
    required this.gridColor,
    required this.labelStyle,
    this.crosshairIndex,
  });

  final List<Candle> candles;
  final ChartViewport viewport;
  final Brightness brightness;
  final Color gridColor;
  final TextStyle labelStyle;
  final int? crosshairIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || viewport.visibleCount == 0) return;

    final geometry = ChartGeometry(
      viewport: viewport,
      width: size.width,
      leftPadding: 4,
      rightPadding: ChartGeometry.axisLabelWidth,
    );

    final visible = candles.sublist(
      viewport.startIndex,
      viewport.endIndex.clamp(0, candles.length),
    );
    if (visible.isEmpty) return;

    var low = visible.first.low;
    var high = visible.first.high;
    for (final candle in visible) {
      if (candle.low < low) low = candle.low;
      if (candle.high > high) high = candle.high;
    }
    final margin = (high - low) * 0.06;
    final scale = VerticalScale(
      min: low - margin,
      max: high + margin,
      top: 0,
      height: size.height,
    );

    _paintGrid(canvas, size, geometry, scale);

    final upColor = CandleColors.up(brightness);
    final downColor = CandleColors.down(brightness);

    for (var i = viewport.startIndex; i < viewport.endIndex; i++) {
      final candle = candles[i];
      final x = geometry.xOf(i);
      final color = candle.isUp ? upColor : downColor;

      // Nến đang chạy vẽ mờ để phân biệt rõ với nến đã đóng (AD-5).
      final paint = Paint()
        ..color = candle.isClosed ? color : color.withValues(alpha: 0.42)
        ..style = PaintingStyle.fill;
      final wickPaint = Paint()
        ..color = paint.color
        ..strokeWidth = 1;

      canvas.drawLine(
        scale.pointAt(x, candle.high),
        scale.pointAt(x, candle.low),
        wickPaint,
      );

      final bodyTop = scale.yOf(candle.isUp ? candle.close : candle.open);
      final bodyBottom = scale.yOf(candle.isUp ? candle.open : candle.close);
      canvas.drawRect(
        Rect.fromLTRB(
          x - geometry.bodyWidth / 2,
          bodyTop,
          x + geometry.bodyWidth / 2,
          // Nến có giá mở bằng giá đóng vẫn phải thấy được.
          bodyBottom - bodyTop < 1 ? bodyTop + 1 : bodyBottom,
        ),
        paint,
      );
    }

    if (crosshairIndex case final index?) {
      _paintCrosshair(canvas, size, geometry, index);
    }
  }

  void _paintGrid(
    Canvas canvas,
    Size size,
    ChartGeometry geometry,
    VerticalScale scale,
  ) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const lineCount = 4;
    for (var i = 0; i <= lineCount; i++) {
      final value = scale.min + (scale.max - scale.min) * i / lineCount;
      final y = scale.yOf(value);
      canvas.drawLine(Offset(0, y), Offset(geometry.plotWidth, y), paint);
      _paintLabel(
        canvas,
        _compact(value),
        Offset(geometry.plotWidth + 4, y - 6),
      );
    }
  }

  void _paintCrosshair(
    Canvas canvas,
    Size size,
    ChartGeometry geometry,
    int index,
  ) {
    final x = geometry.xOf(index);
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = labelStyle.color!.withValues(alpha: 0.55)
        ..strokeWidth = 1,
    );
  }

  void _paintLabel(Canvas canvas, String text, Offset offset) {
    TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, offset);
  }

  /// Nhãn trục giá: BTC cỡ vạn USD nên rút gọn, VNINDEX cỡ nghìn thì để nguyên.
  static String _compact(double value) {
    if (value >= 10000) return '${(value / 1000).toStringAsFixed(1)}k';
    if (value >= 1000) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(CandlePainter old) =>
      old.viewport != viewport ||
      old.crosshairIndex != crosshairIndex ||
      !identical(old.candles, candles) ||
      old.brightness != brightness;
}
