import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/data/db/database.dart';

/// Canh gác hai ràng buộc kiến trúc mà trình phân tích tĩnh không bắt được.
///
/// Cả hai đều hỏng theo kiểu **không báo lỗi**: một `double` lọt vào phép tính
/// tiền chỉ hiện ra sau vài tháng cộng dồn, dưới dạng con số tổng lệch vài
/// đồng so với Excel. Một lời `import` sai hướng chỉ hiện ra khi ai đó muốn
/// viết test cho công thức tài chính và phát hiện phải dựng cả Flutter lên.
///
/// Xem AD-3 và mục Hướng phụ thuộc một chiều.
void main() {
  group('AD-3 — cấm số thực dấu phẩy động', () {
    test('không tệp nào trong lib/domain dùng double', () {
      final hits = _findDouble(_dartFilesIn('lib/domain'));

      expect(
        hits,
        isEmpty,
        reason: 'domain là nơi đặt mọi công thức tài chính, tiền phải là int '
            'đơn vị đồng và phép nhân chia phải chạy qua Decimal:\n'
            '${hits.join('\n')}',
      );
    });

    test('không tệp nào định nghĩa bảng drift dùng double', () {
      // Bỏ qua tệp `.g.dart`: đó là mã do drift sinh ra, kiểm chứng nó thuộc
      // về bài test đọc thẳng kiểu cột trong SQLite ở dưới.
      final files = _dartFilesIn('lib/data/db')
          .where((f) => !f.path.endsWith('.g.dart'));
      final hits = [
        ..._findDouble(files),
        ..._findPattern(files, RegExp(r'\bRealColumn\b'), 'RealColumn'),
      ];

      expect(
        hits,
        isEmpty,
        reason: 'một cột kiểu số thực là đường duy nhất để sai số lọt xuống '
            'ổ đĩa, nơi không còn sửa lại được:\n${hits.join('\n')}',
      );
    });

    test('không cột nào trong cơ sở dữ liệu thật có kiểu REAL', () async {
      // Kiểm tra ở mức SQLite chứ không chỉ ở mã nguồn: đây là con số cuối
      // cùng, sau khi drift đã sinh mã và tạo bảng.
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.select(db.assetClassesTable).get();

      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      expect(tables, isNotEmpty, reason: 'không đọc được bảng nào để kiểm tra');

      final offenders = <String>[];
      for (final table in tables) {
        final tableName = table.data['name'] as String;
        final columns = await db
            .customSelect("SELECT name, type FROM pragma_table_info(?)",
                variables: [Variable.withString(tableName)])
            .get();
        for (final column in columns) {
          final type = (column.data['type'] as String).toUpperCase();
          if (type.contains('REAL') ||
              type.contains('FLOA') ||
              type.contains('DOUB')) {
            offenders.add('$tableName.${column.data['name']} khai báo $type');
          }
        }
      }

      expect(offenders, isEmpty, reason: offenders.join('\n'));

      // Khẳng định ngược lại, để bài test không thể xanh một cách rỗng: nếu
      // việc đọc kiểu cột hỏng thì hai dòng này đổ trước.
      expect(
        await _columnType(db, 'settings', 'initial_contribution_amount'),
        'INTEGER',
      );
      expect(await _columnType(db, 'holdings', 'quantity_raw'), 'INTEGER');
    });
  });

  group('AD-8 — mạng chỉ được dùng để hỏi giá', () {
    test('mọi lời gọi mạng nằm trong đúng thư mục lib/data/remote', () {
      // Ràng buộc này giữ điều quan trọng nhất của sản phẩm: không có
      // backend, không tài khoản, không đồng bộ. Một lời gọi mạng lọt ra
      // ngoài thư mục đó là chỗ số liệu tài chính có thể rời khỏi máy mà
      // không ai để ý.
      // Cấm theo gói mạng, không cấm cả `dart:io`: thư viện đó vừa mở được
      // kết nối mạng vừa ghi được tệp, mà ghi tệp xuất dữ liệu ra máy người
      // dùng là việc hợp lệ. Phần mạng của `dart:io` bị chặn riêng ở dưới
      // bằng tên lớp.
      const networkPackages = [
        'package:http/',
        'package:dio/',
        'package:web_socket_channel/',
        'package:googleapis',
        'package:firebase',
        'package:grpc/',
      ];

      /// Các lớp mở kết nối mạng của `dart:io`.
      const networkTypes = [
        'HttpClient',
        'RawSocket',
        'ServerSocket',
        'WebSocket',
        'Socket.connect',
      ];

      final hits = <String>[];
      for (final file in _dartFilesIn('lib')) {
        final path = _relative(file);
        if (path.startsWith('lib/data/remote/')) continue;

        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trimLeft();
          if (line.startsWith('import ') || line.startsWith('export ')) {
            for (final package in networkPackages) {
              if (lines[i].contains(package)) {
                hits.add('$path:${i + 1} → $package');
              }
            }
          }
          for (final type in networkTypes) {
            if (lines[i].contains(type)) {
              hits.add('$path:${i + 1} → $type');
            }
          }
        }
      }

      expect(
        hits,
        isEmpty,
        reason: 'chuyển lời gọi mạng vào lib/data/remote/ rồi cho tầng trên '
            'dùng qua hợp đồng trừu tượng:\n${hits.join('\n')}',
      );
    });

    test('thư mục data/remote thực sự tồn tại và có hợp đồng nguồn giá', () {
      // Nếu ai đó xoá thư mục thì bài test trên xanh một cách rỗng.
      final files = _dartFilesIn('lib/data/remote').map(_relative);
      expect(files, contains('lib/data/remote/remote_price_source.dart'));
    });
  });

  group('AD-7 — không có tác vụ nền', () {
    test('không mã nguồn nào đăng ký tác vụ chạy nền', () {
      // Bản chốt sinh ra khi người dùng mở ứng dụng, không phải do hệ điều
      // hành đánh thức. Một tác vụ nền là thứ chạy mà người dùng không biết,
      // tiêu pin và có thể ghi dữ liệu sai lúc. Xem AD-7 và FR-28.
      const forbidden = [
        'workmanager',
        'background_fetch',
        'android_alarm_manager',
        'flutter_background',
        'BGTaskScheduler',
        'WorkManager',
      ];

      final hits = <String>[];
      for (final file in _dartFilesIn('lib')) {
        final content = file.readAsStringSync();
        for (final token in forbidden) {
          if (content.contains(token)) {
            hits.add('${_relative(file)} → \$token');
          }
        }
      }

      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test('pubspec không khai báo gói chạy nền nào', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final package in const [
        'workmanager',
        'background_fetch',
        'android_alarm_manager_plus',
        'flutter_background_service',
      ]) {
        expect(
          pubspec,
          isNot(contains(package)),
          reason: 'pubspec khai báo \$package',
        );
      }
    });

    test('cấu hình hai nền tảng không đăng ký tác vụ nền', () {
      // Kiểm tra cả tệp cấu hình gốc, không chỉ mã Dart — đăng ký tác vụ nền
      // thường nằm ở manifest và Info.plist chứ không ở Dart.
      const platformFiles = [
        'android/app/src/main/AndroidManifest.xml',
        'ios/Runner/Info.plist',
      ];
      const markers = [
        'BGTaskSchedulerPermittedIdentifiers',
        'UIBackgroundModes',
        'android.permission.RECEIVE_BOOT_COMPLETED',
        'WorkManagerInitializer',
      ];

      for (final path in platformFiles) {
        final file = File(path);
        if (!file.existsSync()) continue;
        final content = file.readAsStringSync();
        for (final marker in markers) {
          expect(
            content,
            isNot(contains(marker)),
            reason: '\$path khai báo \$marker',
          );
        }
      }
    });
  });

  group('Hướng phụ thuộc một chiều — presentation → domain ← data', () {
    test('lib/domain không import flutter, drift, http, data hay presentation',
        () {
      const forbidden = <String, String>{
        r"package:flutter/": 'package:flutter',
        r"package:flutter_riverpod/": 'package:flutter_riverpod',
        r"package:drift": 'package:drift',
        r"package:http/": 'package:http',
        r"package:personal_finance/data/": 'data/',
        r"package:personal_finance/presentation/": 'presentation/',
        r"'../../data/": 'data/',
        r"'../../presentation/": 'presentation/',
        r"'../data/": 'data/',
        r"'../presentation/": 'presentation/',
      };

      final hits = <String>[];
      for (final file in _dartFilesIn('lib/domain')) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (!line.trimLeft().startsWith('import ') &&
              !line.trimLeft().startsWith('export ')) {
            continue;
          }
          for (final entry in forbidden.entries) {
            if (line.contains(entry.key)) {
              hits.add('${_relative(file)}:${i + 1} → ${entry.value}');
            }
          }
        }
      }

      expect(
        hits,
        isEmpty,
        reason: 'domain phải test được mà không cần dựng Flutter hay cơ sở dữ '
            'liệu — đó là điều kiện để kiểm chứng công thức tài chính:\n'
            '${hits.join('\n')}',
      );
    });
  });
}

