// ignore_for_file: avoid_print — công cụ dòng lệnh, in ra là mục đích.
// Phân tích kiểm chứng công thức DCA theo RSI tuần + Fear & Greed.
//
// Chạy: fvm dart run tool/phan_tich_dca.dart
//
// Dùng đúng computeRsi của app trên nến ĐÃ ĐÓNG. F&G crypto lấy từ
// alternative.me (chỉ công cụ này gọi, app không gọi).
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:rsi_alert/data/binance_source.dart';
import 'package:rsi_alert/data/market_data_source.dart';
import 'package:rsi_alert/data/ssi_source.dart';
import 'package:rsi_alert/data/vndirect_source.dart';
import 'package:rsi_alert/domain/candle.dart';
import 'package:rsi_alert/domain/dca.dart';
import 'package:rsi_alert/domain/market_symbol.dart';
import 'package:rsi_alert/domain/rsi.dart';

class Week {
  Week(this.t, this.close, this.rsi);
  final DateTime t;
  final double close;
  final double rsi;
  int? fng;
}

String d(DateTime t) => t.toIso8601String().substring(0, 10);

Future<List<Week>> load(List<MarketDataSource> sources) async {
  List<Candle>? candles;
  for (final s in sources) {
    try {
      candles = await s.fetchWeekly();
      break;
    } on MarketDataException catch (e) {
      print('! ${s.name}: ${e.message}');
    }
  }
  final closed = candles!.where((c) => c.isClosed).toList();
  final rsi = computeRsi([for (final c in closed) c.close]);
  final provisional = candles.last.isClosed
      ? null
      : computeRsi([for (final c in candles) c.close]).last.value;
  print('  nến đóng: ${closed.length}, từ ${d(closed.first.openTime)} '
      'đến ${d(closed.last.openTime)}; RSI đóng gần nhất '
      '${rsi.last.value.toStringAsFixed(1)}'
      '${provisional == null ? '' : ', tạm tính ${provisional.toStringAsFixed(1)}'}'
      ', giá ${candles.last.close.toStringAsFixed(0)}');
  return [
    for (final p in rsi)
      Week(closed[p.candleIndex].openTime, closed[p.candleIndex].close, p.value),
  ];
}

Future<Map<String, int>> loadFng() async {
  final res = await http
      .get(Uri.parse('https://api.alternative.me/fng/?limit=0&format=json'));
  final data = (jsonDecode(res.body)['data'] as List).cast<Map>();
  return {
    for (final e in data)
      d(DateTime.fromMillisecondsSinceEpoch(
          int.parse(e['timestamp'] as String) * 1000,
          isUtc: true)): int.parse(e['value'] as String),
  };
}

/// Bảng cực trị theo năm để đối chiếu với PDF.
void extremes(String name, List<Week> w) {
  print('\n--- $name: RSI tuần thấp/cao nhất mỗi năm ---');
  final years = w.map((e) => e.t.year).toSet().toList()..sort();
  for (final y in years) {
    final ys = w.where((e) => e.t.year == y).toList();
    final lo = ys.reduce((a, b) => a.rsi < b.rsi ? a : b);
    final hi = ys.reduce((a, b) => a.rsi > b.rsi ? a : b);
    print('$y  min ${lo.rsi.toStringAsFixed(1).padLeft(5)} (${d(lo.t)} '
        '@${lo.close.toStringAsFixed(0)})   max '
        '${hi.rsi.toStringAsFixed(1).padLeft(5)} (${d(hi.t)} '
        '@${hi.close.toStringAsFixed(0)})');
  }
}

