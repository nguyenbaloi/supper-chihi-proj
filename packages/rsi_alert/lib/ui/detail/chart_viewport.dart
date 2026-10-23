/// Cửa sổ thời gian đang xem, dùng chung cho khung giá và khung RSI (AD-7).
///
/// Đây là thứ duy nhất giữ cho hai khung không lệch trục: cả hai painter đều
/// đọc chính đối tượng này, nên một cột thời gian luôn rơi vào cùng toạ độ
/// ngang ở cả hai.
///
/// Viewport đánh chỉ số theo **vị trí nến**, không theo thời gian tuyến tính.
/// Bắt buộc phải vậy: chuỗi VNINDEX thiếu hẳn tuần nghỉ Tết mỗi năm, nên một
/// trục thời gian tuyến tính sẽ vẽ ra khoảng trắng giả ở mỗi dịp Tết.
class ChartViewport {
  const ChartViewport({required this.startIndex, required this.visibleCount});

  /// Số nến hiển thị mặc định khi mới mở màn hình Chi tiết.
  static const int defaultVisibleCount = 60;

  /// Không cho phóng sát hơn mức này — dưới ngưỡng đó biểu đồ mất hết bối cảnh.
  static const int minVisibleCount = 20;

  final int startIndex;
  final int visibleCount;

  int get endIndex => startIndex + visibleCount;

  /// Cửa sổ ban đầu: nến mới nhất nằm sát mép phải.
  factory ChartViewport.initial(int totalCandles) {
    final count = totalCandles < defaultVisibleCount
        ? totalCandles
        : defaultVisibleCount;
    return ChartViewport(
      startIndex: totalCandles - count,
      visibleCount: count,
    );
  }

  /// Cửa sổ đặt sao cho [candleIndex] nằm giữa — dùng khi nhảy từ tab Lịch sử
  /// sang đúng tuần của một Tín hiệu (Story 5.2).
  factory ChartViewport.centeredOn(int candleIndex, int totalCandles) {
    final count = totalCandles < defaultVisibleCount
        ? totalCandles
        : defaultVisibleCount;
    return ChartViewport(
      startIndex: candleIndex - count ~/ 2,
      visibleCount: count,
    ).clamped(totalCandles);
  }

  /// Kẹp vào hai biên dữ liệu. Gọi sau **mọi** thay đổi viewport.
  ChartViewport clamped(int totalCandles) {
    if (totalCandles <= 0) {
      return const ChartViewport(startIndex: 0, visibleCount: 0);
    }

    var count = visibleCount;
    if (count > totalCandles) count = totalCandles;
    if (count < minVisibleCount) {
      count = totalCandles < minVisibleCount ? totalCandles : minVisibleCount;
    }

    var start = startIndex;
    final maxStart = totalCandles - count;
    if (start > maxStart) start = maxStart;
    if (start < 0) start = 0;

    return ChartViewport(startIndex: start, visibleCount: count);
  }

  ChartViewport panBy(int candles, int totalCandles) =>
      ChartViewport(startIndex: startIndex + candles, visibleCount: visibleCount)
          .clamped(totalCandles);

  /// Phóng quanh một điểm neo: [focusRatio] là vị trí ngón tay trên bề rộng
  /// khung, để nến dưới ngón tay đứng yên khi phóng.
  ChartViewport zoomBy(double scale, double focusRatio, int totalCandles) {
    final newCount = (visibleCount / scale).round();
    final focusCandle = startIndex + visibleCount * focusRatio;
    return ChartViewport(
      startIndex: (focusCandle - newCount * focusRatio).round(),
      visibleCount: newCount,
    ).clamped(totalCandles);
  }

  ChartViewport copyWith({int? startIndex, int? visibleCount}) => ChartViewport(
        startIndex: startIndex ?? this.startIndex,
        visibleCount: visibleCount ?? this.visibleCount,
      );

  @override
  bool operator ==(Object other) =>
      other is ChartViewport &&
      other.startIndex == startIndex &&
      other.visibleCount == visibleCount;

  @override
  int get hashCode => Object.hash(startIndex, visibleCount);

  @override
  String toString() => 'ChartViewport($startIndex, $visibleCount)';
}
