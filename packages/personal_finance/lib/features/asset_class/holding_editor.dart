import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/decimal_input.dart';
import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/asset_class.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/holding.dart';
import '../../domain/models/price_quote.dart';
import '../../domain/repositories/holding_repository.dart';
import '../../domain/rules/effective_price.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/form_sheet.dart';
import '../../presentation/widgets/money_field.dart';
import '../../presentation/widgets/quantity_field.dart';
import 'asset_class_screen.dart';

/// Mở form thêm hoặc sửa một Khoản nắm giữ.
///
/// Nạp sẵn Giá nhập tay đang có để form khỏi phải tự xoay xở với trạng thái
/// bất đồng bộ. Chỉ lấy giá **nhập tay**, không lấy giá thị trường: đổ giá
/// thị trường vào ô rồi lưu lại sẽ âm thầm biến nó thành giá nhập tay, và từ
/// đó khoản này không còn tự cập nhật theo thị trường nữa.
Future<void> showHoldingEditor(
  BuildContext context,
  WidgetRef ref, {
  required AssetClass assetClass,
  Holding? existing,
}) async {
  PriceQuote? manualPrice;
  if (existing != null) {
    final quotes =
        await ref.read(priceQuoteRepositoryProvider).quotesFor(existing.symbol);
    manualPrice = quotes.where((q) => q.isManual).firstOrNull;
  }

  if (!context.mounted) return;
  await showFormSheet<void>(
    context,
    builder: (_) => _HoldingForm(
      assetClass: assetClass,
      existing: existing,
      initialManualPrice: manualPrice,
    ),
  );
}

class _HoldingForm extends ConsumerStatefulWidget {
  final AssetClass assetClass;
  final Holding? existing;
  final PriceQuote? initialManualPrice;

  const _HoldingForm({
    required this.assetClass,
    this.existing,
    this.initialManualPrice,
  });

  @override
  ConsumerState<_HoldingForm> createState() => _HoldingFormState();
}

class _HoldingFormState extends ConsumerState<_HoldingForm> {
  late final TextEditingController _symbol;
  late final TextEditingController _displayName;
  late final TextEditingController _quantity;
  late final TextEditingController _note;
  late Money _value;
  late Money _unitPrice;
  late Currency _currency;
  String? _error;

  bool get _isQuantityMode =>
      widget.assetClass.kind.defaultInputMode == InputMode.quantity;

  /// Loại này chưa có nguồn giá tự động nên giá nhập tay là cách duy nhất.
  /// Xem FR-12.
  bool get _needsManualPrice =>
      EffectivePrice.requiresManualPrice(widget.assetClass.kind);

  /// Số lượng đang gõ, `null` khi chưa đọc được thành số.
  Decimal? get _parsedQuantity {
    final normalized = DecimalInput.normalize(
      _quantity.text,
      allowedDecimals: widget.assetClass.kind.quantityDecimals,
    );
    return normalized == null ? null : Decimal.tryParse(normalized);
  }

  /// Giá trị quy đổi tính tại chỗ để người dùng thấy ngay con số mình vừa tạo
  /// ra, thay vì phải lưu rồi quay lại màn hình trước mới biết.
  ///
  /// Phép nhân chạy ở độ chính xác đầy đủ và chỉ làm tròn một lần. Xem AD-3.
  Money? get _convertedValue {
    final quantity = _parsedQuantity;
    if (quantity == null || _unitPrice.isZero) return null;
    return Money.fromDecimal(quantity * _unitPrice.asDecimal);
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _symbol = TextEditingController(text: existing?.symbol ?? '');
    _displayName = TextEditingController(text: existing?.displayName ?? '');
    _quantity =
        TextEditingController(text: existing?.quantity?.toPlainString() ?? '');
    _note = TextEditingController(text: existing?.note ?? '');
    _value = existing?.manualValueAmount ?? Money.zero;
    _unitPrice = widget.initialManualPrice?.priceAmount ?? Money.zero;
    _currency = widget.initialManualPrice?.currency ??
        existing?.currency ??
        Currency.vnd;
  }

