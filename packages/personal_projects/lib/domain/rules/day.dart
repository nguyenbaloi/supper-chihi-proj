/// Quy tắc làm việc với **ngày** (không có giờ).
///
/// Hạn chót và ngày của Mốc tiến độ là ngày thuần. Lưu ở mốc 00:00 giờ địa
/// phương quy về UTC; mọi so sánh phải đi qua đây để không bị lệch múi giờ.
library;

/// Mốc 00:00 giờ địa phương của ngày chứa [value], trả về dạng UTC.
DateTime startOfDay(DateTime value) {
  final local = value.toLocal();
  return DateTime(local.year, local.month, local.day).toUtc();
}

/// Số ngày trọn vẹn từ [from] đến [to], tính theo ngày địa phương.
///
/// Cùng ngày trả 0. [to] sau [from] trả số dương.
int daysBetween(DateTime from, DateTime to) {
  final a = startOfDay(from);
  final b = startOfDay(to);
  return b.difference(a).inDays;
}

/// Số ngày trễ so với hạn. Chưa tới hạn hoặc đúng hạn trả 0.
int overdueDays({required DateTime dueDate, required DateTime now}) {
  final diff = daysBetween(dueDate, now);
  return diff > 0 ? diff : 0;
}

bool isOverdue({required DateTime dueDate, required DateTime now}) =>
    daysBetween(dueDate, now) > 0;

/// Đến hạn trong [withinDays] ngày tới, kể cả hôm nay — nhóm thứ ba của
/// màn hình Hôm nay (FR-29).
bool isDueSoon({
  required DateTime dueDate,
  required DateTime now,
  int withinDays = 7,
}) {
  final diff = daysBetween(now, dueDate);
  return diff >= 0 && diff <= withinDays;
}
