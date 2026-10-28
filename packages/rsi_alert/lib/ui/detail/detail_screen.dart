import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app_core/mini_app_core.dart';

import '../../app/providers.dart';
import '../../app/symbol_view.dart';
import '../../domain/candle.dart';
import '../../domain/market_symbol.dart';
import '../format.dart';
import '../strings.dart';
import 'candle_painter.dart';
import 'chart_geometry.dart';
import 'chart_viewport.dart';
import 'rsi_painter.dart';

/// Màn hình Chi tiết: khung nến trên, khung RSI dưới, chung một viewport
/// (FR-6, FR-7, FR-8).
class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, this.focusCandleIndex});

  /// Khi mở từ tab Lịch sử: chỉ số nến cần đưa vào giữa khung (Story 5.2).
  final int? focusCandleIndex;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  /// Viewport sống trong State chứ không trong provider — ngoại lệ có chủ đích
  /// đã ghi ở §Consistency Conventions: nó là trạng thái hiển thị thuần tuý,
  /// không phải trạng thái nghiệp vụ.
  ChartViewport? _viewport;
  MarketSymbol? _viewportSymbol;
  int? _crosshairIndex;
  double _panRemainder = 0;

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(selectedSymbolProvider);
    final view = ref.watch(overviewControllerProvider).viewOf(symbol);

    return Scaffold(
      appBar: AppBar(
        leading: MiniAppScope.exitButtonOf(context),
        title: Text(symbol.fullName),
        actions: [
          PopupMenuButton<MarketSymbol>(
            icon: const Icon(Icons.swap_horiz),
            onSelected: (next) =>
                ref.read(selectedSymbolProvider.notifier).select(next),
            itemBuilder: (context) => [
              for (final option in MarketSymbol.values)
                PopupMenuItem(value: option, child: Text(option.label)),
            ],
          ),
        ],
      ),
      body: view == null || view.candles.isEmpty
          ? const _EmptyChart()
          : _buildChart(context, view, symbol),
    );
  }

  Widget _buildChart(BuildContext context, SymbolView view, MarketSymbol symbol) {
    final total = view.candles.length;

    // Đổi Mã hoặc dữ liệu đổi độ dài thì dựng lại cửa sổ.
    if (_viewport == null || _viewportSymbol != symbol) {
      _viewportSymbol = symbol;
      _viewport = widget.focusCandleIndex != null
          ? ChartViewport.centeredOn(widget.focusCandleIndex!, total)
          : ChartViewport.initial(total);
    }
    final viewport = _viewport!.clamped(total);

    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.hintColor, fontSize: 10);
    final gridColor = theme.dividerColor.withValues(alpha: 0.6);

    return Column(
      children: [
        _CandleReadout(
          view: view,
          index: _crosshairIndex ?? viewport.endIndex - 1,
          isCrosshair: _crosshairIndex != null,
        ),
        Expanded(
          flex: 3,
          child: _GestureLayer(
            total: total,
            viewport: viewport,
            onViewportChanged: (next) => setState(() => _viewport = next),
            onCrosshair: (index) => setState(() => _crosshairIndex = index),
            panRemainder: () => _panRemainder,
            setPanRemainder: (value) => _panRemainder = value,
            child: CustomPaint(
              painter: CandlePainter(
                candles: view.candles,
                viewport: viewport,
                brightness: theme.brightness,
                gridColor: gridColor,
                labelStyle: labelStyle,
                crosshairIndex: _crosshairIndex,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          flex: 2,
          child: _GestureLayer(
            total: total,
            viewport: viewport,
            onViewportChanged: (next) => setState(() => _viewport = next),
            onCrosshair: (index) => setState(() => _crosshairIndex = index),
            panRemainder: () => _panRemainder,
            setPanRemainder: (value) => _panRemainder = value,
            child: CustomPaint(
              painter: RsiPainter(
                rsiPoints: view.rsiPoints,
                signals: view.signals,
                viewport: viewport,
                brightness: theme.brightness,
                lineColor: theme.colorScheme.primary,
                gridColor: gridColor,
                labelStyle: labelStyle,
                crosshairIndex: _crosshairIndex,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

/// Cử chỉ cuộn và phóng. Đặt trên cả hai khung và cùng cập nhật một viewport,
/// nên kéo ở khung nào thì khung kia cũng đi theo (AD-7).
class _GestureLayer extends StatelessWidget {
  const _GestureLayer({
    required this.total,
    required this.viewport,
    required this.onViewportChanged,
    required this.onCrosshair,
    required this.panRemainder,
    required this.setPanRemainder,
    required this.child,
  });

  final int total;
  final ChartViewport viewport;
  final ValueChanged<ChartViewport> onViewportChanged;
  final ValueChanged<int?> onCrosshair;
  final double Function() panRemainder;
  final ValueChanged<double> setPanRemainder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = ChartGeometry(
          viewport: viewport,
          width: constraints.maxWidth,
          leftPadding: 4,
          rightPadding: ChartGeometry.axisLabelWidth,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (_) => setPanRemainder(0),
          onScaleUpdate: (details) {
            if (details.pointerCount >= 2 && details.scale != 1) {
              final ratio = geometry.plotWidth <= 0
                  ? 0.5
                  : ((details.localFocalPoint.dx - geometry.leftPadding) /
                          geometry.plotWidth)
                      .clamp(0.0, 1.0);
              onViewportChanged(viewport.zoomBy(details.scale, ratio, total));
              return;
            }
            if (geometry.columnWidth <= 0) return;

            // Gom phần lẻ chưa đủ một cột lại, để kéo chậm vẫn mượt thay vì
            // giật từng nến.
            final moved = panRemainder() - details.focalPointDelta.dx / geometry.columnWidth;
            final whole = moved.truncate();
            setPanRemainder(moved - whole);
            if (whole != 0) onViewportChanged(viewport.panBy(whole, total));
          },
          onLongPressStart: (details) =>
              onCrosshair(geometry.indexAt(details.localPosition.dx)),
          onLongPressMoveUpdate: (details) =>
              onCrosshair(geometry.indexAt(details.localPosition.dx)),
          onLongPressEnd: (_) => onCrosshair(null),
          onLongPressCancel: () => onCrosshair(null),
          child: child,
        );
      },
    );
  }
}

/// Dòng số liệu phía trên biểu đồ: mặc định là nến mới nhất, chuyển sang nến
/// dưới ngón tay khi đang giữ (FR-8).
class _CandleReadout extends StatelessWidget {
  const _CandleReadout({
    required this.view,
    required this.index,
    required this.isCrosshair,
  });

  final SymbolView view;
  final int index;
  final bool isCrosshair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (index < 0 || index >= view.candles.length) {
      return const SizedBox(height: 62);
    }
    final Candle candle = view.candles[index];
    final rsi = _rsiAt(index);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF111827)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.weekOf(formatWeekRange(candle.openTime)),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!candle.isClosed) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.hintColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    S.runningWeek,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _field(theme, S.chartOpen, formatPrice(candle.open, view.symbol)),
              _field(theme, S.chartHigh, formatPrice(candle.high, view.symbol)),
              _field(theme, S.chartLow, formatPrice(candle.low, view.symbol)),
              _field(theme, S.chartClose, formatPrice(candle.close, view.symbol)),
              _field(theme, S.chartRsi, rsi == null ? '—' : formatRsi(rsi)),
            ],
          ),
        ],
      ),
    );
  }

  double? _rsiAt(int candleIndex) {
    for (final point in view.rsiPoints) {
      if (point.candleIndex == candleIndex) return point.value;
    }
    return null;
  }

  Widget _field(ThemeData theme, String label, String value) => RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(color: theme.hintColor),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.show_chart, size: 40),
              const SizedBox(height: 12),
              Text(S.noDataTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(S.noDataBody, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
