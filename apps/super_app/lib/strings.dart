/// Chuỗi hiển thị của lớp vỏ.
abstract final class S {
  static const appTitle = "Projs'Chi";
  static const openFailed = 'Không mở được ứng dụng';

  static const backupNow = 'Sao lưu vào app Tệp';
  static const backupDueTitle = 'Sao lưu hằng tuần';
  static String backupDueBody(Iterable<String> apps) =>
      'Xuất dữ liệu của ${apps.join(', ')} vào app Tệp › Trên iPhone › '
      '$appTitle? Bản sao lưu lần trước sẽ bị ghi đè.\n\n'
      'Khi cài lại ứng dụng, dùng chức năng khôi phục/nhập sao lưu trong Cài '
      'đặt của từng mục để lấy lại dữ liệu. Xoá ứng dụng là xoá luôn thư mục '
      'này — hãy chép bản sao lưu sang iCloud Drive nếu cần giữ lâu dài.';
  static const backupLater = 'Để sau';
  static const backupConfirm = 'Sao lưu';
  static const backupDone = "Đã sao lưu vào app Tệp › Trên iPhone › $appTitle";
  static const backupNothing = 'Chưa có dữ liệu nào để sao lưu';
  static String backupFailed(Iterable<String> apps) =>
      'Sao lưu lỗi: ${apps.join(', ')}. Sẽ hỏi lại ở lần mở sau.';
}