/// Lợi nhuận kỳ hạn sau các tuần nằm trong từng vùng RSI.
void forward(String name, List<Week> w, List<double> cuts) {
  print('\n--- $name: lợi nhuận sau N tuần, theo vùng RSI đóng tuần '
      '(ngưỡng $cuts) ---');
  print('vùng            số tuần   +26w trung vị  +52w trung vị  +52w % dương'
      '  +104w trung vị');
  final labels = [
    '≤ ${cuts[0]}',
    '${cuts[0]}–${cuts[1]}',
    '${cuts[1]}–${cuts[2]}',
    '${cuts[2]}–${cuts[3]}',
    '> ${cuts[3]}',
  ];
  int zone(double r) {
    if (r <= cuts[0]) return 0;
    if (r <= cuts[1]) return 1;
    if (r <= cuts[2]) return 2;
    if (r <= cuts[3]) return 3;
    return 4;
  }

  double med(List<double> x) {
    if (x.isEmpty) return double.nan;
    x.sort();
    return x[x.length ~/ 2];
  }

  for (var z = 0; z < 5; z++) {
    final idx = [
      for (var i = 0; i < w.length; i++)
        if (zone(w[i].rsi) == z) i,
    ];
    List<double> f(int n) => [
          for (final i in idx)
            if (i + n < w.length) (w[i + n].close / w[i].close - 1) * 100,
        ];
    final f52 = f(52);
    final pos = f52.isEmpty
        ? double.nan
        : f52.where((x) => x > 0).length / f52.length * 100;
    String p(double v) => v.isNaN ? '   –' : '${v.toStringAsFixed(0)}%';
    print('${labels[z].padRight(14)} ${idx.length.toString().padLeft(6)}  '
        '${p(med(f(26))).padLeft(13)}  ${p(med(f52)).padLeft(13)}  '
        '${p(pos).padLeft(11)}  ${p(med(f(104))).padLeft(14)}');
  }
}

/// Các đợt (episode) RSI nằm trong vùng: bắt đầu, số tuần, giá thấp/cao.
void episodes(String name, List<Week> w, bool Function(Week) inZone,
    String label) {
  print('\n--- $name: các đợt $label ---');
  var i = 0;
  while (i < w.length) {
    if (!inZone(w[i])) {
      i++;
      continue;
    }
    final start = i;
    while (i < w.length && inZone(w[i])) {
      i++;
    }
    final seg = w.sublist(start, i);
    final lo = seg.map((e) => e.close).reduce(math.min);
    final hi = seg.map((e) => e.close).reduce(math.max);
    final rlo = seg.map((e) => e.rsi).reduce(math.min);
    final rhi = seg.map((e) => e.rsi).reduce(math.max);
    print('${d(seg.first.t)} → ${d(seg.last.t)}  ${seg.length} tuần  '
        'RSI ${rlo.toStringAsFixed(1)}–${rhi.toStringAsFixed(1)}  '
        'giá ${lo.toStringAsFixed(0)}–${hi.toStringAsFixed(0)}');
  }
}

/// Mô phỏng: mỗi tuần có 1 đơn vị tiền. So DCA đều với DCA theo vùng.
void simulate(String name, List<Week> w, List<double> cuts, DateTime from) {
  final ws = w.where((e) => !e.t.isBefore(from)).toList();
  // A: DCA đều mỗi tuần.
  var unitsA = 0.0, cashInA = 0.0;
  for (final e in ws) {
    unitsA += 1 / e.close;
    cashInA += 1;
  }
  // B: tiền tích luỹ mỗi tuần; mua theo vùng, bán theo vùng.
  var cash = 0.0, units = 0.0, cashIn = 0.0;
  for (final e in ws) {
    cash += 1;
    cashIn += 1;
    double buyFrac = 0, sellFrac = 0;
    if (e.rsi <= cuts[0]) {
      buyFrac = 1 / 6; // giải ngân dần trong ~6 tuần
    } else if (e.rsi <= cuts[1]) {
      buyFrac = 1 / 10; // thăm dò
    } else if (e.rsi > cuts[3]) {
      sellFrac = 0.15; // 15%/tuần khi quá mua cực đại
    } else if (e.rsi > cuts[2]) {
      sellFrac = 0.05; // bán rải
    }
    final spend = cash * buyFrac;
    units += spend / e.close;
    cash -= spend;
    final sell = units * sellFrac;
    cash += sell * e.close;
    units -= sell;
  }
  final last = ws.last.close;
  final valA = unitsA * last;
  final valB = units * last + cash;
  print('\n--- $name: mô phỏng từ ${d(from)} (${ws.length} tuần, nạp 1/tuần) ---');
  print('DCA đều     : nạp ${cashInA.toStringAsFixed(0)} → '
      '${valA.toStringAsFixed(0)} (x${(valA / cashInA).toStringAsFixed(2)})');
  print('DCA theo vùng: nạp ${cashIn.toStringAsFixed(0)} → '
      '${valB.toStringAsFixed(0)} (x${(valB / cashIn).toStringAsFixed(2)}) '
      '— trong đó tiền mặt chờ ${cash.toStringAsFixed(0)} '
      '(${(cash / valB * 100).toStringAsFixed(0)}%)');
}

