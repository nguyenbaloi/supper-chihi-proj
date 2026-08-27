import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/l10n/l10n_delegates.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/models/app_settings.dart';
import 'package:personal_finance/domain/models/asset_class.dart';
import 'package:personal_finance/domain/models/cash_flow.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/models/fx_rate.dart';
import 'package:personal_finance/domain/models/portfolio_valuation.dart';
import 'package:personal_finance/domain/rules/portfolio_math.dart';
import 'package:personal_finance/features/dashboard/dashboard_screen.dart';
import 'package:personal_finance/presentation/providers/portfolio_providers.dart';

/// Bốn lớp tài sản với đúng con số Excel gốc: 15, 92, 390, 183 triệu.
AssetClass _class(int id, String name, AssetKind kind) => AssetClass(
      id: id,
      name: name,
      kind: kind,
      colorValue: 0xFF1565C0,
      iconCodePoint: 0xe67f,
      sortOrder: id,
      inInvestmentGroup: kind == AssetKind.stock || kind == AssetKind.crypto,
    );

PortfolioValuation _excelValuation() => PortfolioMath.valuation(
      [
        _class(1, 'Chứng khoán', AssetKind.stock),
        _class(2, 'Tiền mặt & Tiết kiệm', AssetKind.cashSavings),
        _class(3, 'Crypto', AssetKind.crypto),
        _class(4, 'Cho vay', AssetKind.lending),
      ],
      const {
        1: Money(15000000),
        2: Money(92000000),
        3: Money(390000000),
        4: Money(183000000),
      },
    );

final _settings = AppSettings(
  initialContributionAmount: const Money(341000000),
  startDate: DateTime.utc(2026, 1, 1),
  onboardingCompleted: true,
);

/// Dựng màn hình trên dữ liệu thuần.
///
/// Không đụng tới cơ sở dữ liệu: test giao diện phải kiểm chứng cách con số
/// được **hiển thị**, còn cách con số được **tính** đã có test riêng ở tầng
/// domain và data.
/// Dựng màn hình trên dữ liệu thuần.
///
/// Không đụng tới cơ sở dữ liệu: test giao diện phải kiểm chứng cách con số
/// được **hiển thị**, còn cách con số được **tính** đã có test riêng ở tầng
/// domain và data.
Widget _harness(
  Widget child, {
  PortfolioValuation? valuation,
  List<CashFlow> cashFlows = const [],
}) =>
    ProviderScope(
      overrides: [
        portfolioValuationProvider.overrideWith(
          (ref) => Stream.value(valuation ?? _excelValuation()),
        ),
        settingsProvider.overrideWith((ref) => Stream.value(_settings)),
        cashFlowsProvider.overrideWith((ref) => Stream.value(cashFlows)),
        assetClassesProvider.overrideWith((ref) => Stream.value(const [])),
        effectiveFxRateProvider.overrideWith(
          (ref) async => const FxRate(
            rateAmount: Money(25000),
            source: PriceSource.manual,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppL10nDelegates.delegates,
        supportedLocales: AppL10nDelegates.locales,
        home: child,
      ),
    );

void main() {
  group('Màn hình tổng quan', () {
    setUp(() {
      // Khung mặc định 800×600 quá thấp: ListView chỉ dựng phần nhìn thấy,
      // nên các lớp tài sản giá trị nhỏ không tồn tại trong cây widget và
      // phép tìm sẽ trượt vì lý do không liên quan gì tới điều đang kiểm.
      final view = TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first;
      view.physicalSize = const Size(1200, 3200);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });
    });

    testWidgets('tổng tài sản là con số nổi bật nhất', (tester) async {
      await tester.pumpWidget(_harness(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('680.000.000 đ'), findsOneWidget);
    });

    testWidgets('nhãn tỷ trọng khớp đúng bốn con số của Excel', (tester) async {
      await tester.pumpWidget(_harness(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('2,2%'), findsWidgets);
      expect(find.text('13,5%'), findsWidgets);
      expect(find.text('57,4%'), findsWidgets);
      expect(find.text('26,9%'), findsWidgets);
    });

    testWidgets('danh sách lớp tài sản sắp theo giá trị giảm dần',
        (tester) async {
      await tester.pumpWidget(_harness(const DashboardScreen()));
      await tester.pumpAndSettle();

      final tiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      final names = tiles
          .map((t) => t.title)
          .whereType<Row>()
          .map((row) => (row.children.first as Flexible).child)
          .whereType<Text>()
          .map((t) => t.data)
          .toList();

      expect(names, [
        'Crypto',
        'Cho vay',
        'Tiền mặt & Tiết kiệm',
        'Chứng khoán',
      ]);
    });

    testWidgets('lãi lỗ hiện ngay trên màn hình tổng quan', (tester) async {
      await tester.pumpWidget(_harness(const DashboardScreen()));
      await tester.pumpAndSettle();

      // Nhóm đầu tư 15 + 390 = 405, vốn góp 341, lãi 64 triệu.
      expect(find.text('+64.000.000 đ'), findsOneWidget);
    });

    testWidgets('danh mục rỗng hiện lời giải thích chứ không phải số 0 trần',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          const DashboardScreen(),
          valuation: PortfolioValuation.empty,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Danh mục còn trống'), findsOneWidget);
    });

    testWidgets('lớp thiếu giá được nói rõ, không lặng lẽ tính bằng 0',
        (tester) async {
      final valuation = PortfolioMath.valuation(
        [_class(1, 'Chứng khoán', AssetKind.stock)],
        const {1: Money(15000000)},
        unpricedByAssetClassId: const {1: 3},
      );

      await tester.pumpWidget(
        _harness(const DashboardScreen(), valuation: valuation),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 khoản chưa có giá'), findsWidgets);
    });
  });
}
