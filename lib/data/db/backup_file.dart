import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

/// Sao lưu và khôi phục toàn bộ cơ sở dữ liệu dưới dạng một tệp `.sqlite`.
///
/// Đây là đường duy nhất mang dữ liệu sang máy mới **không mất mát**: tệp CSV
/// của `export_service.dart` là bản đọc cho người, không giữ được khoá, quan
/// hệ Bản chốt – Chi tiết bản chốt, giá lưu gần nhất hay tỷ giá. Xem FR-38.
///
/// Ba chỗ dễ hỏng lặng lẽ, cả ba đều được xử lý ở đây:
/// - không dồn WAL trước khi chép thì tệp sao ra thiếu các giao dịch mới nhất
/// - khôi phục mà để lại `-wal`/`-shm` cũ thì SQLite đọc lẫn hai bản
/// - khôi phục tệp của một bản ứng dụng mới hơn thì drift hạ cấp không nổi

/// Tên tệp cơ sở dữ liệu thật, khớp với [AppDatabase.open].
const kDatabaseFileName = '$kDatabaseName.sqlite';

/// Mười sáu byte mở đầu của mọi tệp SQLite 3.
final _sqliteMagic = Uint8List.fromList(
  'SQLite format 3'.codeUnits + [0],
);

/// Các bảng bắt buộc phải có mặt thì tệp mới là bản sao lưu của ứng dụng này.
///
/// Không liệt kê đủ mười một bảng: bản sao lưu từ một phiên bản cũ hơn có thể
/// chưa có bảng mới thêm, và migration sẽ tạo chúng khi mở.
const _requiredTables = {'settings', 'asset_classes', 'holdings', 'cash_flows'};

/// Lý do một tệp bị từ chối. Tầng hiển thị dịch sang chuỗi cho người đọc.
enum BackupRejection {
  /// Không đọc được tệp — không tồn tại, rỗng, hoặc hệ điều hành từ chối.
  unreadable,

  /// Đọc được nhưng không phải tệp SQLite.
  notSqlite,

  /// Là tệp SQLite nhưng không phải cơ sở dữ liệu của ứng dụng này.
  missingTables,

  /// Bản sao lưu của một phiên bản ứng dụng mới hơn — không hạ cấp được.
  futureSchema,
}

@immutable
sealed class BackupCheck {
  const BackupCheck();
}

/// Tệp dùng được. [schemaVersion] có thể nhỏ hơn phiên bản hiện tại — khi đó
/// migration của drift sẽ nâng cấp lúc mở.
@immutable
final class BackupAccepted extends BackupCheck {
  final int schemaVersion;
  const BackupAccepted(this.schemaVersion);
}

@immutable
final class BackupRejected extends BackupCheck {
  final BackupRejection reason;

  /// Ngoại lệ gốc nếu có, giữ lại để gỡ lỗi — không phải chuỗi hiển thị.
  final Object? cause;

  const BackupRejected(this.reason, {this.cause});
}

/// Tệp cơ sở dữ liệu đang được ứng dụng dùng.
Future<File> liveDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/$kDatabaseFileName');
}

/// Tên tệp sao lưu, mang ngày giờ để nhiều bản không đè lên nhau.
String backupFileName(DateTime now) {
  String two(int v) => v.toString().padLeft(2, '0');
  final stamp = '${now.year}-${two(now.month)}-${two(now.day)}'
      '-${two(now.hour)}${two(now.minute)}';
  return 'chichimonney-sao-luu-$stamp.sqlite';
}

/// Dồn WAL vào tệp chính rồi chép sang [target].
///
/// Phải gọi `wal_checkpoint(TRUNCATE)` trước khi chép: drift mở cơ sở dữ liệu
/// ở chế độ WAL, các giao dịch gần nhất còn nằm trong tệp `-wal` bên cạnh chứ
/// chưa vào tệp chính. Chép mà bỏ bước này thì bản sao lưu thiếu đúng phần dữ
/// liệu mới nhất — và thiếu im lặng, tệp vẫn mở được bình thường.
Future<File> writeBackupCopy({
  required AppDatabase db,
  required File source,
  required File target,
}) async {
  await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  return source.copy(target.path);
}