Future<void> main() async {
  print('BTC:');
  final btc = await load([BinanceSource()]);
  print('VNINDEX:');
  final vn = await load([SsiSource(), VndirectSource()]);
  final fng = await loadFng();
  for (final e in btc) {
    // F&G tại ngày đóng nến tuần (Chủ nhật).
    e.fng = fng[d(e.t.add(const Duration(days: 6)))];
  }
  final latestKey = fng.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  print('F&G crypto mới nhất: ${fng[latestKey]} ($latestKey), '
      'lịch sử từ ${fng.keys.reduce((a, b) => a.compareTo(b) < 0 ? a : b)}');

  extremes('BTC', btc);
  extremes('VNINDEX', vn.where((e) => e.t.year >= 2005).toList());

  forward('BTC', btc, [35, 45, 70, 82]);
  forward('VNINDEX', vn, [32, 40, 68, 76]);
  forward('VNINDEX (ngưỡng BTC)', vn, [35, 45, 70, 82]);

  episodes('BTC', btc, (e) => e.rsi <= 35, 'RSI ≤ 35');
  episodes('BTC', btc, (e) => e.rsi > 82, 'RSI > 82');
  episodes('VNINDEX', vn, (e) => e.rsi <= 32, 'RSI ≤ 32');
  episodes('VNINDEX', vn, (e) => e.rsi > 76, 'RSI > 76');

  final withF = btc.where((e) => e.fng != null).toList();
  print('\n--- BTC ma trận kép (${withF.length} tuần có F&G) ---');
  final c1 = withF.where((e) => e.rsi <= 35 && e.fng! < 20).toList();
  final c2 = withF
      .where((e) => e.rsi > 35 && e.rsi <= 45 && e.fng! >= 20 && e.fng! <= 40)
      .toList();
  final c4 = withF
      .where((e) => e.rsi > 70 && e.rsi <= 82 && e.fng! > 70 && e.fng! <= 82)
      .toList();
  final c5 = withF.where((e) => e.rsi > 82 && e.fng! > 82).toList();
  final r35 = withF.where((e) => e.rsi <= 35).toList();
  final r82 = withF.where((e) => e.rsi > 82).toList();
  print('RSI≤35: ${r35.length} tuần; kèm F&G<20: ${c1.length} — '
      '${c1.map((e) => '${d(e.t)}(${e.fng})').join(', ')}');
  print('F&G tại các tuần RSI≤35: '
      '${r35.map((e) => '${d(e.t)}:${e.fng}').join(' ')}');
  print('RSI 35–45 & F&G 20–40: ${c2.length} tuần');
  print('RSI 70–82 & F&G 70–82: ${c4.length} tuần');
  print('RSI>82: ${r82.length} tuần; kèm F&G>82: ${c5.length} — '
      '${c5.map((e) => '${d(e.t)}(${e.fng})').join(', ')}');
  print('F&G tại các tuần RSI>82: '
      '${r82.map((e) => '${d(e.t)}:${e.fng}').join(' ')}');

  simulate('BTC', btc, [35, 45, 70, 82], DateTime.utc(2018, 6));
  simulate('VNINDEX', vn, [32, 40, 68, 76], DateTime.utc(2010));
  simulate('VNINDEX', vn, [32, 40, 68, 76], DateTime.utc(2018));

  for (final from in [DateTime.utc(2018, 6), DateTime.utc(2020, 1), DateTime.utc(2022, 1)]) {
    variants('BTC', btc, [35, 45, 70, 82], from, useFng: true);
  }
  variants('VNINDEX', vn, [32, 40, 68, 76], DateTime.utc(2010), useFng: false);
  variants('VNINDEX', vn, [32, 40, 68, 76], DateTime.utc(2018), useFng: false);

  for (final (symbol, source) in [
    (MarketSymbol.btc, BinanceSource() as MarketDataSource),
    (MarketSymbol.vnindex, SsiSource()),
  ]) {
    final weeks = classifyDcaWeeks(symbol, await source.fetchWeekly());
    final idx = {for (final w in weeks) w.candleIndex: w};
    final hits = weeks.where((w) => w.bearishDivergence).toList();
    var measured = 0, lower = 0;
    print('\n--- ${symbol.label}: phân kỳ giảm tuần (FR-16) ---');
    for (final w in hits) {
      final later = idx[w.candleIndex + 52];
      if (later != null) {
        measured++;
        if (later.close < w.close) lower++;
      }
      print('${d(w.weekOpenTime)}  ${w.close.toStringAsFixed(0).padLeft(7)}  '
          'RSI ${w.rsi.toStringAsFixed(1)}  +52w '
          '${later == null ? '–' : '${((later.close / w.close - 1) * 100).toStringAsFixed(0)}%'}');
    }
    print('$lower/$measured tuần đo được có giá thấp hơn sau 52 tuần');
  }

  print('\n--- 12 tuần gần nhất ---');
  for (final e in btc.sublist(btc.length - 12)) {
    print('BTC ${d(e.t)}  ${e.close.toStringAsFixed(0).padLeft(7)}  '
        'RSI ${e.rsi.toStringAsFixed(1)}  F&G ${e.fng}');
  }
  for (final e in vn.sublist(vn.length - 6)) {
    print('VNI ${d(e.t)}  ${e.close.toStringAsFixed(1).padLeft(7)}  '
        'RSI ${e.rsi.toStringAsFixed(1)}');
  }
}

