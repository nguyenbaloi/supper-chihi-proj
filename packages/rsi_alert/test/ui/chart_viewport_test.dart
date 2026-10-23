import 'package:flutter_test/flutter_test.dart';
import 'package:rsi_alert/ui/detail/chart_viewport.dart';

void main() {
  group('ChartViewport — AD-7', () {
    test('cửa sổ ban đầu đặt nến mới nhất sát mép phải', () {
      final viewport = ChartViewport.initial(500);

      expect(viewport.visibleCount, ChartViewport.defaultVisibleCount);
      expect(viewport.endIndex, 500);
    });

    test('ít nến hơn mặc định thì hiện toàn bộ', () {
      final viewport = ChartViewport.initial(25);

      expect(viewport.startIndex, 0);
      expect(viewport.visibleCount, 25);
    });

    test('không cuộn ra ngoài biên trái', () {
      final viewport = ChartViewport.initial(500).panBy(-9999, 500);

      expect(viewport.startIndex, 0);
      expect(viewport.visibleCount, ChartViewport.defaultVisibleCount);
    });

    test('không cuộn ra ngoài biên phải', () {
      final viewport = ChartViewport.initial(500).panBy(9999, 500);

      expect(viewport.endIndex, 500);
    });

    test('phóng bị kẹp ở số nến tối thiểu', () {
      final viewport = ChartViewport.initial(500).zoomBy(100, 0.5, 500);

      expect(viewport.visibleCount, ChartViewport.minVisibleCount);
    });

    test('thu nhỏ hết cỡ thì hiện toàn bộ chuỗi', () {
      final viewport = ChartViewport.initial(500).zoomBy(0.001, 0.5, 500);

      expect(viewport.startIndex, 0);
      expect(viewport.visibleCount, 500);
    });

    test('phóng quanh điểm neo giữ nến dưới ngón tay đứng yên', () {
      const before = ChartViewport(startIndex: 100, visibleCount: 60);
      final anchorBefore = before.startIndex + before.visibleCount * 0.25;

      final after = before.zoomBy(2, 0.25, 500);
      final anchorAfter = after.startIndex + after.visibleCount * 0.25;

      expect((anchorAfter - anchorBefore).abs(), lessThanOrEqualTo(1));
    });

    test('centeredOn đưa nến chỉ định vào trong cửa sổ', () {
      for (final index in [0, 7, 250, 499]) {
        final viewport = ChartViewport.centeredOn(index, 500);
        expect(index, greaterThanOrEqualTo(viewport.startIndex));
        expect(index, lessThan(viewport.endIndex));
      }
    });

    test('chuỗi rỗng không làm hỏng viewport', () {
      final viewport = ChartViewport.initial(0).clamped(0);

      expect(viewport.startIndex, 0);
      expect(viewport.visibleCount, 0);
    });

    test('mọi phép biến đổi đều giữ cửa sổ nằm trong dữ liệu', () {
      var viewport = ChartViewport.initial(120);
      for (final step in [30, -200, 5, 999, -3]) {
        viewport = viewport.panBy(step, 120);
        expect(viewport.startIndex, greaterThanOrEqualTo(0));
        expect(viewport.endIndex, lessThanOrEqualTo(120));
      }
      for (final scale in [3.0, 0.2, 10.0, 0.05]) {
        viewport = viewport.zoomBy(scale, 0.5, 120);
        expect(viewport.startIndex, greaterThanOrEqualTo(0));
        expect(viewport.endIndex, lessThanOrEqualTo(120));
        expect(viewport.visibleCount, greaterThan(0));
      }
    });
  });
}
