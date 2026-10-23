/// Tỷ lệ hoàn thành của một Dự án — FR-12, AD-3.
///
/// **Luôn tính, không bao giờ lưu.** Không có cột `completionRatio` ở bất kỳ
/// bảng nào; đổi trạng thái một Hành động là con số này đổi theo ngay.
library;

import 'package:decimal/decimal.dart';

import '../models/enums.dart';

/// Kết quả đếm Hành động của một Dự án.
final class CompletionTally {
  const CompletionTally({required this.doneCount, required this.countedTotal});

  final int doneCount;

  /// Tổng số Hành động **không** ở trạng thái `Bỏ`.
  final int countedTotal;

  /// `null` khi Dự án chưa có Hành động nào được tính — nơi gọi phải hiển thị
  /// `—`, tuyệt đối không hiển thị `0%` (FR-12).
  Decimal? get ratio => countedTotal == 0
      ? null
      : (Decimal.fromInt(doneCount) / Decimal.fromInt(countedTotal))
          .toDecimal(scaleOnInfinitePrecision: 12);

  bool get isEmpty => countedTotal == 0;
}

CompletionTally tallyCompletion(Iterable<ActionStatus> statuses) {
  var done = 0;
  var counted = 0;
  for (final s in statuses) {
    if (!s.countsTowardCompletion) continue;
    counted++;
    if (s == ActionStatus.done) done++;
  }
  return CompletionTally(doneCount: done, countedTotal: counted);
}
