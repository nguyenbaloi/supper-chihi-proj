import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/asset_class.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/holding.dart';
import '../../domain/repositories/holding_repository.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/money_field.dart';
import 'asset_class_screen.dart';

/// Mở form thêm hoặc sửa một Khoản nắm giữ.
Future<void> showHoldingEditor(
  BuildContext context,
  WidgetRef ref, {
  required AssetClass assetClass,
  Holding? existing,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _HoldingForm(assetClass: assetClass, existing: existing),
      ),
    );

class _HoldingForm extends ConsumerStatefulWidget {
  final AssetClass assetClass;
  final Holding? existing;

  const _HoldingForm({required this.assetClass, this.existing});

  @override
  ConsumerState<_HoldingForm> createState() => _HoldingFormState();
}

class _HoldingFormState extends ConsumerState<_HoldingForm> {
  late final TextEditingController _symbol;
  late final TextEditingController _displayName;
  late final TextEditingController _quantity;
  late final TextEditingController _note;
  late Money _value;
  late Currency _currency;
  String? _error;

  bool get _isQuantityMode =>
      widget.assetClass.kind.defaultInputMode == InputMode.quantity;

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
    _currency = existing?.currency ?? Currency.vnd;
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
              TextField(
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.holdingQuantity,
                  // Ô nhập hiện đúng đơn vị của loại tài sản. Xem FR-2.
                  suffixText: unit ??
                      (_symbol.text.isEmpty ? null : _symbol.text.toUpperCase()),
                  helperText: l10n.holdingQuantityTooPrecise(
                    widget.assetClass.kind.quantityDecimals,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              )
            else
              MoneyField(
                label: l10n.holdingValue,
                initial: _value,
                onChanged: (value) => _value = value,
              ),
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
      Navigator.of(context).pop();
      return;
    }
    setState(() => _error = _describe(result));
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
