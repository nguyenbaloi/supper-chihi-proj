import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/data/db/database.dart';
import 'package:personal_projects/data/repositories/drift_search_repository.dart';
import 'package:personal_projects/data/seed/seeder.dart';
import 'package:personal_projects/domain/repositories/repositories.dart';

void main() {
  late AppDatabase db;
  late DriftSearchRepository search;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    search = DriftSearchRepository(db);
    await Seeder(db, clock: () => DateTime.utc(2026, 8, 28)).applyProjectSeed();
  });

  tearDown(() => db.close());

  group('Story 4.2 — tìm kiếm toàn cục (FR-30)', () {
    test('gõ không dấu tìm ra tên có dấu', () async {
      final hits = await search.search('tai chinh');
      expect(hits.any((h) => h.title == 'Kế hoạch tài chính'), isTrue);
    });

    test('không phân biệt hoa thường', () async {
      final upper = await search.search('TAI CHINH');
      final lower = await search.search('tai chinh');
      expect(upper.length, lower.length);
    });

    test('quét đủ năm loại nội dung', () async {
      expect((await search.search('Kế hoạch tài chính')).any((h) => h.kind == SearchKind.project), isTrue);
      expect((await search.search('may rua bat')).any((h) => h.kind == SearchKind.action), isTrue);
      expect((await search.search('no tot')).any((h) => h.kind == SearchKind.note), isTrue);
      expect((await search.search('appbox')).any((h) => h.kind == SearchKind.link), isTrue);
      expect((await search.search('giao tiep mat')).any((h) => h.kind == SearchKind.review), isTrue);
    });

    test('kết quả ghi rõ thuộc Dự án nào', () async {
      final hit = (await search.search('may rua bat'))
          .firstWhere((h) => h.kind == SearchKind.action);
      expect(hit.projectName, 'Kế hoạch tài chính');
    });

    test('chuỗi rỗng không trả kết quả nào', () async {
      expect(await search.search('   '), isEmpty);
    });

    test('tìm được nội dung bên trong Mục đánh giá của Dạy Huy', () async {
      final hits = await search.search('cai bim');
      expect(hits.any((h) => h.projectName == 'Dạy Huy'), isTrue);
    });
  });
}
