import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/action_note_repository_impl.dart';
import 'package:personal_finance/data/repositories/asset_class_repository_impl.dart';
import 'package:personal_finance/data/repositories/target_repository_impl.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/repositories/action_note_repository.dart';
import 'package:personal_finance/domain/repositories/asset_class_repository.dart';
import 'package:personal_finance/domain/repositories/target_repository.dart';
import 'package:personal_finance/domain/rules/rebalancing.dart';

void main() {
  late AppDatabase db;
  late ActionNoteRepository notes;
  late TargetRepository targets;
  late AssetClassRepository classes;

  var clock = DateTime.utc(2026, 8, 27, 10);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    notes = ActionNoteRepositoryImpl(db, now: () => clock);
    targets = TargetRepositoryImpl(db);
    classes = AssetClassRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<int> idOf(AssetKind kind) async =>
      (await classes.all()).firstWhere((c) => c.kind == kind).id;

  group('Ghi chú kế hoạch', () {
    test('thêm, sửa và xóa', () async {
      final note = await notes.add('  Mua thêm vàng  ');
      expect(note.body, 'Mua thêm vàng');

      await notes.updateBody(note.id, 'Mua thêm vàng và chứng khoán');
      expect((await notes.all()).single.body, 'Mua thêm vàng và chứng khoán');

      expect(await notes.remove(note.id), isTrue);
      expect(await notes.all(), isEmpty);
    });

    test('ghi chú rỗng bị từ chối', () async {
      expect(() => notes.add('   '), throwsArgumentError);
    });

    test('đánh dấu hoàn thành lưu kèm thời điểm', () async {
      final note = await notes.add('Mua thêm vàng');
      final done = await notes.setCompleted(note.id, completed: true);

      expect(done!.isCompleted, isTrue);
      expect(done.completedAt, clock);

      final undone = await notes.setCompleted(note.id, completed: false);
      expect(undone!.isCompleted, isFalse);
      expect(undone.completedAt, isNull);
    });

    test('sắp theo ngày tạo, mới nhất lên trên', () async {
      clock = DateTime.utc(2026, 8, 25);
      await notes.add('cũ');
      clock = DateTime.utc(2026, 8, 27);
      await notes.add('mới');

      expect((await notes.all()).map((n) => n.body), ['mới', 'cũ']);
    });
  });

  group('Tỷ trọng mục tiêu', () {
    test('đặt và sửa mục tiêu cho một lớp', () async {
      final cryptoId = await idOf(AssetKind.crypto);
      await targets.setClassTarget(cryptoId, 5000);
      expect((await classes.byId(cryptoId))!.targetWeightBp, 5000);

      await targets.setClassTarget(cryptoId, 4000);
      expect((await classes.byId(cryptoId))!.targetWeightBp, 4000);

      await targets.setClassTarget(cryptoId, null);
      expect((await classes.byId(cryptoId))!.targetWeightBp, isNull);
    });

    test('gộp hai lớp vào một nhóm mục tiêu chung', () async {
      // "Vàng và Chứng khoán chung 20%". Xem FR-19.
      final group = await targets.addGroup(
        name: 'Vàng & Chứng khoán',
        targetWeightBp: 2000,
      );
      await targets.setClassGroup(await idOf(AssetKind.gold), group.id);
      await targets.setClassGroup(await idOf(AssetKind.stock), group.id);

      final grouped = (await classes.all())
          .where((c) => c.targetGroupId == group.id)
          .map((c) => c.kind)
          .toSet();
      expect(grouped, {AssetKind.gold, AssetKind.stock});
      expect(group.targetWeightBp, 2000);
    });

    test('ba mục tiêu 50 + 30 + 20 cho đủ 100%', () async {
      await targets.addGroup(name: 'BTC', targetWeightBp: 5000);
      await targets.addGroup(name: 'Tiền mặt & Cho vay', targetWeightBp: 3000);
      await targets.addGroup(name: 'Vàng & Chứng khoán', targetWeightBp: 2000);

      final groups = await targets.groups();
      expect(
        Rebalancing.isBalanced(groups.map((g) => g.targetWeightBp)),
        isTrue,
      );
    });

    test('xóa nhóm thì lớp bên trong tách ra chứ không bị xóa theo', () async {
      final group = await targets.addGroup(name: 'Nhóm', targetWeightBp: 2000);
      final goldId = await idOf(AssetKind.gold);
      await targets.setClassGroup(goldId, group.id);

      await targets.removeGroup(group.id);

      expect((await classes.byId(goldId)), isNotNull);
      expect((await classes.byId(goldId))!.targetGroupId, isNull);
    });
  });

  group('Cấu hình nhóm đầu tư', () {
    test('mặc định đúng hai lớp Chứng khoán và Crypto', () async {
      final inGroup = (await classes.all())
          .where((c) => c.inInvestmentGroup)
          .map((c) => c.kind)
          .toSet();
      expect(inGroup, {AssetKind.stock, AssetKind.crypto});
    });

    test('đổi cấu hình thay thế toàn bộ tập cũ', () async {
      final goldId = await idOf(AssetKind.gold);
      await targets.setInvestmentGroup({goldId});

      final inGroup = (await classes.all())
          .where((c) => c.inInvestmentGroup)
          .map((c) => c.kind)
          .toSet();
      expect(inGroup, {AssetKind.gold});
    });

    test('đặt tập rỗng thì không lớp nào tham gia', () async {
      await targets.setInvestmentGroup(const {});
      expect(
        (await classes.all()).where((c) => c.inInvestmentGroup),
        isEmpty,
      );
    });
  });
}
