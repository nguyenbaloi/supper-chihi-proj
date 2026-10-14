import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/data/db/database.dart';
import 'package:personal_projects/data/repositories/drift_action_repository.dart';
import 'package:personal_projects/data/repositories/drift_project_repository.dart';
import 'package:personal_projects/data/seed/seeder.dart';
import 'package:personal_projects/domain/models/enums.dart';

void main() {
  late AppDatabase db;
  late DriftProjectRepository projects;
  late DriftActionRepository actions;

  DateTime now = DateTime.utc(2026, 8, 28, 10);
  DateTime clock() => now;

  setUp(() async {
    now = DateTime.utc(2026, 8, 28, 10);
    db = AppDatabase(NativeDatabase.memory());
    projects = DriftProjectRepository(db, clock: clock);
    actions = DriftActionRepository(db, clock: clock);
    await Seeder(db, clock: clock).ensureAreas();
  });

  tearDown(() => db.close());

  group('FR-42 — ghim vào danh sách Làm ngay', () {
    test('mặc định không ghim; danh sách Làm ngay rỗng', () async {
      final p = await projects.create(name: 'Kế hoạch tài chính');
      final a = await actions.create(projectId: p.id, title: 'Mua máy rửa bát');
      expect(a.pinned, isFalse);
      expect(await actions.watchPinned().first, isEmpty);
    });

    test('ghim rồi bỏ ghim', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Việc');

      await actions.setPinned(a.id, true);
      var pinned = await actions.watchPinned().first;
      expect(pinned.single.id, a.id);
      expect(pinned.single.pinnedAt, isNotNull);

      await actions.setPinned(a.id, false);
      pinned = await actions.watchPinned().first;
      expect(pinned, isEmpty);
    });

    test('cùng độ ưu tiên: việc ghim sau cùng lên trên', () async {
      final p = await projects.create(name: 'Dự án');
      final a1 = await actions.create(projectId: p.id, title: 'Một');
      final a2 = await actions.create(projectId: p.id, title: 'Hai');
      final a3 = await actions.create(projectId: p.id, title: 'Ba');

      now = DateTime.utc(2026, 8, 28, 15);
      await actions.setPinned(a2.id, true);
      now = DateTime.utc(2026, 8, 28, 16);
      await actions.setPinned(a1.id, true);
      now = DateTime.utc(2026, 8, 28, 17);
      await actions.setPinned(a3.id, true);

      expect((await actions.watchPinned().first).map((a) => a.title).toList(),
          ['Ba', 'Một', 'Hai']);
    });

    test('ưu tiên cao lên trên trước, rồi mới xét thời điểm ghim', () async {
      final p = await projects.create(name: 'Dự án');
      final thapMoi = await actions.create(
          projectId: p.id, title: 'Thấp, ghim mới', priority: Priority.low);
      final caoCu = await actions.create(
          projectId: p.id, title: 'Cao, ghim cũ', priority: Priority.high);
      final tbMoi = await actions.create(
          projectId: p.id, title: 'TB, ghim mới', priority: Priority.medium);
      final caoMoi = await actions.create(
          projectId: p.id, title: 'Cao, ghim mới', priority: Priority.high);
      final tbCu = await actions.create(
          projectId: p.id, title: 'TB, ghim cũ', priority: Priority.medium);

      for (final a in [caoCu, tbCu, thapMoi, tbMoi, caoMoi]) {
        now = now.add(const Duration(hours: 1));
        await actions.setPinned(a.id, true);
      }

      expect((await actions.watchPinned().first).map((a) => a.title).toList(), [
        'Cao, ghim mới',
        'Cao, ghim cũ',
        'TB, ghim mới',
        'TB, ghim cũ',
        'Thấp, ghim mới',
      ], reason: 'xếp chữ cái sẽ ra high · low · medium — phải theo mức thật');
    });

    test('đổi độ ưu tiên thì việc đã ghim tự đổi chỗ', () async {
      final p = await projects.create(name: 'Dự án');
      final a1 = await actions.create(projectId: p.id, title: 'Một');
      final a2 = await actions.create(projectId: p.id, title: 'Hai');
      now = DateTime.utc(2026, 8, 28, 15);
      await actions.setPinned(a1.id, true);
      now = DateTime.utc(2026, 8, 28, 16);
      await actions.setPinned(a2.id, true);
      expect((await actions.watchPinned().first).map((a) => a.title).toList(),
          ['Hai', 'Một']);

      final mot = (await actions.watchPinned().first)
          .firstWhere((a) => a.id == a1.id);
      await actions.update(mot.copyWith(priority: Priority.high));

      expect((await actions.watchPinned().first).map((a) => a.title).toList(),
          ['Một', 'Hai']);
    });

    test('bỏ ghim rồi ghim lại thì tính là ghim mới nhất', () async {
      final p = await projects.create(name: 'Dự án');
      final a1 = await actions.create(projectId: p.id, title: 'Một');
      final a2 = await actions.create(projectId: p.id, title: 'Hai');
      now = DateTime.utc(2026, 8, 28, 15);
      await actions.setPinned(a1.id, true);
      now = DateTime.utc(2026, 8, 28, 16);
      await actions.setPinned(a2.id, true);

      await actions.setPinned(a1.id, false);
      now = DateTime.utc(2026, 8, 28, 18);
      await actions.setPinned(a1.id, true);

      expect((await actions.watchPinned().first).map((a) => a.title).toList(),
          ['Một', 'Hai']);
    });

    test('hoàn tác xoá giữ nguyên thời điểm ghim', () async {
      final p = await projects.create(name: 'Dự án');
      final a1 = await actions.create(projectId: p.id, title: 'Một');
      final a2 = await actions.create(projectId: p.id, title: 'Hai');
      now = DateTime.utc(2026, 8, 28, 15);
      await actions.setPinned(a1.id, true);
      now = DateTime.utc(2026, 8, 28, 16);
      await actions.setPinned(a2.id, true);
      final saved =
          (await actions.watchPinned().first).firstWhere((a) => a.id == a1.id);

      now = DateTime.utc(2026, 8, 28, 20);
      await actions.delete(a1.id);
      await actions.restore(saved);

      expect((await actions.watchPinned().first).map((a) => a.title).toList(),
          ['Hai', 'Một'],
          reason: 'hoàn tác không phải là ghim lại');
    });

    test('đánh dấu Xong thì tự rời danh sách Làm ngay', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Việc');
      await actions.setPinned(a.id, true);
      expect((await actions.watchPinned().first).length, 1);

      await actions.changeStatus(a.id, ActionStatus.done);

      expect(await actions.watchPinned().first, isEmpty,
          reason: 'việc đã xong không nên nằm lại màn hình Hôm nay');
    });

    test('đánh dấu Bỏ cũng tự rời danh sách', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Việc');
      await actions.setPinned(a.id, true);
      await actions.changeStatus(a.id, ActionStatus.dropped);
      expect(await actions.watchPinned().first, isEmpty);
    });

    test('chuyển sang Đang làm thì VẪN giữ ghim', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Việc');
      await actions.setPinned(a.id, true);
      await actions.changeStatus(a.id, ActionStatus.doing);
      expect((await actions.watchPinned().first).length, 1);
    });

    test('khôi phục sau khi xoá giữ nguyên trạng thái ghim', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Việc');
      await actions.setPinned(a.id, true);
      final saved = (await actions.watchPinned().first).single;

      await actions.delete(a.id);
      expect(await actions.watchPinned().first, isEmpty);

      await actions.restore(saved);
      expect((await actions.watchPinned().first).single.pinned, isTrue);
    });
  });

  group('FR-41 — độ ưu tiên của Hành động', () {
    test('mặc định là Trung bình', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Việc');
      expect(a.priority, Priority.medium);
    });

    test('đặt và sửa được độ ưu tiên', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(
          projectId: p.id, title: 'Việc gấp', priority: Priority.high);
      expect(a.priority, Priority.high);

      await actions.update(a.copyWith(priority: Priority.low));
      final reloaded = (await actions.watchByProject(p.id).first).single;
      expect(reloaded.priority, Priority.low);
    });

    test('bộ hạt giống gán đúng độ ưu tiên cao cho bốn việc', () async {
      await Seeder(db, clock: clock).applyProjectSeed();
      final all = await actions.watchAll().first;
      final high = all.where((a) => a.priority == Priority.high).toList();
      expect(high.length, 4);
      expect(
        high.map((a) => a.title),
        containsAll([
          'Sắp xếp lại thời gian làm việc ở cty và cho cá nhân',
          'Tập đòi đi vệ sinh (tè, ị), tiến tới cai bỉm',
        ]),
      );
    });

    test('không việc nào được ghim sẵn sau khi nạp hạt giống', () async {
      await Seeder(db, clock: clock).applyProjectSeed();
      expect(await actions.watchPinned().first, isEmpty,
          reason: 'ghim là việc của người dùng, app không tự ghim hộ');
    });
  });
}
