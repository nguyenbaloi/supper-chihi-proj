import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rsi_alert/data/candle_store.dart';
import 'package:rsi_alert/data/fear_greed_source.dart';
import 'package:rsi_alert/data/market_data_source.dart';
import 'package:rsi_alert/data/market_repository.dart';
import 'package:rsi_alert/data/weekly_reminder.dart';
import 'package:rsi_alert/domain/market_symbol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Hình dạng thật của alternative.me — mới nhất đứng đầu, số là chuỗi.
const sampleBody = '''
{"name":"Fear and Greed Index","data":[
 {"value":"20","value_classification":"Extreme Fear","timestamp":"1762992000"},
 {"value":"28","value_classification":"Fear","timestamp":"1762905600"}
],"metadata":{"error":null}}''';

void main() {
  group('FearGreedSource — FR-15, AD-13', () {
    test('parse đổi sang UTC theo ngày, xếp tăng dần', () {
      final points = FearGreedSource.parse(sampleBody);
      expect(points.map((p) => p.value), [28, 20]);
      expect(points.last.day, DateTime.utc(2025, 11, 13));
      expect(points.every((p) => p.day.isUtc), isTrue);
    });

    test('nội dung lạ thì ném parse, rỗng thì ném empty', () {
      expect(
        () => FearGreedSource.parse('<html>'),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.parse)),
      );
      expect(
        () => FearGreedSource.parse('{"data":[]}'),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.empty)),
      );
    });

    test('gọi đúng host alternative.me', () async {
      Uri? called;
      final source = FearGreedSource(
        client: MockClient((request) async {
          called = request.url;
          return http.Response(sampleBody, 200);
        }),
      );
      await source.fetchDaily();
      expect(called!.host, 'api.alternative.me');
    });
  });

  group('MarketRepository.loadFearGreed — AD-6', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<MarketRepository> repo(MockClient client) async => MarketRepository(
          store: await CandleStore.open(),
          sources: const {},
          fearGreedSource: FearGreedSource(client: client),
        );

    test('tải được thì lưu, lần sau hỏng thì rơi về kho chứ không ném', () async {
      final ok = await repo(MockClient((_) async => http.Response(sampleBody, 200)));
      final fresh = await ok.loadFearGreed();
      expect(fresh.staleness, Staleness.fresh);

      final broken = await repo(MockClient((_) async => http.Response('', 503)));
      final fallback = await broken.loadFearGreed();
      expect(fallback.staleness, Staleness.stale);
      expect(fallback.points, fresh.points);
    });

    test('hỏng và kho rỗng thì trả rỗng — Vùng vẫn xếp bằng RSI', () async {
      final broken = await repo(
        MockClient((_) async => throw Exception('mất mạng')),
      );
      final data = await broken.loadFearGreed();
      expect(data.staleness, Staleness.empty);
      expect(data.points, isEmpty);
    });

    test('AD-2: kho chỉ giữ điểm F&G thô, không giữ Vùng', () async {
      final ok = await repo(MockClient((_) async => http.Response(sampleBody, 200)));
      await ok.loadFearGreed();
      await ok.markDcaSeen(MarketSymbol.btc, DateTime.utc(2026, 11, 2));
      expect(ok.lastSeenDca(MarketSymbol.btc), DateTime.utc(2026, 11, 2));
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getKeys().map((k) => '$k=${prefs.get(k)}').join(' ');
      for (final banned in ['zone', 'rsi', 'status', 'signals', 'divergence']) {
        expect(raw.toLowerCase().contains(banned), isFalse,
            reason: 'AD-2: không được lưu "$banned"');
      }
    });
  });

  group('Lời nhắc sáng thứ Hai — FR-19', () {
    setUpAll(tzdata.initializeTimeZones);
    tz.Location vn() => tz.getLocation('Asia/Ho_Chi_Minh');

    test('từ thứ Sáu → 09:30 thứ Hai kế tiếp', () {
      final next = LocalNotificationWeeklyReminder.nextMondayMorning(
        tz.TZDateTime(vn(), 2026, 11, 13, 20),
      );
      expect(next, tz.TZDateTime(vn(), 2026, 11, 16, 9, 30));
    });

    test('đúng thứ Hai trước 09:30 → hôm nay; sau 09:30 → tuần sau', () {
      expect(
        LocalNotificationWeeklyReminder.nextMondayMorning(
          tz.TZDateTime(vn(), 2026, 11, 16, 8),
        ),
        tz.TZDateTime(vn(), 2026, 11, 16, 9, 30),
      );
      expect(
        LocalNotificationWeeklyReminder.nextMondayMorning(
          tz.TZDateTime(vn(), 2026, 11, 16, 9, 30),
        ),
        tz.TZDateTime(vn(), 2026, 11, 23, 9, 30),
      );
    });
  });
}
