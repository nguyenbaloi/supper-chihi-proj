/// Quy tắc của Đợt đánh giá — FR-37, FR-39, FR-40, AD-15.
library;

import 'package:decimal/decimal.dart';

import '../models/enums.dart';
import '../models/review.dart';
import 'day.dart';

/// Kết quả đếm Mục của một Đợt đánh giá.
final class ReviewTally {
  const ReviewTally({required this.metCount, required this.total});

  final int metCount;
  final int total;

  /// `null` khi Đợt chưa có Mục nào — nơi gọi phải hiển thị `—`, tuyệt đối
  /// không hiển thị `0%` (FR-39).
  Decimal? get ratio => total == 0
      ? null
      : (Decimal.fromInt(metCount) / Decimal.fromInt(total))
          .toDecimal(scaleOnInfinitePrecision: 12);

  bool get isEmpty => total == 0;
}

/// `Một phần` vào mẫu số nhưng không vào tử số — FR-39.
ReviewTally tallyReview(Iterable<ReviewVerdict> verdicts) {
  var met = 0;
  var total = 0;
  for (final v in verdicts) {
    total++;
    if (v.countsAsMet) met++;
  }
  return ReviewTally(metCount: met, total: total);
}

/// Các Mục được đề nghị chép sang Đợt kế tiếp — FR-37.
///
/// `Đạt` không bao giờ được chép. Thứ tự tương đối giữ nguyên.
List<ReviewItem> carryForwardCandidates(Iterable<ReviewItem> previous) {
  final list = previous.where((i) => i.verdict.carriesForward).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return list;
}

/// Đợt gần nhất của một Dự án. `null` khi Dự án chưa có Đợt nào.
Review? latestReview(Iterable<Review> reviews) {
  Review? best;
  for (final r in reviews) {
    if (best == null || _isLater(r, best)) best = r;
  }
  return best;
}

bool _isLater(Review a, Review b) {
  final byDate = startOfDay(a.date).compareTo(startOfDay(b.date));
  if (byDate != 0) return byDate > 0;
  final byCreated = a.createdAt.compareTo(b.createdAt);
  if (byCreated != 0) return byCreated > 0;
  return a.id > b.id;
}

/// FR-40: chỉ Đợt **gần nhất** được xét, và Dự án đã đóng không bao giờ nhắc.
bool isReviewDue({
  required ProjectStatus status,
  required Iterable<Review> reviews,
  required DateTime now,
}) {
  if (status == ProjectStatus.done || status == ProjectStatus.dropped) {
    return false;
  }
  final latest = latestReview(reviews);
  final next = latest?.nextReviewDate;
  if (next == null) return false;
  return daysBetween(next, now) >= 0;
}
