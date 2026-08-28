import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/core/result/result.dart';
import 'package:personal_projects/data/backup/backup_codec.dart';
import 'package:personal_projects/data/backup/backup_service.dart';
import 'package:personal_projects/data/db/database.dart';
import 'package:personal_projects/data/seed/seeder.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;
  DateTime clock() => DateTime.utc(2026, 8, 28, 10);

  /// Chụp lại toàn bộ nội dung cơ sở dữ liệu để so khớp sau khi khôi phục.
  Future<Map<String, List<Map<String, Object?>>>> snapshot() async {
    final doc = await backup.buildDocument();
    return doc.sections;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    backup = BackupService(db, clock: clock);
    await Seeder(db, clock: clock).applyProjectSeed();
  });

  tearDown(() => db.close());

  group('Story 6.1 — xuất bản sao lưu (FR-31)', () {
    test('file mở đầu bằng schemaVersion và exportedAt', () async {
      final json = jsonDecode(await backup.exportJson()) as Map<String, Object?>;
      expect(json['schemaVersion'], backupFormatVersion);
      expect(DateTime.parse(json['exportedAt']! as String), clock().toUtc());
    });

    test('chứa đủ tám mục và phần cài đặt', () async {
      final json = jsonDecode(await backup.exportJson()) as Map<String, Object?>;
      for (final name in backupSections) {
        expect(json.containsKey(name), isTrue, reason: 'thiếu mục $name');
      }
      expect(json['settings'], isA<Map<String, Object?>>());
    });

    test('đủ số lượng bản ghi của bộ hạt giống', () async {
      final json = jsonDecode(await backup.exportJson()) as Map<String, Object?>;
      expect((json['projects']! as List).length, 7);
      expect((json['actions']! as List).length, 17);
      expect((json['notes']! as List).length, 5);
      expect((json['links']! as List).length, 4);
      expect((json['reviews']! as List).length, 2);
      expect((json['reviewItems']! as List).length, 10);
    });

    test('tên file theo mẫu sao-luu-YYYY-MM-DD.json', () {
      expect(backup.fileNameFor(DateTime(2026, 8, 5)), 'sao-luu-2026-08-05.json');
    });
  });

  group('Story 6.2 — nhập khôi phục (FR-32)', () {
    test('KỊCH BẢN BẮT BUỘC 4 — xuất, xoá sạch, nhập, so khớp toàn bộ', () async {
      final before = await snapshot();
      final json = await backup.exportJson();

      await backup.wipeAll();
      expect(await db.select(db.projects).get(), isEmpty);
      expect(await db.select(db.reviews).get(), isEmpty);

      final result = await backup.import(json);
      expect(result.isOk, isTrue);

      final after = await snapshot();
      for (final name in backupSections) {
        expect(after[name], equals(before[name]),
            reason: 'mục "$name" không khớp sau khi khôi phục');
      }
    });

    test('giữ nguyên createdAt và sortOrder', () async {
      final before = await snapshot();
      final json = await backup.exportJson();
      await backup.wipeAll();
      await backup.import(json);
      final after = await snapshot();

      final beforeActions = before['actions']!;
      final afterActions = after['actions']!;
      expect(afterActions.length, beforeActions.length);
      for (var i = 0; i < beforeActions.length; i++) {
        expect(afterActions[i]['createdAt'], beforeActions[i]['createdAt']);
        expect(afterActions[i]['sortOrder'], beforeActions[i]['sortOrder']);
        expect(afterActions[i]['id'], beforeActions[i]['id']);
      }
    });

    test('nhập là thay thế toàn bộ, không trộn', () async {
      final json = await backup.exportJson();
      // Nhập chồng lên chính dữ liệu hiện có: số lượng phải giữ nguyên,
      // không nhân đôi.
      final result = await backup.import(json);
      expect(result.isOk, isTrue);
      expect((await db.select(db.projects).get()).length, 7);
      expect((await db.select(db.reviewItems).get()).length, 10);
    });

    test('file sai định dạng bị từ chối, dữ liệu hiện tại không đụng tới', () async {
      final before = await snapshot();
      final result = await backup.import('{ đây không phải json }');
      expect(result.isErr, isTrue);
      result.fold((_) => fail('phải trả về lỗi'), (f) {
        expect(f.code, FailureCode.malformedBackup);
        expect(f.detail, isNotNull);
      });
      expect(await snapshot(), equals(before));
    });

    test('thiếu trường bắt buộc bị từ chối kèm lý do cụ thể', () async {
      final before = await snapshot();
      final bad = jsonEncode({
        'schemaVersion': 2,
        'exportedAt': '2026-08-28T00:00:00.000Z',
        'projects': [
          {'id': 1, 'name': 'Thiếu topicId'}
        ],
      });
      final result = await backup.import(bad);
      expect(result.isErr, isTrue);
      result.fold((_) => fail('phải trả về lỗi'), (f) {
        expect(f.code, FailureCode.malformedBackup);
        expect(f.detail, contains('topicId'));
      });
      expect(await snapshot(), equals(before));
    });

    test('phiên bản mới hơn ứng dụng bị từ chối', () async {
      final before = await snapshot();
      final tooNew = jsonEncode({
        'schemaVersion': backupFormatVersion + 1,
        'exportedAt': '2026-08-28T00:00:00.000Z',
      });
      final result = await backup.import(tooNew);
      result.fold((_) => fail('phải trả về lỗi'), (f) {
        expect(f.code, FailureCode.backupTooNew);
      });
      expect(await snapshot(), equals(before));
    });

    test('lỗi giữa chừng cuộn ngược hoàn toàn — không để lại dữ liệu nửa vời',
        () async {
      final before = await snapshot();
      // Hợp lệ về hình thức nhưng vi phạm khoá ngoại: Hành động trỏ tới một
      // Dự án không tồn tại.
      final broken = jsonEncode({
        'schemaVersion': 2,
        'exportedAt': '2026-08-28T00:00:00.000Z',
        'topics': [
          {'id': 1, 'name': 'Gia đình', 'colorValue': 1, 'iconKey': 'family'}
        ],
        'projects': [
          {
            'id': 1,
            'topicId': 1,
            'name': 'Dự án hợp lệ',
            'status': 'active',
            'priority': 'medium',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          }
        ],
        'actions': [
          {
            'id': 1,
            'projectId': 999, // không tồn tại
            'title': 'Hành động mồ côi',
            'status': 'todo',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          }
        ],
      });
      final result = await backup.import(broken);
      expect(result.isErr, isTrue);
      expect(await snapshot(), equals(before),
          reason: 'giao dịch phải cuộn ngược, dữ liệu cũ còn nguyên');
    });

    test('file của phiên bản cũ thiếu mục reviews vẫn nhập được', () async {
      final old = jsonEncode({
        'schemaVersion': 1,
        'exportedAt': '2026-05-15T00:00:00.000Z',
        'topics': [
          {'id': 1, 'name': 'Tài chính', 'colorValue': 1, 'iconKey': 'finance'}
        ],
        'projects': [
          {
            'id': 1,
            'topicId': 1,
            'name': 'Kế hoạch tài chính',
            'status': 'active',
            'priority': 'high',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          }
        ],
      });
      final result = await backup.import(old);
      expect(result.isOk, isTrue);
      expect((await db.select(db.projects).get()).single.name, 'Kế hoạch tài chính');
      expect(await db.select(db.reviews).get(), isEmpty);
    });

    test('chỉ mục tìm kiếm được sinh lại khi nhập, không lấy từ file', () async {
      final json = await backup.exportJson();
      await backup.wipeAll();
      await backup.import(json);
      final p = (await db.select(db.projects).get())
          .firstWhere((p) => p.name == 'Kế hoạch tài chính');
      expect(p.searchText, contains('ke hoach tai chinh'));
    });
  });

  group('Story 6.3 — xoá sạch dữ liệu (FR-34)', () {
    test('xoá sạch rồi dựng lại sáu Chủ đề mặc định', () async {
      await backup.wipeAll();
      expect(await db.select(db.projects).get(), isEmpty);
      expect(await db.select(db.reviews).get(), isEmpty);
      expect(await db.select(db.statusEvents).get(), isEmpty);
      expect((await db.select(db.topics).get()).length, 6);
    });
  });
}
