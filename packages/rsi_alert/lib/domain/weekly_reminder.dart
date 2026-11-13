/// Nhắc hằng tuần sau khi nến tuần đóng (FR-19, AD-14).
///
/// Là thông báo **cục bộ lặp lại**, hệ điều hành tự bắn — không chạy nền,
/// không backend. Hệ quả có chủ đích: nội dung không mang Vùng hay RSI, vì
/// lúc đặt lịch chưa ai biết nến tuần sau đóng ở đâu. Vùng chỉ được tính khi
/// người dùng mở app (AD-5 — không báo gì từ nến chưa đóng).
abstract class WeeklyReminder {
  /// Đặt (hoặc đặt lại) lịch nhắc. Gọi mỗi lần mở app là an toàn: cùng một
  /// id nên lịch cũ bị thay, không nhân bản. Không bao giờ ném.
  Future<void> ensureScheduled(ReminderText text);
}

/// Mọi chữ người dùng thấy của lời nhắc — do `ui/strings.dart` cấp (AD-10).
class ReminderText {
  const ReminderText({
    required this.title,
    required this.body,
    required this.channelName,
    required this.channelDescription,
  });

  final String title;
  final String body;

  /// Tên kênh hiện trong Cài đặt thông báo của Android.
  final String channelName;
  final String channelDescription;
}

/// Dùng trong test và khi chạy trên nền tảng không có thông báo.
class NoopWeeklyReminder implements WeeklyReminder {
  const NoopWeeklyReminder();

  @override
  Future<void> ensureScheduled(ReminderText text) async {}
}
