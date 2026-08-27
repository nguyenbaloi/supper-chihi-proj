import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/money/money.dart';
import '../../domain/models/default_asset_classes.dart';
import '../../domain/models/enums.dart';
import 'converters.dart';

import 'tables/asset_classes_table.dart';
import 'tables/holdings_table.dart';
import 'tables/price_quotes_table.dart';
import 'tables/settings_table.dart';

part 'database.g.dart';

/// Cơ sở dữ liệu cục bộ. Toàn bộ danh mục nằm ở đây và không rời khỏi máy.
///
/// Không có cột nào lưu giá trị tổng hợp: giá trị Lớp tài sản, Tổng tài sản,
/// Vốn góp lũy kế và Lãi lỗ đều được tính tại chỗ. Xem AD-4 và AD-5.
@DriftDatabase(
  tables: [
    SettingsTable,
    AssetClassesTable,
    HoldingsTable,
    PriceQuotesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Mở cơ sở dữ liệu thật, đặt trong thư mục riêng của ứng dụng.
  AppDatabase.open() : super(driftDatabase(name: 'personal_finance'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedAssetClasses();
        },
        onUpgrade: (m, from, to) async {
          // Mỗi lần đổi cấu trúc dữ liệu phải có bước chuyển đổi tương ứng và
          // một bài test dựng cơ sở dữ liệu ở phiên bản cũ rồi nâng lên. Cấm
          // xoá cột đang chứa dữ liệu người dùng mà không chuyển sang nơi
          // khác — mất dữ liệu ở đây là không thể sửa vì không có bản sao lưu
          // trên máy chủ. Xem AD-10.
          //
          // Các bước xếp theo bậc thang và không có `else`: một máy đang ở
          // phiên bản 1 phải chạy qua đúng mọi bậc để lên phiên bản mới nhất.
          if (from < 2) {
            // Thêm bộ nhớ đệm giá. Không đụng tới bảng nào đang có dữ liệu.
            await m.createTable(priceQuotesTable);
          }
          if (to > 2) {
            throw UnsupportedError(
              'Chưa định nghĩa bước nâng cấp từ schema $from lên $to',
            );
          }
        },
        beforeOpen: (details) async {
          // Bắt buộc, nếu không SQLite bỏ qua mọi ràng buộc khoá ngoại.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Tạo sẵn năm Lớp tài sản ngay khi cơ sở dữ liệu ra đời. Xem FR-1.
  ///
  /// Đặt ở `onCreate` chứ không phải một bước khởi tạo riêng ở tầng trên: gieo
  /// cùng giao dịch với lệnh tạo bảng thì không tồn tại trạng thái trung gian
  /// nào mà ứng dụng mở lên với danh mục rỗng.
  Future<void> _seedAssetClasses() async {
    await batch((b) {
      b.insertAll(
        assetClassesTable,
        defaultAssetClasses.map(
          (seed) => AssetClassesTableCompanion.insert(
            name: seed.name,
            kind: seed.kind,
            colorValue: seed.colorValue,
            iconCodePoint: seed.iconCodePoint,
            inInvestmentGroup: Value(seed.inInvestmentGroup),
            sortOrder: Value(seed.sortOrder),
          ),
        ),
      );
    });
  }
}
