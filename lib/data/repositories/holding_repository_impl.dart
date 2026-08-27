import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../core/money/quantity.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/holding.dart';
import '../../domain/repositories/holding_repository.dart';
import '../db/database.dart';

/// Cài đặt [HoldingRepository] trên drift.
class HoldingRepositoryImpl implements HoldingRepository {
  final AppDatabase _db;

  /// Đồng hồ, tách ra để test bơm thời điểm cố định vào.
  ///
  /// Mặc định trả về giờ UTC: cơ sở dữ liệu lưu UTC, còn `DateTime.now()`
  /// trả về giờ địa phương.
  final DateTime Function() _now;

  HoldingRepositoryImpl(this._db, {DateTime Function()? now})
      : _now = now ?? _utcNow;

  static DateTime _utcNow() => DateTime.now().toUtc();

  @override
  Future<List<Holding>> all() => _ordered().get();

  @override
  Future<List<Holding>> byAssetClass(int assetClassId) =>
      _ordered(assetClassId: assetClassId).get();

  @override
  Stream<List<Holding>> watchByAssetClass(int assetClassId) =>
      _ordered(assetClassId: assetClassId).watch();

  @override
  Future<Holding?> byId(int id) =>
      (_db.select(_db.holdingsTable)..where((t) => t.id.equals(id)))
          .map(_toDomain)
          .getSingleOrNull();

  @override
  Future<SaveHoldingResult> add({
    required int assetClassId,
    required String symbol,
    String? displayName,
    String? quantityText,
    Money? manualValueAmount,
    Currency currency = Currency.vnd,
    String? note,
  }) =>
      _db.transaction(() async {
        final kind = await _kindOf(assetClassId);
        if (kind == null) return const HoldingAssetClassNotFound();

        final normalized = _normalizeSymbol(symbol);
        if (await _symbolTaken(assetClassId, normalized, exceptId: null)) {
          return DuplicateSymbol(normalized);
        }

        final parsed = _parseInput(
          kind: kind,
          quantityText: quantityText,
          manualValueAmount: manualValueAmount,
        );
        if (parsed is _InputRejected) return parsed.result;
        final input = parsed as _InputAccepted;

        final id = await _db.into(_db.holdingsTable).insert(
              HoldingsTableCompanion.insert(
                assetClassId: assetClassId,
                symbol: normalized,
                inputMode: kind.defaultInputMode,
                currency: currency,
                updatedAt: _now(),
                displayName: Value(_trimToNull(displayName)),
                quantityRaw: Value(input.quantity?.raw),
                decimals: Value(input.quantity?.decimals ?? 0),
                manualValueAmount: Value(input.manualValueAmount),
                note: Value(_trimToNull(note)),
              ),
            );

        return HoldingSaved((await byId(id))!);
      });

  @override
  Future<SaveHoldingResult> update(
    int id, {
    String? symbol,
    String? displayName,
    String? quantityText,
    Money? manualValueAmount,
    Currency? currency,
    String? note,
  }) =>
      _db.transaction(() async {
        final existing = await byId(id);
        if (existing == null) return const HoldingNotFound();

        final kind = await _kindOf(existing.assetClassId);
        if (kind == null) return const HoldingAssetClassNotFound();

        var normalized = existing.symbol;
        if (symbol != null) {
          normalized = _normalizeSymbol(symbol);
          if (await _symbolTaken(
            existing.assetClassId,
            normalized,
            exceptId: id,
          )) {
            return DuplicateSymbol(normalized);
          }
        }

        // Chỉ kiểm tra số lượng hoặc giá trị khi lần sửa này thực sự đụng tới
        // chúng; bỏ trống nghĩa là giữ nguyên, không phải xoá.
        Quantity? quantity = existing.quantity;
        Money? value = existing.manualValueAmount;
        if (quantityText != null || manualValueAmount != null) {
          final parsed = _parseInput(
            kind: kind,
            quantityText: quantityText ?? existing.quantity?.toPlainString(),
            manualValueAmount: manualValueAmount ?? existing.manualValueAmount,
          );
          if (parsed is _InputRejected) return parsed.result;
          final input = parsed as _InputAccepted;
          quantity = input.quantity;
          value = input.manualValueAmount;
        }

        await (_db.update(_db.holdingsTable)..where((t) => t.id.equals(id)))
            .write(
          HoldingsTableCompanion(
            symbol: Value(normalized),
            displayName: displayName == null
                ? const Value.absent()
                : Value(_trimToNull(displayName)),
            quantityRaw: Value(quantity?.raw),
            decimals: Value(quantity?.decimals ?? 0),
            manualValueAmount: Value(value),
            currency: currency == null ? const Value.absent() : Value(currency),
            note: note == null ? const Value.absent() : Value(_trimToNull(note)),
            updatedAt: Value(_now()),
          ),
        );

        return HoldingSaved((await byId(id))!);
      });

