import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rsi_alert/domain/candle.dart';
import 'package:rsi_alert/domain/dca.dart';
import 'package:rsi_alert/domain/market_symbol.dart';
import 'package:rsi_alert/ui/strings.dart';

import '../domain/signal_test.dart' show candlesWithRsi;
import 'overview_test.dart' show StubSource, flatSeries, pumpOverview;

/// BTC đóng tuần gần nhất ở RSI 40 — Vùng 2.
List<Candle> probeBuySeries({bool lastOpen = false}) =>
    candlesWithRsi([55, 50, 40], lastOpen: lastOpen);

void main() {
  setUpAll(() async => initializeDateFormatting('vi_VN'));

  final probeName = S.dcaZoneName(DcaZone.probeBuy);
  final probeRule =
      S.dcaQuotePrefix + S.dcaRule(MarketSymbol.btc, DcaZone.probeBuy);

  group('Vùng DCA — FR-14, FR-17', () {
    testWidgets('tuần đóng ở Vùng 2 thì có dải, trích đúng luật của cẩm nang',
        (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', probeBuySeries())],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      expect(find.text('BTC — $probeName'), findsOneWidget);
      // Một lần trong dải, một lần trong thẻ.
      expect(find.text(probeRule), findsNWidgets(2));
    });

    testWidgets('chạm dải thì đánh dấu đã xem, dải biến mất, thẻ vẫn giữ vùng',
        (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', probeBuySeries())],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      await tester.tap(find.text('BTC — $probeName'));
      await tester.pumpAndSettle();
      // Đóng bảng cẩm nang vừa mở.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('BTC — $probeName'), findsNothing);
      expect(find.text(probeName), findsWidgets);
    });

    testWidgets('Vùng Nắm giữ không có dải — im lặng là kết quả đúng (UJ-1)',
        (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', flatSeries())],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      expect(find.textContaining('BTC — Vùng'), findsNothing);
      expect(find.text(S.dcaZoneName(DcaZone.hold)), findsNWidgets(2));
    });

    testWidgets('AD-5: vùng của tuần đang chạy chỉ hiện dòng tạm tính, không có dải',
        (tester) async {
      // Tuần đóng gần nhất ở RSI 50 (Nắm giữ); tuần đang chạy tạm tính 40.
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [
          StubSource('Binance', probeBuySeries(lastOpen: true)),
        ],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      expect(find.textContaining('BTC — Vùng'), findsNothing);
      expect(find.text(S.dcaProvisional(DcaZone.probeBuy)), findsOneWidget);
    });

    testWidgets('mở cẩm nang thấy đủ năm vùng và luật phân kỳ', (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', flatSeries())],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      await tester.tap(find.text(S.dcaGuideOpen).first);
      await tester.pumpAndSettle();

      expect(find.text('${S.dcaGuideTitle} — BTC'), findsOneWidget);
      final sheet = find.byType(Scrollable).last;
      for (final zone in DcaZone.values) {
        final title = find.textContaining('${S.dcaZoneName(zone)}  ·  RSI');
        await tester.scrollUntilVisible(title, 120, scrollable: sheet);
        expect(title, findsOneWidget);
      }
      await tester.scrollUntilVisible(find.text(S.dcaDivergenceName), 120,
          scrollable: sheet);
      expect(find.text(S.dcaDivergenceName), findsOneWidget);
    });
  });
}
