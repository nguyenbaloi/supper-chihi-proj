import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/data/db/database.dart';
import 'package:personal_projects/data/repositories/drift_action_repository.dart';
import 'package:personal_projects/data/repositories/drift_content_repositories.dart';
import 'package:personal_projects/data/repositories/drift_project_repository.dart';
import 'package:personal_projects/data/repositories/drift_area_repository.dart';
import 'package:personal_projects/data/seed/seeder.dart';
import 'package:personal_projects/domain/models/enums.dart';
import 'package:personal_projects/domain/repositories/repositories.dart';

void main() {
  late AppDatabase db;
  late DriftProjectRepository projects;
  late DriftActionRepository actions;
  late DriftAreaRepository areas;
  late Seeder seeder;

  DateTime now = DateTime.utc(2026, 8, 28, 10);
  DateTime clock() => now;

  setUp(() async {
    now = DateTime.utc(2026, 8, 28, 10);
    db = AppDatabase(NativeDatabase.memory());
    projects = DriftProjectRepository(db, clock: clock);
    actions = DriftActionRepository(db, clock: clock);
    areas = DriftAreaRepository(db);
    seeder = Seeder(db, clock: clock);
    await seeder.ensureAreas();
  });

  tearDown(() => db.close());

  group('Story 1.6 — sáu Lĩnh vực dựng sẵn (FR-1)', () {
    test('đúng sáu Lĩnh vực với tên chuẩn', () async {
      final all = await areas.getAll();
      expect(all.map((t) => t.name).toList(),
          ['Gia đình', 'Thu nhập', 'Tài chính', 'Sức khoẻ', 'Học tập', 'Khác']);
    });

    test('Khác là Lĩnh vực hệ thống và không xoá được', () async {
      final other = (await areas.getAll()).firstWhere((t) => t.name == 'Khác');
      expect(other.isSystemFallback, isTrue);
      await areas.delete(other.id);
      expect((await areas.getAll()).length, 6);
    });

    test('xoá Lĩnh vực thì Dự án chuyển về Khác, không bị xoá theo', () async {
      final health = (await areas.getAll()).firstWhere((t) => t.name == 'Sức khoẻ');
      final other = (await areas.getAll()).firstWhere((t) => t.name == 'Khác');
      final p = await projects.create(name: 'Chạy bộ', areaId: health.id);

      await areas.delete(health.id);

      final reloaded = await projects.getById(p.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.areaId, other.id);
      expect((await areas.getAll()).length, 5);
    });

    test('chạy ensureAreas hai lần không nhân đôi', () async {
      await seeder.ensureAreas();
      expect((await areas.getAll()).length, 6);
    });
  });

  group('Story 2.2 — trạng thái Dự án và dấu thời gian (FR-8, AD-5)', () {
    test('KỊCH BẢN BẮT BUỘC 3 — Đang làm → Xong → Đang làm', () async {
      final p = await projects.create(name: 'Kênh TikTok');
      expect(p.startedAt, isNull);

      now = DateTime.utc(2026, 8, 28, 11);
      await projects.changeStatus(p.id, ProjectStatus.active);
      final started = (await projects.getById(p.id))!.startedAt;
      expect(started, DateTime.utc(2026, 8, 28, 11));

      now = DateTime.utc(2026, 9, 1);
      await projects.changeStatus(p.id, ProjectStatus.done);
      final done = await projects.getById(p.id);
      expect(done!.completedAt, DateTime.utc(2026, 9, 1));
      expect(done.startedAt, started, reason: 'startedAt không được đổi');

      now = DateTime.utc(2026, 9, 10);
      await projects.changeStatus(p.id, ProjectStatus.active);
      final again = await projects.getById(p.id);
      expect(again!.completedAt, isNull, reason: 'rời Xong thì xoá completedAt');
      expect(again.startedAt, started, reason: 'startedAt giữ nguyên lần đầu');
    });

    test('mỗi lần đổi trạng thái sinh một StatusEvent', () async {
      final p = await projects.create(name: 'Dự án A');
      await projects.changeStatus(p.id, ProjectStatus.active);
      await projects.changeStatus(p.id, ProjectStatus.paused);
      final history = await projects.watchStatusHistory(p.id).first;
      expect(history.length, 2);
      expect(history.first.toStatus, 'paused');
      expect(history.last.fromStatus, 'not_started');
    });

    test('đổi sang chính trạng thái đang có thì không ghi gì', () async {
      final p = await projects.create(name: 'Dự án B');
      await projects.changeStatus(p.id, ProjectStatus.notStarted);
      expect(await projects.watchStatusHistory(p.id).first, isEmpty);
    });
  });

  group('Story 2.5 — trạng thái Hành động (FR-16)', () {
    test('Chưa → Đang làm → Xong → Chưa giữ đúng dấu thời gian', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Mua máy rửa bát');

      now = DateTime.utc(2026, 8, 29);
      await actions.changeStatus(a.id, ActionStatus.doing);
      var row = (await actions.watchByProject(p.id).first).single;
      expect(row.startedAt, DateTime.utc(2026, 8, 29));

      now = DateTime.utc(2026, 8, 30);
      await actions.changeStatus(a.id, ActionStatus.done);
      row = (await actions.watchByProject(p.id).first).single;
      expect(row.completedAt, DateTime.utc(2026, 8, 30));

      await actions.changeStatus(a.id, ActionStatus.todo);
      row = (await actions.watchByProject(p.id).first).single;
      expect(row.completedAt, isNull);
      expect(row.startedAt, DateTime.utc(2026, 8, 29));
    });

    test('thứ tự kéo thả được lưu', () async {
      final p = await projects.create(name: 'Dự án');
      final a1 = await actions.create(projectId: p.id, title: 'Một');
      final a2 = await actions.create(projectId: p.id, title: 'Hai');
      final a3 = await actions.create(projectId: p.id, title: 'Ba');

      await actions.reorder(p.id, [a3.id, a1.id, a2.id]);
      final ordered = await actions.watchByProject(p.id).first;
      expect(ordered.map((a) => a.title).toList(), ['Ba', 'Một', 'Hai']);
    });

    test('chuyển Hành động sang Dự án khác — FR-15', () async {
      final p1 = await projects.create(name: 'Nguồn');
      final p2 = await projects.create(name: 'Đích');
      final a = await actions.create(projectId: p1.id, title: 'Việc');

      await actions.moveToProject(a.id, p2.id);

      expect(await actions.watchByProject(p1.id).first, isEmpty);
      expect((await actions.watchByProject(p2.id).first).single.title, 'Việc');
    });
  });

  group('Chi tiết Hành động — nhập hạn, sửa hạn, sửa ưu tiên', () {
    test('tạo kèm hạn và độ ưu tiên, không phải mặc định', () async {
      final p = await projects.create(name: 'Dự án');
      final due = DateTime.utc(2026, 9, 20);
      final a = await actions.create(
        projectId: p.id,
        title: 'Gọi thợ',
        priority: Priority.high,
        dueDate: due,
      );

      final row = await actions.watchById(a.id).first;
      expect(row!.priority, Priority.high);
      expect(row.dueDate, due);
    });

    test('sửa hạn và độ ưu tiên rồi đọc lại đúng, updatedAt đổi theo', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Gọi thợ');

      now = DateTime.utc(2026, 9, 1, 8);
      await actions.update(a.copyWith(
        priority: Priority.low,
        dueDate: DateTime.utc(2026, 9, 30),
      ));

      final row = (await actions.watchById(a.id).first)!;
      expect(row.priority, Priority.low);
      expect(row.dueDate, DateTime.utc(2026, 9, 30));
      expect(row.updatedAt, DateTime.utc(2026, 9, 1, 8));
      expect(row.createdAt, a.createdAt, reason: 'AD-5: createdAt không đổi');
    });

    test('bỏ hạn thì về null, không giữ lại hạn cũ', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(
        projectId: p.id,
        title: 'Gọi thợ',
        dueDate: DateTime.utc(2026, 9, 20),
      );

      await actions.update(a.copyWith(clearDueDate: true));

      expect((await actions.watchById(a.id).first)!.dueDate, isNull);
    });

    test('xoá rồi thì trả null, để màn hình chi tiết tự đóng', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Gọi thợ');

      await actions.delete(a.id);

      expect(await actions.watchById(a.id).first, isNull);
    });

    test('đổi trạng thái ở màn chi tiết vẫn ghi startedAt một lần', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Gọi thợ');

      now = DateTime.utc(2026, 9, 2);
      await actions.changeStatus(a.id, ActionStatus.doing);
      now = DateTime.utc(2026, 9, 3);
      await actions.changeStatus(a.id, ActionStatus.done);
      await actions.changeStatus(a.id, ActionStatus.doing);

      final row = (await actions.watchById(a.id).first)!;
      expect(row.startedAt, DateTime.utc(2026, 9, 2));
      expect(row.completedAt, isNull);
    });
  });

  group('Story 2.1 — xoá Dự án (FR-7)', () {
    // FR-50, AD-18. Trước v5 test này khẳng định điều ngược lại: Ghi chú và
    // Liên kết bị xoá theo. Đó chính là lỗi mất dữ liệu Story 8.4 vá.
    test('xoá theo tầng Hành động, nhưng Ghi chú và Liên kết chuyển sang Lĩnh vực',
        () async {
      final notes = DriftNoteRepository(db, clock: clock);
      final links = DriftLinkRepository(db);
      final p = await projects.create(name: 'Kế hoạch tài chính');
      await actions.create(projectId: p.id, title: 'Việc 1');
      await notes.create(projectId: p.id, title: 'Nợ tốt', bodyMarkdown: '...');
      await notes.create(projectId: p.id, title: 'Khi nào nên vay');
      await links.create(projectId: p.id, label: 'Sheet', url: 'https://x.test');

      final before = await projects.attachedContentCount(p.id);
      expect(before, (notes: 2, links: 1));

      await projects.delete(p.id);

      expect(await projects.getById(p.id), isNull);
      expect(await db.select(db.actions).get(), isEmpty,
          reason: 'Hành động vẫn chết theo Dự án — AD-8');

      final survivingNotes = await db.select(db.notes).get();
      expect(survivingNotes.length, 2);
      expect(survivingNotes.map((n) => n.title).toSet(),
          {'Nợ tốt', 'Khi nào nên vay'});
      expect(survivingNotes.first.bodyMarkdown, '...');
      for (final n in survivingNotes) {
        expect(n.projectId, isNull);
        expect(n.areaId, p.areaId,
            reason: 'phải về Lĩnh vực của Dự án, không rơi vào kho chung');
      }

      final survivingLinks = await db.select(db.links).get();
      expect(survivingLinks.single.url, 'https://x.test');
      expect(survivingLinks.single.projectId, isNull);
      expect(survivingLinks.single.areaId, p.areaId);
    });

    test('chuyển Tư liệu giữa Dự án, Lĩnh vực và kho chung giữ nguyên nội dung',
        () async {
      final notes = DriftNoteRepository(db, clock: clock);
      final p = await projects.create(name: 'Dự án');
      final n = await notes.create(
          projectId: p.id, title: 'Bài học', bodyMarkdown: 'Nội dung dài');
      final createdAt = (await db.select(db.notes).get()).single.createdAt;

      await notes.move(n.id, areaId: p.areaId);
      var row = (await db.select(db.notes).get()).single;
      expect(row.projectId, isNull);
      expect(row.areaId, p.areaId);

      await notes.move(n.id);
      row = (await db.select(db.notes).get()).single;
      expect(row.projectId, isNull);
      expect(row.areaId, isNull, reason: 'không tham số nào nghĩa là kho chung');

      await notes.move(n.id, projectId: p.id);
      row = (await db.select(db.notes).get()).single;
      expect(row.projectId, p.id);
      expect(row.title, 'Bài học');
      expect(row.bodyMarkdown, 'Nội dung dài');
      expect(row.createdAt, createdAt, reason: 'createdAt không bao giờ đổi');
      expect(row.searchText, contains('bai hoc'),
          reason: 'searchText là dẫn xuất, phải sinh lại sau mỗi lần chuyển');
    });

    test('xoá Lĩnh vực thì Tư liệu gắn thẳng vào nó về Khác, không mất', () async {
      final notes = DriftNoteRepository(db, clock: clock);
      final areas = DriftAreaRepository(db);
      final area = await areas.create(
          name: 'Tạm', colorValue: 1, iconKey: 'other');
      await notes.create(areaId: area.id, title: 'Ghi chú của Lĩnh vực');

      await areas.delete(area.id);

      final row = (await db.select(db.notes).get()).single;
      expect(row.title, 'Ghi chú của Lĩnh vực');
      final fallback = (await db.select(db.areas).get())
          .firstWhere((a) => a.isSystemFallback);
      expect(row.areaId, fallback.id);
    });
  });

  group('Story 2.3 — danh sách và bộ lọc (FR-10)', () {
    test('mặc định ẩn Xong và Bỏ', () async {
      final a = await projects.create(name: 'Đang chạy');
      final b = await projects.create(name: 'Đã xong');
      await projects.changeStatus(a.id, ProjectStatus.active);
      await projects.changeStatus(b.id, ProjectStatus.done);

      final visible = await projects.watchSummaries(const ProjectFilter()).first;
      expect(visible.map((s) => s.project.name).toList(), ['Đang chạy']);

      final all = await projects
          .watchSummaries(const ProjectFilter(includeClosed: true))
          .first;
      expect(all.length, 2);
    });

    test('tỷ lệ hoàn thành suy ra đúng, Bỏ không vào mẫu số', () async {
      final p = await projects.create(name: 'Dự án');
      final a1 = await actions.create(projectId: p.id, title: '1');
      final a2 = await actions.create(projectId: p.id, title: '2');
      final a3 = await actions.create(projectId: p.id, title: '3');
      await actions.changeStatus(a1.id, ActionStatus.done);
      await actions.changeStatus(a3.id, ActionStatus.dropped);

      final s = (await projects
              .watchSummaries(const ProjectFilter(includeClosed: true))
              .first)
          .firstWhere((s) => s.project.id == p.id);
      expect(s.doneCount, 1);
      expect(s.countedTotal, 2);
      expect(a2.status, ActionStatus.todo);
    });

    test('mốc hoạt động gần nhất lấy từ StatusEvent của Hành động', () async {
      final p = await projects.create(name: 'Dự án');
      final a = await actions.create(projectId: p.id, title: 'Việc');
      now = DateTime.utc(2026, 9, 5);
      await actions.changeStatus(a.id, ActionStatus.doing);

      final s = (await projects
              .watchSummaries(const ProjectFilter(includeClosed: true))
              .first)
          .single;
      expect(s.lastActivityAt, DateTime.utc(2026, 9, 5));
    });

    test('lọc theo Lĩnh vực kết hợp AND với trạng thái', () async {
      final all = await areas.getAll();
      final family = all.firstWhere((t) => t.name == 'Gia đình');
      final income = all.firstWhere((t) => t.name == 'Thu nhập');
      final p1 = await projects.create(name: 'Con học toán', areaId: family.id);
      await projects.create(name: 'TikTok', areaId: income.id);
      await projects.changeStatus(p1.id, ProjectStatus.active);

      final filtered = await projects
          .watchSummaries(ProjectFilter(
            areaIds: {family.id},
            statuses: {ProjectStatus.active},
          ))
          .first;
      expect(filtered.map((s) => s.project.name).toList(), ['Con học toán']);
    });
  });

  group('Story 5.3 và 5.4 — dữ liệu hạt giống (FR-2, FR-3, FR-4)', () {
    test('nạp đúng số lượng từng loại', () async {
      await seeder.applyProjectSeed();

      expect((await db.select(db.projects).get()).length, 7);
      // 6 hành động của Kế hoạch tài chính + 11 của Dạy Huy.
      expect((await db.select(db.actions).get()).length, 17);
      expect((await db.select(db.notes).get()).length, 5);
      expect((await db.select(db.links).get()).length, 4);
      expect((await db.select(db.reviews).get()).length, 2);
    });

    test('sáu Hành động thuộc Kế hoạch tài chính, ánh xạ đúng trạng thái', () async {
      await seeder.applyProjectSeed();
      final finance = (await db.select(db.projects).get())
          .firstWhere((p) => p.name == 'Kế hoạch tài chính');
      final list = await actions.watchByProject(finance.id).first;

      expect(list.length, 6);
      expect(list.where((a) => a.status == ActionStatus.done).length, 3);
      expect(list.where((a) => a.status == ActionStatus.doing).length, 1);
      expect(list.where((a) => a.status == ActionStatus.todo).length, 2);
    });

    test('FR-4 — chạy lại không nhân đôi bản ghi', () async {
      await seeder.applyProjectSeed();
      await seeder.applyProjectSeed();

      expect((await db.select(db.projects).get()).length, 7);
      expect((await db.select(db.actions).get()).length, 17);
      expect((await db.select(db.reviews).get()).length, 2);
    });
  });

}
