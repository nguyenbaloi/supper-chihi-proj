import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Kiểm tra tĩnh trên chính mã nguồn — NFR-3, FR-33, FR-34.
///
/// Hai quy tắc này không thể kiểm bằng test hành vi: một dòng `http` lọt vào
/// hay một chuỗi tiếng Việt viết thẳng trong widget đều chạy bình thường, chỉ
/// là sai nguyên tắc. Nên phải quét mã nguồn.
void main() {
  final libDir = Directory('lib');

  List<File> dartFilesUnder(String path) => Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .toList();

  group('FR-33, NFR-3 — không có mạng, điểm', () {
    test('không import thư viện mạng nào', () {
      const forbidden = [
        "package:http/",
        "package:dio/",
        "package:web_socket_channel/",
        "package:firebase_",
        "package:supabase",
      ];
      final offenders = <String>[];
      for (final file in dartFilesUnder(libDir.path)) {
        final src = file.readAsStringSync();
        for (final needle in forbidden) {
          if (src.contains(needle)) offenders.add('${file.path}: $needle');
        }
      }
      expect(offenders, isEmpty);
    });

    test('không dùng HttpClient, Socket hay WebSocket của dart:io', () {
      final offenders = <String>[];
      for (final file in dartFilesUnder(libDir.path)) {
        final src = _stripComments(file.readAsStringSync());
        for (final needle in ['HttpClient(', 'Socket.connect', 'WebSocket.connect']) {
          if (src.contains(needle)) offenders.add('${file.path}: $needle');
        }
      }
      expect(offenders, isEmpty);
    });

    test('pubspec không khai báo gói mạng', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final deps = pubspec.split('dev_dependencies:').first;
      expect(deps.contains('\n  http:'), isFalse);
      expect(deps.contains('\n  dio:'), isFalse);
    });

    test('không có tầng data/remote', () {
      expect(Directory('lib/data/remote').existsSync(), isFalse);
    });
  });

  group('AD-1 — hướng phụ thuộc một chiều', () {
    test('domain không import Flutter, drift, data hay presentation', () {
      final offenders = <String>[];
      for (final file in dartFilesUnder('lib/domain')) {
        // Bỏ chú thích: `project_action.dart` có nhắc `package:flutter` trong
        // phần giải thích vì sao lớp không đặt tên là `Action`.
        final src = _stripComments(file.readAsStringSync());
        for (final needle in [
          "package:flutter/",
          "package:drift/",
          "../../data/",
          "../../presentation/",
        ]) {
          if (src.contains(needle)) offenders.add('${file.path}: $needle');
        }
      }
      expect(offenders, isEmpty);
    });
  });

  group('AD-4 — không double trong tầng nghiệp vụ', () {
    test('domain không khai báo biến kiểu double', () {
      final offenders = <String>[];
      final pattern = RegExp(r'\bdouble\b');
      for (final file in dartFilesUnder('lib/domain')) {
        if (pattern.hasMatch(_stripComments(file.readAsStringSync()))) {
          offenders.add(file.path);
        }
      }
      expect(offenders, isEmpty);
    });
  });

  group('FR-34 — chuỗi hiển thị phải đi qua lớp l10n', () {
    /// Chỉ `core/l10n/strings.dart` và `data/seed/` được chứa tiếng Việt:
    /// một bên là lớp l10n, một bên là dữ liệu hạt giống thật.
    test('không chuỗi tiếng Việt nào viết thẳng trong widget', () {
      final diacritics = RegExp(
        r'''["'][^"'\n]*[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]''',
        caseSensitive: false,
      );
      final offenders = <String>[];
      for (final dir in ['lib/features', 'lib/presentation']) {
        for (final file in dartFilesUnder(dir)) {
          final src = _stripComments(file.readAsStringSync());
          for (final match in diacritics.allMatches(src)) {
            offenders.add('${file.path}: ${match.group(0)}');
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'Đưa các chuỗi này vào lib/core/l10n/strings.dart');
    });
  });
}

/// Bỏ chú thích để không nhầm chú thích tiếng Việt thành chuỗi hiển thị.
String _stripComments(String source) => source
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .split('\n')
    .map((line) {
      final idx = line.indexOf('//');
      if (idx < 0) return line;
      // Không cắt nếu `//` nằm trong một chuỗi (ví dụ https://).
      final before = line.substring(0, idx);
      final quotes = "'".allMatches(before).length + '"'.allMatches(before).length;
      return quotes.isEven ? before : line;
    })
    .join('\n');
