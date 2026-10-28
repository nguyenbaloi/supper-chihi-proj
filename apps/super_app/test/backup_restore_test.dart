import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/data/db/backup_file.dart' as fin;
import 'package:personal_finance/data/db/database.dart' as fin;
import 'package:personal_finance/finance_mini_app.dart';
import 'package:personal_finance/presentation/providers/repository_providers.dart'
    as fin;
import 'package:personal_projects/data/backup/weekly_backup.dart' as proj;
import 'package:personal_projects/data/db/database.dart' as proj;
import 'package:personal_projects/data/repositories/drift_content_repositories.dart'
    as proj;
import 'package:personal_projects/presentation/providers/providers.dart'
    as proj;
import 'package:personal_projects/projects_mini_app.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/weekly_backup.dart';

/// Thư mục của ứng dụng trên máy, dựng trong một thư mục tạm.
class _FakePaths extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _FakePaths(this.root);

  final Directory root;

  String _dir(String name) =>
      (Directory('${root.path}/$name')..createSync(recursive: true)).path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir('Documents');
  @override
  Future<String?> getApplicationSupportPath() async =>
      _dir('Library/Application Support');
  @override
  Future<String?> getTemporaryPath() async => _dir('tmp');
}

/// Chu trình đầy đủ trên tệp thật: mini app thật ghi dữ liệu → super app xuất
/// bản hằng tuần → ghi đè ở tuần sau → cài lại ứng dụng → khôi phục bằng đúng
/// cơ chế của từng mini app. Chỉ thư mục hệ thống là giả.
void main() {
  late Directory root;
  late Directory documents;
  late Directory support;
  late DateTime now;

  setUp(() {
    root = Directory.systemTemp.createTempSync('backup_restore_test');
    PathProviderPlatform.instance = _FakePaths(root);
    documents = Directory('${root.path}/Documents');
    support = Directory('${root.path}/Library/Application Support');
    now = DateTime.utc(2026, 10, 28, 9);
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() => root.deleteSync(recursive: true));

  final sources = [
    ...const FinanceMiniApp().backupSources,
    ...const ProjectsMiniApp().backupSources,
  ];

  Future<WeeklyBackup> schedule() async =>
      WeeklyBackup(await SharedPreferences.getInstance(), clock: () => now);

  Future<Map<String, BackupOutcome>> runBackup() async {
    final outcomes = await (await schedule()).run(documents, sources);
    return {for (final e in outcomes.entries) e.key.fileName: e.value};
  }

  File inDocuments(String name) => File('${documents.path}/$name');

  /// Xoá ứng dụng: mất cả cơ sở dữ liệu lẫn mọi tệp phụ của nó.
  void uninstall() {
    for (final f in support.listSync()) {
      f.deleteSync(recursive: true);
    }
  }

  Future<void> addCashFlow(ProviderContainer c, int amount) async {
    final db = c.read(fin.databaseProvider);
    await db.into(db.cashFlowsTable).insert(
          fin.CashFlowsTableCompanion.insert(
            date: DateTime.utc(2026, 10, 28),
            amount: Money(amount),
          ),
        );
  }

  Future<List<int>> cashFlows(ProviderContainer c) async {
    final db = c.read(fin.databaseProvider);
    final rows = await db.select(db.cashFlowsTable).get();
    return [for (final r in rows) r.amount.amount]..sort();
  }

  Future<List<String>> noteTitles(ProviderContainer c) async {
    final db = c.read(proj.databaseProvider);
    final rows = await db.select(db.notes).get();
    return [for (final r in rows) r.title]..sort();
  }

  group('Tài chính', () {
    test('xuất khi mini app đang mở, ghi đè tuần sau, khôi phục sau cài lại',
        () async {
      final app = ProviderContainer();
      await addCashFlow(app, 47000000);

      // Tuần 1 — mini app vẫn mở, giao dịch còn trong WAL.
      expect((await runBackup())[fin.kWeeklyBackupFileName],
          BackupOutcome.written);

      // Tuần 2 — thêm dữ liệu rồi xuất lại: phải đè lên bản tuần 1.
      await addCashFlow(app, 9000000);
      now = now.add(WeeklyBackup.interval);
      expect((await runBackup())[fin.kWeeklyBackupFileName],
          BackupOutcome.written);
      app.dispose();

      uninstall();
      final reinstalled = ProviderContainer();
      addTearDown(reinstalled.dispose);
      expect(await cashFlows(reinstalled), isEmpty);

      // Đúng các bước của nút Khôi phục: soi tệp, rồi thay khi đã đóng.
      final backup = inDocuments(fin.kWeeklyBackupFileName);
      final check = await fin.inspectBackupFile(
        backup,
        currentSchemaVersion:
            reinstalled.read(fin.databaseProvider).schemaVersion,
      );
      expect(check, isA<fin.BackupAccepted>());
      await reinstalled.read(fin.databaseHostProvider.notifier).reopen(
            () async => fin.replaceDatabaseFile(
              backup: backup,
              target: await fin.liveDatabaseFile(),
            ),
          );

      expect(await cashFlows(reinstalled), [9000000, 47000000]);
    });

    test('dữ liệu bị xoá nhầm thì khôi phục về đúng bản tuần trước', () async {
      final app = ProviderContainer();
      addTearDown(app.dispose);
      await addCashFlow(app, 341000000);
      await runBackup();

      final db = app.read(fin.databaseProvider);
      await db.delete(db.cashFlowsTable).go();
      expect(await cashFlows(app), isEmpty);

      await app.read(fin.databaseHostProvider.notifier).reopen(
            () async => fin.replaceDatabaseFile(
              backup: inDocuments(fin.kWeeklyBackupFileName),
              target: await fin.liveDatabaseFile(),
            ),
          );
      expect(await cashFlows(app), [341000000]);
    });

    test('bản cài cũ để cơ sở dữ liệu trong Documents vẫn được giữ nguyên',
        () async {
      // Dựng đúng tình trạng bản cài trước khi cập nhật: tệp nằm trong
      // Documents, nơi giờ hiện ra trong app Tệp.
      final legacy = fin.AppDatabase(
        NativeDatabase(File('${documents.path}/${fin.kDatabaseFileName}')),
      );
      await legacy.into(legacy.cashFlowsTable).insert(
            fin.CashFlowsTableCompanion.insert(
              date: DateTime.utc(2026, 1, 1),
              amount: const Money(60000000),
              note: const Value('dòng vốn cũ'),
            ),
          );
      await legacy.close();

      final app = ProviderContainer();
      addTearDown(app.dispose);
      expect(await cashFlows(app), [60000000]);
      await runBackup();

      // App Tệp chỉ còn thấy bản sao lưu, không thấy tệp đang chạy.
      final visible = documents
          .listSync()
          .map((e) => e.uri.pathSegments.last)
          .toList();
      expect(visible, [fin.kWeeklyBackupFileName]);
      expect(
        File('${support.path}/${fin.kDatabaseFileName}').existsSync(),
        isTrue,
      );
    });
  });

  group('Dự án', () {
    test('chưa từng mở thì không xuất và không tạo cơ sở dữ liệu rỗng',
        () async {
      expect((await runBackup())[proj.kWeeklyBackupFileName],
          BackupOutcome.empty);
      expect(inDocuments(proj.kWeeklyBackupFileName).existsSync(), isFalse);
      expect(
        File('${support.path}/${proj.kDatabaseName}.sqlite').existsSync(),
        isFalse,
      );
    });

    test('xuất khi mini app đang mở, ghi đè tuần sau, nhập lại sau cài lại',
        () async {
      final app = ProviderContainer();
      final notes = proj.DriftNoteRepository(app.read(proj.databaseProvider));
      await notes.create(title: 'Kế hoạch quý 4', bodyMarkdown: 'Giữ tỷ trọng');

      expect((await runBackup())[proj.kWeeklyBackupFileName],
          BackupOutcome.written);

      await notes.create(title: 'Ôn lại danh mục 🎯');
      now = now.add(WeeklyBackup.interval);
      expect((await runBackup())[proj.kWeeklyBackupFileName],
          BackupOutcome.written);
      app.dispose();

      uninstall();
      final reinstalled = ProviderContainer();
      addTearDown(reinstalled.dispose);
      expect(await noteTitles(reinstalled), isEmpty);

      // Đúng hàm nút Nhập sao lưu gọi, đọc tệp bằng UTF-8 như nút đó.
      final raw = await inDocuments(proj.kWeeklyBackupFileName).readAsString();
      final result =
          await reinstalled.read(proj.backupServiceProvider).import(raw);
      expect(result.isOk, isTrue);

      expect(
        await noteTitles(reinstalled),
        ['Kế hoạch quý 4', 'Ôn lại danh mục 🎯'],
      );
    });
  });

  test('hai mini app xuất cùng lúc, thư mục chỉ có đúng hai tệp sao lưu',
      () async {
    final finance = ProviderContainer();
    final projects = ProviderContainer();
    addTearDown(finance.dispose);
    addTearDown(projects.dispose);
    await addCashFlow(finance, 1000000);
    await proj.DriftNoteRepository(projects.read(proj.databaseProvider))
        .create(title: 'x');

    for (var week = 0; week < 3; week++) {
      final outcomes = await runBackup();
      expect(outcomes.values, everyElement(BackupOutcome.written));
      now = now.add(WeeklyBackup.interval);
    }

    final names =
        documents.listSync().map((e) => e.uri.pathSegments.last).toSet();
    expect(names, {fin.kWeeklyBackupFileName, proj.kWeeklyBackupFileName});
  });
}
