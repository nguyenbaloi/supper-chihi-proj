import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/cash_flow_repository_impl.dart';
import 'package:personal_finance/domain/repositories/cash_flow_repository.dart';
import 'package:personal_finance/domain/rules/contribution.dart';

Money _m(int millions) => Money(millions * 1000000);

void main() {
  late AppDatabase db;
  late CashFlowRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CashFlowRepositoryImpl(db);
  });
  tearDown(() => db.close());

  group('Sổ dòng vốn', () {
    test('thêm được dòng nạp và dòng rút', () async {
      await repo.add(date: DateTime.utc(2026, 1, 6), amount: _m(-60));
      await repo.add(date: DateTime.utc(2026, 1, 8), amount: _m(9));

      final flows = await repo.all();
      expect(flows.map((f) => f.amount), [_m(-60), _m(9)]);
      expect(flows.first.isWithdrawal, isTrue);
      expect(flows.last.isDeposit, isTrue);
    });

    test('ngày được cắt về đầu ngày UTC', () async {
      // Một dòng ghi lúc 23 giờ và một mốc đọc lúc 8 giờ sáng cùng ngày phải
      // nằm cùng một ngày.
      final flow = await repo.add(
        date: DateTime.utc(2026, 1, 6, 23, 45),
        amount: _m(10),
      );
      expect(flow.date, DateTime.utc(2026, 1, 6));
      expect(flow.date.isUtc, isTrue);
    });

    test('sắp theo ngày tăng dần, id phá thế hoà', () async {
      await repo.add(date: DateTime.utc(2026, 1, 8), amount: _m(1));
      await repo.add(date: DateTime.utc(2026, 1, 6), amount: _m(2));
      await repo.add(date: DateTime.utc(2026, 1, 6), amount: _m(3));

      final flows = await repo.all();
      expect(flows.map((f) => f.amount), [_m(2), _m(3), _m(1)]);
    });

    test('bảng không có cột chia theo lớp tài sản', () async {
      // Người dùng nghĩ về việc bỏ tiền vào đầu tư như một hành động duy
      // nhất, không phân biệt bỏ vào lớp nào. Xem FR-22.
      await repo.all();
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('cash_flows')")
          .get();
      final names = columns.map((r) => r.data['name'] as String).toList();

      expect(names, isNot(contains('asset_class_id')));
      expect(names, isNot(contains('asset_class')));
    });

    test('không bảng nào có cột vốn góp lũy kế', () async {
      // AD-4: lũy kế luôn là giá trị tính toán.
      await repo.all();
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name NOT LIKE 'sqlite_%'",
          )
          .get();

      for (final t in tables) {
        final name = t.data['name'] as String;
        final cols = await db
            .customSelect("SELECT name FROM pragma_table_info('$name')")
            .get();
        final colNames = cols.map((r) => r.data['name'] as String);
        expect(colNames, isNot(contains('cumulative_contribution')),
            reason: 'bảng $name không được có cột vốn góp lũy kế');
        expect(colNames, isNot(contains('cumulative_amount')),
            reason: 'bảng $name không được có cột vốn góp lũy kế');
      }
    });

    test('vốn góp khởi điểm nằm ở bảng thiết lập một dòng duy nhất', () async {
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('settings')")
          .get();
      expect(
        columns.map((r) => r.data['name']),
        contains('initial_contribution_amount'),
      );
    });
  });

  group('Sửa và xóa dòng vốn', () {
    test('sửa được dòng cũ nhất', () async {
      final first = await repo.add(
        date: DateTime.utc(2026, 1, 6),
        amount: _m(-60),
      );
      await repo.add(date: DateTime.utc(2026, 1, 7), amount: _m(-36));

      await repo.update(first.id, amount: _m(-50));

      expect((await repo.byId(first.id))!.amount, _m(-50));
      expect(
        Contribution.total(
          initialContribution: _m(341),
          cashFlows: await repo.all(),
        ),
        _m(255),
      );
    });

    test('đổi ngày làm chuỗi sắp lại đúng thứ tự mới', () async {
      final a = await repo.add(date: DateTime.utc(2026, 1, 6), amount: _m(-60));
      await repo.add(date: DateTime.utc(2026, 1, 8), amount: _m(9));

      await repo.update(a.id, date: DateTime.utc(2026, 1, 10));

      expect((await repo.all()).map((f) => f.amount), [_m(9), _m(-60)]);
    });

    test('sửa ghi chú không đụng số tiền và ngày', () async {
      final flow = await repo.add(
        date: DateTime.utc(2026, 1, 6),
        amount: _m(-60),
        note: 'rút mua nhà',
      );
      await repo.update(flow.id, note: 'rút mua xe');

      final updated = (await repo.byId(flow.id))!;
      expect(updated.note, 'rút mua xe');
      expect(updated.amount, _m(-60));
      expect(updated.date, DateTime.utc(2026, 1, 6));
    });

    test('xóa xong thì chuỗi giống như dòng đó chưa từng tồn tại', () async {
      final a = await repo.add(date: DateTime.utc(2026, 1, 6), amount: _m(-60));
      await repo.add(date: DateTime.utc(2026, 1, 8), amount: _m(9));

      expect(await repo.remove(a.id), isTrue);

      expect(
        Contribution.total(
          initialContribution: _m(341),
          cashFlows: await repo.all(),
        ),
        _m(350),
      );
    });

    test('sửa dòng không tồn tại trả về null', () async {
      expect(await repo.update(999, amount: _m(1)), isNull);
      expect(await repo.remove(999), isFalse);
    });
  });
}
