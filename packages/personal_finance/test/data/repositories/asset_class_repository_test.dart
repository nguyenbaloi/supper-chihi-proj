import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/asset_class_repository_impl.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/repositories/asset_class_repository.dart';

void main() {
  late AppDatabase db;
  late AssetClassRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = AssetClassRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<int> idOf(AssetKind kind) async =>
      (await repo.all()).firstWhere((c) => c.kind == kind).id;

  Future<void> addHolding(int assetClassId, String symbol) =>
      db.into(db.holdingsTable).insert(
            HoldingsTableCompanion.insert(
              assetClassId: assetClassId,
              symbol: symbol,
              inputMode: InputMode.quantity,
              currency: Currency.usd,
              updatedAt: DateTime.utc(2026, 8, 27),
              quantityRaw: const Value(12345678),
              decimals: const Value(8),
            ),
          );

  group('Cài đặt xong là dùng được ngay', () {
    test('mở lần đầu đã có sẵn đúng năm lớp, đúng thứ tự', () async {
      final classes = await repo.all();

      expect(
        classes.map((c) => c.name),
        ['Chứng khoán', 'Vàng', 'Crypto', 'Tiền mặt & Tiết kiệm', 'Cho vay'],
      );
      expect(classes.map((c) => c.kind).toSet(), AssetKind.values.toSet());
    });

    test('không lớp nào bị ẩn sẵn', () async {
      expect(await repo.visible(), hasLength(5));
    });

    test('nhóm đầu tư được gieo đúng hai lớp', () async {
      final inGroup = (await repo.all())
          .where((c) => c.inInvestmentGroup)
          .map((c) => c.kind)
          .toSet();
      expect(inGroup, {AssetKind.stock, AssetKind.crypto});
    });

    test('mỗi lớp mang màu và biểu tượng riêng', () async {
      final classes = await repo.all();
      expect(classes.map((c) => c.colorValue).toSet(), hasLength(5));
      expect(classes.map((c) => c.iconCodePoint).toSet(), hasLength(5));
    });

    test('gieo đúng một lần, mở lại không nhân đôi', () async {
      // onCreate chỉ chạy khi cơ sở dữ liệu ra đời. Nếu nó chạy lại ở lần mở
      // thứ hai thì người dùng sẽ thấy mười lớp tài sản.
      await repo.all();
      await db.close();

      db = AppDatabase(NativeDatabase.memory());
      repo = AssetClassRepositoryImpl(db);
      expect(await repo.all(), hasLength(5));
    });
  });

  group('Đổi tên', () {
    test('tên mới thay thế tên cũ ở mọi đường đọc', () async {
      final id = await idOf(AssetKind.stock);
      await repo.rename(id, 'Cổ phiếu');

      expect((await repo.byId(id))!.name, 'Cổ phiếu');
      expect((await repo.all()).first.name, 'Cổ phiếu');
    });

    test('khoảng trắng thừa hai đầu bị cắt', () async {
      final id = await idOf(AssetKind.gold);
      await repo.rename(id, '  Vàng miếng  ');
      expect((await repo.byId(id))!.name, 'Vàng miếng');
    });

    test('tên rỗng bị từ chối', () async {
      final id = await idOf(AssetKind.gold);
      expect(() => repo.rename(id, '   '), throwsArgumentError);
      expect((await repo.byId(id))!.name, 'Vàng');
    });

    test('đổi tên không đụng tới loại của lớp', () async {
      final id = await idOf(AssetKind.crypto);
      await repo.rename(id, 'Tiền mã hoá');
      expect((await repo.byId(id))!.kind, AssetKind.crypto);
    });
  });

  group('Ẩn lớp tài sản', () {
    test('lớp rỗng ẩn được và biến mất khỏi danh sách hiển thị', () async {
      final id = await idOf(AssetKind.lending);

      expect(await repo.hide(id), isA<AssetClassHidden>());

      final visible = await repo.visible();
      expect(visible, hasLength(4));
      expect(visible.map((c) => c.kind), isNot(contains(AssetKind.lending)));

      // Vẫn còn trong all() — ẩn không phải là xoá.
      expect(await repo.all(), hasLength(5));
      expect((await repo.byId(id))!.hidden, isTrue);
    });

    test('lớp đang chứa khoản nắm giữ thì từ chối, kèm số khoản', () async {
      final id = await idOf(AssetKind.crypto);
      await addHolding(id, 'BTC');
      await addHolding(id, 'ETH');

      final result = await repo.hide(id);

      expect(result, isA<AssetClassNotEmpty>());
      expect((result as AssetClassNotEmpty).holdingCount, 2);
      expect((await repo.byId(id))!.hidden, isFalse);
      expect(await repo.visible(), hasLength(5));
    });

    test('chỉ đếm khoản nắm giữ của đúng lớp đó', () async {
      final cryptoId = await idOf(AssetKind.crypto);
      final stockId = await idOf(AssetKind.stock);
      await addHolding(cryptoId, 'BTC');

      // Lớp Chứng khoán rỗng, không được lây số đếm từ lớp Crypto.
      expect(await repo.hide(stockId), isA<AssetClassHidden>());
    });

    test('ẩn lớp không tồn tại trả về không tìm thấy', () async {
      expect(await repo.hide(999), isA<AssetClassNotFound>());
    });

    test('bỏ ẩn thì lớp quay lại danh sách hiển thị', () async {
      final id = await idOf(AssetKind.gold);
      await repo.hide(id);
      await repo.unhide(id);

      expect(await repo.visible(), hasLength(5));
      expect((await repo.byId(id))!.hidden, isFalse);
    });

    test('xoá hết khoản nắm giữ rồi thì ẩn được', () async {
      final id = await idOf(AssetKind.crypto);
      await addHolding(id, 'BTC');
      expect(await repo.hide(id), isA<AssetClassNotEmpty>());

      await db.delete(db.holdingsTable).go();
      expect(await repo.hide(id), isA<AssetClassHidden>());
    });
  });

  group('Theo dõi thay đổi', () {
    test('đổi tên phát ra danh sách mới cho màn hình vẽ lại', () async {
      final id = await idOf(AssetKind.stock);
      final emissions = repo.watchAll();

      expect(
        emissions.map((list) => list.first.name),
        emitsInOrder(['Chứng khoán', 'Cổ phiếu']),
      );

      await repo.rename(id, 'Cổ phiếu');
    });
  });
}
