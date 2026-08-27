import 'package:meta/meta.dart';

import '../../core/money/money.dart';
import 'enums.dart';

/// Tỷ giá USD sang VND, kèm nguồn và thời điểm.
@immutable
class FxRate {
  /// Số đồng cho một đô la.
  final Money rateAmount;

  final PriceSource source;
  final DateTime? fetchedAt;

  /// Đây có phải giá trị dự phòng dựng sẵn không.
  ///
  /// Khi đúng, giao diện phải ghi rõ — người dùng cần biết con số quy đổi
  /// đang dựa trên một tỷ giá phỏng đoán. Xem FR-11.
  final bool isFallback;

  const FxRate({
    required this.rateAmount,
    required this.source,
    this.fetchedAt,
    this.isFallback = false,
  });

  @override
  bool operator ==(Object other) =>
      other is FxRate &&
      other.rateAmount == rateAmount &&
      other.source == source &&
      other.fetchedAt == fetchedAt &&
      other.isFallback == isFallback;

  @override
  int get hashCode => Object.hash(rateAmount, source, fetchedAt, isFallback);

  @override
  String toString() => 'FxRate($rateAmount, $source)';
}
