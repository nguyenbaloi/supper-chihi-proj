import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/data/db/database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// AD-10: mỗi lần tăng `schemaVersion` phải có test dựng cơ sở dữ liệu bản cũ
/// rồi nâng lên, chứng minh dữ liệu người dùng không mất.
///
/// Ở đây dựng bản v1 bằng SQL thô thay vì dùng helper sinh sẵn của drift, vì
/// bản v1 chưa từng được dump trước khi lên v2. Cách này còn chặt hơn ở một
/// điểm: nó kiểm chứng dữ liệu thật sống sót, không chỉ kiểm cấu trúc bảng.
const List<String> _schemaV1 = [
  '''CREATE TABLE topics (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    color_value INTEGER NOT NULL,
    icon_key TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_system_fallback INTEGER NOT NULL DEFAULT 0
  )''',
  '''CREATE TABLE projects (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics (id),
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL,
    priority TEXT NOT NULL,
    due_date TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    started_at TEXT,
    completed_at TEXT,
    search_text TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE actions (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    note TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL,
    due_date TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    started_at TEXT,
    completed_at TEXT,
    search_text TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE goals (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    is_numeric INTEGER NOT NULL DEFAULT 1,
    target_raw INTEGER,
    decimals INTEGER NOT NULL DEFAULT 0,
    unit TEXT NOT NULL DEFAULT 'VND',
    due_date TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    search_text TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE goal_updates (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    goal_id INTEGER NOT NULL REFERENCES goals (id) ON DELETE CASCADE,
    date TEXT NOT NULL,
    value_raw INTEGER NOT NULL,
    decimals INTEGER NOT NULL DEFAULT 0,
    note TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL
  )''',
  '''CREATE TABLE project_goals (
    project_id INTEGER NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    goal_id INTEGER NOT NULL REFERENCES goals (id) ON DELETE CASCADE,
    PRIMARY KEY (project_id, goal_id)
  )''',
  '''CREATE TABLE notes (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body_markdown TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    search_text TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE links (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    url TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    search_text TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE status_events (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    entity_type TEXT NOT NULL,
    entity_id INTEGER NOT NULL,
    from_status TEXT NOT NULL,
    to_status TEXT NOT NULL,
    at TEXT NOT NULL
  )''',
  '''CREATE TABLE app_settings (
    id INTEGER NOT NULL DEFAULT 1,
    stale_days INTEGER NOT NULL DEFAULT 21,
    theme_mode TEXT NOT NULL DEFAULT 'system',
    seed_applied INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
  )''',
];

void main() {
  test('v1 → v2: thêm bảng Đợt đánh giá, dữ liệu cũ còn nguyên', () async {
    final raw = sqlite.sqlite3.openInMemory();
    for (final stmt in _schemaV1) {
      raw.execute(stmt);
    }
    raw.execute('PRAGMA user_version = 1');

    // Dữ liệu người dùng có thật trước khi nâng cấp.
    raw.execute(
      "INSERT INTO topics (id, name, color_value, icon_key, sort_order, is_system_fallback) "
      "VALUES (1, 'Gia đình', 1, 'family', 0, 0)",
    );
    raw.execute(
      "INSERT INTO projects (id, topic_id, name, description, status, priority, "
      "created_at, updated_at, search_text) "
      "VALUES (1, 1, 'Dạy Huy', 'theo dõi tiến bộ', 'active', 'high', "
      "'2026-05-15T00:00:00.000Z', '2026-05-15T00:00:00.000Z', 'day huy')",
    );
    raw.execute(
      "INSERT INTO actions (id, project_id, title, status, created_at, updated_at) "
      "VALUES (1, 1, 'Ngủ sớm trước 11 giờ đêm', 'doing', "
      "'2026-05-15T00:00:00.000Z', '2026-05-15T00:00:00.000Z')",
    );
    raw.execute(
      "INSERT INTO goals (id, name, is_numeric, target_raw, created_at, updated_at) "
      "VALUES (1, 'Mục tiêu 1 tỷ', 1, 1000000000, "
      "'2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z')",
    );

    final db = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(db.close);

    // Chạm vào cơ sở dữ liệu để buộc drift chạy migration.
    final projects = await db.select(db.projects).get();

    expect(db.schemaVersion, 2);
    expect(raw.select('PRAGMA user_version').first.values.first, 2);

    // Dữ liệu cũ nguyên vẹn.
    expect(projects.length, 1);
    expect(projects.single.name, 'Dạy Huy');
    expect((await db.select(db.actions).get()).single.title,
        'Ngủ sớm trước 11 giờ đêm');
    expect((await db.select(db.goals).get()).single.targetRaw, 1000000000);

    // Bảng mới đã tồn tại và dùng được.
    expect(await db.select(db.reviews).get(), isEmpty);
    final reviewId = await db.into(db.reviews).insert(
          ReviewsCompanion.insert(
            projectId: 1,
            date: DateTime.utc(2026, 8, 7),
            createdAt: DateTime.utc(2026, 8, 7),
          ),
        );
    await db.into(db.reviewItems).insert(
          ReviewItemsCompanion.insert(
            reviewId: reviewId,
            label: 'Tăng cường thể chất vận động',
            verdict: 'met',
          ),
        );
    expect((await db.select(db.reviewItems).get()).single.verdict, 'met');
  });

  test('cài mới ở v2 tạo đủ mười hai bảng', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.select(db.projects).get();
    expect(db.allTables.length, 12);
  });
}
