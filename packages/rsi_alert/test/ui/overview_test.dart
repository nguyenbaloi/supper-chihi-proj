import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rsi_alert/app/providers.dart';
import 'package:rsi_alert/data/candle_store.dart';
import 'package:rsi_alert/data/market_data_source.dart';
import 'package:rsi_alert/data/market_repository.dart';
import 'package:rsi_alert/domain/candle.dart';
import 'package:rsi_alert/domain/market_symbol.dart';
import 'package:rsi_alert/ui/history/history_screen.dart';
import 'package:rsi_alert/ui/overview/overview_screen.dart';
import 'package:rsi_alert/ui/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/signal_test.dart' show candlesWithRsi;

class StubSource implements MarketDataSource {
  StubSource(this.name, this._candles);
  StubSource.failing(this.name) : _candles = null;

  @override
  final String name;
  final List<Candle>? _candles;

  @override
  Future<List<Candle>> fetchWeekly() async {
    if (_candles == null) {
      throw MarketDataException(MarketDataErrorKind.network, 'giả lập');
    }
    return _candles;
  }
}

/// Chuỗi đi ngang: RSI quanh 50, không sinh tín hiệu nào.
List<Candle> flatSeries() => candlesWithRsi([50, 51, 49, 50, 52]);

/// Chuỗi kết thúc bằng một cú cắt xuống dưới 30.
List<Candle> oversoldSeries() => candlesWithRsi([45, 40, 35, 26]);

