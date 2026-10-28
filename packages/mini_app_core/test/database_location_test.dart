import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_app_core/mini_app_core.dart';

/// Chuyển tệp cơ sở dữ liệu ra khỏi Documents. Hỏng ở đây là mất dữ liệu
/// thật của bản cài cũ, và mất im lặng: ứng dụng mở ra một cơ sở dữ liệu rỗng.
void main() {
  late Directory tmp;
  late Directory documents;
  late Directory support;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('database_location_test');
    documents = Directory('${tmp.path}/Documents')..createSync();
    support = Directory('${tmp.path}/Library/Application Support');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  File at(Directory dir, String name) => File('${dir.path}/$name');

  test('chuyển tệp chính cùng -wal và -shm của bản cài cũ', () async {
    at(documents, 'a.sqlite').writeAsStringSync('chinh');
    at(documents, 'a.sqlite-wal').writeAsStringSync('wal');
    at(documents, 'a.sqlite-shm').writeAsStringSync('shm');

    await moveDatabaseFiles(from: documents, to: support, fileName: 'a.sqlite');

    expect(at(support, 'a.sqlite').readAsStringSync(), 'chinh');
    // Bỏ sót -wal là mất đúng những giao dịch mới nhất.
    expect(at(support, 'a.sqlite-wal').readAsStringSync(), 'wal');
    expect(at(support, 'a.sqlite-shm').readAsStringSync(), 'shm');
    expect(documents.listSync(), isEmpty);
  });

  test('không đè lên tệp đã có ở chỗ mới', () async {
    at(documents, 'b.sqlite').writeAsStringSync('cu');
    support.createSync(recursive: true);
    at(support, 'b.sqlite').writeAsStringSync('dang-dung');

    await moveDatabaseFiles(from: documents, to: support, fileName: 'b.sqlite');

    expect(at(support, 'b.sqlite').readAsStringSync(), 'dang-dung');
    expect(at(documents, 'b.sqlite').existsSync(), isTrue);
  });

  test('cài mới, không có gì để chuyển', () async {
    await moveDatabaseFiles(from: documents, to: support, fileName: 'c.sqlite');

    expect(at(support, 'c.sqlite').existsSync(), isFalse);
  });

  test('hai lần gọi đồng thời chỉ chuyển một lần', () async {
    at(documents, 'd.sqlite').writeAsStringSync('chinh');
    at(documents, 'd.sqlite-wal').writeAsStringSync('wal');

    await Future.wait([
      moveDatabaseFiles(from: documents, to: support, fileName: 'd.sqlite'),
      moveDatabaseFiles(from: documents, to: support, fileName: 'd.sqlite'),
    ]);

    expect(at(support, 'd.sqlite').readAsStringSync(), 'chinh');
    expect(at(support, 'd.sqlite-wal').readAsStringSync(), 'wal');
  });
}
