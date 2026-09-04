import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rsi_alert/data/binance_source.dart';
import 'package:rsi_alert/data/market_data_source.dart';
import 'package:rsi_alert/data/ssi_source.dart';
import 'package:rsi_alert/data/vndirect_source.dart';

/// Mọi ca thử dùng một mốc "hiện tại" cố định thay vì đồng hồ thật, để kết quả
/// `isClosed` không đổi theo ngày chạy test.
final now = DateTime.utc(2026, 9, 4, 12);

String fixture(String name) =>
    File('test/fixtures/$name').readAsStringSync();

MockClient failing(int status, [String body = 'error']) =>
    MockClient((_) async => http.Response(body, status));

void main() {
  group('BinanceSource — FR-10', () {
    test('gọi đúng host .vision, không gọi api.binance.com', () async {
      late Uri seen;
      final source = BinanceSource(
        client: MockClient((request) async {
          seen = request.url;
          return http.Response(fixture('binance_klines_1w.json'), 200);
        }),
      );

      await source.fetchWeekly();

      expect(seen.host, 'data-api.binance.vision');
      expect(seen.path, '/api/v3/klines');
      expect(seen.queryParameters['symbol'], 'BTCUSDT');
      expect(seen.queryParameters['interval'], '1w');
    });

    test('đọc đúng dữ liệu mẫu thật', () {
      final candles =
          BinanceSource.parseKlines(fixture('binance_klines_1w.json'), now: now);

      expect(candles.length, greaterThan(400));
      expect(candles.first.openTime.isUtc, isTrue);
      for (var i = 1; i < candles.length; i++) {
        expect(
          candles[i].openTime.isAfter(candles[i - 1].openTime),
          isTrue,
          reason: 'chuỗi phải tăng dần theo thời gian',
        );
        expect(
          candles[i].openTime.difference(candles[i - 1].openTime),
          const Duration(days: 7),
        );
      }
      for (final candle in candles) {
        expect(candle.high, greaterThanOrEqualTo(candle.low));
        expect(candle.high, greaterThanOrEqualTo(candle.close));
        expect(candle.low, lessThanOrEqualTo(candle.close));
      }
    });

    test('AD-4: chỉ nến cuối chưa đóng khi tuần còn đang chạy', () {
      final candles =
          BinanceSource.parseKlines(fixture('binance_klines_1w.json'), now: now);

      expect(candles.last.isClosed, isFalse);
      expect(
        candles.take(candles.length - 1).every((c) => c.isClosed),
        isTrue,
      );
    });

    test('mốc rất xa trong tương lai thì mọi nến đều đã đóng', () {
      final candles = BinanceSource.parseKlines(
        fixture('binance_klines_1w.json'),
        now: DateTime.utc(2030),
      );
      expect(candles.every((c) => c.isClosed), isTrue);
    });

    test('HTTP khác 200 ném kind http', () async {
      final source = BinanceSource(client: failing(503));
      await expectLater(
        source.fetchWeekly(),
        throwsA(
          isA<MarketDataException>()
              .having((e) => e.kind, 'kind', MarketDataErrorKind.http),
        ),
      );
    });

    test('thân không phải JSON ném kind parse', () {
      expect(
        () => BinanceSource.parseKlines('<html>', now: now),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.parse)),
      );
    });

    test('mảng rỗng ném kind empty, không trả danh sách rỗng', () {
      expect(
        () => BinanceSource.parseKlines('[]', now: now),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.empty)),
      );
    });

    test('kline sai hình dạng ném kind parse', () {
      expect(
        () => BinanceSource.parseKlines('[[1, 2]]', now: now),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.parse)),
      );
    });

    test('mất mạng ném kind network', () async {
      final source = BinanceSource(
        client: MockClient((_) async => throw const SocketException('mất mạng')),
      );
      await expectLater(
        source.fetchWeekly(),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.network)),
      );
    });
  });

  group('SsiSource — FR-11 nguồn chính', () {
    test('gọi đúng endpoint với resolution=W', () async {
      late Uri seen;
      final source = SsiSource(
        client: MockClient((request) async {
          seen = request.url;
          return http.Response(fixture('ssi_vnindex_w.json'), 200);
        }),
      );

      await source.fetchWeekly();

      expect(seen.host, 'iboard-api.ssi.com.vn');
      expect(seen.queryParameters['symbol'], 'VNINDEX');
      expect(seen.queryParameters['resolution'], 'W');
    });

    test('đọc sáu mảng song song thành chuỗi nến tuần', () {
      final candles =
          SsiSource.parseBody(fixture('ssi_vnindex_w.json'), now: now);

      expect(candles.length, greaterThan(300));
      for (final candle in candles) {
        expect(candle.openTime.isUtc, isTrue);
        expect(candle.close, greaterThan(0));
      }
      for (var i = 1; i < candles.length; i++) {
        expect(
          candles[i].openTime.isAfter(candles[i - 1].openTime),
          isTrue,
          reason: 'chuỗi phải tăng dần theo thời gian',
        );
      }
    });

    test('khoảng cách giữa hai nến luôn là bội số của bảy ngày', () {
      // Chuỗi của SSI **thiếu hẳn** tuần nghỉ Tết mỗi năm — thị trường Việt
      // Nam không giao dịch tuần đó nên không có nến. Đây là dữ liệu đúng, và
      // RSI vẫn tính trên chuỗi giá đóng cửa liên tiếp như TradingView. Điều
      // phải giữ là mọi mốc vẫn rơi đúng vào thứ Hai.
      final candles =
          SsiSource.parseBody(fixture('ssi_vnindex_w.json'), now: now);

      for (var i = 1; i < candles.length; i++) {
        final gap = candles[i].openTime.difference(candles[i - 1].openTime);
        expect(
          gap.inDays % 7,
          0,
          reason: 'khoảng trống lạ giữa ${candles[i - 1].openTime} '
              'và ${candles[i].openTime}',
        );
      }
    });

    test('mốc mở tuần rơi vào thứ Hai giờ Việt Nam', () {
      final candles =
          SsiSource.parseBody(fixture('ssi_vnindex_w.json'), now: now);
      for (final candle in candles) {
        final vnTime = candle.openTime.add(const Duration(hours: 7));
        expect(vnTime.weekday, DateTime.monday);
      }
    });

    test('AD-4: nến tuần hiện tại chưa đóng', () {
      final candles =
          SsiSource.parseBody(fixture('ssi_vnindex_w.json'), now: now);
      expect(candles.last.isClosed, isFalse);
      expect(candles[candles.length - 2].isClosed, isTrue);
    });

    test('code khác SUCCESS ném kind http để rơi sang dự phòng', () {
      expect(
        () => SsiSource.parseBody(
          jsonEncode({'code': 'ERROR', 'message': 'hỏng'}),
          now: now,
        ),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.http)),
      );
    });

    test('mảng lệch độ dài ném kind parse', () {
      expect(
        () => SsiSource.parseBody(
          jsonEncode({
            'code': 'SUCCESS',
            'data': {
              't': [1, 2, 3],
              'o': [1, 2],
              'h': [1, 2, 3],
              'l': [1, 2, 3],
              'c': [1, 2, 3],
            },
          }),
          now: now,
        ),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.parse)),
      );
    });

    test('mảng t rỗng ném kind empty', () {
      expect(
        () => SsiSource.parseBody(
          jsonEncode({
            'code': 'SUCCESS',
            'data': {'t': [], 'o': [], 'h': [], 'l': [], 'c': []},
          }),
          now: now,
        ),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.empty)),
      );
    });
  });

  group('VndirectSource — FR-11 dự phòng', () {
    test('gọi resolution=D vì VNDirect không hỗ trợ W', () async {
      late Uri seen;
      final source = VndirectSource(
        client: MockClient((request) async {
          seen = request.url;
          return http.Response(fixture('vndirect_vnindex_d.json'), 200);
        }),
      );

      await source.fetchWeekly();

      expect(seen.host, 'dchart-api.vndirect.com.vn');
      expect(seen.queryParameters['resolution'], 'D');
      expect(seen.queryParameters['resolution'], isNot('W'));
    });

    test('phản hồi "Not support resolution W" ném kind http', () {
      expect(
        () => VndirectSource.parseBody('Not support resolution W', now: now),
        throwsA(isA<MarketDataException>()
            .having((e) => e.kind, 'kind', MarketDataErrorKind.http)),
      );
    });

    test('gộp nến ngày thành tuần bắt đầu thứ Hai giờ Việt Nam', () {
      final weekly =
          VndirectSource.parseBody(fixture('vndirect_vnindex_d.json'), now: now);

      expect(weekly, isNotEmpty);
      for (final candle in weekly) {
        final vnTime = candle.openTime.add(const Duration(hours: 7));
        expect(vnTime.weekday, DateTime.monday);
        expect(vnTime.hour, 0);
        expect(candle.high, greaterThanOrEqualTo(candle.low));
      }
      for (var i = 1; i < weekly.length; i++) {
        expect(weekly[i].openTime.isAfter(weekly[i - 1].openTime), isTrue);
      }
    });

    test('tuần nghỉ lễ chỉ có hai phiên vẫn tạo đúng một nến', () {
      final daily = <Map<String, dynamic>>[];
      // Thứ Tư và thứ Năm của cùng một tuần, giờ Việt Nam.
      for (final day in [DateTime.utc(2026, 4, 22, 2), DateTime.utc(2026, 4, 23, 2)]) {
        daily.add({'t': day.millisecondsSinceEpoch ~/ 1000});
      }
      final body = jsonEncode({
        't': [for (final d in daily) d['t']],
        'o': [100.0, 104.0],
        'h': [106.0, 108.0],
        'l': [99.0, 103.0],
        'c': [104.0, 107.0],
        'v': [10.0, 20.0],
      });

      final weekly = VndirectSource.parseBody(body, now: now);

      expect(weekly.length, 1);
      expect(weekly.single.open, 100.0);
      expect(weekly.single.close, 107.0);
      expect(weekly.single.high, 108.0);
      expect(weekly.single.low, 99.0);
      expect(weekly.single.volume, 30.0);
    });

    test('nến gộp khớp nến tuần trực tiếp của SSI trong 0.5 điểm', () {
      final fromVndirect =
          VndirectSource.parseBody(fixture('vndirect_vnindex_d.json'), now: now);
      final fromSsi =
          SsiSource.parseBody(fixture('ssi_vnindex_w.json'), now: now);

      final ssiByWeek = {for (final c in fromSsi) _mondayKey(c.openTime): c};

      var compared = 0;
      for (final candle in fromVndirect) {
        final counterpart = ssiByWeek[_mondayKey(candle.openTime)];
        if (counterpart == null) continue;
        // Bỏ qua tuần đang chạy: hai nguồn có thể chốt ở hai thời điểm khác nhau.
        if (!candle.isClosed || !counterpart.isClosed) continue;
        compared++;
        expect(
          (candle.close - counterpart.close).abs(),
          lessThanOrEqualTo(0.5),
          reason: 'giá đóng lệch ở tuần ${candle.openTime}',
        );
      }
      expect(compared, greaterThan(30), reason: 'phải so được nhiều tuần');
    });
  });
}

/// Khoá tuần theo ngày thứ Hai giờ Việt Nam, để so hai nguồn có mốc giờ khác
/// nhau (SSI đánh 02:00 UTC, bản gộp đánh 17:00 UTC hôm trước).
String _mondayKey(DateTime utcTime) {
  final vn = utcTime.add(const Duration(hours: 7));
  final monday = DateTime.utc(vn.year, vn.month, vn.day)
      .subtract(Duration(days: vn.weekday - 1));
  return '${monday.year}-${monday.month}-${monday.day}';
}
