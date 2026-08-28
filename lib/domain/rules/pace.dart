/// Nhịp cần đi và dự báo về đích — FR-24.
///
/// Quy tắc cứng: **không có hạn chót thì tuyệt đối không tính nhịp và không
/// dự báo.** Suy đoán từ một con số không có mốc thời gian là bịa.
library;

import 'package:decimal/decimal.dart';

import '../../core/money/scaled_value.dart';
import '../models/goal.dart';
import 'day.dart';
import 'progress.dart';

enum PaceVerdict {
  /// Chưa đủ dữ liệu: không hạn chót, hoặc dưới hai Mốc.
  unknown,

  /// Nhịp thực tế đủ hoặc hơn mức cần để về đích đúng hạn.
  onTrack,

  /// Nhịp thực tế chậm hơn mức cần.
  behind,

  /// Giá trị đang đi lùi — nói thẳng, không hiện dự báo dương.
  goingBackwards,

  /// Đã đạt hoặc vượt đích.
  reached,

  /// Đã qua hạn chót mà chưa đạt đích.
  pastDue,
}

final class PaceReport {
  const PaceReport({
    required this.verdict,
    this.remaining,
    this.daysRemaining,
    this.requiredPerMonth,
    this.actualPerMonth,
    this.forecastMonthsDelta,
  });

  static const PaceReport unknown = PaceReport(verdict: PaceVerdict.unknown);

  final PaceVerdict verdict;

  /// Khoảng còn thiếu.
  final ScaledValue? remaining;

  /// Số ngày còn lại tới hạn chót.
  final int? daysRemaining;

  /// Mức cần thêm mỗi tháng để về đích đúng hạn.
  final ScaledValue? requiredPerMonth;

  /// Nhịp thực tế mỗi tháng, tính từ Mốc đầu tới Mốc mới nhất.
  final ScaledValue? actualPerMonth;

  /// Dương là **chậm** so với hạn, âm là **sớm**, đơn vị tháng.
  /// `null` khi không dự báo được — nhịp âm hoặc bằng 0.
  final int? forecastMonthsDelta;

  bool get hasForecast => forecastMonthsDelta != null;
}

const int _daysPerMonth = 30;

/// Tính nhịp. Trả [PaceReport.unknown] khi thiếu bất kỳ điều kiện nào —
/// không đoán, không suy diễn.
PaceReport computePace({
  required Goal goal,
  required List<GoalUpdate> updates,
  required DateTime now,
}) {
  if (!goal.isNumeric) return PaceReport.unknown;
  final target = goal.target;
  final dueDate = goal.dueDate;
  // FR-24: không hạn chót thì không có nhịp và không có dự báo.
  if (target == null || dueDate == null) return PaceReport.unknown;

  final visible = updates
      .where((u) => !startOfDay(u.date).isAfter(startOfDay(now)))
      .toList()
    ..sort((a, b) => startOfDay(a.date).compareTo(startOfDay(b.date)));
  if (visible.length < 2) return PaceReport.unknown;

  final last = latestUpdate(visible, now)!;
  final first = visible.first;
  final remaining = target - last.value;
  final daysRemaining = daysBetween(now, dueDate);

  if (!remaining.isNegative && remaining.isZero) {
    return PaceReport(
      verdict: PaceVerdict.reached,
      remaining: remaining,
      daysRemaining: daysRemaining,
    );
  }
  if (remaining.isNegative) {
    return PaceReport(
      verdict: PaceVerdict.reached,
      remaining: remaining,
      daysRemaining: daysRemaining,
    );
  }

  final elapsedDays = daysBetween(first.date, last.date);
  final gained = last.value.raw - first.value.raw;
  final actualPerDay = elapsedDays <= 0
      ? null
      : (Decimal.fromInt(gained) / Decimal.fromInt(elapsedDays))
          .toDecimal(scaleOnInfinitePrecision: 12);
  final actualPerMonth = actualPerDay == null
      ? null
      : ScaledValue(
          (actualPerDay * Decimal.fromInt(_daysPerMonth)).round().toBigInt().toInt(),
          goal.decimals,
        );

  if (daysRemaining <= 0) {
    return PaceReport(
      verdict: PaceVerdict.pastDue,
      remaining: remaining,
      daysRemaining: daysRemaining,
      actualPerMonth: actualPerMonth,
    );
  }

  final requiredPerDay =
      (Decimal.fromInt(remaining.raw) / Decimal.fromInt(daysRemaining))
          .toDecimal(scaleOnInfinitePrecision: 12);
  final requiredPerMonth = ScaledValue(
    (requiredPerDay * Decimal.fromInt(_daysPerMonth)).round().toBigInt().toInt(),
    goal.decimals,
  );

  // Nhịp âm hoặc đứng yên: nói thẳng, không dự báo dương.
  if (actualPerDay == null || actualPerDay <= Decimal.zero) {
    return PaceReport(
      verdict: actualPerDay != null && actualPerDay < Decimal.zero
          ? PaceVerdict.goingBackwards
          : PaceVerdict.behind,
      remaining: remaining,
      daysRemaining: daysRemaining,
      requiredPerMonth: requiredPerMonth,
      actualPerMonth: actualPerMonth,
    );
  }

  final projectedDays =
      (Decimal.fromInt(remaining.raw) / actualPerDay).toDecimal(scaleOnInfinitePrecision: 6);
  final deltaDays = projectedDays - Decimal.fromInt(daysRemaining);
  final monthsDelta =
      (deltaDays / Decimal.fromInt(_daysPerMonth)).toDecimal(scaleOnInfinitePrecision: 6).round().toBigInt().toInt();

  return PaceReport(
    verdict: actualPerDay >= requiredPerDay ? PaceVerdict.onTrack : PaceVerdict.behind,
    remaining: remaining,
    daysRemaining: daysRemaining,
    requiredPerMonth: requiredPerMonth,
    actualPerMonth: actualPerMonth,
    forecastMonthsDelta: monthsDelta,
  );
}
