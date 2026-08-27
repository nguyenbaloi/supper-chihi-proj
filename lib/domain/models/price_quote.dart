import 'package:meta/meta.dart';

import '../../core/money/money.dart';
import 'enums.dart';

/// Giá một đơn vị tài sản, kèm nguồn và thời điểm.
///
/// Nguồn và thời điểm là phần bắt buộc của giá chứ không phải thông tin phụ:
/// không có trạng thái nào mà ứng dụng hiện số liệu tài chính mà không cho
/// biết nó tính từ giá lúc nào. Xem FR-13.
@immutable
class PriceQuote {
  final String symbol;

  /// Giá một đơn vị, theo đơn vị nhỏ nhất của [currency].
  final Money priceAmount;

  final Currency currency;
  final PriceSource source;
  final DateTime fetchedAt;

  const PriceQuote({
    required this.symbol,
    required this.priceAmount,
    required this.currency,
    required this.source,
    required this.fetchedAt,
  });

  bool get isManual => source == PriceSource.manual;

  @override
  bool operator ==(Object other) =>
      other is PriceQuote &&
      other.symbol == symbol &&
      other.priceAmount == priceAmount &&
      other.currency == currency &&
      other.source == source &&
      other.fetchedAt == fetchedAt;

  @override
  int get hashCode =>
      Object.hash(symbol, priceAmount, currency, source, fetchedAt);

  @override
  String toString() => 'PriceQuote($symbol, $priceAmount, $source)';
}
