import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/l10n/l10n_delegates.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/rules/allocation.dart';
import 'package:personal_finance/features/targets/allocation_plan_card.dart';
import 'package:personal_finance/presentation/providers/portfolio_providers.dart';

AllocationPlan planOf({
  required int totalAssets,
  required List<(String, int, int)> targets,
}) =>
    Allocation.plan(
      totalAssets: Money(totalAssets),
      targets: [
        for (final (label, current, bp) in targets)
          AllocationTarget(
            label: label,
            currentValue: Money(current),
            targetWeightBp: bp,
          ),
      ],
    );

Future<void> pumpCard(WidgetTester tester, AllocationPlan plan) async {
  // Khung điện thoại hẹp: đây là nơi bố cục vỡ nếu vỡ.
  final view = tester.view;
  view.devicePixelRatio = 1.0;
  view.physicalSize = const Size(360, 800);
  addTearDown(() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [allocationPlanProvider.overrideWithValue(plan)],
      child: MaterialApp(
        localizationsDelegates: AppL10nDelegates.delegates,
        supportedLocales: AppL10nDelegates.locales,
        home: const Scaffold(
          body: SingleChildScrollView(child: AllocationPlanCard()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Kế hoạch phân bổ hiện ra con số để hành động', () {
    testWidgets('tách rõ mua thêm và bán bớt, kèm số tiền', (tester) async {
      await pumpCard(
        tester,
        planOf(
          totalAssets: 680000000,
          targets: [
            ('Chứng khoán', 130000000, 3000),
            ('Vàng', 80000000, 2000),
            ('Crypto', 470000000, 5000),
          ],
        ),
      );

      expect(find.text('Mua thêm'), findsOneWidget);
      expect(find.text('Bán bớt'), findsOneWidget);

      expect(find.text('+74.000.000 đ'), findsOneWidget);
      expect(find.text('+56.000.000 đ'), findsOneWidget);
      expect(find.text('-130.000.000 đ'), findsOneWidget);

      // Hiện tại → Phân bổ chuẩn, đặt cạnh nhau.
      expect(find.text('Hiện 130.000.000 · chuẩn 204.000.000 đ'), findsOneWidget);
      expect(find.text('Hiện 470.000.000 · chuẩn 340.000.000 đ'), findsOneWidget);
    });

    testWidgets('việc lớn xếp trước', (tester) async {
      await pumpCard(
        tester,
        planOf(
          totalAssets: 680000000,
          targets: [
            ('Chứng khoán', 130000000, 3000),
            ('Vàng', 80000000, 2000),
            ('Crypto', 470000000, 5000),
          ],
        ),
      );

      final chungKhoan = tester.getTopLeft(find.text('Chứng khoán')).dy;
      final vang = tester.getTopLeft(find.text('Vàng')).dy;
      expect(
        chungKhoan,
        lessThan(vang),
        reason: 'mua 74 triệu phải đứng trên mua 56 triệu',
      );
    });

    testWidgets('đủ 100% thì kế hoạch tự cân', (tester) async {
      await pumpCard(
        tester,
        planOf(
          totalAssets: 680000000,
          targets: [
            ('Chứng khoán', 130000000, 3000),
            ('Vàng', 80000000, 2000),
            ('Crypto', 470000000, 5000),
          ],
        ),
      );

      expect(find.text('Kế hoạch tự cân'), findsOneWidget);
      expect(find.text('Cần nạp thêm'), findsNothing);
      expect(find.text('Đang ở lớp chưa đặt mục tiêu'), findsNothing);
    });

    testWidgets('chưa đủ 100% thì nói ra phần còn lại và tiền chênh',
        (tester) async {
      await pumpCard(
        tester,
        planOf(
          totalAssets: 100000000,
          targets: [
            ('Chứng khoán', 40000000, 4000),
            ('Vàng', 30000000, 3000),
          ],
        ),
      );

      // 70 triệu được phân bổ, 30 triệu đang nằm ở lớp chưa đặt mục tiêu.
      expect(find.text('Đang ở lớp chưa đặt mục tiêu'), findsOneWidget);
      expect(find.text('30.000.000 đ'), findsOneWidget);
      expect(find.text('Kế hoạch tự cân'), findsOneWidget);
    });

    testWidgets('đã đúng tỷ trọng thì không có lệnh nào', (tester) async {
      await pumpCard(
        tester,
        planOf(
          totalAssets: 100000000,
          targets: [
            ('Chứng khoán', 60000000, 6000),
            ('Vàng', 40000000, 4000),
          ],
        ),
      );

      expect(find.text('Mua thêm'), findsNothing);
      expect(find.text('Bán bớt'), findsNothing);
      expect(find.text('Đang cân'), findsOneWidget);
    });

    testWidgets('chưa có tài sản thì nói thẳng, không hiện bảng toàn số 0',
        (tester) async {
      await pumpCard(
        tester,
        planOf(totalAssets: 0, targets: [('Chứng khoán', 0, 10000)]),
      );

      expect(find.text('Chưa có tài sản để phân bổ.'), findsOneWidget);
      expect(find.text('Tổng mua'), findsNothing);
    });

    testWidgets('chưa đặt mục tiêu nào thì thẻ không chiếm chỗ', (tester) async {
      await pumpCard(tester, planOf(totalAssets: 100000000, targets: const []));
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('tên danh mục dài không làm vỡ bố cục', (tester) async {
      // Bố cục vỡ sẽ làm bài test đổ ngay ở `pumpCard`.
      await pumpCard(
        tester,
        planOf(
          totalAssets: 680000000,
          targets: [
            ('Tiền mặt và Tiết kiệm ngân hàng dài hạn', 130000000, 3000),
            ('Crypto', 550000000, 7000),
          ],
        ),
      );

      expect(find.textContaining('Tiền mặt và Tiết kiệm'), findsOneWidget);
    });
  });
}