Future<String?> _columnType(
  AppDatabase db,
  String table,
  String column,
) async {
  final rows = await db
      .customSelect(
        'SELECT type FROM pragma_table_info(?) WHERE name = ?',
        variables: [
          Variable.withString(table),
          Variable.withString(column),
        ],
      )
      .get();
  return rows.isEmpty ? null : (rows.single.data['type'] as String).toUpperCase();
}

List<File> _dartFilesIn(String relativePath) {
  final dir = Directory(relativePath);
  expect(dir.existsSync(), isTrue, reason: 'không tìm thấy thư mục $relativePath');
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

List<String> _findDouble(Iterable<File> files) =>
    _findPattern(files, RegExp(r'\bdouble\b'), 'double');

/// Tìm [pattern] trong mã thật, bỏ qua chú thích và chuỗi ký tự.
///
/// Bỏ qua chú thích có chủ đích: một dòng chú thích giải thích *vì sao* cấm
/// `double` không phải là vi phạm, và cấm luôn cả nó thì không ai viết được
/// lời giải thích nữa.
List<String> _findPattern(Iterable<File> files, RegExp pattern, String label) {
  final hits = <String>[];
  for (final file in files) {
    final lines = _stripCommentsAndStrings(file.readAsStringSync()).split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (pattern.hasMatch(lines[i])) {
        hits.add('${_relative(file)}:${i + 1} → $label');
      }
    }
  }
  return hits;
}

/// Thay chú thích và chuỗi ký tự bằng khoảng trắng, **giữ nguyên số dòng** để
/// thông báo lỗi chỉ đúng chỗ.
String _stripCommentsAndStrings(String source) {
  String blank(Match m) => m[0]!.replaceAll(RegExp(r'[^\n]'), ' ');

  var s = source.replaceAllMapped(RegExp(r'/\*.*?\*/', dotAll: true), blank);
  s = s.replaceAllMapped(RegExp(r'//[^\n]*'), blank);
  s = s.replaceAllMapped(RegExp(r"r?'''.*?'''", dotAll: true), blank);
  s = s.replaceAllMapped(RegExp(r'r?""".*?"""', dotAll: true), blank);
  s = s.replaceAllMapped(RegExp(r"r?'(?:\\.|[^'\\\n])*'"), blank);
  s = s.replaceAllMapped(RegExp(r'r?"(?:\\.|[^"\\\n])*"'), blank);
  return s;
}

String _relative(File file) =>
    file.path.replaceFirst('${Directory.current.path}/', '');
