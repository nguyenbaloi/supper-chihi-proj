import 'constants.dart';

/// Giá trị RSI tại một nến, kèm chỉ số của nến đó trong chuỗi gốc.
///
/// [candleIndex] để tầng vẽ ghép được điểm RSI về đúng cột thời gian: chuỗi
/// RSI ngắn hơn chuỗi nến đúng [rsiPeriod] phần tử.
class RsiPoint {
  const RsiPoint({required this.candleIndex, required this.value});

  final int candleIndex;
  final double value;

  @override
  bool operator ==(Object other) =>
      other is RsiPoint &&
      other.candleIndex == candleIndex &&
      other.value == value;

  @override
  int get hashCode => Object.hash(candleIndex, value);

  @override
  String toString() => 'RsiPoint($candleIndex, $value)';
}

/// Tính RSI chu kỳ [rsiPeriod] theo phương pháp làm mượt Wilder trên chuỗi
/// giá đóng cửa (FR-13).
///
/// Hàm thuần: cùng đầu vào cho cùng đầu ra, không đọc đồng hồ hệ thống,
/// không gọi mạng (AD-1). Kết quả không bao giờ được lưu xuống kho — luôn
/// tính lại từ chuỗi nến (AD-2).
///
/// Giá trị đầu tiên nằm tại chỉ số [rsiPeriod] của chuỗi gốc và dùng trung
/// bình cộng đơn giản của [rsiPeriod] mức tăng và mức giảm đầu tiên. Các giá
/// trị sau dùng công thức Wilder:
///
///     avg = (avg_trước × (rsiPeriod - 1) + giá_trị_hiện_tại) ÷ rsiPeriod
///
/// Chuỗi có ít hơn [minCandlesForRsi] phần tử thì trả về danh sách rỗng,
/// không ném lỗi.
List<RsiPoint> computeRsi(List<double> closes) {
  if (closes.length < minCandlesForRsi) return const [];

  // Trung bình khởi tạo: trung bình cộng đơn giản của rsiPeriod biến động đầu.
  var avgGain = 0.0;
  var avgLoss = 0.0;
  for (var i = 1; i <= rsiPeriod; i++) {
    final change = closes[i] - closes[i - 1];
    if (change > 0) {
      avgGain += change;
    } else {
      avgLoss += -change;
    }
  }
  avgGain /= rsiPeriod;
  avgLoss /= rsiPeriod;

  final points = <RsiPoint>[
    RsiPoint(candleIndex: rsiPeriod, value: _rsiFrom(avgGain, avgLoss)),
  ];

  for (var i = rsiPeriod + 1; i < closes.length; i++) {
    final change = closes[i] - closes[i - 1];
    final gain = change > 0 ? change : 0.0;
    final loss = change < 0 ? -change : 0.0;
    avgGain = (avgGain * (rsiPeriod - 1) + gain) / rsiPeriod;
    avgLoss = (avgLoss * (rsiPeriod - 1) + loss) / rsiPeriod;
    points.add(RsiPoint(candleIndex: i, value: _rsiFrom(avgGain, avgLoss)));
  }

  return points;
}

/// Trung bình mức giảm bằng 0 nghĩa là không có nến giảm nào trong cửa sổ —
/// RSI bằng 100. Trả thẳng 100 thay vì để phép chia sinh ra `Infinity`.
double _rsiFrom(double avgGain, double avgLoss) {
  if (avgLoss == 0) return 100;
  if (avgGain == 0) return 0;
  final rs = avgGain / avgLoss;
  return 100 - (100 / (1 + rs));
}
