/// Một Nến tuần: bản ghi OHLCV ứng với một tuần giao dịch của một Mã.
///
/// [openTime] luôn là UTC và luôn giữ đúng mốc nguồn trả về — không làm tròn,
/// không đổi múi giờ khi lưu (AD-3). Chỉ tầng `ui/` mới đổi sang giờ Việt Nam
/// để hiển thị.
///
/// [isClosed] do adapter quyết định lúc dựng nến, dựa trên dữ liệu nguồn trả
/// về (AD-4). `domain/` chỉ đọc cờ này, không tự suy từ đồng hồ hệ thống —
/// nó không biết lịch giao dịch của từng thị trường.
class Candle {
  Candle({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.isClosed,
  }) : assert(openTime.isUtc, 'openTime phải là UTC — AD-3');

  final DateTime openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  /// `false` khi đây là Nến đang chạy — tuần chưa kết thúc, mọi giá trị còn đổi.
  final bool isClosed;

  bool get isUp => close >= open;

  Map<String, dynamic> toJson() => {
        't': openTime.millisecondsSinceEpoch,
        'o': open,
        'h': high,
        'l': low,
        'c': close,
        'v': volume,
        'closed': isClosed,
      };

  factory Candle.fromJson(Map<String, dynamic> json) => Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch(
          (json['t'] as num).toInt(),
          isUtc: true,
        ),
        open: (json['o'] as num).toDouble(),
        high: (json['h'] as num).toDouble(),
        low: (json['l'] as num).toDouble(),
        close: (json['c'] as num).toDouble(),
        volume: (json['v'] as num).toDouble(),
        isClosed: json['closed'] as bool,
      );

  @override
  bool operator ==(Object other) =>
      other is Candle &&
      other.openTime == openTime &&
      other.open == open &&
      other.high == high &&
      other.low == low &&
      other.close == close &&
      other.volume == volume &&
      other.isClosed == isClosed;

  @override
  int get hashCode =>
      Object.hash(openTime, open, high, low, close, volume, isClosed);

  @override
  String toString() =>
      'Candle(${openTime.toIso8601String()}, c=$close, closed=$isClosed)';
}
