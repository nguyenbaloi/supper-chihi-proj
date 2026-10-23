/// Cắt một thời điểm về đầu ngày UTC.
///
/// Ngày của Bản chốt và Dòng vốn phải cắt về đầu ngày để so sánh không bị
/// lệch bởi giờ phút: một Dòng vốn ghi lúc 23 giờ và một mốc đọc lúc 8 giờ
/// sáng cùng ngày phải nằm cùng một ngày.
DateTime startOfDayUtc(DateTime value) {
  final utc = value.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}

String? trimToNull(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