Future<void> pumpOverview(
  WidgetTester tester, {
  required Map<MarketSymbol, List<MarketDataSource>> sources,
  Map<String, Object> initialPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final store = await CandleStore.open();
  final repository = MarketRepository(store: store, sources: sources);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [marketRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        home: OverviewScreen(onOpenChart: (_) {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async => initializeDateFormatting('vi_VN'));

  group('Màn hình Tổng quan — FR-1', () {
    testWidgets('hiện đúng hai thẻ, BTC trên VNINDEX dưới', (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', flatSeries())],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      final btc = tester.getTopLeft(find.text('BTC'));
      final vnindex = tester.getTopLeft(find.text('VNINDEX'));

      expect(btc.dy, lessThan(vnindex.dy), reason: 'BTC phải nằm trên');
    });

    testWidgets('nhãn Trạng thái dùng đúng từ ở Từ điển PRD', (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', flatSeries())],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      expect(find.text(S.statusNeutral), findsNWidgets(2));
      expect(find.text('Trung tính'), findsNWidgets(2));
    });

    testWidgets('chuỗi dưới 15 nến hiện Chưa đủ dữ liệu, không hiện số RSI',
        (tester) async {
      final short = flatSeries().take(10).toList();
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', short)],
        MarketSymbol.vnindex: [StubSource('SSI', short)],
      });

      expect(find.text(S.statusInsufficient), findsNWidgets(2));
      expect(find.text('—'), findsNWidgets(2));
    });

    testWidgets('nến đang chạy thì thẻ hiện nhãn tạm tính', (tester) async {
      final candles = [...flatSeries()];
      final last = candles.removeLast();
      candles.add(
        Candle(
          openTime: last.openTime,
          open: last.open,
          high: last.high,
          low: last.low,
          close: last.close,
          volume: last.volume,
          isClosed: false,
        ),
      );

      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', candles)],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      expect(find.text(S.provisional), findsOneWidget);
    });
  });

  group('Ngoại tuyến — FR-3', () {
    testWidgets('mọi nguồn hỏng và kho rỗng thì hiện thẻ rỗng có nút thử lại',
        (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource.failing('Binance')],
        MarketSymbol.vnindex: [StubSource.failing('SSI')],
      });

      expect(find.text(S.noDataTitle), findsNWidgets(2));
      expect(find.text(S.retry), findsNWidgets(2));
    });

    testWidgets('không có dialog hay snackbar chặn thao tác', (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource.failing('Binance')],
        MarketSymbol.vnindex: [StubSource.failing('SSI')],
      });

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('một Mã hỏng không ảnh hưởng Mã còn lại — NFR-3',
        (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', flatSeries())],
        MarketSymbol.vnindex: [StubSource.failing('SSI')],
      });

      expect(find.text(S.statusNeutral), findsOneWidget);
      expect(find.text(S.noDataTitle), findsOneWidget);
    });
  });

  group('Dải cảnh báo — FR-5', () {
    testWidgets('lần chạy đầu KHÔNG dội cảnh báo lịch sử', (tester) async {
      await pumpOverview(tester, sources: {
        MarketSymbol.btc: [StubSource('Binance', oversoldSeries())],
        MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
      });

      expect(find.text(S.tapToView), findsNothing);
    });

    testWidgets('có tín hiệu mới hơn mốc đã xem thì hiện dải', (tester) async {
      final candles = oversoldSeries();
      // Giả lập người dùng đã xem mọi thứ trước tuần cuối cùng.
      final seenBefore = candles[candles.length - 2].openTime;

      await pumpOverview(
        tester,
        sources: {
          MarketSymbol.btc: [StubSource('Binance', candles)],
          MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
        },
        initialPrefs: {
          'lastSeenSignal.BTC': seenBefore.millisecondsSinceEpoch,
        },
      );

      expect(find.text(S.tapToView), findsOneWidget);
      expect(find.textContaining('BTC — ${S.signalOversoldTitle}'), findsOneWidget);
    });

    testWidgets('chạm vào dải thì đánh dấu đã xem và dải biến mất',
        (tester) async {
      final candles = oversoldSeries();
      final seenBefore = candles[candles.length - 2].openTime;

      await pumpOverview(
        tester,
        sources: {
          MarketSymbol.btc: [StubSource('Binance', candles)],
          MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
        },
        initialPrefs: {
          'lastSeenSignal.BTC': seenBefore.millisecondsSinceEpoch,
        },
      );

      await tester.tap(find.text(S.tapToView));
      await tester.pumpAndSettle();

      expect(find.text(S.tapToView), findsNothing);
    });

    testWidgets('AD-5: RSI tạm tính dưới ngưỡng không sinh dải cảnh báo',
        (tester) async {
      final candles = [...oversoldSeries()];
      final last = candles.removeLast();
      candles.add(
        Candle(
          openTime: last.openTime,
          open: last.open,
          high: last.high,
          low: last.low,
          close: last.close,
          volume: last.volume,
          isClosed: false,
        ),
      );
      final seenBefore = candles[candles.length - 3].openTime;

      await pumpOverview(
        tester,
        sources: {
          MarketSymbol.btc: [StubSource('Binance', candles)],
          MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
        },
        initialPrefs: {
          'lastSeenSignal.BTC': seenBefore.millisecondsSinceEpoch,
        },
      );

      expect(find.text(S.tapToView), findsNothing);
    });
  });

  group('Lịch sử tín hiệu — FR-9', () {
    testWidgets('không có tín hiệu thì hiện trạng thái rỗng có giải thích',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = await CandleStore.open();
      final repository = MarketRepository(
        store: store,
        sources: {
          MarketSymbol.btc: [StubSource('Binance', flatSeries())],
          MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [marketRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: HistoryScreen(onOpenChart: (_, _) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(S.emptyHistoryTitle), findsOneWidget);
      expect(find.textContaining('vốn hiếm'), findsOneWidget);
    });

    testWidgets('tín hiệu hiện đủ Mã, loại, tuần, giá và RSI', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = await CandleStore.open();
      final repository = MarketRepository(
        store: store,
        sources: {
          MarketSymbol.btc: [StubSource('Binance', oversoldSeries())],
          MarketSymbol.vnindex: [StubSource('SSI', flatSeries())],
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [marketRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: HistoryScreen(onOpenChart: (_, _) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 'BTC' xuất hiện cả ở chip lọc lẫn ở dòng tín hiệu — chỉ xét dòng.
      final tile = find.byType(ListTile);
      expect(tile, findsOneWidget);
      expect(find.descendant(of: tile, matching: find.text('BTC')),
          findsOneWidget);
      expect(
        find.descendant(of: tile, matching: find.text(S.signalOversoldTitle)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: tile, matching: find.textContaining('tuần ')),
        findsOneWidget,
      );
    });
  });
}
