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
    Reviews,
    ReviewItems,
    StatusEvents,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'personal_projects'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        // AD-10: mỗi lần tăng schemaVersion phải thêm một nhánh ở đây kèm
        // test migrateAndValidate cho cặp phiên bản mới.
        onUpgrade: (m, from, to) async {
          // v1 → v2: thêm Đợt đánh giá định kỳ (FR-35..FR-40). Chỉ tạo bảng
          // mới, không đụng tới bảng cũ nên dữ liệu người dùng còn nguyên.
          if (from < 2) {
            await m.createTable(reviews);
            await m.createTable(reviewItems);
          }
        },
        beforeOpen: (details) async {
          // Khoá ngoại phải bật tường minh: SQLite mặc định tắt, mà toàn bộ
          // hành vi xoá theo tầng của AD-8 dựa vào nó.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
