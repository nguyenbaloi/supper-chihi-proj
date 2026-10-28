import 'dart:io';

import 'package:mini_app_core/mini_app_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kết quả xuất của một tệp.
enum BackupOutcome {
  written,

  /// Mini app chưa có dữ liệu — bản cũ, nếu có, được giữ nguyên.
  empty,

  /// Xuất lỗi — bản cũ, nếu có, được giữ nguyên.
  failed,
}

/// Lịch và thao tác của bản sao lưu hằng tuần.
///
/// Tệp được ghi vào thư mục Documents của ứng dụng, trên iOS chính là thư mục
/// "Projs'Chi" trong app Tệp (Info.plist bật `UIFileSharingEnabled`). Tên tệp
/// cố định nên lần sau ghi đè lần trước.
class WeeklyBackup {
  WeeklyBackup(this._prefs, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  static const interval = Duration(days: 7);

  /// Người dùng chọn "Để sau" thì một ngày sau mới hỏi lại.
  static const snoozeFor = Duration(days: 1);

  static const _lastKey = 'weeklyBackup.lastAt';
  static const _snoozeKey = 'weeklyBackup.snoozedUntil';

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  DateTime? get lastBackupAt => _read(_lastKey);

  bool get isDue {
    final now = _now();
    final snoozedUntil = _read(_snoozeKey);
    if (snoozedUntil != null && now.isBefore(snoozedUntil)) return false;
    final last = lastBackupAt;
    return last == null || now.difference(last) >= interval;
  }

  Future<void> snooze() => _write(_snoozeKey, _now().add(snoozeFor));

  /// Xuất mọi [sources] vào [dir], đè lên bản của lần trước.
  ///
  /// Chỉ ghi nhận đã sao lưu khi không tệp nào lỗi — lỗi một tệp thì lần mở
  /// sau sẽ hỏi lại, thay vì im lặng chờ thêm một tuần.
  Future<Map<BackupSource, BackupOutcome>> run(
    Directory dir,
    Iterable<BackupSource> sources,
  ) async {
    await dir.create(recursive: true);
    final outcomes = {
      for (final source in sources) source: await _export(dir, source),
    };
    if (!outcomes.containsValue(BackupOutcome.failed)) {
      await _write(_lastKey, _now());
      await _prefs.remove(_snoozeKey);
    }
    return outcomes;
  }

  // Ghi ra tệp tạm rồi mới đổi tên đè lên bản cũ: xuất hỏng giữa chừng thì
  // bản tuần trước vẫn còn nguyên. Tên tệp tạm bắt đầu bằng dấu chấm để app
  // Tệp không hiện nó.
  static Future<BackupOutcome> _export(Directory dir, BackupSource source) async {
    final target = File('${dir.path}/${source.fileName}');
    final temp = File('${dir.path}/.${source.fileName}.tam');
    try {
      if (await temp.exists()) await temp.delete();
      if (!await source.write(temp)) return BackupOutcome.empty;
      await temp.rename(target.path);
      return BackupOutcome.written;
    } on Object {
      return BackupOutcome.failed;
    } finally {
      try {
        if (await temp.exists()) await temp.delete();
      } on Object {
        // Tệp tạm sót lại sẽ bị xoá ở lần xuất sau.
      }
    }
  }

  DateTime? _read(String key) {
    final millis = _prefs.getInt(key);
    return millis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  Future<void> _write(String key, DateTime value) =>
      _prefs.setInt(key, value.toUtc().millisecondsSinceEpoch);
}
