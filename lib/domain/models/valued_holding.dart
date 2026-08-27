import 'package:meta/meta.dart';

import '../../core/money/money.dart';
import '../rules/holding_value.dart';
import 'holding.dart';
import 'price_quote.dart';

/// Một Khoản nắm giữ kèm Giá hiệu lực đang dùng và Giá trị quy đổi.
///
/// Ba mảnh này luôn đi cùng nhau ở tầng hiển thị: không có trạng thái nào mà
/// ứng dụng hiện một con số tiền mà không cho biết nó tính từ giá nào và lúc
/// nào. Xem FR-13.
@immutable
class ValuedHolding {
  final Holding holding;

  /// Giá hiệu lực do [EffectivePrice] quyết định, `null` nếu chưa có giá.
  final PriceQuote? effectivePrice;

  final HoldingValue value;

  const ValuedHolding({
    required this.holding,
    required this.effectivePrice,
    required this.value,
  });

  Money? get amountOrNull => value.amountOrNull;

  /// Khoản này đang chạy bằng Giá nhập tay — giao diện phải có dấu hiệu nhận
  /// biết. Xem FR-12.
  bool get usesManualPrice => effectivePrice?.isManual ?? false;

  @override
  String toString() => 'ValuedHolding(${holding.symbol}, $amountOrNull)';
}
