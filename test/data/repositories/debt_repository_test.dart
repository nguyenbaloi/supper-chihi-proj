import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/data/repositories/debt_repository_impl.dart';
import 'package:personal_finance/domain/repositories/debt_repository.dart';
import 'package:personal_finance/domain/rules/debt_math.dart';

Money _m(int millions) => Money(millions * 1000000);

void main() {
  late AppDatabase db;
  late DebtRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DebtRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<void> seedExcelDebts() async {
    for (final entry in [
      ('Anh Thắng', 63),
      ('Chị Hà', 30),
      ('Anh Dũng', 30),
      ('Cô Lan', 0),
      ('Anh Nam', 20),
      ('Ngân hàng', -10),
    ]) {
      await repo.add(
        personName: entry.$1,
        amount: _m(entry.$2),
        date: DateTime.utc(2026, 8, 27),
      );
    }
  }

  group('Quản lý khoản nợ', () {
    test('tổng khớp số liệu Excel gốc: 143, 10, ròng 133', () async {
      await seedExcelDebts();
      final totals = DebtMath.totals(await repo.active());

      expect(totals.lent, _m(143));
      expect(totals.borrowed, _m(10));
      expect(totals.net, _m(133));
    });

    test('người vay trả một phần thì sửa số tiền xuống mức còn lại', () async {
      // Không yêu cầu ghi lại lịch sử từng lần trả. Xem FR-32.
      final debt = await repo.add(
        personName: 'Anh Thắng',
        amount: _m(63),
        date: DateTime.utc(2026, 8, 27),
      );

      await repo.update(debt.id, amount: _m(30));

      expect(DebtMath.lendingClassValue(await repo.active()), _m(30));
    });

    test('tên rỗng bị từ chối', () async {
      expect(
        () => repo.add(
          personName: '  ',
          amount: _m(10),
          date: DateTime.utc(2026, 8, 27),
        ),
        throwsArgumentError,
      );
    });

    test('xóa được khoản nợ', () async {
      final debt = await repo.add(
        personName: 'Chị Hà',
        amount: _m(30),
        date: DateTime.utc(2026, 8, 27),
      );
      expect(await repo.remove(debt.id), isTrue);
      expect(await repo.all(), isEmpty);
    });
  });

  group('Tất toán', () {
    test('lưu kèm ngày và rời khỏi danh sách đang hiệu lực', () async {
      await seedExcelDebts();
      final thang = (await repo.active())
          .firstWhere((d) => d.personName == 'Anh Thắng');

      final settled = await repo.settle(thang.id, DateTime.utc(2026, 9, 1));

      expect(settled!.settledAt, DateTime.utc(2026, 9, 1));
      expect(settled.isSettled, isTrue);
      expect(await repo.active(), hasLength(5));
      expect(await repo.settled(), hasLength(1));
      // 133 giảm đúng 63.
      expect(DebtMath.lendingClassValue(await repo.active()), _m(70));
    });

    test('khoản đã tất toán vẫn tra cứu lại được', () async {
      await seedExcelDebts();
      final thang = (await repo.active())
          .firstWhere((d) => d.personName == 'Anh Thắng');
      await repo.settle(thang.id, DateTime.utc(2026, 9, 1));

      final history = await repo.settled();
      expect(history.single.personName, 'Anh Thắng');
      expect(history.single.amount, _m(63));
    });

    test('bỏ đánh dấu thì khoản quay lại và được cộng lại vào tổng', () async {
      await seedExcelDebts();
      final thang = (await repo.active())
          .firstWhere((d) => d.personName == 'Anh Thắng');
      await repo.settle(thang.id, DateTime.utc(2026, 9, 1));

      final reopened = await repo.unsettle(thang.id);

      expect(reopened!.settledAt, isNull);
      expect(await repo.active(), hasLength(6));
      expect(DebtMath.lendingClassValue(await repo.active()), _m(133));
    });

    test('tất toán khoản không tồn tại trả về null', () async {
      expect(await repo.settle(999, DateTime.utc(2026, 9, 1)), isNull);
      expect(await repo.unsettle(999), isNull);
    });
  });

  group('Ràng buộc kiến trúc', () {
    test('không có cột nào lưu sẵn tổng ròng của sổ nợ', () async {
      // AD-5: giá trị lớp Cho vay luôn suy ra từ Sổ nợ.
      await repo.all();
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('debts')")
          .get();
      final names = columns.map((r) => r.data['name'] as String);

      expect(names, isNot(contains('net_amount')));
      expect(names, isNot(contains('total_amount')));
    });
  });
}
