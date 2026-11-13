import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/candle.dart';
import '../domain/fear_greed.dart';
import '../domain/market_symbol.dart';

/// Kho cục bộ: JSON phẳng trong `shared_preferences`, mỗi Mã một khoá (AD-9).
///
/// Dữ liệu chỉ cỡ 1000 nến cho cả hai Mã nên không cần sqlite. Ghi là **thay
/// toàn bộ**, không merge — ghép chồng từng phần sẽ làm chuỗi nến thủng lỗ mà
/// không báo lỗi.
///
/// Kho chỉ giữ OHLCV, mốc đã xem và dấu thời gian. **Không lưu RSI, Trạng
/// thái, hay Tín hiệu** (AD-2) — chúng luôn được tính lại từ chuỗi nến.
class CandleStore {
  CandleStore(this._prefs);

  static const int schemaVersion = 1;

  final SharedPreferences _prefs;

  static Future<CandleStore> open() async =>
      CandleStore(await SharedPreferences.getInstance());

  static String _candlesKey(MarketSymbol symbol) =>
      'candles.${symbol.storageKey}';

  static String _lastSeenKey(MarketSymbol symbol) =>
      'lastSeenSignal.${symbol.storageKey}';

  /// `null` khi chưa có gì, hoặc khi bản ghi thuộc phiên bản lược đồ khác.
  StoredCandles? load(MarketSymbol symbol) {
    final raw = _prefs.getString(_candlesKey(symbol));
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      // Lược đồ khác thì bỏ luôn thay vì cố nâng cấp: dữ liệu này tải lại
      // được trong một giây, không đáng để viết đường nâng cấp.
      if (json['v'] != schemaVersion) return null;

      return StoredCandles(
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(
          (json['fetchedAt'] as num).toInt(),
          isUtc: true,
        ),
        candles: [
          for (final item in json['candles'] as List)
            Candle.fromJson(item as Map<String, dynamic>),
        ],
      );
    } catch (error) {
      debugPrint('CandleStore: bỏ bản ghi hỏng của ${symbol.storageKey}: $error');
      return null;
    }
  }

  Future<void> save(
    MarketSymbol symbol,
    List<Candle> candles,
    DateTime fetchedAt,
  ) async {
    await _prefs.setString(
      _candlesKey(symbol),
      jsonEncode({
        'v': schemaVersion,
        'fetchedAt': fetchedAt.toUtc().millisecondsSinceEpoch,
        'candles': [for (final candle in candles) candle.toJson()],
      }),
    );
  }

  /// Mốc tuần của Tín hiệu cuối cùng người dùng đã xem cho [symbol] (FR-5).
  DateTime? loadLastSeenSignal(MarketSymbol symbol) {
    final millis = _prefs.getInt(_lastSeenKey(symbol));
    return millis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  Future<void> saveLastSeenSignal(MarketSymbol symbol, DateTime weekOpenTime) =>
      _prefs.setInt(
        _lastSeenKey(symbol),
        weekOpenTime.toUtc().millisecondsSinceEpoch,
      );

  static String _lastSeenDcaKey(MarketSymbol symbol) =>
      'lastSeenDca.${symbol.storageKey}';

  /// Mốc tuần của cảnh báo Vùng DCA cuối cùng người dùng đã xem (FR-17).
  /// Chỉ là một mốc thời gian — Vùng thì luôn tính lại (AD-2).
  DateTime? loadLastSeenDca(MarketSymbol symbol) {
    final millis = _prefs.getInt(_lastSeenDcaKey(symbol));
    return millis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  Future<void> saveLastSeenDca(MarketSymbol symbol, DateTime weekOpenTime) =>
      _prefs.setInt(
        _lastSeenDcaKey(symbol),
        weekOpenTime.toUtc().millisecondsSinceEpoch,
      );

  static const String _fearGreedKey = 'fearGreed';

  /// Chuỗi F&G thô (AD-13). Cùng lược đồ và cùng luật "thay toàn bộ" như nến.
  StoredFearGreed? loadFearGreed() {
    final raw = _prefs.getString(_fearGreedKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['v'] != schemaVersion) return null;
      return StoredFearGreed(
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(
          (json['fetchedAt'] as num).toInt(),
          isUtc: true,
        ),
        points: [
          for (final item in json['points'] as List)
            FearGreedPoint.fromJson(item as Map<String, dynamic>),
        ],
      );
    } catch (error) {
      debugPrint('CandleStore: bỏ bản ghi F&G hỏng: $error');
      return null;
    }
  }

  Future<void> saveFearGreed(
    List<FearGreedPoint> points,
    DateTime fetchedAt,
  ) =>
      _prefs.setString(
        _fearGreedKey,
        jsonEncode({
          'v': schemaVersion,
          'fetchedAt': fetchedAt.toUtc().millisecondsSinceEpoch,
          'points': [for (final p in points) p.toJson()],
        }),
      );

  static const String _themeModeKey = 'themeMode';

  ThemeMode loadThemeMode() {
    final name = _prefs.getString(_themeModeKey);
    return switch (name) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) => _prefs.setString(
        _themeModeKey,
        mode.name,
      );
}

class StoredCandles {
  const StoredCandles({required this.fetchedAt, required this.candles});

  final DateTime fetchedAt;
  final List<Candle> candles;
}

class StoredFearGreed {
  const StoredFearGreed({required this.fetchedAt, required this.points});

  final DateTime fetchedAt;
  final List<FearGreedPoint> points;
}
