import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Tệp cơ sở dữ liệu `$name.sqlite` của một mini app.
///
/// Nằm trong Application Support chứ không phải Documents: super app bật
/// `UIFileSharingEnabled` để bản sao lưu hằng tuần hiện trong app Tệp, mà khi
/// đó **toàn bộ** Documents hiện ra. Để tệp đang chạy ở đó thì người dùng xoá
/// nhầm một cái là mất trắng dữ liệu.
///
/// Bản cài trước đây để tệp trong Documents — lần gọi đầu sẽ chuyển sang.
/// Phải gọi trước khi mở cơ sở dữ liệu.
Future<File> miniAppDatabaseFile(String name) async {
  final dir = await getApplicationSupportDirectory();
  await moveDatabaseFiles(
    from: await getApplicationDocumentsDirectory(),
    to: dir,
    fileName: '$name.sqlite',
  );
  return File('${dir.path}/$name.sqlite');
}

// Mini app và bản sao lưu hằng tuần có thể cùng mở một tệp gần như đồng thời;
// hai lần chuyển chồng lên nhau sẽ đổi tên một tệp đã đi mất.
final _moves = <String, Future<void>>{};

/// Chuyển tệp SQLite [fileName] từ [from] sang [to] nếu nó còn ở chỗ cũ.
///
/// Không làm gì khi chỗ mới đã có tệp: đó là bản đang dùng, chỗ cũ chỉ có thể
/// là rác cũ hơn. Chuyển `-wal` trước tệp chính — các giao dịch gần nhất còn
/// nằm trong đó, bỏ sót là mất im lặng. Tệp chính đi sau cùng, nên hỏng giữa
/// chừng thì lần mở sau vẫn thấy tệp ở chỗ cũ và chuyển tiếp.
Future<void> moveDatabaseFiles({
  required Directory from,
  required Directory to,
  required String fileName,
}) =>
    _moves.putIfAbsent('${to.path}/$fileName', () async {
      final source = File('${from.path}/$fileName');
      final target = File('${to.path}/$fileName');
      if (!await source.exists() || await target.exists()) return;

      await to.create(recursive: true);
      for (final suffix in const ['-wal', '-shm', '']) {
        final side = File('${source.path}$suffix');
        if (await side.exists()) await side.rename('${target.path}$suffix');
      }
    });
