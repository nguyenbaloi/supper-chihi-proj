import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/data/db/database.dart';
import 'package:personal_projects/data/repositories/drift_action_repository.dart';
import 'package:personal_projects/data/repositories/drift_project_repository.dart';
import 'package:personal_projects/data/repositories/drift_review_repository.dart';
import 'package:personal_projects/data/seed/seeder.dart';
import 'package:personal_projects/domain/models/enums.dart';
import 'package:personal_projects/domain/rules/review.dart';

void main() {
  late AppDatabase db;
  late DriftProjectRepository projects;
  late DriftReviewRepository reviews;
  late Seeder seeder;

  DateTime now = DateTime.utc(2026, 8, 28, 10);
  DateTime clock() => now;

  setUp(() async {
    now = DateTime.utc(2026, 8, 28, 10);
    db = AppDatabase(NativeDatabase.memory());
    projects = DriftProjectRepository(db, clock: clock);
    reviews = DriftReviewRepository(db, clock: clock);
    seeder = Seeder(db, clock: clock);
    await seeder.ensureAreas();
  });

  tearDown(() => db.close());

  group('Story 7.3 — tỷ lệ đạt suy ra (FR-39)', () {
    test('Một phần vào mẫu số nhưng không vào tử số', () {
      final tally = tallyReview([
        ReviewVerdict.met,
        ReviewVerdict.met,
        ReviewVerdict.partial,
        ReviewVerdict.notMet,
      ]);
      expect(tally.metCount, 2);
      expect(tally.total, 4);
      expect(tally.ratio, Decimal.parse('0.5'));
    });

    test('Đợt không có Mục nào trả null, không phải 0', () {
      expect(tallyReview(const []).ratio, isNull);
      expect(tallyReview(const []).isEmpty, isTrue);
    });

    test('đọc chuỗi kết quả lạ về Chưa đạt, không ném lỗi — AD-9', () {
      expect(ReviewVerdict.fromWire('xuat_sac'), ReviewVerdict.notMet);
      expect(ReviewVerdict.fromWire(null), ReviewVerdict.notMet);
      expect(ReviewVerdict.fromWire('partial'), ReviewVerdict.partial);
    });

    test('số Mục đạt đếm đúng qua truy vấn tổng hợp', () async {
      final p = await projects.create(name: 'Dạy Huy');
      final r = await reviews.create(projectId: p.id, date: DateTime(2026, 5, 15));
      await reviews.addItem(reviewId: r.id, label: 'Giấc ngủ', verdict: ReviewVerdict.met);
      await reviews.addItem(
          reviewId: r.id, label: 'Ăn uống', verdict: ReviewVerdict.met);
      await reviews.addItem(reviewId: r.id, label: 'Vận động');

      final summary = (await reviews.watchByProject(p.id).first).single;
      expect(summary.itemCount, 3);
      expect(summary.metCount, 2);
    });
  });

  group('Story 7.4 — kế thừa mục chưa đạt (FR-37, AD-15)', () {
    test('chỉ chép Chưa đạt và Một phần, không chép Đạt', () async {
      final p = await projects.create(name: 'Dạy Huy');
      final first = await reviews.create(projectId: p.id, date: DateTime(2026, 5, 15));
      await reviews.addItem(
          reviewId: first.id, label: 'Giấc ngủ', verdict: ReviewVerdict.met);
      await reviews.addItem(
          reviewId: first.id, label: 'Vận động', verdict: ReviewVerdict.notMet);
      await reviews.addItem(
          reviewId: first.id, label: 'Giao tiếp mắt', verdict: ReviewVerdict.partial);

      final candidates =
          carryForwardCandidates(await reviews.getItems(first.id));
      expect(candidates.map((i) => i.label).toList(), ['Vận động', 'Giao tiếp mắt']);

      final second = await reviews.create(projectId: p.id, date: DateTime(2026, 8, 7));
      await reviews.carryForward(targetReviewId: second.id, items: candidates);

      final copied = await reviews.getItems(second.id);
      expect(copied.map((i) => i.label).toList(), ['Vận động', 'Giao tiếp mắt']);
      expect(copied.every((i) => i.verdict == ReviewVerdict.notMet), isTrue,
          reason: 'Mục chép sang khởi điểm ở Chưa đạt');
      expect(copied.map((i) => i.sortOrder).toList(), [0, 1],
          reason: 'giữ thứ tự tương đối');
    });

    test('chép sang không tạo liên kết — sửa Mục cũ không đổi Mục mới', () async {
      final p = await projects.create(name: 'Dạy Huy');
      final first = await reviews.create(projectId: p.id, date: DateTime(2026, 5, 15));
      final old = await reviews.addItem(
          reviewId: first.id, label: 'Vận động', verdict: ReviewVerdict.notMet);
      final second = await reviews.create(projectId: p.id, date: DateTime(2026, 8, 7));
      await reviews.carryForward(targetReviewId: second.id, items: [old]);

      await reviews.updateItem(old.copyWith(label: 'ĐÃ SỬA'));

      final copied = await reviews.getItems(second.id);
      expect(copied.single.label, 'Vận động',
          reason: 'AD-15: nhật ký quá khứ giữ đúng chữ đã viết lúc đó');
    });

    test('bỏ chọn hết thì Đợt mới trống', () async {
      final p = await projects.create(name: 'Dạy Huy');
      final second = await reviews.create(projectId: p.id, date: DateTime(2026, 8, 7));
      await reviews.carryForward(targetReviewId: second.id, items: const []);
      expect(await reviews.getItems(second.id), isEmpty);
    });

    test('sửa Hành động không làm đổi Mục đánh giá — AD-15', () async {
      final actions = DriftActionRepository(db, clock: clock);
      final p = await projects.create(name: 'Dạy Huy');
      final a = await actions.create(projectId: p.id, title: 'Ngủ sớm trước 11 giờ');
      final r = await reviews.create(projectId: p.id, date: DateTime(2026, 8, 7));
      await reviews.addItem(
        reviewId: r.id,
        label: 'Ngủ sớm trước 11 giờ',
        verdict: ReviewVerdict.met,
        sourceActionId: a.id,
      );

      await actions.update(a.copyWith(title: 'Ngủ sớm trước 10 giờ'));

      expect((await reviews.getItems(r.id)).single.label, 'Ngủ sớm trước 11 giờ');
    });
  });

  group('Story 7.5 — nhắc đến hạn đánh giá (FR-40)', () {
    test('chỉ Đợt gần nhất được xét', () async {
      final p = await projects.create(name: 'Dạy Huy');
      // Đợt cũ đã quá hạn xem lại, nhưng Đợt gần nhất thì chưa.
      final list = [
        await reviews.create(
            projectId: p.id,
            date: DateTime(2026, 1, 1),
            nextReviewDate: DateTime(2026, 1, 15)),
        await reviews.create(
            projectId: p.id,
            date: DateTime(2026, 8, 7),
            nextReviewDate: DateTime(2026, 11, 7)),
      ];
      expect(
        isReviewDue(
            status: ProjectStatus.active, reviews: list, now: DateTime(2026, 8, 28)),
        isFalse,
      );
    });

    test('Đợt gần nhất quá hạn thì nhắc', () async {
      final p = await projects.create(name: 'Dạy Huy');
      final list = [
        await reviews.create(
            projectId: p.id,
            date: DateTime(2026, 5, 15),
            nextReviewDate: DateTime(2026, 8, 7)),
      ];
      expect(
        isReviewDue(
            status: ProjectStatus.active, reviews: list, now: DateTime(2026, 8, 28)),
        isTrue,
      );
    });

    test('Dự án Xong và Bỏ không bao giờ nhắc', () async {
      final p = await projects.create(name: 'Dạy Huy');
      final list = [
        await reviews.create(
            projectId: p.id,
            date: DateTime(2026, 5, 15),
            nextReviewDate: DateTime(2026, 8, 7)),
      ];
      for (final s in [ProjectStatus.done, ProjectStatus.dropped]) {
        expect(isReviewDue(status: s, reviews: list, now: DateTime(2026, 8, 28)),
            isFalse,
            reason: s.wire);
      }
    });

    test('không có ngày xem lại thì không nhắc', () async {
      final p = await projects.create(name: 'Dạy Huy');
      final list = [
        await reviews.create(projectId: p.id, date: DateTime(2026, 5, 15))
      ];
      expect(
        isReviewDue(
            status: ProjectStatus.active, reviews: list, now: DateTime(2026, 8, 28)),
        isFalse,
      );
    });
  });

  group('Story 7.6 — hai đợt đánh giá thật của Dạy Huy', () {
    test('nạp đúng hai Đợt với kết quả khớp file gốc', () async {
      await seeder.applyProjectSeed();
      final huy = (await db.select(db.projects).get())
          .firstWhere((p) => p.name == 'Dạy Huy');

      final list = await reviews.watchByProject(huy.id).first;
      expect(list.length, 2);

      // Đợt gần nhất lên đầu.
      final august = list.first;
      final may = list.last;
      expect(august.review.date.toLocal().month, 8);
      expect(may.review.date.toLocal().month, 5);

      expect(may.itemCount, 5);
      expect(may.metCount, 2, reason: 'file gốc: 2 đạt, 3 chưa đạt');

      expect(august.itemCount, 5);
      expect(august.metCount, 3, reason: 'file gốc: 3 đạt, 2 chưa đạt');
    });

    test('Dạy Huy có 11 hành động và 2 ghi chú', () async {
      await seeder.applyProjectSeed();
      final huy = (await db.select(db.projects).get())
          .firstWhere((p) => p.name == 'Dạy Huy');
      final actions = await (db.select(db.actions)
            ..where((a) => a.projectId.equals(huy.id)))
          .get();
      final notes = await (db.select(db.notes)
            ..where((n) => n.projectId.equals(huy.id)))
          .get();
      expect(actions.length, 11);
      expect(notes.length, 2);
    });

    test('chạy lại bộ hạt giống không nhân đôi Đợt đánh giá', () async {
      await seeder.applyProjectSeed();
      await seeder.applyProjectSeed();
      expect((await db.select(db.reviews).get()).length, 2);
      expect((await db.select(db.reviewItems).get()).length, 10);
    });

    test('xoá Dự án xoá theo Đợt đánh giá và Mục', () async {
      await seeder.applyProjectSeed();
      final huy = (await db.select(db.projects).get())
          .firstWhere((p) => p.name == 'Dạy Huy');
      await projects.delete(huy.id);
      expect(await db.select(db.reviews).get(), isEmpty);
      expect(await db.select(db.reviewItems).get(), isEmpty);
    });
  });
}
