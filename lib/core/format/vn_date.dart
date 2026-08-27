/// Định dạng ngày kiểu Việt Nam: `27/08/2026`.
///
/// Cơ sở dữ liệu lưu UTC, màn hình hiện giờ địa phương — việc đổi múi giờ
/// diễn ra ở đây và chỉ ở đây.
class VnDate {
  const VnDate._();

  /// `27/08/2026`.
  static String full(DateTime value) {
    final local = value.toLocal();
    return '${_two(local.day)}/${_two(local.month)}/${local.year}';
  }

  /// `27/08` — dùng cho trục biểu đồ, nơi năm chỉ tổ chiếm chỗ.
  static String short(DateTime value) {
    final local = value.toLocal();
    return '${_two(local.day)}/${_two(local.month)}';
  }

  /// `27/08/2026 14:30`.
  static String withTime(DateTime value) {
    final local = value.toLocal();
    return '${full(value)} ${_two(local.hour)}:${_two(local.minute)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
