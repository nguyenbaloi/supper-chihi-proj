import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/data/db/database.dart';

/// Bảo vệ AD-3 và AD-4 ở mức schema: một cột sai kiểu hoặc một cột lưu giá trị
/// suy ra lọt vào là hỏng tính đúng đắn của sản phẩm mà không báo lỗi.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Các cột tuyệt đối không được tồn tại — CLAUDE.md quy tắc 1.
  const forbidden = {
    'completion_ratio',
    'completion_percent',
    'action_count',
    'current_value',
    'progress',
    'progress_percent',
    'met_count',
    'met_ratio',
    'item_count',
  };

  test('AD-3 — không bảng nào lưu giá trị suy ra', () {
    for (final table in db.allTables) {
      for (final column in table.$columns) {
        expect(
          forbidden.contains(column.name),
          isFalse,
          reason: 'Bảng ${table.actualTableName} có cột cấm ${column.name}',
        );
      }
    }
  });

  test('AD-4 — không cột nào kiểu số thực', () {
    for (final table in db.allTables) {
      for (final column in table.$columns) {
        expect(
          column.type,
          isNot(DriftSqlType.double),
          reason: 'Bảng ${table.actualTableName}, cột ${column.name} kiểu double',
        );
      }
    }
  });

  test('AD-8 — Hành động luôn thuộc một Dự án và không có parentId', () {
    final actions = db.actions;
    expect(actions.projectId.$nullable, isFalse);
    final names = actions.$columns.map((c) => c.name).toSet();
    expect(names.contains('parent_id'), isFalse);
  });

  test('mười hai bảng đúng như sơ đồ thực thể', () {
    final names = db.allTables.map((t) => t.actualTableName).toSet();
    expect(names, {
      'topics',
      'projects',
      'actions',
      'goals',
      'goal_updates',
      'project_goals',
      'notes',
      'links',
      'status_events',
      'reviews',
      'review_items',
      'app_settings',
    });
  });

  test('mở cơ sở dữ liệu rỗng rồi đọc lại thành công', () async {
    expect(await db.select(db.projects).get(), isEmpty);
    expect(db.schemaVersion, 2);
  });
}
