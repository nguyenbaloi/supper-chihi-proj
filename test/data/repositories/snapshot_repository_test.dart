import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/asset_class_repository_impl.dart';
import 'package:personal_finance/data/repositories/cash_flow_repository_impl.dart';
import 'package:personal_finance/data/repositories/debt_repository_impl.dart';
import 'package:personal_finance/data/repositories/fx_rate_repository_impl.dart';
import 'package:personal_finance/data/repositories/holding_repository_impl.dart';
import 'package:personal_finance/data/repositories/portfolio_repository_impl.dart';
import 'package:personal_finance/data/repositories/price_quote_repository_impl.dart';
import 'package:personal_finance/data/repositories/settings_repository_impl.dart';
import 'package:personal_finance/data/repositories/snapshot_repository_impl.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/repositories/asset_class_repository.dart';
import 'package:personal_finance/domain/repositories/cash_flow_repository.dart';
import 'package:personal_finance/domain/repositories/holding_repository.dart';
import 'package:personal_finance/domain/repositories/settings_repository.dart';

Money _m(int millions) => Money(millions * 1000000);

void main() {
  late AppDatabase db;
  late AssetClassRepository classes;
  late HoldingRepository holdings;
  late CashFlowRepository cashFlows;
  late SettingsRepository settings;
  late SnapshotRepositoryImpl snapshots;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    classes = AssetClassRepositoryImpl(db);
    holdings = HoldingRepositoryImpl(db);
    cashFlows = CashFlowRepositoryImpl(db);
    settings = SettingsRepositoryImpl(db);
    final prices = PriceQuoteRepositoryImpl(db);
    final portfolio = PortfolioRepositoryImpl(
      db: db,
      assetClasses: classes,
      holdings: holdings,
      prices: prices,
      debts: DebtRepositoryImpl(db),
      fxRates: FxRateRepositoryImpl(db, settings),
    );
    snapshots = SnapshotRepositoryImpl(
      db: db,
      portfolio: portfolio,
      cashFlows: cashFlows,
      settings: settings,
    );

    await settings.initialize(
      initialContributionAmount: _m(341),
      startDate: DateTime.utc(2026, 1, 1),
    );
  });
  tearDown(() => db.close());

  Future<int> idOf(AssetKind kind) async =>
      (await classes.all()).firstWhere((c) => c.kind == kind).id;

  Future<void> addCash(int millions) async {
    await holdings.add(
      assetClassId: await idOf(AssetKind.cashSavings),
      symbol: 'TK\$millions',
      manualValueAmount: _m(millions),
    );
  }

  group('Cấu trúc bản chốt', () {
    test('không có cột vốn góp lũy kế và cột lãi lỗ', () async {
      // Hai con số đó tính lại từ chuỗi Dòng vốn mỗi lần đọc. Xem AD-12.
      await snapshots.all();
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('snapshots')")
          .get();
      final names = columns.map((r) => r.data['name'] as String);

      expect(names, isNot(contains('cumulative_contribution_amount')));
      expect(names, isNot(contains('profit_loss_amount')));
    });

    test('chi tiết không tham chiếu tới khoản nắm giữ', () async {
      await snapshots.all();
      final columns = await db
          .customSelect(
            "SELECT name FROM pragma_table_info('snapshot_details')",
          )
          .get();
      final names = columns.map((r) => r.data['name'] as String);

      expect(names, isNot(contains('holding_id')));
      expect(names, contains('value_amount'));
      expect(names, contains('asset_class_name'));
    });

    test('mỗi lớp tài sản có một dòng chi tiết', () async {
      await addCash(92);
      final snapshot = await snapshots.captureManual(DateTime.utc(2026, 3, 1));

      expect(snapshot.details, hasLength(5));
      expect(
        snapshot.details.map((d) => d.assetClassName),
        contains('Tiền mặt & Tiết kiệm'),
      );
    });
  });

  group('Bản chốt là ảnh chụp bất biến', () {
    test('xóa khoản nắm giữ ở hiện tại không đụng bản chốt cũ', () async {
      await addCash(92);
      final snapshot = await snapshots.captureManual(DateTime.utc(2026, 3, 1));
      expect(snapshot.totalAssetsAmount, _m(92));

      await db.delete(db.holdingsTable).go();

      final reread = await snapshots.byId(snapshot.id);
      expect(reread!.totalAssetsAmount, _m(92));
      expect(
        reread.details.firstWhere((d) => d.valueAmount == _m(92)).valueAmount,
        _m(92),
      );
    });

    test('đổi tên lớp tài sản không làm biến dạng lịch sử', () async {
      await addCash(92);
      final snapshot = await snapshots.captureManual(DateTime.utc(2026, 3, 1));

      await classes.rename(await idOf(AssetKind.cashSavings), 'Tiền gửi');

      final reread = await snapshots.byId(snapshot.id);
      expect(
        reread!.details.map((d) => d.assetClassName),
        contains('Tiền mặt & Tiết kiệm'),
      );
    });

    test('sửa dòng vốn trước ngày chốt thì lãi lỗ của bản chốt tính lại',
        () async {
      // Ngoại lệ có chủ đích của tính bất biến: sửa Dòng vốn chính là sửa
      // lịch sử. Xem AD-12.
      await holdings.add(
        assetClassId: await idOf(AssetKind.stock),
        symbol: 'FPT',
        quantityText: '100',
      );
      await PriceQuoteRepositoryImpl(db).saveManualPrice(
        symbol: 'FPT',
        price: const Money(3410000),
      );
      final flow = await cashFlows.add(
        date: DateTime.utc(2026, 2, 1),
        amount: _m(-60),
      );
      await snapshots.captureManual(DateTime.utc(2026, 3, 1));

      var series = await snapshots.series();
      expect(series.single.cumulativeContribution, _m(281));

      await cashFlows.update(flow.id, amount: _m(-50));

      series = await snapshots.series();
      expect(series.single.cumulativeContribution, _m(291));
      // Giá trị tài sản đã ghi vẫn nguyên, chỉ lãi lỗ đổi theo.
      expect(series.single.totalAssets, _m(341));
      expect(series.single.profitLoss, _m(50));
    });
  });

  group('Bản chốt tự động', () {
    test('mở lần đầu trong ngày thì sinh một bản', () async {
      await addCash(92);
      final created = await snapshots.captureAutomatic(DateTime.utc(2026, 3, 1));

      expect(created, isNotNull);
      expect(created!.kind, SnapshotKind.auto);
      expect(created.totalAssetsAmount, _m(92));
    });

    test('mở lại trong cùng ngày thì không sinh thêm', () async {
      await addCash(92);
      await snapshots.captureAutomatic(DateTime.utc(2026, 3, 1, 8));

      final second =
          await snapshots.captureAutomatic(DateTime.utc(2026, 3, 1, 20));

      expect(second, isNull);
      expect(await snapshots.all(), hasLength(1));
    });

    test('nghỉ ba ngày rồi mở lại chỉ sinh cho ngày thứ tư', () async {
      await addCash(92);
      await snapshots.captureAutomatic(DateTime.utc(2026, 3, 1));

      await snapshots.captureAutomatic(DateTime.utc(2026, 3, 5));

      final all = await snapshots.all();
      // Không nội suy ba ngày trống — lấp bằng giá trị giả là bịa lịch sử.
      expect(all, hasLength(2));
      expect(all.map((s) => s.date), [
        DateTime.utc(2026, 3, 1),
        DateTime.utc(2026, 3, 5),
      ]);
    });

    test('bản chốt tự động không xóa được', () async {
      await addCash(92);
      final auto = await snapshots.captureAutomatic(DateTime.utc(2026, 3, 1));

      expect(await snapshots.removeManual(auto!.id), isFalse);
      expect(await snapshots.all(), hasLength(1));
    });
  });

  group('Chốt sổ thủ công', () {
    test('lưu kèm ghi chú và phân biệt được với bản tự động', () async {
      await addCash(92);
      await snapshots.captureAutomatic(DateTime.utc(2026, 3, 1));
      final manual = await snapshots.captureManual(
        DateTime.utc(2026, 3, 2),
        note: 'bán bớt BTC',
      );

      expect(manual.kind, SnapshotKind.manual);
      expect(manual.note, 'bán bớt BTC');
      expect(manual.isAutomatic, isFalse);

      final all = await snapshots.all();
      expect(all.where((s) => s.isAutomatic), hasLength(1));
    });

    test('xóa được bản chốt thủ công', () async {
      await addCash(92);
      final manual = await snapshots.captureManual(DateTime.utc(2026, 3, 2));

      expect(await snapshots.removeManual(manual.id), isTrue);
      expect(await snapshots.all(), isEmpty);
    });

    test('xóa bản chốt kéo theo chi tiết của nó', () async {
      await addCash(92);
      final manual = await snapshots.captureManual(DateTime.utc(2026, 3, 2));
      await snapshots.removeManual(manual.id);

      expect(await db.select(db.snapshotDetailsTable).get(), isEmpty);
    });
  });
}
