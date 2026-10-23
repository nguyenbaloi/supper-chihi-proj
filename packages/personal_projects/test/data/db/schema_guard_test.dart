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

  test('chín bảng đúng như sơ đồ thực thể', () {
    final names = db.allTables.map((t) => t.actualTableName).toSet();
    expect(names, {
      'areas',
      'projects',
      'actions',
      'notes',
      'links',
      'status_events',
      'reviews',
      'review_items',
      'app_settings',
    });
  });

  // AD-3: hạn xem lại của Lĩnh vực là giá trị suy ra. Có cột lưu cứng là nó
  // đứng yên khi người dùng xoá Đợt gần nhất, và nói dối từ đó trở đi.
  test('AD-3 — areas không có cột nào lưu cứng hạn xem lại', () {
    final names = db.areas.$columns.map((c) => c.name).toSet();
    for (final forbidden in [
      'next_review_date',
      'is_due_for_review',
      'last_review_date',
      'review_count',
    ]) {
      expect(names.contains(forbidden), isFalse,
          reason: 'areas.$forbidden là giá trị suy ra, cấm lưu — AD-3');
    }
    expect(names.contains('review_cadence_days'), isTrue);
    expect(names.contains('standard'), isTrue);
    expect(names.contains('created_at'), isTrue);
  });

  test('AD-19 — reviews có đúng hai khoá chủ thể, cả hai đều nullable', () {
    expect(db.reviews.projectId.$nullable, isTrue);
    expect(db.reviews.areaId.$nullable, isTrue);
  });

  test('mở cơ sở dữ liệu rỗng rồi đọc lại thành công', () async {
    expect(await db.select(db.projects).get(), isEmpty);
    expect(db.schemaVersion, 7);
  });

  // Thứ tự trong danh sách Làm ngay và thứ tự kéo thả trong một Dự án là hai
  // chuyện khác nhau (FR-18 với FR-42). Gộp vào một cột thì kéo thả ở màn Dự
  // án sẽ lặng lẽ xáo lại màn Hôm nay.
  test('actions có hai cột thứ tự tách bạch', () {
    final names = db.actions.$columns.map((c) => c.name).toSet();
    expect(names.containsAll({'sort_order', 'pinned_order'}), isTrue);
  });
}
