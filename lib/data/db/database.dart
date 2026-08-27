import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/money/money.dart';
import '../../domain/models/enums.dart';
import 'converters.dart';

import 'tables/asset_classes_table.dart';
import 'tables/holdings_table.dart';
import 'tables/settings_table.dart';

part 'database.g.dart';

/// Cơ sở dữ liệu cục bộ. Toàn bộ danh mục nằm ở đây và không rời khỏi máy.
///
/// Không có cột nào lưu giá trị tổng hợp: giá trị Lớp tài sản, Tổng tài sản,
/// Vốn góp lũy kế và Lãi lỗ đều được tính tại chỗ. Xem AD-4 và AD-5.
@DriftDatabase(
  tables: [SettingsTable, AssetClassesTable, HoldingsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Mở cơ sở dữ liệu thật, đặt trong thư mục riêng của ứng dụng.
  AppDatabase.open() : super(driftDatabase(name: 'personal_finance'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Mỗi lần đổi cấu trúc dữ liệu phải có bước chuyển đổi tương ứng và
          // một bài test dựng cơ sở dữ liệu ở phiên bản cũ rồi nâng lên. Cấm
          // xoá cột đang chứa dữ liệu người dùng mà không chuyển sang nơi
          // khác — mất dữ liệu ở đây là không thể sửa vì không có bản sao lưu
          // trên máy chủ. Xem AD-10.
          // Chưa có bước nâng cấp nào vì schemaVersion mới là 1. Khi tăng
          // lên 2, thêm bước vào đây kèm bài test dựng cơ sở dữ liệu ở phiên
          // bản cũ rồi nâng lên, chứng minh dữ liệu còn nguyên.
          throw UnsupportedError(
            'Chưa định nghĩa bước nâng cấp từ schema $from lên $to',
          );
        },
        beforeOpen: (details) async {
          // Bắt buộc, nếu không SQLite bỏ qua mọi ràng buộc khoá ngoại.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
