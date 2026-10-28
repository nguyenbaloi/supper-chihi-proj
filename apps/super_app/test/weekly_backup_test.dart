import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_app_core/mini_app_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/backup_prompt.dart';
import 'package:super_app/strings.dart';
import 'package:super_app/weekly_backup.dart';

Future<bool> _writeNew(File target) async {
  await target.writeAsString('moi');
  return true;
}

Future<bool> _writeNothing(File target) async => false;

Future<bool> _writeHalfThenFail(File target) async {
  await target.writeAsString('do-dang');
  throw const FileSystemException('đầy bộ nhớ');
}

const _ok = BackupSource(fileName: 'a.sqlite', write: _writeNew);
const _empty = BackupSource(fileName: 'b.json', write: _writeNothing);
const _broken = BackupSource(fileName: 'a.sqlite', write: _writeHalfThenFail);

class _App implements MiniApp {
  const _App(this.title, this.backupSources);

  @override
  final String title;
  @override
  final List<BackupSource> backupSources;

  @override
  String get id => title;
  @override
  IconData get icon => Icons.star;
  @override
  Color get color => Colors.blue;
  @override
  Future<ProviderContainer> createContainer() async => ProviderContainer();
  @override
  Widget buildApp() => const SizedBox();
}

void main() {
  late Directory dir;
  late DateTime now;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('weekly_backup_test');
    now = DateTime.utc(2026, 10, 28, 9);
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<WeeklyBackup> schedule() async =>
      WeeklyBackup(await SharedPreferences.getInstance(), clock: () => now);

  File at(String name) => File('${dir.path}/$name');

  group('Lịch', () {
    test('chưa từng sao lưu thì đến hạn ngay', () async {
      expect((await schedule()).isDue, isTrue);
    });

    test('đến hạn lại sau đúng bảy ngày', () async {
      final backup = await schedule();
      await backup.run(dir, [_ok]);
      expect(backup.isDue, isFalse);

      now = now.add(const Duration(days: 6, hours: 23));
      expect(backup.isDue, isFalse);
      now = now.add(const Duration(hours: 1));
      expect(backup.isDue, isTrue);
    });

    test('"Để sau" hoãn một ngày rồi hỏi lại', () async {
      final backup = await schedule();
      await backup.snooze();
      expect(backup.isDue, isFalse);

      now = now.add(WeeklyBackup.snoozeFor);
      expect(backup.isDue, isTrue);
    });
  });

  group('Xuất', () {
    test('ghi đè lên bản của lần trước, không để lại tệp tạm', () async {
      at('a.sqlite').writeAsStringSync('cu');

      final outcomes = await (await schedule()).run(dir, [_ok]);

      expect(outcomes[_ok], BackupOutcome.written);
      expect(at('a.sqlite').readAsStringSync(), 'moi');
      expect(dir.listSync().map((e) => e.uri.pathSegments.last), ['a.sqlite']);
    });

    test('xuất lỗi giữa chừng thì bản cũ còn nguyên và lần sau hỏi lại',
        () async {
      at('a.sqlite').writeAsStringSync('cu');
      final backup = await schedule();

      final outcomes = await backup.run(dir, [_broken]);

      expect(outcomes[_broken], BackupOutcome.failed);
      expect(at('a.sqlite').readAsStringSync(), 'cu');
      expect(dir.listSync(), hasLength(1));
      expect(backup.isDue, isTrue);
    });

    test('mini app chưa có dữ liệu thì không đụng tới bản cũ', () async {
      at('b.json').writeAsStringSync('cu');

      final outcomes = await (await schedule()).run(dir, [_ok, _empty]);

      expect(outcomes[_empty], BackupOutcome.empty);
      expect(at('b.json').readAsStringSync(), 'cu');
      expect(at('a.sqlite').readAsStringSync(), 'moi');
    });
  });

  group('Hỏi ý kiến', () {
    Widget host(List<MiniApp> apps) => MaterialApp(
          home: WeeklyBackupPrompt(
            apps: apps,
            openSchedule: schedule,
            backupDirectory: () async => dir,
            builder: (context, backupNow) => Scaffold(
              body: Text(backupNow == null ? 'khong-nut' : 'co-nut'),
            ),
          ),
        );

    testWidgets('đến hạn thì hỏi, đồng ý mới xuất', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(host([
          const _App('Tài chính', [_ok]),
          const _App('RSI', []),
        ]));
        await tester.pump();
        await tester.pump();
      });

      expect(find.text(S.backupDueTitle), findsOneWidget);
      // Mini app không có dữ liệu không được nhắc tên.
      expect(find.textContaining('Tài chính'), findsOneWidget);
      expect(find.textContaining('RSI'), findsNothing);
      expect(at('a.sqlite').existsSync(), isFalse);

      await tester.runAsync(() async {
        await tester.tap(find.text(S.backupConfirm));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(at('a.sqlite').readAsStringSync(), 'moi');
      expect(find.text(S.backupDone), findsOneWidget);
    });

    testWidgets('từ chối thì không xuất gì và hoãn một ngày', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(host([const _App('Tài chính', [_ok])]));
        await tester.pump();
        await tester.pump();
      });

      await tester.runAsync(() async {
        await tester.tap(find.text(S.backupLater));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text(S.backupDueTitle), findsNothing);
      expect(dir.listSync(), isEmpty);
      expect((await schedule()).isDue, isFalse);
    });

    testWidgets('không mini app nào có dữ liệu thì không hỏi, không có nút',
        (tester) async {
      await tester.pumpWidget(host([const _App('RSI', [])]));
      await tester.pump();

      expect(find.text(S.backupDueTitle), findsNothing);
      expect(find.text('khong-nut'), findsOneWidget);
    });
  });
}