  @override
  void dispose() {
    _symbol.dispose();
    _displayName.dispose();
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final unit = widget.assetClass.kind.quantityUnit;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? l10n.addHolding : l10n.editHolding,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _symbol,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.holdingSymbol),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _displayName,
              decoration: InputDecoration(labelText: l10n.holdingDisplayName),
            ),
            const SizedBox(height: 12),
            if (_isQuantityMode)
              QuantityField(
                controller: _quantity,
                label: l10n.holdingQuantity,
                allowedDecimals: widget.assetClass.kind.quantityDecimals,
                // Ô nhập hiện đúng đơn vị của loại tài sản. Xem FR-2.
                suffixText: unit ??
                    (_symbol.text.isEmpty ? null : _symbol.text.toUpperCase()),
                helperText: l10n.holdingQuantityTooPrecise(
                  widget.assetClass.kind.quantityDecimals,
                ),
                onChanged: (_) => setState(() {}),
              )
            else
              MoneyField(
                label: l10n.holdingValue,
                initial: _value,
                onChanged: (value) => _value = value,
                decimals: _currency.decimals,
                suffixText: _currency.code,
              ),
            if (_isQuantityMode) ...[
              const SizedBox(height: 12),
              MoneyField(
                label: l10n.holdingPrice,
                initial: _unitPrice,
                decimals: _currency.decimals,
                suffixText: _currency.code,
                helperText: _needsManualPrice
                    ? l10n.holdingPriceOnlyManual
                    : l10n.holdingPriceOverridesMarket,
                onChanged: (value) => setState(() => _unitPrice = value),
              ),
              const SizedBox(height: 8),
              _ConvertedValueLine(
                value: _convertedValue,
                currency: _currency,
              ),
            ],
            const SizedBox(height: 12),
            SegmentedButton<Currency>(
              segments: [
                for (final currency in Currency.values)
                  ButtonSegment(value: currency, label: Text(currency.code)),
              ],
              selected: {_currency},
              onSelectionChanged: (selection) =>
                  setState(() => _currency = selection.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.holdingNote),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.existing != null)
                  TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.actionDelete),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.actionCancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _save,
                  child: Text(l10n.actionSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final existing = widget.existing!;
    if (!await confirmDeleteHolding(context, existing.symbol)) return;
    await ref.read(holdingRepositoryProvider).remove(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final repo = ref.read(holdingRepositoryProvider);
    final symbol = _symbol.text.trim();
    if (symbol.isEmpty) {
      setState(() => _error = AppL10n.of(context).holdingSymbol);
      return;
    }

    final result = widget.existing == null
        ? await repo.add(
            assetClassId: widget.assetClass.id,
            symbol: symbol,
            displayName: _displayName.text,
            quantityText: _isQuantityMode ? _quantity.text : null,
            manualValueAmount: _isQuantityMode ? null : _value,
            currency: _currency,
            note: _note.text,
          )
        : await repo.update(
            widget.existing!.id,
            symbol: symbol,
            displayName: _displayName.text,
            quantityText: _isQuantityMode ? _quantity.text : null,
            manualValueAmount: _isQuantityMode ? null : _value,
            currency: _currency,
            note: _note.text,
          );

    if (!mounted) return;
    if (result is HoldingSaved) {
      await _saveManualPrice(result.holding.symbol);
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _error = _describe(result));
  }

  /// Ghi Giá nhập tay kèm theo, hoặc xoá nó khi người dùng để trống ô giá.
  ///
  /// Chỉ chạy sau khi Khoản nắm giữ đã lưu thành công, và dùng ký hiệu đã
  /// chuẩn hoá mà repository trả về — nếu dùng chuỗi thô trong ô nhập thì gõ
  /// `btc` sẽ ghi giá cho một ký hiệu khác với ký hiệu vừa lưu.
  Future<void> _saveManualPrice(String symbol) async {
    if (!_isQuantityMode) return;
    final repo = ref.read(priceQuoteRepositoryProvider);

    if (_unitPrice.isZero) {
      // Để trống nghĩa là quay lại dùng giá thị trường. Xem FR-12.
      if (widget.initialManualPrice != null) {
        await repo.clearManualPrice(symbol);
      }
      return;
    }

    await repo.saveManualPrice(
      symbol: symbol,
      price: _unitPrice,
      currency: _currency,
    );
  }

  /// Đổi kết quả nghiệp vụ sang câu giải thích cho người dùng.
  ///
  /// Mỗi nhánh hỏng mang sẵn dữ liệu cần thiết, nên câu chữ dựng được đầy đủ
  /// mà không phải đoán.
  String _describe(SaveHoldingResult result) {
    final l10n = AppL10n.of(context);
    return switch (result) {
      DuplicateSymbol(:final symbol) => l10n.holdingDuplicateSymbol(symbol),
      QuantityTooPrecise(:final allowedDecimals) =>
        l10n.holdingQuantityTooPrecise(allowedDecimals),
      InvalidQuantity() => l10n.holdingInvalidQuantity,
      MissingRequiredInput(:final inputMode) =>
        inputMode == InputMode.quantity
            ? l10n.holdingMissingQuantity
            : l10n.holdingMissingValue,
      _ => l10n.errorGeneric,
    };
  }
}

/// Dòng hiện Giá trị quy đổi tính từ số lượng nhân giá.
class _ConvertedValueLine extends StatelessWidget {
  final Money? value;
  final Currency currency;

  const _ConvertedValueLine({required this.value, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final amount = value;

    if (amount == null) {
      return Text(
        l10n.holdingPriceMissingForValue,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.holdingConvertedValue, style: theme.textTheme.bodyMedium),
          Text(
            '${VnFormat.amount(amount, decimals: currency.decimals)} ${currency.code}',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
