import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/core/money/quantity.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/domain/models/enums.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('Cơ sở dữ liệu', () {
    test('mở được ở phiên bản schema hiện hành', () async {
      // Con số cụ thể do test migration giữ, ở đó nó được đối chiếu với ảnh
      // chụp schema. Ở đây chỉ cần biết cơ sở dữ liệu mở lên được.
      expect(db.schemaVersion, greaterThan(0));
      // Chạm vào một bảng để buộc drift thực sự tạo schema.
      await db.select(db.assetClassesTable).get();
    });

    test('ràng buộc khoá ngoại được bật', () async {
      // Nếu quên PRAGMA này thì SQLite âm thầm bỏ qua mọi khoá ngoại, và một
      // Khoản nắm giữ có thể trỏ tới Lớp tài sản không tồn tại.
      await db.select(db.assetClassesTable).get();
      final rows = await db.customSelect('PRAGMA foreign_keys').get();
      expect(rows.first.data.values.first, 1);
    });
  });

  group('Lưu trữ tiền tệ không mất chính xác', () {
    test('vốn góp khởi điểm lưu rồi đọc lại đúng từng đồng', () async {
      await db.into(db.settingsTable).insert(
            SettingsTableCompanion.insert(
              initialContributionAmount: const Money(333000000),
              startDate: DateTime.utc(2026, 8, 27),
            ),
          );

      final row = await db.select(db.settingsTable).getSingle();
      expect(row.initialContributionAmount, const Money(333000000));
      expect(row.initialContributionAmount.amount, 333000000);
    });

    test('cột tiền tệ trong SQLite là kiểu số nguyên, không phải số thực',
        () async {
      await db.into(db.settingsTable).insert(
            SettingsTableCompanion.insert(
              initialContributionAmount: const Money(333000000),
              startDate: DateTime.utc(2026, 8, 27),
            ),
          );

      final rows = await db
          .customSelect(
            "SELECT typeof(initial_contribution_amount) AS t FROM settings",
          )
          .get();
      expect(rows.single.data['t'], 'integer');
    });
  });

  group('Lưu trữ số lượng không mất chữ số', () {
    Future<int> insertCryptoClass() => db.into(db.assetClassesTable).insert(
          AssetClassesTableCompanion.insert(
            name: 'Crypto',
            kind: AssetKind.crypto,
            colorValue: 0xFF1565C0,
            iconCodePoint: 0xe0af,
          ),
        );

    test('0,12345678 BTC lưu rồi đọc lại còn đủ 8 chữ số', () async {
      final classId = await insertCryptoClass();
      final q = Quantity.parse('0.12345678', 8);

      await db.into(db.holdingsTable).insert(
            HoldingsTableCompanion.insert(
              assetClassId: classId,
              symbol: 'BTC',
              inputMode: InputMode.quantity,
              currency: Currency.usd,
              updatedAt: DateTime.utc(2026, 8, 27),
              quantityRaw: Value(q.raw),
              decimals: const Value(8),
            ),
          );

      final row = await db.select(db.holdingsTable).getSingle();
      final readBack = Quantity(row.quantityRaw!, row.decimals);
      expect(readBack, q);
      expect(readBack.toPlainString(), '0.12345678');
    });

    test('một satoshi vẫn phân biệt được với 0 sau khi qua cơ sở dữ liệu',
        () async {
      final classId = await insertCryptoClass();
      await db.into(db.holdingsTable).insert(
            HoldingsTableCompanion.insert(
              assetClassId: classId,
              symbol: 'BTC',
              inputMode: InputMode.quantity,
              currency: Currency.usd,
              updatedAt: DateTime.utc(2026, 8, 27),
              quantityRaw: const Value(1),
              decimals: const Value(8),
            ),
          );

      final row = await db.select(db.holdingsTable).getSingle();
      expect(Quantity(row.quantityRaw!, row.decimals).isZero, isFalse);
    });

    test('không cho hai khoản trùng ký hiệu trong cùng một lớp', () async {
      final classId = await insertCryptoClass();
      Future<void> insertBtc() => db.into(db.holdingsTable).insert(
            HoldingsTableCompanion.insert(
              assetClassId: classId,
              symbol: 'BTC',
              inputMode: InputMode.quantity,
              currency: Currency.usd,
              updatedAt: DateTime.utc(2026, 8, 27),
              quantityRaw: const Value(1),
              decimals: const Value(8),
            ),
          );

      await insertBtc();
      expect(insertBtc, throwsA(isA<SqliteException>()));
    });

    test('khoản nắm giữ không trỏ được tới lớp tài sản không tồn tại',
        () async {
      expect(
        () => db.into(db.holdingsTable).insert(
              HoldingsTableCompanion.insert(
                assetClassId: 999,
                symbol: 'BTC',
                inputMode: InputMode.quantity,
                currency: Currency.usd,
                updatedAt: DateTime.utc(2026, 8, 27),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('Ngày tháng giữ nguyên UTC', () {
    Future<void> insertSettings(DateTime startDate) =>
        db.into(db.settingsTable).insert(
              SettingsTableCompanion.insert(
                initialContributionAmount: const Money(333000000),
                startDate: startDate,
              ),
            );

    test('lưu rồi đọc lại vẫn là UTC, không rơi về giờ địa phương', () async {
      // Kiểu số nguyên mặc định của drift giữ đúng thời điểm nhưng đánh mất
      // cờ UTC. Với người dùng ở múi giờ âm, `2026-08-27T00:00:00Z` đọc lên
      // thành ngày 26 — mà Bản chốt và Dòng vốn đều cắt về đầu ngày, nên chỗ
      // này quyết định số liệu rơi vào ngày nào.
      final startDate = DateTime.utc(2026, 8, 27);
      await insertSettings(startDate);

      final row = await db.select(db.settingsTable).getSingle();
      expect(row.startDate.isUtc, isTrue);
      expect(row.startDate, startDate);
      expect(row.startDate.day, 27);
    });

    test('cột ngày lưu dạng chuỗi ISO-8601 UTC', () async {
      await insertSettings(DateTime.utc(2026, 8, 27));

      final raw = await db
          .customSelect(
            'SELECT start_date, typeof(start_date) AS t FROM settings',
          )
          .getSingle();
      expect(raw.data['t'], 'text');
      expect(raw.data['start_date'], endsWith('Z'));
      expect(raw.data['start_date'], startsWith('2026-08-27T00:00:00'));
    });

    test('so sánh và sắp xếp theo ngày vẫn đúng trên cột chuỗi', () async {
      // Lý do chấp nhận được kiểu TEXT: chuỗi ISO-8601 UTC so sánh theo thứ
      // tự từ điển trùng khớp với so sánh thời gian, nên `WHERE date <= ?`
      // của công thức Vốn góp lũy kế vẫn chạy đúng. Xem AD-4.
      final classId = await db.into(db.assetClassesTable).insert(
            AssetClassesTableCompanion.insert(
              name: 'Crypto',
              kind: AssetKind.crypto,
              colorValue: 0xFF1565C0,
              iconCodePoint: 0xe0af,
            ),
          );
      final days = [
        DateTime.utc(2025, 12, 31),
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 8, 27),
        DateTime.utc(2026, 9, 3),
      ];
      for (var i = 0; i < days.length; i++) {
        await db.into(db.holdingsTable).insert(
              HoldingsTableCompanion.insert(
                assetClassId: classId,
                symbol: 'C$i',
                inputMode: InputMode.value,
                currency: Currency.vnd,
                updatedAt: days[i],
              ),
            );
      }

      final upTo = DateTime.utc(2026, 8, 27);
      final rows = await (db.select(db.holdingsTable)
            ..where((t) => t.updatedAt.isSmallerOrEqualValue(upTo))
            ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
          .get();

      expect(rows.map((r) => r.symbol), ['C0', 'C1', 'C2']);
      expect(rows.map((r) => r.updatedAt), days.take(3));
    });
  });

  group('Ràng buộc kiến trúc', () {
    test('không bảng nào có cột lưu giá trị tổng hợp', () async {
      // AD-5: giá trị Lớp tài sản luôn suy ra từ các Khoản nắm giữ, không bao
      // giờ lưu sẵn. Đây chính là lỗi cộng thủ công giữa hai sheet trong Excel.
      await db.select(db.assetClassesTable).get();
      final columns = await db.customSelect(
        "SELECT name FROM pragma_table_info('asset_classes')",
      ).get();
      final names = columns.map((r) => r.data['name'] as String).toList();
      expect(names, isNot(contains('total_value_amount')));
      expect(names, isNot(contains('value_amount')));
    });

    test('không bảng nào có cột portfolio_id', () async {
      // AD-9: một Danh mục duy nhất, vĩnh viễn.
      await db.select(db.assetClassesTable).get();
      final tables = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' "
        "AND name NOT LIKE 'sqlite_%'",
      ).get();

      for (final t in tables) {
        final name = t.data['name'] as String;
        final cols = await db
            .customSelect("SELECT name FROM pragma_table_info('$name')")
            .get();
        final colNames = cols.map((r) => r.data['name'] as String);
        expect(colNames, isNot(contains('portfolio_id')),
            reason: 'bảng $name không được có portfolio_id');
      }
    });
  });
}
