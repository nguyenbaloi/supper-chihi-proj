import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/backup_file.dart';
import 'package:personal_finance/data/db/database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Sao lưu và khôi phục là đường duy nhất mang dữ liệu sang máy mới. Cả ba
/// cách hỏng ở đây đều hỏng **không báo lỗi**: bản sao thiếu giao dịch mới
/// nhất, tệp `-wal` cũ sống sót qua khôi phục, hoặc một tệp lạ được ghi đè
/// lên cơ sở dữ liệu thật.
void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('backup_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  /// Mở một cơ sở dữ liệu trên tệp, ở chế độ WAL như bản thật trên máy.
  AppDatabase openOnFile(File file) => AppDatabase(
        NativeDatabase(
          file,
          setup: (db) => db.execute('PRAGMA journal_mode = WAL'),
        ),
      );

  group('Tạo bản sao lưu', () {
    test('giữ được cả giao dịch vừa ghi, còn nằm trong WAL', () async {
      final source = File('${tmp.path}/$kDatabaseFileName');
      final db = openOnFile(source);
      await db.into(db.cashFlowsTable).insert(
            CashFlowsTableCompanion.insert(
              date: DateTime.utc(2026, 8, 28),
              amount: const Money(47000000),
            ),
          );

      final copy = await writeBackupCopy(
        db: db,
        source: source,
        target: File('${tmp.path}/ban-sao.sqlite'),
      );
      await db.close();

      // Không dồn WAL trước khi chép thì dòng vốn vừa ghi ở lại tệp `-wal`
      // bên cạnh và bản sao mở ra rỗng — mất đúng phần dữ liệu mới nhất.
      final restored = openOnFile(copy);
      addTearDown(restored.close);
      final flows = await restored.select(restored.cashFlowsTable).get();
      expect(flows, hasLength(1));
      expect(flows.single.amount, const Money(47000000));
    });

    test('tên tệp mang ngày giờ để nhiều bản không đè lên nhau', () {
      expect(
        backupFileName(DateTime(2026, 8, 28, 9, 5)),
        'chichimonney-sao-luu-2026-08-28-0905.sqlite',
      );
    });
  });

  group('Soi tệp trước khi khôi phục', () {
    test('nhận bản sao lưu thật của ứng dụng', () async {
      final source = File('${tmp.path}/$kDatabaseFileName');
      final db = openOnFile(source);
      await db.select(db.assetClassesTable).get();
      final copy = await writeBackupCopy(
        db: db,
        source: source,
        target: File('${tmp.path}/ban-sao.sqlite'),
      );
      await db.close();

      final check = await inspectBackupFile(copy, currentSchemaVersion: 3);
      expect(check, isA<BackupAccepted>());
      expect((check as BackupAccepted).schemaVersion, 3);
    });

    test('từ chối tệp không tồn tại', () async {
      final check = await inspectBackupFile(
        File('${tmp.path}/khong-co.sqlite'),
        currentSchemaVersion: 3,
      );
      expect(check, isA<BackupRejected>());
      expect(
        (check as BackupRejected).reason,
        BackupRejection.unreadable,
      );
    });

    test('từ chối tệp CSV — nhầm lẫn dễ xảy ra nhất', () async {
      // Màn hình Cài đặt có cả Xuất dữ liệu (CSV) lẫn Sao lưu (.sqlite), nên
      // người dùng rất dễ chọn nhầm tệp xuất khi khôi phục.
      final csv = File('${tmp.path}/xuat.csv')
        ..writeAsStringSync('KHOAN NAM GIU\nLớp tài sản,Ký hiệu\n');
      final check = await inspectBackupFile(csv, currentSchemaVersion: 3);
      expect((check as BackupRejected).reason, BackupRejection.notSqlite);
    });

    test('từ chối tệp SQLite của ứng dụng khác', () async {
      final other = File('${tmp.path}/khac.sqlite');
      sqlite3.open(other.path)
        ..execute('CREATE TABLE ghi_chu (id INTEGER PRIMARY KEY)')
        ..dispose();

      final check = await inspectBackupFile(other, currentSchemaVersion: 3);
      expect((check as BackupRejected).reason, BackupRejection.missingTables);
    });

    test('từ chối bản sao lưu của phiên bản ứng dụng mới hơn', () async {
      // Hạ cấp là đường không có: drift chỉ biết nâng schema lên. Chặn ở đây,
      // không để migration chạm vào tệp.
      final source = File('${tmp.path}/$kDatabaseFileName');
      final db = openOnFile(source);
      await db.select(db.assetClassesTable).get();
      final copy = await writeBackupCopy(
        db: db,
        source: source,
        target: File('${tmp.path}/tuong-lai.sqlite'),
      );
      await db.close();

      sqlite3.open(copy.path)
        ..execute('PRAGMA user_version = 99')
        ..dispose();

      final check = await inspectBackupFile(copy, currentSchemaVersion: 3);
      expect((check as BackupRejected).reason, BackupRejection.futureSchema);
    });
  });

  group('Thay tệp cơ sở dữ liệu', () {
    test('xoá tệp -wal và -shm của bản cũ', () async {
      final target = File('${tmp.path}/$kDatabaseFileName');
      final db = openOnFile(target);
      await db.into(db.cashFlowsTable).insert(
            CashFlowsTableCompanion.insert(
              date: DateTime.utc(2026, 1, 1),
              amount: const Money(1000),
            ),
          );
      await db.close();

      // Dựng lại đúng tình huống thật: hai tệp phụ nằm cạnh cơ sở dữ liệu cũ.
      final wal = File('${target.path}-wal')..writeAsBytesSync(const [0]);
      final shm = File('${target.path}-shm')..writeAsBytesSync(const [0]);

      final backupSource = File('${tmp.path}/nguon.sqlite');
      final backupDb = openOnFile(backupSource);
      await backupDb.into(backupDb.cashFlowsTable).insert(
            CashFlowsTableCompanion.insert(
              date: DateTime.utc(2026, 2, 2),
              amount: const Money(2000),
            ),
          );
      final backup = await writeBackupCopy(
        db: backupDb,
        source: backupSource,
        target: File('${tmp.path}/ban-sao.sqlite'),
      );
      await backupDb.close();

      await replaceDatabaseFile(backup: backup, target: target);

      // Để lại `-wal` cũ thì SQLite dựng lại trạng thái cũ đè lên bản vừa
      // khôi phục, và dữ liệu quay ngược về lúc trước.
      expect(wal.existsSync(), isFalse);
      expect(shm.existsSync(), isFalse);

      final restored = openOnFile(target);
      addTearDown(restored.close);
      final flows = await restored.select(restored.cashFlowsTable).get();
      expect(flows.single.amount, const Money(2000));
    });

    test('không để lại tệp tạm nào bên cạnh cơ sở dữ liệu', () async {
      final target = File('${tmp.path}/$kDatabaseFileName');
      final db = openOnFile(target);
      await db.select(db.assetClassesTable).get();
      await db.close();

      final backupSource = File('${tmp.path}/nguon.sqlite');
      final backupDb = openOnFile(backupSource);
      await backupDb.select(backupDb.assetClassesTable).get();
      final backup = await writeBackupCopy(
        db: backupDb,
        source: backupSource,
        target: File('${tmp.path}/ban-sao.sqlite'),
      );
      await backupDb.close();

      await replaceDatabaseFile(backup: backup, target: target);

      final leftovers = tmp
          .listSync()
          .map((e) => e.path.split('/').last)
          .where((name) => name.contains('khoi-phuc'))
          .toList();
      expect(leftovers, isEmpty);
    });
  });

  group('Sao lưu hằng tuần', () {
    test('chụp được cả giao dịch còn trong WAL khi mini app đang mở', () async {
      final source = File('${tmp.path}/$kDatabaseFileName');
      final db = openOnFile(source);
      await db.into(db.cashFlowsTable).insert(
            CashFlowsTableCompanion.insert(
              date: DateTime.utc(2026, 10, 28),
              amount: const Money(32000000),
            ),
          );

      // Cố ý không đóng db: super app chụp bản tuần trong lúc mini app vẫn
      // giữ kết nối, giao dịch vừa ghi còn nằm trong `-wal`.
      final target = File('${tmp.path}/hang-tuan.sqlite');
      expect(await writeSnapshotBackup(source: source, target: target), isTrue);
      await db.close();

      // Phải khôi phục được bằng đúng cửa của nút Khôi phục.
      final check = await inspectBackupFile(target, currentSchemaVersion: 3);
      expect(check, isA<BackupAccepted>());
      expect((check as BackupAccepted).schemaVersion, 3);
      expect(File('${target.path}-wal').existsSync(), isFalse);

      final restored = openOnFile(target);
      addTearDown(restored.close);
      final flows = await restored.select(restored.cashFlowsTable).get();
      expect(flows.single.amount, const Money(32000000));
    });

    test('chưa có cơ sở dữ liệu thì không xuất và không tạo tệp rỗng', () async {
      final source = File('${tmp.path}/$kDatabaseFileName');
      final target = File('${tmp.path}/hang-tuan.sqlite');

      expect(await writeSnapshotBackup(source: source, target: target), isFalse);
      expect(source.existsSync(), isFalse);
      expect(target.existsSync(), isFalse);
    });
  });
}
