import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/data/backup/backup_codec.dart';
import 'package:personal_projects/data/backup/backup_service.dart';
import 'package:personal_projects/data/db/database.dart';
import 'package:personal_projects/data/repositories/drift_content_repositories.dart';
import 'package:personal_projects/data/seed/seeder.dart';

/// Chu trình chuyển máy đi qua **file thật trên đĩa**, không phải chuỗi trong
/// bộ nhớ — FR-31, FR-32.
///
/// Đây là chỗ dễ hỏng âm thầm nhất: nội dung có dấu tiếng Việt, tên người, và
/// cả emoji trong tên lĩnh vực. Ghi sai mã hoá thì file vẫn tạo ra được, vẫn nhập
/// lại được, chỉ là chữ biến thành ký tự rác.
void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('backup_test'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  Future<AppDatabase> freshDb() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  // FR-50: một Ghi chú đã rời Dự án và chuyển sang Lĩnh vực phải sống sót qua
  // file. Định dạng v3 không có chỗ ghi `areaId`, nên nếu quên tăng
  // `backupFormatVersion` ở Story 8.4 thì chỗ gắn biến mất — mất im lặng, đúng
  // kiểu hỏng mà FR-50 sinh ra để chặn.
  test('Tư liệu gắn vào Lĩnh vực và Tư liệu ở kho chung đi qua file nguyên vẹn',
      () async {
    final oldPhone = await freshDb();
    DateTime clock() => DateTime.utc(2026, 9, 3);
    await Seeder(oldPhone, clock: clock).applyProjectSeed();

    final notes = DriftNoteRepository(oldPhone, clock: clock);
    final links = DriftLinkRepository(oldPhone);
    final area = (await oldPhone.select(oldPhone.areas).get()).first;

    await notes.create(
        areaId: area.id, title: 'Nguyên tắc chung', bodyMarkdown: 'Giữ mức này');
    await notes.create(title: 'Chưa xếp chỗ');
    await links.create(areaId: area.id, label: 'Tham khảo', url: 'https://a.test');

    final file = File('${tempDir.path}/para.json');
    await file.writeAsString(
        await BackupService(oldPhone, clock: clock).exportJson());
    expect(jsonDecode(await file.readAsString())['schemaVersion'],
        backupFormatVersion,
        reason: 'schema thêm dữ liệu người dùng thì định dạng phải theo ngay');

    final newPhone = await freshDb();
    final result = await BackupService(newPhone, clock: clock)
        .import(await file.readAsString());
    expect(result.isOk, isTrue);

    final attached = (await newPhone.select(newPhone.notes).get())
        .firstWhere((n) => n.title == 'Nguyên tắc chung');
    expect(attached.areaId, area.id);
    expect(attached.projectId, isNull);
    expect(attached.bodyMarkdown, 'Giữ mức này');

    final loose = (await newPhone.select(newPhone.notes).get())
        .firstWhere((n) => n.title == 'Chưa xếp chỗ');
    expect(loose.areaId, isNull);
    expect(loose.projectId, isNull);

    final link = (await newPhone.select(newPhone.links).get())
        .firstWhere((l) => l.label == 'Tham khảo');
    expect(link.areaId, area.id);
    expect(link.projectId, isNull);
  });

  test('chuyển máy: máy cũ xuất ra file, máy mới nhập vào, khớp từng chữ',
      () async {
    // ----- MÁY CŨ -----
    final oldPhone = await freshDb();
    final oldService = BackupService(oldPhone, clock: () => DateTime.utc(2026, 8, 28));
    await Seeder(oldPhone, clock: () => DateTime.utc(2026, 8, 28)).applyProjectSeed();

    final fileName = oldService.fileNameFor(DateTime(2026, 8, 28));
    final file = File('${tempDir.path}/$fileName');
    // Đúng cách `runExport` ghi file trong ứng dụng.
    await file.writeAsString(await oldService.exportJson());

    expect(file.existsSync(), isTrue);
    expect(fileName, 'sao-luu-2026-08-28.json');
    expect(await file.length(), greaterThan(1000));

    // ----- MÁY MỚI: cơ sở dữ liệu trắng tinh -----
    final newPhone = await freshDb();
    final newService = BackupService(newPhone, clock: () => DateTime.utc(2026, 9, 1));
    // Máy mới mở app lần đầu sẽ dựng sáu Lĩnh vực trước khi người dùng nhập.
    await Seeder(newPhone, clock: () => DateTime.utc(2026, 9, 1)).ensureAreas();
    expect(await newPhone.select(newPhone.projects).get(), isEmpty);

    // Đúng cách `runImport` đọc file: bytes rồi giải mã UTF-8.
    final raw = utf8.decode(await file.readAsBytes());
    final result = await newService.import(raw);
    expect(result.isOk, isTrue);

    // ----- SO KHỚP -----
    final before = (await oldService.buildDocument()).sections;
    final after = (await newService.buildDocument()).sections;
    for (final key in before.keys) {
      expect(after[key], equals(before[key]), reason: 'mục "$key" lệch');
    }
  });

  test('dấu tiếng Việt sống sót qua file — không thành ký tự rác', () async {
    final oldPhone = await freshDb();
    final service = BackupService(oldPhone, clock: () => DateTime.utc(2026, 8, 28));
    await Seeder(oldPhone, clock: () => DateTime.utc(2026, 8, 28)).applyProjectSeed();

    final file = File('${tempDir.path}/sao-luu.json');
    await file.writeAsString(await service.exportJson());

    final raw = utf8.decode(await file.readAsBytes());
    expect(raw, contains('Kế hoạch tài chính'));
    expect(raw, contains('Dồn tiền mua máy rửa bát'));
    expect(raw, contains('Dạy Huy'));
    expect(raw, contains('Sức khoẻ'));
    expect(raw, contains('mồ hôi trộm'));

    final newPhone = await freshDb();
    final newService = BackupService(newPhone, clock: () => DateTime.utc(2026, 9, 1));
    await newService.import(raw);

    final names = (await newPhone.select(newPhone.projects).get())
        .map((p) => p.name)
        .toList();
    expect(names, contains('Kế hoạch tài chính'));
    expect(names, contains('Dạy Huy'));

    final items = (await newPhone.select(newPhone.reviewItems).get())
        .map((i) => i.label)
        .toList();
    expect(items, contains('Ăn uống đa dạng'));
  });

  test('tìm kiếm không dấu vẫn chạy trên máy mới sau khi nhập', () async {
    final oldPhone = await freshDb();
    final oldService = BackupService(oldPhone, clock: () => DateTime.utc(2026, 8, 28));
    await Seeder(oldPhone, clock: () => DateTime.utc(2026, 8, 28)).applyProjectSeed();
    final raw = await oldService.exportJson();

    final newPhone = await freshDb();
    await BackupService(newPhone, clock: () => DateTime.utc(2026, 9, 1)).import(raw);

    // Chỉ mục được sinh lại lúc nhập, không lấy từ file — AD-12.
    // Chỉ mục là cột thường, so khớp trực tiếp cho khỏi phụ thuộc API truy vấn.
    final indexed = (await newPhone.select(newPhone.projects).get())
        .where((p) => p.searchText.contains('tai chinh'))
        .map((p) => p.name)
        .toList();
    // Hai dự án khớp: một ở tên, một ở mô tả "Làm ứng dụng tài chính".
    expect(indexed, contains('Kế hoạch tài chính'));
    expect(indexed, contains('Viết app đẩy store kiếm thu nhập'));
  });

  test('nhập đè lên máy đã có dữ liệu: thay thế, không trộn', () async {
    final oldPhone = await freshDb();
    final oldService = BackupService(oldPhone, clock: () => DateTime.utc(2026, 8, 28));
    await Seeder(oldPhone, clock: () => DateTime.utc(2026, 8, 28)).applyProjectSeed();
    final raw = await oldService.exportJson();

    // Máy mới đã lỡ tự nạp bộ hạt giống trước khi nhập.
    final newPhone = await freshDb();
    await Seeder(newPhone, clock: () => DateTime.utc(2026, 9, 1)).applyProjectSeed();
    expect((await newPhone.select(newPhone.projects).get()).length, 7);

    await BackupService(newPhone, clock: () => DateTime.utc(2026, 9, 1)).import(raw);

    // Vẫn đúng 7, không thành 14.
    expect((await newPhone.select(newPhone.projects).get()).length, 7);
    expect((await newPhone.select(newPhone.actions).get()).length, 17);
    expect((await newPhone.select(newPhone.reviewItems).get()).length, 10);
  });
}
