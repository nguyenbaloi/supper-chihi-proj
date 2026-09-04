import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rsi_alert/data/candle_store.dart';
import 'package:rsi_alert/data/market_data_source.dart';
import 'package:rsi_alert/data/market_repository.dart';
import 'package:rsi_alert/domain/candle.dart';
import 'package:rsi_alert/domain/market_symbol.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Candle> series(int count, {DateTime? start}) {
  var time = start ?? DateTime.utc(2026, 1, 5);
  return [
    for (var i = 0; i < count; i++)
      () {
        final candle = Candle(
          openTime: time,
          open: 100.0 + i,
          high: 105.0 + i,
          low: 95.0 + i,
          close: 102.0 + i,
          volume: 1000.0 + i,
          isClosed: true,
        );
        time = time.add(const Duration(days: 7));
        return candle;
      }(),
  ];
}

/// Nguồn giả: hoặc trả về chuỗi đã định, hoặc ném lỗi đã định.
class FakeSource implements MarketDataSource {
  FakeSource.ok(this.name, this._candles) : _error = null;
  FakeSource.failing(this.name, this._error) : _candles = null;

  @override
  final String name;
  final List<Candle>? _candles;
  final MarketDataException? _error;

  int calls = 0;

  @override
  Future<List<Candle>> fetchWeekly() async {
    calls++;
    if (_error != null) throw _error;
    return _candles!;
  }
}

MarketDataException boom(MarketDataErrorKind kind) =>
    MarketDataException(kind, 'giả lập');

