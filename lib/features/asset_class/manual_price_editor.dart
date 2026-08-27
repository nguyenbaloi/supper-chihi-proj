import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/enums.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/money_field.dart';

/// Nhập hoặc xoá Giá nhập tay cho một ký hiệu. Xem FR-12.
Future<void> showManualPriceEditor(
  BuildContext context,
  WidgetRef ref, {
  required String symbol,
  required Currency currency,
}) async {
  final l10n = AppL10n.of(context);
  final repo = ref.read(priceQuoteRepositoryProvider);
  final quotes = await repo.quotesFor(symbol);
  final existingManual =
      quotes.where((q) => q.source == PriceSource.manual).firstOrNull;

  if (!context.mounted) return;

  var amount = existingManual?.priceAmount ?? Money.zero;
  var selectedCurrency = existingManual?.currency ?? currency;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${l10n.setManualPrice} — $symbol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoneyField(
              label: l10n.holdingPrice,
              initial: amount,
              onChanged: (value) => amount = value,
              helperText: selectedCurrency == Currency.usd
                  ? '${l10n.holdingCurrency}: USD'
                  : null,
            ),
            const SizedBox(height: 12),
            SegmentedButton<Currency>(
              segments: [
                for (final c in Currency.values)
                  ButtonSegment(value: c, label: Text(c.code)),
              ],
              selected: {selectedCurrency},
              onSelectionChanged: (selection) =>
                  setState(() => selectedCurrency = selection.first),
            ),
          ],
        ),
        actions: [
          if (existingManual != null)
            TextButton(
              onPressed: () async {
                await repo.clearManualPrice(symbol);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l10n.clearManualPrice),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () async {
              await repo.saveManualPrice(
                symbol: symbol,
                price: amount,
                currency: selectedCurrency,
              );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    ),
  );
}
