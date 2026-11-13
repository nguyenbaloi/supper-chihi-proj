import 'constants.dart';

/// Một giá trị Fear & Greed Index crypto theo ngày (AD-13).
///
/// Đây là dữ liệu **đầu vào thô** như OHLCV, được phép lưu. Việc nó có xác
/// nhận một Vùng DCA hay không thì luôn tính lại (AD-2).
class FearGreedPoint {
  FearGreedPoint({required this.day, required this.value})
      : assert(day.isUtc, 'day phải là UTC — AD-3');

  /// 00:00 UTC của ngày nguồn công bố giá trị.
  final DateTime day;

  /// 0 (sợ hãi tột độ) – 100 (tham lam tột độ).
  final int value;

  Map<String, dynamic> toJson() =>
      {'t': day.millisecondsSinceEpoch, 'x': value};

  factory FearGreedPoint.fromJson(Map<String, dynamic> json) => FearGreedPoint(
        day: DateTime.fromMillisecondsSinceEpoch(
          (json['t'] as num).toInt(),
          isUtc: true,
        ),
        value: (json['x'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      other is FearGreedPoint && other.day == day && other.value == value;

  @override
  int get hashCode => Object.hash(day, value);
}

/// Giá trị F&G tại ngày đóng của nến tuần mở lúc [weekOpenTime].
///
/// Nến BTC mở thứ Hai 00:00 UTC nên ngày cuối tuần là Chủ nhật — mở + 6 ngày.
/// Nguồn có thể thiếu vài ngày, nên lùi tối đa 3 ngày để tìm giá trị gần nhất;
/// không bao giờ lấy giá trị **sau** khi nến đóng (sẽ là nhìn trước tương lai).
int? fearGreedAtWeekClose(
  Map<int, int> valueByDay,
  DateTime weekOpenTime,
) {
  final close = DateTime.utc(
    weekOpenTime.year,
    weekOpenTime.month,
    weekOpenTime.day + 6,
  );
  for (var back = 0; back <= 3; back++) {
    final day = DateTime.utc(close.year, close.month, close.day - back);
    final value = valueByDay[day.millisecondsSinceEpoch];
    if (value != null) return value;
  }
  return null;
}

/// Chỉ mục tra cứu theo ngày cho [fearGreedAtWeekClose].
Map<int, int> indexFearGreed(List<FearGreedPoint> points) => {
      for (final p in points)
        DateTime.utc(p.day.year, p.day.month, p.day.day).millisecondsSinceEpoch:
            p.value,
    };

/// Năm mức tâm lý theo cột Crypto của Cẩm nang trang 1.
enum FearGreedLevel {
  extremeFear,
  fear,
  neutral,
  greed,
  extremeGreed;

  static FearGreedLevel of(int value) {
    if (value <= fearGreedExtremeFearMax) return extremeFear;
    if (value <= fearGreedFearMax) return fear;
    if (value <= fearGreedNeutralMax) return neutral;
    if (value <= fearGreedGreedMax) return greed;
    return extremeGreed;
  }
}
