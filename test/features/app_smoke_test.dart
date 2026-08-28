import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personal_projects/app.dart';
import 'package:personal_projects/core/l10n/strings.dart';
import 'package:personal_projects/data/db/database.dart';
import 'package:personal_projects/presentation/providers/providers.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('vi_VN'));

  /// Không dùng `pumpAndSettle`: màn hình chờ có `CircularProgressIndicator`
  /// quay vô hạn nên khung hình không bao giờ "lắng".
  ///
  /// Cũng không pump trong vùng thời gian giả: drift chạy I/O thật, mà đồng hồ
  /// giả của `testWidgets` không đẩy Future của nó đi tiếp. Mọi lần chờ đều
  /// phải nằm trong `tester.runAsync`.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  Future<void> pump(WidgetTester tester, AppDatabase db) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const PersonalProjectsApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('lần chạy đầu mời nạp dữ liệu có sẵn — FR-2', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pump(tester, db);

    expect(find.text(S.onboardingTitle), findsOneWidget);
    expect(find.text(S.onboardingSeed), findsOneWidget);
    expect(find.text(S.onboardingSkip), findsOneWidget);
  });

  testWidgets('nạp hạt giống rồi vào thẳng màn hình có dữ liệu', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pump(tester, db);

    await tester.tap(find.text(S.onboardingSeed));
    await settle(tester);

    // Ba tab đã lên
    expect(find.text(S.tabToday), findsWidgets);
    expect(find.text(S.tabProjects), findsWidgets);
    expect(find.text(S.tabGoals), findsWidgets);

    // Bảy dự án thật đã có mặt
    await tester.tap(find.text(S.tabProjects).last);
    await settle(tester);
    expect(find.text('Kế hoạch tài chính'), findsOneWidget);
    expect(find.text('Kênh TikTok, YouTube tiếp thị liên kết'), findsOneWidget);
  });

  testWidgets('bỏ qua nạp thì vào app trống, không còn lời mời', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pump(tester, db);

    await tester.tap(find.text(S.onboardingSkip));
    await settle(tester);

    expect(find.text(S.onboardingTitle), findsNothing);
    await tester.tap(find.text(S.tabProjects).last);
    await settle(tester);
    expect(find.text(S.projectEmptyList), findsOneWidget);
  });

  testWidgets('màn hình Hôm nay không liệt kê toàn bộ hành động chưa xong — FR-29',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pump(tester, db);
    await tester.tap(find.text(S.onboardingSeed));
    await settle(tester);

    // Hai hành động `Chưa` trong bộ hạt giống không có hạn chót, nên không
    // được xuất hiện ở Hôm nay.
    expect(find.text('Dồn tiền mua máy rửa bát'), findsNothing);
    // Hành động `Đang làm` thì phải có mặt.
    expect(find.text('Sắp xếp lại thời gian làm việc ở cty và cho cá nhân'),
        findsOneWidget);
  });
}
