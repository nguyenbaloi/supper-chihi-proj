import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/l10n/l10n_delegates.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/models/asset_class.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/models/portfolio_valuation.dart';
import 'package:personal_finance/features/targets/targets_screen.dart';
import 'package:personal_finance/presentation/providers/portfolio_providers.dart';

AssetClass _class(int id, String name, AssetKind kind, int? targetWeightBp) =>
    AssetClass(
      id: id,
      name: name,
      kind: kind,
      iconCodePoint: 0xe3af,
      colorValue: 0xff2196f3,
      sortOrder: id,
      targetWeightBp: targetWeightBp,
    );

/// Danh mục 740 triệu, đặt đủ 100% mục tiêu. Chứng khoán đang thiếu, Crypto
/// đang thừa — đủ để kiểm cả hai chiều.
PortfolioValuation _valuation({String cashName = 'Tiền mặt & Tiết kiệm'}) =>
    PortfolioValuation([
      AssetClassValuation(
          _class(1, 'Chứng khoán', AssetKind.stock, 1000), const Money(59500000)),
      AssetClassValuation(
          _class(2, 'Vàng', AssetKind.gold, 1500), const Money(106000000)),
      AssetClassValuation(
          _class(3, 'Crypto', AssetKind.crypto, 5000), const Money(390000000)),
      AssetClassValuation(_class(4, cashName, AssetKind.cashSavings, 1500),
          const Money(52000000)),
      AssetClassValuation(
          _class(5, 'Cho vay', AssetKind.lending, 1000), const Money(132500000)),
    ]);

Future<void> _pump(WidgetTester tester, PortfolioValuation valuation) async {
  final view = tester.view;
  view.devicePixelRatio = 1.0;
  // Cao để dựng hết danh sách; hẹp để bắt lỗi tràn bố cục.
  view.physicalSize = const Size(360, 3000);
  addTearDown(() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        portfolioValuationProvider.overrideWith((ref) => Stream.value(valuation)),
        targetGroupsProvider.overrideWith((ref) => Stream.value(const [])),
        actionNotesProvider.overrideWith((ref) => const Stream.empty()),
        settingsProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppL10nDelegates.delegates,
        supportedLocales: AppL10nDelegates.locales,
        home: const TargetsScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Biểu đồ thanh nằm ngang', () {
    testWidgets('mỗi danh mục có một hàng, kèm mức chuẩn và số tiền lệch',
        (tester) async {
      await _pump(tester, _valuation());

      expect(find.text('Thực tế so với chuẩn'), findsOneWidget);

      // Thực tế bên trái, chuẩn kèm số tiền bên phải.
      expect(find.text('thực tế 8,0%'), findsOneWidget);
      expect(find.text('thực tế 52,7%'), findsOneWidget);
      expect(find.text('chuẩn 50,0% · 370 tr'), findsOneWidget);
      // Chứng khoán và Cho vay cùng đặt 10% nên cùng một mức chuẩn.
      expect(find.text('chuẩn 10,0% · 74 tr'), findsNWidgets(2));
    });

    testWidgets('số tiền lệch theo khung hành động, không phải thừa/thiếu',
        (tester) async {
      await _pump(tester, _valuation());

      // Thiếu là dương và "Mua thêm"; thừa là âm và "Bán bớt".
      expect(find.text('+14,5 tr'), findsWidgets);
      expect(find.text('-20 tr'), findsWidgets);
      expect(find.text('Đang thừa'), findsNothing);
      expect(find.text('Đang thiếu'), findsNothing);
    });

    testWidgets('tên dài không chồng lên nhau như biểu đồ cột dọc cũ',
        (tester) async {
      // Bố cục vỡ sẽ làm bài test đổ ngay ở `_pump`.
      await _pump(
        tester,
        _valuation(cashName: 'Tiền mặt và Tiết kiệm ngân hàng dài hạn'),
      );

      expect(
        find.text('Tiền mặt và Tiết kiệm ngân hàng dài hạn'),
        findsWidgets,
      );
    });
  });

  group('Cả màn hình nói một thứ tiếng', () {
    testWidgets('thẻ Khoảng lệch và Kế hoạch phân bổ khớp từng con số',
        (tester) async {
      await _pump(tester, _valuation());

      // Kế hoạch phân bổ ghi đủ chữ số, thẻ Khoảng lệch và biểu đồ ghi rút
      // gọn — cùng một con số, hai độ chi tiết.
      expect(find.text('+14.500.000 đ'), findsOneWidget);
      expect(find.text('+14,5 tr'), findsNWidgets(2));

      expect(find.text('-58.500.000 đ'), findsOneWidget);
      expect(find.text('-58,5 tr'), findsNWidgets(2));
    });

    testWidgets('kế hoạch tự cân khi mục tiêu đủ 100%', (tester) async {
      await _pump(tester, _valuation());
      expect(find.text('Kế hoạch tự cân'), findsOneWidget);
      expect(find.textContaining('không phải 100%'), findsNothing);
    });
  });
}
