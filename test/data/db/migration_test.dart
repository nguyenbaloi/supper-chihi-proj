import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:personal_finance/domain/models/enums.dart';

import 'generated/schema.dart';

/// Bảo vệ dữ liệu người dùng khi cấu trúc cơ sở dữ liệu thay đổi.
///
/// Ứng dụng không có bản sao lưu trên máy chủ. Người dùng cập nhật phiên bản
/// rồi mất toàn bộ lịch sử là thảm hoạ không sửa được. Xem AD-10.
///
/// Khi tăng `schemaVersion` lên 2, quy trình bắt buộc là:
///   1. `fvm dart run build_runner build`
///   2. `fvm dart run drift_dev schema dump lib/data/db/database.dart drift_schemas/`
///   3. `fvm dart run drift_dev schema generate drift_schemas/ test/data/db/generated/`
///   4. Thêm bước nâng cấp vào `MigrationStrategy.onUpgrade`
///   5. Nhân bản test dữ liệu nguyên vẹn ở dưới cho cặp phiên bản mới
///
/// `drift_schemas/` và `test/data/db/generated/` phải được commit. Đó là bản
/// ghi duy nhất về hình dạng schema các phiên bản đã phát hành — mất chúng là
/// mất luôn khả năng viết migration đúng cho máy người dùng đang chạy bản cũ.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('Cấu trúc cơ sở dữ liệu', () {
    test('schema thực tế khớp đúng ảnh chụp phiên bản 1', () async {
      // Bắt lệch giữa định nghĩa bảng trong mã nguồn và ảnh chụp đã lưu ở
      // drift_schemas/. Lệch ở đây nghĩa là ai đó đổi cấu trúc mà quên cập
      // nhật ảnh chụp — và bài test migration sau này sẽ chạy trên schema sai.
      final connection = await verifier.startAt(1);
      final db = AppDatabase(connection);
      addTearDown(db.close);

      await verifier.migrateAndValidate(db, 1);
    });

    test('phiên bản schema hiện tại là 3', () {
      expect(GeneratedHelper.versions.last, 3);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      expect(db.schemaVersion, GeneratedHelper.versions.last);
    });

    test('schema thực tế khớp đúng ảnh chụp phiên bản 2', () async {
      final connection = await verifier.startAt(2);
      final db = AppDatabase(connection);
      addTearDown(db.close);

      await verifier.migrateAndValidate(db, 2);
    });
  });

  group('Dữ liệu sống sót qua vòng đời cơ sở dữ liệu', () {
    test('đóng hẳn rồi mở lại tệp vẫn còn nguyên từng đồng', () async {
      // Phải đi qua một tệp thật: giữ nguyên một QueryExecutor trong bộ nhớ
      // rồi đọc lại chỉ chứng minh được là biến còn đó, không chứng minh được
      // gì về việc dữ liệu có thực sự nằm trên ổ đĩa hay không.
      final dir = await Directory.systemTemp.createTemp('personal_finance_db');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/personal_finance.sqlite');

      final first = AppDatabase(NativeDatabase(file));
      await first.into(first.settingsTable).insert(
            SettingsTableCompanion.insert(
              initialContributionAmount: const Money(333000000),
              startDate: DateTime.utc(2026, 8, 27),
            ),
          );
      final classId = await first.into(first.assetClassesTable).insert(
            AssetClassesTableCompanion.insert(
              name: 'Crypto',
              kind: AssetKind.crypto,
              colorValue: 0xFF1565C0,
              iconCodePoint: 0xe0af,
            ),
          );
      await first.into(first.holdingsTable).insert(
            HoldingsTableCompanion.insert(
              assetClassId: classId,
              symbol: 'BTC',
              inputMode: InputMode.quantity,
              currency: Currency.usd,
              updatedAt: DateTime.utc(2026, 8, 27),
              quantityRaw: const Value(12345678),
              decimals: const Value(8),
            ),
          );
      await first.close();

      expect(file.existsSync(), isTrue, reason: 'tệp cơ sở dữ liệu chưa được tạo');

      final second = AppDatabase(NativeDatabase(file));
      addTearDown(second.close);

      final settings = await second.select(second.settingsTable).getSingle();
      final holding = await second.select(second.holdingsTable).getSingle();

      expect(settings.initialContributionAmount, const Money(333000000));
      expect(settings.startDate, DateTime.utc(2026, 8, 27));
      expect(holding.quantityRaw, 12345678);
      expect(holding.decimals, 8);

      final userVersion =
          await second.customSelect('PRAGMA user_version').getSingle();
      expect(userVersion.data.values.first, second.schemaVersion);
    });

    test('dữ liệu ghi ở schema v1 còn nguyên sau khi nâng lên bản mới nhất', () async {
      // Đây là bài test thật sự bảo vệ dữ liệu người dùng: dựng cơ sở dữ liệu
      // ở phiên bản 1, ghi dữ liệu bằng SQL thô đúng như dữ liệu đang nằm trên
      // máy người dùng đã cài bản cũ, rồi nâng lên phiên bản 2 và kiểm chứng
      // từng con số còn nguyên.
      final connection = await verifier.startAt(1);
      final db = AppDatabase(connection);
      addTearDown(db.close);

      // Chuỗi ISO-8601 UTC, đúng định dạng drift ghi xuống cột TEXT.
      const startDate = '2026-08-27T00:00:00.000Z';
      await db.customStatement(
        'INSERT INTO settings (id, initial_contribution_amount, start_date, '
        'drift_threshold_bp, onboarding_completed) '
        "VALUES (1, 333000000, '$startDate', 500, 1)",
      );
      await db.customStatement(
        'INSERT INTO asset_classes (id, name, kind, in_investment_group, '
        'hidden, sort_order, color_value, icon_code_point) '
        "VALUES (1, 'Crypto', 'crypto', 1, 0, 0, ${0xFF1565C0}, ${0xe0af})",
      );
      await db.customStatement(
        'INSERT INTO holdings (id, asset_class_id, symbol, input_mode, '
        'quantity_raw, decimals, currency, updated_at) '
        "VALUES (1, 1, 'BTC', 'quantity', 12345678, 8, 'usd', "
        "'$startDate')",
      );

      await verifier.migrateAndValidate(db, 3);

      final settings = await db.select(db.settingsTable).getSingle();
      expect(settings.initialContributionAmount, const Money(333000000));
      expect(settings.startDate, DateTime.utc(2026, 8, 27));
      expect(settings.onboardingCompleted, isTrue);

      final holding = await db.select(db.holdingsTable).getSingle();
      expect(holding.symbol, 'BTC');
      expect(holding.quantityRaw, 12345678);
      expect(holding.decimals, 8);
      expect(holding.currency, Currency.usd);

      // Bảng mới của phiên bản 2 phải có mặt và dùng được ngay.
      expect(await db.select(db.priceQuotesTable).get(), isEmpty);
    });

    test('nâng từ v2 lên v3 giữ nguyên giá đã lưu trong bộ nhớ đệm', () async {
      final connection = await verifier.startAt(2);
      final db = AppDatabase(connection);
      addTearDown(db.close);

      await db.customStatement(
        'INSERT INTO price_quotes (symbol, source, price_amount, currency, '
        'fetched_at) '
        "VALUES ('BTC', 'manual', 6500000, 'usd', '2026-08-27T00:00:00.000Z')",
      );

      await verifier.migrateAndValidate(db, 3);

      final quote = await db.select(db.priceQuotesTable).getSingle();
      expect(quote.symbol, 'BTC');
      expect(quote.priceAmount, const Money(6500000));

      // Các bảng của phiên bản 3 phải dùng được ngay sau khi nâng.
      expect(await db.select(db.cashFlowsTable).get(), isEmpty);
      expect(await db.select(db.debtsTable).get(), isEmpty);
      expect(await db.select(db.snapshotsTable).get(), isEmpty);
      expect(await db.select(db.actionNotesTable).get(), isEmpty);

      // Cột thêm vào bảng cũ phải có mặt với giá trị mặc định.
      final settingsColumns = await db
          .customSelect("SELECT name FROM pragma_table_info('settings')")
          .get();
      expect(
        settingsColumns.map((r) => r.data['name']),
        contains('theme_mode'),
      );
    });

    test('nâng cấp không đụng tới số dòng của các bảng cũ', () async {
      final connection = await verifier.startAt(1);
      final db = AppDatabase(connection);
      addTearDown(db.close);

      await db.customStatement(
        'INSERT INTO asset_classes (id, name, kind, in_investment_group, '
        'hidden, sort_order, color_value, icon_code_point) '
        "VALUES (1, 'Crypto', 'crypto', 1, 0, 0, 1, 1), "
        "(2, 'Vàng', 'gold', 0, 0, 1, 2, 2)",
      );

      await verifier.migrateAndValidate(db, 3);

      // onCreate gieo năm lớp mặc định, nhưng đây là nâng cấp chứ không phải
      // tạo mới — hai lớp của người dùng phải còn đúng hai, không bị gieo đè.
      final classes = await db.select(db.assetClassesTable).get();
      expect(classes, hasLength(2));
      expect(classes.map((c) => c.name), ['Crypto', 'Vàng']);
    });
  });
}