/// Các biến thể: base = phần nạp mỗi tuần mua ngay; phần còn lại vào quỹ chờ,
/// giải ngân theo vùng. Bán theo luật tuỳ biến thể.
void variants(String name, List<Week> w, List<double> c, DateTime from,
    {required bool useFng}) {
  final ws = w.where((e) => !e.t.isBefore(from)).toList();
  final last = ws.last.close;
  String run(String label, double base, bool sell, bool sellNeedsFng) {
    var reserve = 0.0, units = 0.0, cashOut = 0.0;
    for (final e in ws) {
      units += base / e.close;
      reserve += 1 - base;
      double f = 0;
      if (e.rsi <= c[0]) {
        f = 1 / 6;
      } else if (e.rsi <= c[1]) {
        f = 1 / 10;
      }
      final spend = reserve * f;
      units += spend / e.close;
      reserve -= spend;
      if (sell) {
        final fngOk = !sellNeedsFng || (e.fng ?? 0) > 82;
        double s = 0;
        if (e.rsi > c[3] && fngOk) {
          s = 0.15;
        } else if (e.rsi > c[2] && !sellNeedsFng) {
          s = 0.05;
        }
        final q = units * s;
        cashOut += q * e.close;
        reserve += q * e.close; // tiền chốt quay về quỹ chờ, mua lại ở vùng đáy
        units -= q;
      }
    }
    final v = units * last + reserve;
    return '${label.padRight(44)} x${(v / ws.length).toStringAsFixed(2)}'
        '  (tiền chờ ${(reserve / v * 100).toStringAsFixed(0)}%, '
        'tổng đã chốt ${(cashOut / ws.length).toStringAsFixed(2)} đv)';
  }

  print('\n--- $name biến thể từ ${d(from)} (${ws.length} tuần) ---');
  print(run('A. DCA đều 100%', 1, false, false));
  print(run('B. Chỉ mua theo vùng, không bán', 0, false, false));
  print(run('C. 50% DCA nền + 50% quỹ chờ vùng, không bán', 0.5, false, false));
  print(run('D. 50/50 + bán theo vùng RSI (gốc PDF)', 0.5, true, false));
  if (useFng) {
    print(run('E. 50/50 + bán chỉ khi RSI>82 VÀ F&G>82', 0.5, true, true));
  }
}
