import 'package:meta/meta.dart';

import 'enums.dart';

/// Một lần nhìn lại một Dự án **hoặc** một Lĩnh vực tại một mốc thời gian —
/// FR-35, FR-49.
///
/// **Không có** trường `metCount` hay `metRatio`. Tỷ lệ đạt luôn tính từ danh
/// sách [ReviewItem] (AD-3).
@immutable
final class Review {
  const Review({
    required this.id,
    this.projectId,
    this.areaId,
    required this.date,
    required this.title,
    required this.summaryMarkdown,
    required this.createdAt,
    this.nextReviewDate,
  });

  final int id;

  /// AD-19: **đúng một** trong [projectId] và [areaId] khác `null`. Không bao
  /// giờ cả hai, không bao giờ cả hai cùng `null`.
  final int? projectId;

  /// Nhìn lại cả một mảng đời sống thay vì một Dự án — FR-49.
  final int? areaId;

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
        areaId: areaId,
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
