import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/asset_class_repository_impl.dart';
import 'package:personal_finance/data/repositories/holding_repository_impl.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/repositories/asset_class_repository.dart';
import 'package:personal_finance/domain/repositories/holding_repository.dart';

void main() {
  late AppDatabase db;
  late AssetClassRepository classes;
  late HoldingRepository holdings;

  final clock = DateTime.utc(2026, 8, 27, 10);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    classes = AssetClassRepositoryImpl(db);
    holdings = HoldingRepositoryImpl(db, now: () => clock);
  });
  tearDown(() => db.close());

  Future<int> idOf(AssetKind kind) async =>
      (await classes.all()).firstWhere((c) => c.kind == kind).id;

  group('Thêm khoản nắm giữ theo số lượng', () {
    test('BTC giữ đủ 8 chữ số thập phân', () async {
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
        quantityText: '0.12345678',
        currency: Currency.usd,
      );

      final holding = (result as HoldingSaved).holding;
      expect(holding.quantity!.decimals, 8);
      expect(holding.quantity!.toPlainString(), '0.12345678');
      expect(holding.inputMode, InputMode.quantity);
    });

    test('cổ phiếu chỉ nhận số nguyên', () async {
      final stockId = await idOf(AssetKind.stock);

      final ok = await holdings.add(
        assetClassId: stockId,
        symbol: 'FPT',
        quantityText: '100',
      );
      expect((ok as HoldingSaved).holding.quantity!.decimals, 0);

      final rejected = await holdings.add(
        assetClassId: stockId,
        symbol: 'HCM',
        quantityText: '10.5',
      );
      expect(rejected, isA<QuantityTooPrecise>());
      expect((rejected as QuantityTooPrecise).allowedDecimals, 0);
      expect(rejected.kind, AssetKind.stock);
    });

    test('vàng nhận tối đa hai chữ số thập phân', () async {
      final goldId = await idOf(AssetKind.gold);

      final ok = await holdings.add(
        assetClassId: goldId,
        symbol: 'SJC',
        quantityText: '7.25',
      );
      expect((ok as HoldingSaved).holding.quantity!.toPlainString(), '7.25');

      final rejected = await holdings.add(
        assetClassId: goldId,
        symbol: 'PNJ',
        quantityText: '7.253',
      );
      expect(rejected, isA<QuantityTooPrecise>());
      expect((rejected as QuantityTooPrecise).allowedDecimals, 2);
    });

    test('từ chối thay vì lặng lẽ làm tròn', () async {
      // Làm tròn ở đây đổi đúng con số người dùng vừa gõ mà không báo gì.
      final rejected = await holdings.add(
        assetClassId: await idOf(AssetKind.stock),
        symbol: 'FPT',
        quantityText: '10.5',
      );
      expect(rejected, isA<QuantityTooPrecise>());
      expect(await holdings.all(), isEmpty);
    });

    test('chuỗi không đọc được thành số bị từ chối', () async {
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
        quantityText: 'một trăm',
      );
      expect(result, isA<InvalidQuantity>());
    });

    test('thiếu số lượng thì báo thiếu', () async {
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
      );
      expect(result, isA<MissingRequiredInput>());
      expect((result as MissingRequiredInput).inputMode, InputMode.quantity);
    });
  });

  group('Nhập số kiểu Việt Nam', () {
    test('0,16 BTC nhận được như 0.16 — lỗi người dùng báo', () async {
      // Ứng dụng hiển thị `0,12 BTC` nên người dùng gõ lại dấu phẩy, và bàn
      // phím số trên máy tiếng Việt cũng cho ra dấu phẩy.
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
        quantityText: '0,16',
      );

      final holding = (result as HoldingSaved).holding;
      expect(holding.quantity!.toPlainString(), '0.16');
    });

    test('dấu phẩy và dấu chấm cho cùng một kết quả', () async {
      final cryptoId = await idOf(AssetKind.crypto);
      final withComma = await holdings.add(
        assetClassId: cryptoId,
        symbol: 'BTC',
        quantityText: '0,12345678',
      );
      final withDot = await holdings.add(
        assetClassId: cryptoId,
        symbol: 'ETH',
        quantityText: '0.12345678',
      );

      expect(
        (withComma as HoldingSaved).holding.quantity,
        (withDot as HoldingSaved).holding.quantity,
      );
    });

    test('vàng 7,25 chỉ nhận được', () async {
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.gold),
        symbol: 'SJC',
        quantityText: '7,25',
      );
      expect((result as HoldingSaved).holding.quantity!.toPlainString(), '7.25');
    });

    test('cổ phiếu nhận ngăn nghìn kiểu Việt Nam', () async {
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.stock),
        symbol: 'FPT',
        quantityText: '10.000',
      );
      expect((result as HoldingSaved).holding.quantity!.toPlainString(), '10000');
    });

    test('cổ phiếu 10,5 bị từ chối kèm lý do cụ thể', () async {
      // Chấp nhận dấu phẩy không được kéo theo việc đoán bừa, và thông báo
      // phải nói rõ loại này chỉ nhận số nguyên.
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.stock),
        symbol: 'HCM',
        quantityText: '10,5',
      );
      expect(result, isA<QuantityTooPrecise>());
      expect((result as QuantityTooPrecise).allowedDecimals, 0);
      expect(await holdings.all(), isEmpty);
    });

    test('sửa số lượng cũng nhận dấu phẩy', () async {
      final added = await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
        quantityText: '0.12',
      );
      final id = (added as HoldingSaved).holding.id;

      await holdings.update(id, quantityText: '0,16');

      expect((await holdings.byId(id))!.quantity!.toPlainString(), '0.16');
    });
  });

  group('Thêm khoản nắm giữ theo giá trị', () {
    test('tiền mặt nhập thẳng số tiền, không hỏi số lượng', () async {
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.cashSavings),
        symbol: 'TK VCB',
        manualValueAmount: const Money(92000000),
      );

      final holding = (result as HoldingSaved).holding;
      expect(holding.inputMode, InputMode.value);
      expect(holding.manualValueAmount, const Money(92000000));
      expect(holding.quantity, isNull);
    });

    test('thiếu số tiền thì báo thiếu', () async {
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.cashSavings),
        symbol: 'TK VCB',
        quantityText: '100',
      );
      expect(result, isA<MissingRequiredInput>());
      expect((result as MissingRequiredInput).inputMode, InputMode.value);
    });
  });

  group('Ký hiệu', () {
    test('lớp đã có BTC thì thêm BTC nữa bị từ chối', () async {
      final cryptoId = await idOf(AssetKind.crypto);
      await holdings.add(
        assetClassId: cryptoId,
        symbol: 'BTC',
        quantityText: '0.1',
      );

      final again = await holdings.add(
        assetClassId: cryptoId,
        symbol: 'BTC',
        quantityText: '0.2',
      );

      expect(again, isA<DuplicateSymbol>());
      expect((again as DuplicateSymbol).symbol, 'BTC');
      expect(await holdings.byAssetClass(cryptoId), hasLength(1));
    });

    test('chữ thường va đúng vào ký hiệu đã có', () async {
      // Chỉ mục của SQLite phân biệt hoa thường; không chuẩn hoá thì cùng một
      // đồng coin nằm được hai dòng.
      final cryptoId = await idOf(AssetKind.crypto);
      await holdings.add(
        assetClassId: cryptoId,
        symbol: 'BTC',
        quantityText: '0.1',
      );

      final again = await holdings.add(
        assetClassId: cryptoId,
        symbol: '  btc ',
        quantityText: '0.2',
      );
      expect(again, isA<DuplicateSymbol>());
    });

    test('cùng ký hiệu ở hai lớp khác nhau thì được', () async {
      await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
        quantityText: '0.1',
      );
      final other = await holdings.add(
        assetClassId: await idOf(AssetKind.stock),
        symbol: 'BTC',
        quantityText: '10',
      );
      expect(other, isA<HoldingSaved>());
    });
  });

  group('Tiền tệ', () {
    test('khoản tính bằng USD được ghi là USD, không quy đổi lúc lưu', () async {
      // Tỷ giá thay đổi theo thời gian; quy đổi ở bước lưu là đóng băng một
      // tỷ giá cũ vào dữ liệu gốc.
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'ETH',
        quantityText: '2',
        currency: Currency.usd,
      );

      final holding = (result as HoldingSaved).holding;
      expect(holding.currency, Currency.usd);
      expect(holding.quantity!.toPlainString(), '2');
    });

    test('mặc định là VND', () async {
      final result = await holdings.add(
        assetClassId: await idOf(AssetKind.cashSavings),
        symbol: 'Tiền mặt',
        manualValueAmount: const Money(5000000),
      );
      expect((result as HoldingSaved).holding.currency, Currency.vnd);
    });
  });

  group('Sửa khoản nắm giữ', () {
    Future<int> addBtc(String quantity) async {
      final r = await holdings.add(
        assetClassId: await idOf(AssetKind.crypto),
        symbol: 'BTC',
        quantityText: quantity,
      );
      return (r as HoldingSaved).holding.id;
    }

    test('đổi số lượng từ 0,12 thành 0,13', () async {
      final id = await addBtc('0.12');

      final result = await holdings.update(id, quantityText: '0.13');

      expect((result as HoldingSaved).holding.quantity!.toPlainString(), '0.13');
      expect((await holdings.byId(id))!.quantity!.toPlainString(), '0.13');
    });

    test('sửa vẫn giữ nguyên độ chính xác của loại tài sản', () async {
      final id = await addBtc('0.12');
      await holdings.update(id, quantityText: '0.13');
      expect((await holdings.byId(id))!.quantity!.decimals, 8);
    });

    test('sửa sang số lượng quá mịn bị từ chối, dữ liệu cũ còn nguyên', () async {
      final stockId = await idOf(AssetKind.stock);
      final added = await holdings.add(
        assetClassId: stockId,
        symbol: 'FPT',
        quantityText: '100',
      );
      final id = (added as HoldingSaved).holding.id;

      final result = await holdings.update(id, quantityText: '100.5');

      expect(result, isA<QuantityTooPrecise>());
      expect((await holdings.byId(id))!.quantity!.toPlainString(), '100');
    });

    test('bỏ trống tham số nghĩa là giữ nguyên, không phải xoá', () async {
      final id = await addBtc('0.12');
      await holdings.update(id, displayName: 'Bitcoin');

      final holding = (await holdings.byId(id))!;
      expect(holding.displayName, 'Bitcoin');
      expect(holding.quantity!.toPlainString(), '0.12');
      expect(holding.symbol, 'BTC');
    });

    test('đổi ký hiệu trùng với khoản khác trong lớp bị từ chối', () async {
      final cryptoId = await idOf(AssetKind.crypto);
      await addBtc('0.12');
      final eth = await holdings.add(
        assetClassId: cryptoId,
        symbol: 'ETH',
        quantityText: '2',
      );
      final ethId = (eth as HoldingSaved).holding.id;

      final result = await holdings.update(ethId, symbol: 'BTC');
      expect(result, isA<DuplicateSymbol>());
      expect((await holdings.byId(ethId))!.symbol, 'ETH');
    });

    test('đổi ký hiệu thành chính nó thì không bị coi là trùng', () async {
      final id = await addBtc('0.12');
      expect(await holdings.update(id, symbol: 'btc'), isA<HoldingSaved>());
    });

    test('sửa khoản không tồn tại trả về không tìm thấy', () async {
      expect(await holdings.update(999, quantityText: '1'), isA<HoldingNotFound>());
    });
  });

  group('Xóa khoản nắm giữ', () {
    test('xóa xong thì không còn trong danh sách', () async {
      final cryptoId = await idOf(AssetKind.crypto);
      final added = await holdings.add(
        assetClassId: cryptoId,
        symbol: 'BTC',
        quantityText: '0.12',
      );
      final id = (added as HoldingSaved).holding.id;

      expect(await holdings.remove(id), isTrue);
      expect(await holdings.byAssetClass(cryptoId), isEmpty);
      expect(await holdings.byId(id), isNull);
    });

    test('xóa khoản không tồn tại trả về false', () async {
      expect(await holdings.remove(999), isFalse);
    });

    test('xóa lớp tài sản kéo theo khoản nắm giữ bên trong', () async {
      final cryptoId = await idOf(AssetKind.crypto);
      await holdings.add(
        assetClassId: cryptoId,
        symbol: 'BTC',
        quantityText: '0.12',
      );

      await db.delete(db.assetClassesTable).go();
      expect(await holdings.all(), isEmpty);
    });
  });
}
