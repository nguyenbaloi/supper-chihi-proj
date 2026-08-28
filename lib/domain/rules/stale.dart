/// Dự án nguội — FR-13.
///
/// Tính lúc dựng hình, so với thời điểm hiện tại. Không có tác vụ nền (AD-7).
library;

import '../models/enums.dart';
import 'day.dart';

/// Ngưỡng mặc định. Sửa được trong Cài đặt, chấp nhận 7..180.
const int defaultStaleDays = 21;
const int minStaleDays = 7;
const int maxStaleDays = 180;

bool isValidStaleDays(int value) => value >= minStaleDays && value <= maxStaleDays;

/// Chỉ Dự án `Đang làm` mới có thể nguội. `Tạm dừng`, `Xong`, `Bỏ`,
/// `Chưa bắt đầu` không bao giờ bị đánh dấu.
///
/// [lastActivityAt] là thời điểm gần nhất một Hành động của Dự án đổi trạng
/// thái. `null` nghĩa là chưa có hoạt động nào — khi đó lấy mốc tạo Dự án.
bool isProjectStale({
  required ProjectStatus status,
  required DateTime? lastActivityAt,
  required DateTime createdAt,
  required DateTime now,
  int staleDays = defaultStaleDays,
}) {
  if (!status.canGoStale) return false;
  final since = lastActivityAt ?? createdAt;
  return daysBetween(since, now) >= staleDays;
}

/// Số ngày kể từ hoạt động gần nhất — hiển thị trên dòng Dự án (FR-10).
int idleDays({
  required DateTime? lastActivityAt,
  required DateTime createdAt,
  required DateTime now,
}) =>
    daysBetween(lastActivityAt ?? createdAt, now);
