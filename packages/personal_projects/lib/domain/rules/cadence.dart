/// Nhịp xem lại của Lĩnh vực — FR-48, AD-3.
///
/// **Luôn tính, không bao giờ lưu.** Không có cột `nextReviewDate` hay
/// `isDueForReview` trên bảng `areas`: xoá Đợt đánh giá gần nhất là ngày đến
/// hạn phải tự lùi về theo Đợt trước đó, ngay lập tức.
///
/// Nguyên tắc quan trọng nhất ở đây là **không đặt nhịp thì không nhắc gì
/// cả**. Cùng một nguyên tắc với "Mục tiêu không có hạn thì tuyệt đối không
/// hiện nhịp và dự báo": ứng dụng không được tự bịa ra một kỳ vọng mà người
/// dùng chưa từng đặt.
library;

import 'day.dart';

/// Ngày phải nhìn lại Lĩnh vực này lần tới.
///
/// `null` khi [cadenceDays] là `null` — người dùng chưa đặt nhịp, và đó là
/// một lựa chọn hợp lệ chứ không phải dữ liệu thiếu.
///
/// [lastReviewDate] là ngày của Đợt đánh giá **mới nhất** thuộc Lĩnh vực.
/// Chưa có Đợt nào thì đếm từ [areaCreatedAt].
DateTime? nextAreaReviewDate({
  required int? cadenceDays,
  required DateTime? lastReviewDate,
  required DateTime areaCreatedAt,
}) {
  if (cadenceDays == null || cadenceDays <= 0) return null;
  final from = startOfDay(lastReviewDate ?? areaCreatedAt);
  return from.add(Duration(days: cadenceDays));
}

/// Đã tới lúc nhìn lại chưa.
///
/// Đến hạn **đúng hôm nay** tính là đến hạn — cùng quy ước với `dueDate` của
/// Hành động, nơi "đến hạn hôm nay" chưa phải quá hạn nhưng đã phải hiện ra.
bool isAreaReviewDue({
  required int? cadenceDays,
  required DateTime? lastReviewDate,
  required DateTime areaCreatedAt,
  required DateTime now,
}) {
  final next = nextAreaReviewDate(
    cadenceDays: cadenceDays,
    lastReviewDate: lastReviewDate,
    areaCreatedAt: areaCreatedAt,
  );
  if (next == null) return false;
  return daysBetween(next, now) >= 0;
}

/// Số ngày còn lại tới hạn xem lại; âm nghĩa là đã trễ bấy nhiêu ngày.
///
/// `null` khi không đặt nhịp.
int? daysUntilAreaReview({
  required int? cadenceDays,
  required DateTime? lastReviewDate,
  required DateTime areaCreatedAt,
  required DateTime now,
}) {
  final next = nextAreaReviewDate(
    cadenceDays: cadenceDays,
    lastReviewDate: lastReviewDate,
    areaCreatedAt: areaCreatedAt,
  );
  if (next == null) return null;
  return daysBetween(now, next);
}

/// Nhịp gợi ý sẵn trong giao diện. Người dùng nhập số khác được — FR-48.
const List<int> suggestedCadenceDays = [7, 30, 90];

/// Chặn giá trị vô nghĩa trước khi ghi xuống cơ sở dữ liệu.
bool isValidCadenceDays(int value) => value >= 1 && value <= 365;
