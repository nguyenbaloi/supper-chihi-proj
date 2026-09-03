import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Areas,
    Projects,
    Actions,
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
  int get schemaVersion => 5;

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
          if (from < 3) {
            // Hành động có độ ưu tiên riêng và cờ ghim "làm ngay" (FR-41, FR-42).
            await m.addColumn(actions, actions.priority);
            await m.addColumn(actions, actions.pinned);
            await m.addColumn(actions, actions.pinnedAt);
            // Bỏ hẳn Mục tiêu theo quyết định ngày 2026-08-28. Đây là lần duy
            // nhất trong dự án này dữ liệu người dùng bị xoá theo chủ đích;
            // đường lui là file sao lưu định dạng phiên bản 2.
            await customStatement('DROP TABLE IF EXISTS project_goals');
            await customStatement('DROP TABLE IF EXISTS goal_updates');
            await customStatement('DROP TABLE IF EXISTS goals');
          }
          if (from < 4) {
            // v3 → v4: Chủ đề đổi tên thành Lĩnh vực — FR-46, Story 8.1.
            //
            // Đổi tên thuần tuý: không cột nào mất, không giá trị nào của
            // người dùng đổi.
            await m.renameTable(areas, 'topics');

            // `projects` phải dựng lại chứ không chỉ đổi tên cột. Lý do:
            // SQLite chỉ tự sửa mệnh đề `REFERENCES` của các bảng khác khi
            // `PRAGMA foreign_keys` đang **bật** lúc `ALTER TABLE ... RENAME`.
            // Migration chạy trong một giao dịch, mà pragma đó không đổi được
            // bên trong giao dịch — nên sau `renameTable` ở trên, khoá ngoại
            // của `projects` vẫn trỏ tới cái tên `topics` không còn tồn tại.
            //
            // Hỏng theo kiểu im lặng: đọc thì vẫn chạy, tới khi `beforeOpen`
            // bật lại `foreign_keys` và người dùng thêm Dự án mới thì mới chết.
            // `alterTable` dựng lại bảng từ định nghĩa Dart hiện tại nên khoá
            // ngoại trỏ đúng `areas`, đồng thời chép `topic_id` sang `area_id`.
            await m.alterTable(TableMigration(
              projects,
              columnTransformer: {
                projects.areaId: const CustomExpression<int>('topic_id'),
              },
            ));
          }
          if (from < 5) {
            // v4 → v5: Ghi chú và Liên kết thôi chết theo Dự án — FR-50,
            // AD-18, Story 8.4.
            //
            // `alterTable` dựng lại hai bảng từ định nghĩa Dart hiện tại:
            // `project_id` thành nullable với `onDelete: setNull`, thêm
            // `area_id` nullable, và ràng buộc CHECK nhiều-nhất-một.
            //
            // `area_id` **để trống** cho mọi bản ghi đang có. Đó là chủ ý,
            // không phải bỏ sót: bản ghi nào còn `project_id` thì đã có chỗ
            // thuộc về, và điền thêm `area_id` sẽ vi phạm đúng cái CHECK vừa
            // dựng. `area_id` chỉ được ghi lúc Dự án cha bị xoá.
            //
            // `newColumns` là bắt buộc: không khai báo thì `alterTable` đưa
            // `area_id` vào cả câu SELECT chép dữ liệu, mà bảng cũ chưa có cột
            // đó nên câu lệnh chết ngay giữa migration.
            await m.alterTable(TableMigration(notes, newColumns: [notes.areaId]));
            await m.alterTable(TableMigration(links, newColumns: [links.areaId]));
          }
        },
        beforeOpen: (details) async {
          // Khoá ngoại phải bật tường minh: SQLite mặc định tắt, mà toàn bộ
          // hành vi xoá theo tầng của AD-8 dựa vào nó.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