void main() {
  late CandleStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await CandleStore.open();
  });

  group('CandleStore — FR-12, AD-9', () {
    test('chưa có gì thì load trả null', () {
      expect(store.load(MarketSymbol.btc), isNull);
    });

    test('đi qua save/load giữ nguyên mọi trường và tính UTC', () async {
      final candles = series(5);
      final at = DateTime.utc(2026, 9, 4, 8, 30);

      await store.save(MarketSymbol.btc, candles, at);
      final loaded = store.load(MarketSymbol.btc)!;

      expect(loaded.candles, candles);
      expect(loaded.fetchedAt, at);
      expect(loaded.candles.every((c) => c.openTime.isUtc), isTrue);
    });

    test('save là thay toàn bộ, không merge', () async {
      await store.save(MarketSymbol.btc, series(500), DateTime.utc(2026));
      await store.save(MarketSymbol.btc, series(480), DateTime.utc(2026));

      expect(store.load(MarketSymbol.btc)!.candles.length, 480);
    });

    test('AD-2: JSON đã lưu không chứa trường suy ra', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final freshStore = CandleStore(prefs);
      await freshStore.save(MarketSymbol.vnindex, series(3), DateTime.utc(2026));

      final raw = prefs.getString('candles.VNINDEX')!;
      for (final banned in ['"rsi"', '"status"', '"signals"', '"lastRsi"']) {
        expect(raw.contains(banned), isFalse, reason: 'AD-2: bỏ $banned');
      }
    });

    test('phiên bản lược đồ khác thì bỏ dữ liệu, không ném lỗi', () async {
      SharedPreferences.setMockInitialValues({
        'candles.BTC': jsonEncode({'v': 99, 'fetchedAt': 0, 'candles': []}),
      });
      final legacyStore = CandleStore(await SharedPreferences.getInstance());

      expect(legacyStore.load(MarketSymbol.btc), isNull);
    });

    test('bản ghi hỏng thì bỏ, không ném lỗi', () async {
      SharedPreferences.setMockInitialValues({'candles.BTC': 'không phải json'});
      final brokenStore = CandleStore(await SharedPreferences.getInstance());

      expect(brokenStore.load(MarketSymbol.btc), isNull);
    });

    test('mốc tín hiệu đã xem lưu riêng theo từng Mã', () async {
      final week = DateTime.utc(2026, 8, 24);
      await store.saveLastSeenSignal(MarketSymbol.btc, week);

      expect(store.loadLastSeenSignal(MarketSymbol.btc), week);
      expect(store.loadLastSeenSignal(MarketSymbol.vnindex), isNull);
    });

    test('cấu hình ThemeMode lưu và tải chính xác', () async {
      expect(store.loadThemeMode(), ThemeMode.system);
      await store.saveThemeMode(ThemeMode.dark);
      expect(store.loadThemeMode(), ThemeMode.dark);
      await store.saveThemeMode(ThemeMode.light);
      expect(store.loadThemeMode(), ThemeMode.light);
    });
  });

  group('MarketRepository — FR-2, FR-3, AD-6', () {
    test('nguồn chính thành công cho staleness fresh và ghi vào kho', () async {
      final source = FakeSource.ok('Chính', series(20));
      final repo = MarketRepository(
        store: store,
        sources: {MarketSymbol.btc: [source]},
      );

      final data = await repo.load(MarketSymbol.btc);

      expect(data.staleness, Staleness.fresh);
      expect(data.sourceName, 'Chính');
      expect(data.candles.length, 20);
      expect(data.errorKind, isNull);
      expect(store.load(MarketSymbol.btc)!.candles.length, 20);
    });

    test('nguồn chính hỏng thì thử nguồn dự phòng', () async {
      final primary = FakeSource.failing('SSI', boom(MarketDataErrorKind.http));
      final backup = FakeSource.ok('VNDirect', series(30));
      final repo = MarketRepository(
        store: store,
        sources: {MarketSymbol.vnindex: [primary, backup]},
      );

      final data = await repo.load(MarketSymbol.vnindex);

      expect(primary.calls, 1);
      expect(backup.calls, 1);
      expect(data.staleness, Staleness.fresh);
      expect(data.sourceName, 'VNDirect');
    });

    test('nguồn chính chạy được thì không gọi tới dự phòng', () async {
      final primary = FakeSource.ok('SSI', series(30));
      final backup = FakeSource.ok('VNDirect', series(30));
      final repo = MarketRepository(
        store: store,
        sources: {MarketSymbol.vnindex: [primary, backup]},
      );

      await repo.load(MarketSymbol.vnindex);

      expect(backup.calls, 0);
    });

    test('mọi nguồn hỏng nhưng kho có dữ liệu thì trả stale', () async {
      await store.save(MarketSymbol.btc, series(12), DateTime.utc(2026, 9, 1));
      final repo = MarketRepository(
        store: store,
        sources: {
          MarketSymbol.btc: [
            FakeSource.failing('A', boom(MarketDataErrorKind.network)),
            FakeSource.failing('B', boom(MarketDataErrorKind.http)),
          ],
        },
      );

      final data = await repo.load(MarketSymbol.btc);

      expect(data.staleness, Staleness.stale);
      expect(data.candles.length, 12);
      expect(data.fetchedAt, DateTime.utc(2026, 9, 1));
      expect(data.errorKind, MarketDataErrorKind.http, reason: 'lỗi cuối cùng');
    });

    test('mọi nguồn hỏng và kho rỗng thì trả empty', () async {
      final repo = MarketRepository(
        store: store,
        sources: {
          MarketSymbol.btc: [
            FakeSource.failing('A', boom(MarketDataErrorKind.network)),
          ],
        },
      );

      final data = await repo.load(MarketSymbol.btc);

      expect(data.staleness, Staleness.empty);
      expect(data.candles, isEmpty);
      expect(data.fetchedAt, isNull);
    });

    test('AD-6: lỗi lạ ngoài MarketDataException cũng không vượt biên', () async {
      final repo = MarketRepository(
        store: store,
        sources: {
          MarketSymbol.btc: [_ExplodingSource()],
        },
      );

      final data = await repo.load(MarketSymbol.btc);

      expect(data.staleness, Staleness.empty);
    });

    test('nguồn trả chuỗi rỗng bị coi là hỏng và rơi sang dự phòng', () async {
      final empty = FakeSource.ok('Rỗng', const []);
      final backup = FakeSource.ok('Dự phòng', series(16));
      final repo = MarketRepository(
        store: store,
        sources: {MarketSymbol.vnindex: [empty, backup]},
      );

      final data = await repo.load(MarketSymbol.vnindex);

      expect(data.sourceName, 'Dự phòng');
      expect(data.staleness, Staleness.fresh);
    });

    test('cached() đọc được ngay mà không chạm mạng — NFR-1', () async {
      await store.save(MarketSymbol.btc, series(8), DateTime.utc(2026, 9, 2));
      final source = FakeSource.ok('Chính', series(20));
      final repo = MarketRepository(
        store: store,
        sources: {MarketSymbol.btc: [source]},
      );

      final data = repo.cached(MarketSymbol.btc);

      expect(source.calls, 0);
      expect(data.candles.length, 8);
      expect(data.staleness, Staleness.stale);
    });

    test('một Mã hỏng không chặn Mã còn lại — NFR-3', () async {
      final repo = MarketRepository(
        store: store,
        sources: {
          MarketSymbol.btc: [FakeSource.ok('Binance', series(20))],
          MarketSymbol.vnindex: [
            FakeSource.failing('SSI', boom(MarketDataErrorKind.network)),
          ],
        },
      );

      final results = await Future.wait([
        repo.load(MarketSymbol.btc),
        repo.load(MarketSymbol.vnindex),
      ]);

      expect(results[0].staleness, Staleness.fresh);
      expect(results[1].staleness, Staleness.empty);
    });

    test('không cấu hình nguồn nào thì vẫn trả về, không ném', () async {
      final repo = MarketRepository(store: store, sources: const {});
      expect((await repo.load(MarketSymbol.btc)).staleness, Staleness.empty);
    });
  });
}

class _ExplodingSource implements MarketDataSource {
  @override
  String get name => 'Nổ';

  @override
  Future<List<Candle>> fetchWeekly() async => throw StateError('lỗi lạ');
}
