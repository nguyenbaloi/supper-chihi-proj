import 'package:meta/meta.dart';

import 'enums.dart';

/// Một lần nhìn lại Dự án tại một mốc thời gian — FR-35.
///
/// **Không có** trường `metCount` hay `metRatio`. Tỷ lệ đạt luôn tính từ danh
/// sách [ReviewItem] (AD-3).
@immutable
final class Review {
  const Review({
    required this.id,
    required this.projectId,
    required this.date,
    required this.title,
    required this.summaryMarkdown,
    required this.createdAt,
    this.nextReviewDate,
  });

  final int id;
  final int projectId;

  /// Ngày đánh giá, do người dùng chọn.
  final DateTime date;

  /// Để trống thì hiển thị bằng ngày đánh giá — FR-35.
  final String title;

  final String summaryMarkdown;

  /// "Mốc time" của chu kỳ. Nguồn duy nhất của nhắc nhở ở FR-40.
  final DateTime? nextReviewDate;

  final DateTime createdAt;

  Review copyWith({
    DateTime? date,
    String? title,
    String? summaryMarkdown,
    DateTime? nextReviewDate,
    bool clearNextReviewDate = false,
  }) =>
      Review(
        id: id,
        projectId: projectId,
        date: date ?? this.date,
        title: title ?? this.title,
        summaryMarkdown: summaryMarkdown ?? this.summaryMarkdown,
        nextReviewDate:
            clearNextReviewDate ? null : (nextReviewDate ?? this.nextReviewDate),
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) => other is Review && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Một dòng trong Đợt đánh giá — FR-36.
@immutable
final class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.reviewId,
    required this.label,
    required this.verdict,
    required this.note,
    required this.sortOrder,
    this.sourceActionId,
  });

  final int id;
  final int reviewId;

  /// Bản chụp văn bản tại thời điểm đánh giá — AD-15.
  final String label;

  final ReviewVerdict verdict;
  final String note;
  final int sortOrder;

  /// Chỉ để mở nhanh Hành động liên quan; không tham gia phép tính nào.
  final int? sourceActionId;

  ReviewItem copyWith({
    String? label,
    ReviewVerdict? verdict,
    String? note,
    int? sortOrder,
  }) =>
      ReviewItem(
        id: id,
        reviewId: reviewId,
        label: label ?? this.label,
        verdict: verdict ?? this.verdict,
        note: note ?? this.note,
        sortOrder: sortOrder ?? this.sortOrder,
        sourceActionId: sourceActionId,
      );

  @override
  bool operator ==(Object other) => other is ReviewItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
