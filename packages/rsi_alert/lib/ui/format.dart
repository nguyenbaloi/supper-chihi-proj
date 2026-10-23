import 'package:intl/intl.dart';

import '../domain/market_symbol.dart';

/// Giờ Việt Nam. Toàn app lưu mốc bằng UTC (AD-3); chỉ chỗ hiển thị mới đổi.
const Duration vnOffset = Duration(hours: 7);

DateTime toVnTime(DateTime utc) => utc.toUtc().add(vnOffset);

final _dayMonth = DateFormat('dd/MM');
final _dayMonthYear = DateFormat('dd/MM/yyyy');
final _dateTime = DateFormat('HH:mm dd/MM/yyyy');

/// Khoảng ngày của một tuần giao dịch, ví dụ `25/08–31/08/2026`.
String formatWeekRange(DateTime weekOpenUtc) {
  final start = toVnTime(weekOpenUtc);
  final end = start.add(const Duration(days: 6));
  return '${_dayMonth.format(start)}–${_dayMonthYear.format(end)}';
}

String formatWeekShort(DateTime weekOpenUtc) =>
    _dayMonthYear.format(toVnTime(weekOpenUtc));

String formatTimestamp(DateTime utc) => _dateTime.format(toVnTime(utc));

String formatPrice(double value, MarketSymbol symbol) =>
    NumberFormat.decimalPatternDigits(
      locale: 'vi_VN',
      decimalDigits: symbol.priceDecimals,
    ).format(value);

String formatRsi(double value) => value.toStringAsFixed(1);
