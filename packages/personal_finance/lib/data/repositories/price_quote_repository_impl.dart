import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/price_quote.dart';
import '../../domain/repositories/price_quote_repository.dart';
import '../../domain/rules/effective_price.dart';
import '../db/database.dart';

/// Cài đặt [PriceQuoteRepository] trên drift.
class PriceQuoteRepositoryImpl implements PriceQuoteRepository {
  final AppDatabase _db;
  final DateTime Function() _now;

  PriceQuoteRepositoryImpl(this._db, {DateTime Function()? now})
      : _now = now ?? _utcNow;

  static DateTime _utcNow() => DateTime.now().toUtc();

  @override
  Future<List<PriceQuote>> quotesFor(String symbol) =>
      (_db.select(_db.priceQuotesTable)
            ..where((t) => t.symbol.equals(_normalize(symbol))))
          .map(_toDomain)
          .get();

  @override
  Future<PriceQuote?> effectivePriceFor(String symbol) async =>
      // Đi qua đúng hàm quyết định duy nhất, không tự xếp thứ tự ở đây.
      EffectivePrice.from(await quotesFor(symbol));

  @override
  Future<Map<String, PriceQuote>> effectivePricesFor(
    Iterable<String> symbols,
  ) async {
    final wanted = symbols.map(_normalize).toSet();
    if (wanted.isEmpty) return const {};

    final rows = await (_db.select(_db.priceQuotesTable)
          ..where((t) => t.symbol.isIn(wanted)))
        .map(_toDomain)
        .get();

    final grouped = <String, List<PriceQuote>>{};
    for (final quote in rows) {
      grouped.putIfAbsent(quote.symbol, () => []).add(quote);
    }

    final result = <String, PriceQuote>{};
    for (final entry in grouped.entries) {
      final effective = EffectivePrice.from(entry.value);
      if (effective != null) result[entry.key] = effective;
    }
    return result;
  }

  @override
  Stream<List<PriceQuote>> watchAll() =>
      _db.select(_db.priceQuotesTable).map(_toDomain).watch();

  @override
  Future<PriceQuote> saveManualPrice({
    required String symbol,
    required Money price,
    Currency currency = Currency.vnd,
  }) async {
    final quote = PriceQuote(
      symbol: _normalize(symbol),
      priceAmount: price,
      currency: currency,
      source: PriceSource.manual,
      fetchedAt: _now(),
    );
    await _db.into(_db.priceQuotesTable).insertOnConflictUpdate(_toRow(quote));
    return quote;
  }

  @override
  Future<void> clearManualPrice(String symbol) async {
    await (_db.delete(_db.priceQuotesTable)
          ..where((t) =>
              t.symbol.equals(_normalize(symbol)) &
              t.source.equalsValue(PriceSource.manual)))
        .go();
  }

  @override
  Future<void> saveMarketPrices(Iterable<PriceQuote> quotes) async {
    if (quotes.isEmpty) return;
    await _db.batch((b) {
      for (final quote in quotes) {
        b.insert(
          _db.priceQuotesTable,
          _toRow(
            PriceQuote(
              symbol: _normalize(quote.symbol),
              priceAmount: quote.priceAmount,
              currency: quote.currency,
              source: PriceSource.api,
              fetchedAt: quote.fetchedAt,
            ),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  static String _normalize(String symbol) => symbol.trim().toUpperCase();

  static PriceQuotesTableCompanion _toRow(PriceQuote quote) =>
      PriceQuotesTableCompanion.insert(
        symbol: quote.symbol,
        source: quote.source,
        priceAmount: quote.priceAmount,
        currency: quote.currency,
        fetchedAt: quote.fetchedAt,
      );

  static PriceQuote _toDomain(PriceQuotesTableData row) => PriceQuote(
        symbol: row.symbol,
        priceAmount: row.priceAmount,
        currency: row.currency,
        source: row.source,
        fetchedAt: row.fetchedAt,
      );
}
