import 'package:decimal/decimal.dart';

import '../../core/money/money.dart';
import '../models/enums.dart';
import '../models/holding.dart';
import '../models/price_quote.dart';

/// Vì sao một Khoản nắm giữ chưa tính được Giá trị quy đổi.
enum MissingValueReason {
  /// Chưa có Giá hiệu lực cho ký hiệu này.
  noPrice,

  /// Có giá tính bằng USD nhưng chưa có Tỷ giá để quy về VND.
  noFxRate,

  /// Khoản nhập theo giá trị nhưng chưa nhập số tiền.
  noAmount,
}

/// Giá trị quy đổi của một Khoản nắm giữ, hoặc lý do chưa tính được.
sealed class HoldingValue {
  const HoldingValue();

  /// Số tiền nếu tính được, `null` nếu chưa.
  Money? get amountOrNull =>
      this is HoldingValueKnown ? (this as HoldingValueKnown).amount : null;
}

final class HoldingValueKnown extends HoldingValue {
  final Money amount;
  const HoldingValueKnown(this.amount);
}

final class HoldingValueUnknown extends HoldingValue {
  final MissingValueReason reason;
  const HoldingValueUnknown(this.reason);
}

/// Quy đổi một Khoản nắm giữ ra VND.
///
/// Toàn bộ phép tính chạy ở độ chính xác đầy đủ của [Decimal] và **chỉ làm
/// tròn đúng một lần** ở bước cuối. Làm tròn ở từng bước trung gian rồi mới
/// nhân tiếp sẽ cho tổng lệch so với Excel gốc. Xem AD-3.
class HoldingValuation {
  const HoldingValuation._();

  /// [price] là Giá hiệu lực do [EffectivePrice] quyết định, [usdToVndRate]
  /// là số đồng cho một đô la.
  static HoldingValue of(
    Holding holding, {
    PriceQuote? price,
    Money? usdToVndRate,
  }) {
    final (Decimal raw, Currency currency) = switch (holding.inputMode) {
      InputMode.value => (
          holding.manualValueAmount?.asDecimal ?? Decimal.zero,
          holding.currency,
        ),
      InputMode.quantity => (
          (holding.quantity?.asDecimal ?? Decimal.zero) *
              (price?.priceAmount.asDecimal ?? Decimal.zero),
          price?.currency ?? holding.currency,
        ),
    };

    if (holding.inputMode == InputMode.value &&
        holding.manualValueAmount == null) {
      return const HoldingValueUnknown(MissingValueReason.noAmount);
    }
    if (holding.inputMode == InputMode.quantity && price == null) {
      return const HoldingValueUnknown(MissingValueReason.noPrice);
    }

    if (currency == Currency.vnd) {
      return HoldingValueKnown(Money.fromDecimal(raw));
    }

    if (usdToVndRate == null) {
      return const HoldingValueUnknown(MissingValueReason.noFxRate);
    }

    // USD lưu bằng xu, nên chia cho 100 trước khi nhân tỷ giá.
    final scale = Decimal.fromInt(10).pow(currency.decimals).toDecimal();
    final inVnd = (raw / scale).toDecimal(scaleOnInfinitePrecision: 10) *
        usdToVndRate.asDecimal;
    return HoldingValueKnown(Money.fromDecimal(inVnd));
  }
}
