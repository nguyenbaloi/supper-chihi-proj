import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Topics,
    Projects,
    Actions,
    Goals,
    GoalUpdates,
    ProjectGoals,
    Notes,
    Links,
    StatusEvents,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'personal_projects'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        // AD-10: mỗi lần tăng schemaVersion phải thêm một nhánh ở đây kèm
        // test migrateAndValidate cho cặp phiên bản mới.
        onUpgrade: (m, from, to) async {},
        beforeOpen: (details) async {
          // Khoá ngoại phải bật tường minh: SQLite mặc định tắt, mà toàn bộ
          // hành vi xoá theo tầng của AD-8 dựa vào nó.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
