import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup_source.dart';

/// Một ứng dụng con chạy được cả độc lập lẫn bên trong super app.
///
/// Hai đường chạy dùng chung đúng một mã khởi tạo: `main()` độc lập của mini
/// app cũng gọi [createContainer] rồi [buildApp], nên thứ được test khi chạy
/// riêng chính là thứ chạy trong super app.
abstract interface class MiniApp {
  /// Định danh ổn định, dùng làm khoá ghi nhớ — không đổi sau khi phát hành.
  String get id;

  String get title;

  IconData get icon;

  Color get color;

  /// Khởi tạo bất đồng bộ (mở kho dữ liệu, nạp locale) và trả về container
  /// Riverpod **riêng** của mini app — không có container cha. Mini app không
  /// bao giờ nhìn thấy provider của mini app khác.
  Future<ProviderContainer> createContainer();

  /// Chính `MaterialApp` của mini app, không sửa đổi gì.
  Widget buildApp();

  /// Các tệp super app xuất ra mỗi tuần. Rỗng khi mini app không có dữ liệu
  /// nào đáng giữ — ví dụ chỉ là bộ đệm tải lại được từ mạng.
  List<BackupSource> get backupSources;
}
