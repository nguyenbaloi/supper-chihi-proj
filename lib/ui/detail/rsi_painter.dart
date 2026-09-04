import 'package:flutter/material.dart';

import '../../domain/constants.dart';
import '../../domain/rsi.dart';
import '../../domain/rsi_status.dart';
import '../../domain/signal.dart';
import '../theme.dart';
import 'chart_geometry.dart';
import 'chart_viewport.dart';

/// Vẽ khung RSI kèm hai vạch ngưỡng (FR-7).
///
/// Trục dọc **cố định 0–100**, không co giãn theo dữ liệu: hai vạch ngưỡng chỉ
/// có nghĩa khi chúng luôn nằm ở cùng một chỗ trên màn hình.
class RsiPainter extends CustomPainter {
  RsiPainter({
    required this.rsiPoints,
    required this.signals,
    required this.viewport,
    required this.brightness,
    required this.lineColor,
    required this.gridColor,
    required this.labelStyle,
    this.crosshairIndex,
  });

  /// Trục dọc cố định — xem chú thích lớp.
  static const double axisMin = 0;
  static const double axisMax = 100;

  final List<RsiPoint> rsiPoints;
  final List<Signal> signals;
  final ChartViewport viewport;
  final Brightness brightness;
  final Color lineColor;
  final Color gridColor;
  final TextStyle labelStyle;
  final int? crosshairIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (viewport.visibleCount == 0) return;

    final geometry = ChartGeometry(
      viewport: viewport,
      width: size.width,
      leftPadding: 4,
      rightPadding: ChartGeometry.axisLabelWidth,
    );
    final scale = VerticalScale(
      min: axisMin,
      max: axisMax,
      top: 0,
      height: size.height,
    );

    _paintThresholds(canvas, geometry, scale);
    _paintLine(canvas, geometry, scale);
    _paintSignalMarkers(canvas, geometry, scale);

    if (crosshairIndex case final index?) {
      final x = geometry.xOf(index);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = labelStyle.color!.withValues(alpha: 0.55)
          ..strokeWidth = 1,
      );
    }
  }

  void _paintThresholds(
    Canvas canvas,
    ChartGeometry geometry,
    VerticalScale scale,
  ) {
    final midPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(0, scale.yOf((axisMin + axisMax) / 2)),
      Offset(geometry.plotWidth, scale.yOf((axisMin + axisMax) / 2)),
      midPaint,
    );

    final bands = <(double, RsiStatus)>[
      (oversoldThreshold, RsiStatus.oversold),
      (overboughtThreshold, RsiStatus.overbought),
    ];
    for (final (value, status) in bands) {
      final color = StatusColors.of(status, brightness);
      final y = scale.yOf(value);
      canvas.drawLine(
        Offset(0, y),
        Offset(geometry.plotWidth, y),
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = 1,
      );
      TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(0),
          style: labelStyle.copyWith(color: color),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(geometry.plotWidth + 4, y - 6));
    }
  }

  /// Đoạn đầu chuỗi chưa có RSI thì **không vẽ gì** — vẽ giá trị 0 ở đó sẽ là
  /// một lời nói dối về dữ liệu (AD-2).
  void _paintLine(
    Canvas canvas,
    ChartGeometry geometry,
    VerticalScale scale,
  ) {
    final path = Path();
    var started = false;

    for (final point in rsiPoints) {
      if (point.candleIndex < viewport.startIndex - 1) continue;
      if (point.candleIndex > viewport.endIndex) break;

      final offset = scale.pointAt(geometry.xOf(point.candleIndex), point.value);
      if (started) {
        path.lineTo(offset.dx, offset.dy);
      } else {
        path.moveTo(offset.dx, offset.dy);
        started = true;
      }
    }
    if (!started) return;

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintSignalMarkers(
    Canvas canvas,
    ChartGeometry geometry,
    VerticalScale scale,
  ) {
    for (final signal in signals) {
      if (signal.candleIndex < viewport.startIndex ||
          signal.candleIndex >= viewport.endIndex) {
        continue;
      }
      final color = StatusColors.of(
        signal.type == SignalType.oversold
            ? RsiStatus.oversold
            : RsiStatus.overbought,
        brightness,
      );
      final center =
          scale.pointAt(geometry.xOf(signal.candleIndex), signal.rsiValue);
      // Vòng ngoài mờ nhạt làm nổi bật điểm tín hiệu
      canvas.drawCircle(
        center,
        6.0,
        Paint()..color = color.withValues(alpha: 0.35),
      );
      // Điểm tâm đậm
      canvas.drawCircle(
        center,
        3.5,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(RsiPainter old) =>
      old.viewport != viewport ||
      old.crosshairIndex != crosshairIndex ||
      !identical(old.rsiPoints, rsiPoints) ||
      !identical(old.signals, signals) ||
      old.brightness != brightness;
}