  @override
  Future<bool> remove(int id) async {
    final deleted = await (_db.delete(_db.holdingsTable)
          ..where((t) => t.id.equals(id)))
        .go();
    return deleted > 0;
  }

  /// Kiểm tra và chuyển chuỗi người dùng nhập thành số lượng hoặc giá trị,
  /// theo đúng chế độ nhập của loại tài sản.
  _InputOutcome _parseInput({
    required AssetKind kind,
    required String? quantityText,
    required Money? manualValueAmount,
  }) {
    if (kind.defaultInputMode == InputMode.value) {
      if (manualValueAmount == null) {
        return const _InputRejected(MissingRequiredInput(InputMode.value));
      }
      return _InputAccepted(manualValueAmount: manualValueAmount);
    }

    final text = quantityText?.trim();
    if (text == null || text.isEmpty) {
      return const _InputRejected(MissingRequiredInput(InputMode.quantity));
    }

    final Decimal value;
    try {
      value = Decimal.parse(text);
    } on FormatException {
      return _InputRejected(InvalidQuantity(text));
    }

    final allowed = kind.quantityDecimals;
    try {
      return _InputAccepted(quantity: Quantity.fromDecimal(value, allowed));
    } on ArgumentError {
      return _InputRejected(
        QuantityTooPrecise(input: text, allowedDecimals: allowed, kind: kind),
      );
    }
  }

  Future<AssetKind?> _kindOf(int assetClassId) async {
    final row = await (_db.select(_db.assetClassesTable)
          ..where((t) => t.id.equals(assetClassId)))
        .getSingleOrNull();
    return row?.kind;
  }

  Future<bool> _symbolTaken(
    int assetClassId,
    String symbol, {
    required int? exceptId,
  }) async {
    final query = _db.select(_db.holdingsTable)
      ..where((t) =>
          t.assetClassId.equals(assetClassId) & t.symbol.equals(symbol));
    if (exceptId != null) query.where((t) => t.id.isNotValue(exceptId));
    return (await query.get()).isNotEmpty;
  }

  Selectable<Holding> _ordered({int? assetClassId}) {
    final query = _db.select(_db.holdingsTable)
      ..orderBy([
        (t) => OrderingTerm.asc(t.assetClassId),
        (t) => OrderingTerm.asc(t.symbol),
      ]);
    if (assetClassId != null) {
      query.where((t) => t.assetClassId.equals(assetClassId));
    }
    return query.map(_toDomain);
  }

  /// Chuẩn hoá ký hiệu về chữ hoa không khoảng trắng.
  ///
  /// Nhờ vậy `btc` và `BTC` va nhau đúng như người dùng mong đợi — chỉ mục
  /// duy nhất của SQLite phân biệt chữ hoa chữ thường, nếu không chuẩn hoá
  /// thì cùng một đồng coin nằm được hai dòng.
  static String _normalizeSymbol(String symbol) {
    final trimmed = symbol.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(symbol, 'symbol', 'ký hiệu không được rỗng');
    }
    return trimmed.toUpperCase();
  }

  static String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static Holding _toDomain(HoldingsTableData row) => Holding(
        id: row.id,
        assetClassId: row.assetClassId,
        symbol: row.symbol,
        displayName: row.displayName,
        inputMode: row.inputMode,
        quantity: row.quantityRaw == null
            ? null
            : Quantity(row.quantityRaw!, row.decimals),
        manualValueAmount: row.manualValueAmount,
        currency: row.currency,
        note: row.note,
        updatedAt: row.updatedAt,
      );
}

sealed class _InputOutcome {
  const _InputOutcome();
}

final class _InputAccepted extends _InputOutcome {
  final Quantity? quantity;
  final Money? manualValueAmount;
  const _InputAccepted({this.quantity, this.manualValueAmount});
}

final class _InputRejected extends _InputOutcome {
  final SaveHoldingResult result;
  const _InputRejected(this.result);
}
