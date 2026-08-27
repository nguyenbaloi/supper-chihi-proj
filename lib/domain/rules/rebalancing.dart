import 'package:decimal/decimal.dart';

import '../../core/money/money.dart';

/// Khoảng lệch của một Lớp tài sản hoặc một Nhóm mục tiêu so với mục tiêu.
class TargetDrift {
  /// Tên hiển thị: tên Lớp tài sản, hoặc tên Nhóm mục tiêu.
  final String label;

  final Money currentValue;

  /// Tỷ trọng thực tế, `null` khi Tổng tài sản bằng 0.
  final Decimal? actualWeight;

  /// Tỷ trọng mục tiêu, đơn vị phần vạn.
  final int targetWeightBp;

  final Money totalAssets;

  const TargetDrift({
    required this.label,
    required this.currentValue,
    required this.actualWeight,
    required this.targetWeightBp,
    required this.totalAssets,
  });

  Decimal get targetWeight =>
      (Decimal.fromInt(targetWeightBp) / Decimal.fromInt(10000))
          .toDecimal(scaleOnInfinitePrecision: 10);

  /// Hiệu tỷ trọng: dương là đang thừa, âm là đang thiếu.
  Decimal? get weightDrift =>
      actualWeight == null ? null : actualWeight! - targetWeight;

  /// Khoảng lệch quy ra tiền = hiệu tỷ trọng × Tổng tài sản. Xem FR-20.
  Money? get amountDrift {
    final drift = weightDrift;
    if (drift == null) return null;
    return Money.fromDecimal(drift * totalAssets.asDecimal);
  }

  bool get isOver => (weightDrift?.sign ?? 0) > 0;
  bool get isUnder => (weightDrift?.sign ?? 0) < 0;

  /// Lệch quá ngưỡng cảnh báo chưa. Xem FR-21.
  bool exceedsThreshold(int thresholdBp) {
    final drift = weightDrift;
    if (drift == null) return false;
    final driftBp = (drift * Decimal.fromInt(10000)).round().toBigInt().abs();
    return driftBp > BigInt.from(thresholdBp);
  }

  @override
  String toString() => 'TargetDrift($label, $amountDrift)';
}

/// Công thức tái cân bằng.
class Rebalancing {
  const Rebalancing._();

  /// Tổng các Tỷ trọng mục tiêu, đơn vị phần vạn.
  ///
  /// Khác 10000 thì ứng dụng cảnh báo nhưng **vẫn cho lưu** — người dùng có
  /// thể đang đặt mục tiêu dở dang. Xem FR-19.
  static int totalTargetBp(Iterable<int> targetWeightsBp) =>
      targetWeightsBp.fold(0, (sum, bp) => sum + bp);

  static bool isBalanced(Iterable<int> targetWeightsBp) =>
      totalTargetBp(targetWeightsBp) == 10000;
}