/// Kiểm tra một tệp trước khi cho phép khôi phục.
///
/// Mở ở chế độ chỉ đọc bằng SQLite thô, cố ý không dùng [AppDatabase]: mở tệp
/// chưa kiểm chứng bằng drift sẽ kích hoạt migration ngay lập tức, tức là ghi
/// vào tệp trước khi biết nó có phải bản sao lưu hợp lệ hay không.
Future<BackupCheck> inspectBackupFile(
  File file, {
  required int currentSchemaVersion,
}) async {
  Uint8List header;
  try {
    if (!await file.exists()) {
      return const BackupRejected(BackupRejection.unreadable);
    }
    final raw = await file.openRead(0, _sqliteMagic.length).toList();
    header = Uint8List.fromList(raw.expand((chunk) => chunk).toList());
  } on Object catch (e) {
    return BackupRejected(BackupRejection.unreadable, cause: e);
  }

  if (header.length < _sqliteMagic.length) {
    return const BackupRejected(BackupRejection.notSqlite);
  }
  for (var i = 0; i < _sqliteMagic.length; i++) {
    if (header[i] != _sqliteMagic[i]) {
      return const BackupRejected(BackupRejection.notSqlite);
    }
  }

  Database? raw;
  try {
    // `immutable=1` chứ không chỉ readOnly: tệp sao lưu được ghi ở chế độ WAL
    // nên SQLite muốn tạo tệp `-shm` bên cạnh trước khi đọc, và chỗ tệp nằm
    // (thư mục tạm của trình chọn tệp, thẻ nhớ, ổ chỉ đọc) thường không cho
    // ghi. Cờ này nói rằng tệp đứng yên, đọc thẳng không cần tệp phụ.
    final uri = '${Uri.file(file.path)}?immutable=1';
    raw = sqlite3.open(uri, uri: true, mode: OpenMode.readOnly);

    final tables = raw
        .select("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((row) => row['name'] as String)
        .toSet();
    if (!_requiredTables.every(tables.contains)) {
      return const BackupRejected(BackupRejection.missingTables);
    }

    final version = raw.select('PRAGMA user_version').first.columnAt(0) as int;
    if (version > currentSchemaVersion) {
      return const BackupRejected(BackupRejection.futureSchema);
    }
    return BackupAccepted(version);
  } on Object catch (e) {
    return BackupRejected(BackupRejection.unreadable, cause: e);
  } finally {
    raw?.dispose();
  }
}

/// Đưa [backup] vào chỗ của [target], thay thế cơ sở dữ liệu hiện tại.
///
/// Chỉ được gọi khi cơ sở dữ liệu đã đóng. Bản cũ được giữ lại cho tới khi
/// bản mới nằm đúng chỗ, và được trả về nếu bước đổi tên thất bại — mất tệp
/// giữa chừng là mất toàn bộ lịch sử, không có đường khôi phục.
Future<void> replaceDatabaseFile({
  required File backup,
  required File target,
}) async {
  final staged = File('${target.path}.dang-khoi-phuc');
  final previous = File('${target.path}.truoc-khi-khoi-phuc');

  if (await staged.exists()) await staged.delete();
  if (await previous.exists()) await previous.delete();
  await backup.copy(staged.path);

  final hadPrevious = await target.exists();
  if (hadPrevious) await target.rename(previous.path);
  try {
    await staged.rename(target.path);
  } on Object {
    if (hadPrevious) await previous.rename(target.path);
    rethrow;
  }

  // Chỉ xoá tệp phụ sau khi bản mới đã yên vị: chúng thuộc về cơ sở dữ liệu
  // cũ, để lại thì SQLite dựng lại trạng thái cũ đè lên bản vừa khôi phục.
  for (final suffix in const ['-wal', '-shm']) {
    final side = File('${target.path}$suffix');
    if (await side.exists()) await side.delete();
  }
  if (hadPrevious) await previous.delete();
}
