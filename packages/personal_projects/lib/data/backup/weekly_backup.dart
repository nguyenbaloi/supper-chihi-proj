import 'dart:io';

import 'package:mini_app_core/mini_app_core.dart';

import '../db/database.dart';
import 'backup_service.dart';

/// Tên tệp sao lưu hằng tuần — cố định để lần sau ghi đè lần trước.
const kWeeklyBackupFileName = 'du-an-sao-luu-hang-tuan.json';

/// Bản sao lưu hằng tuần do super app gọi, cùng định dạng JSON với FR-31 để
/// nhập lại được bằng FR-32. Xem `BackupSource`.
///
/// Mở một kết nối riêng chứ không dùng container của mini app: lúc này mini
/// app có thể chưa từng mở.
Future<bool> writeWeeklyBackup(File target) async {
  // Chưa có tệp thì chưa có dữ liệu — mở AppDatabase lúc này sẽ tạo một cơ
  // sở dữ liệu rỗng và xuất ra một bản sao lưu rỗng đè lên bản cũ.
  if (!await (await miniAppDatabaseFile(kDatabaseName)).exists()) return false;

  final db = AppDatabase();
  try {
    await target.writeAsString(await BackupService(db).exportJson());
  } finally {
    await db.close();
  }
  return true;
}
