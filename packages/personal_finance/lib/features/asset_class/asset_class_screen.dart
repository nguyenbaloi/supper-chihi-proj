import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/asset_class.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/valued_holding.dart';
import '../../domain/repositories/asset_class_repository.dart';
import '../../domain/rules/effective_price.dart';
import '../../domain/rules/holding_value.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/confirm_dialog.dart';
import '../../presentation/widgets/empty_state.dart';
import '../../presentation/widgets/money_text.dart';
import '../../presentation/widgets/price_freshness_label.dart';
import 'holding_editor.dart';
import 'manual_price_editor.dart';

/// Chi tiết một Lớp tài sản: danh sách Khoản nắm giữ và cơ cấu nội bộ.
/// Xem FR-7.
class AssetClassScreen extends ConsumerWidget {
  final int assetClassId;

  const AssetClassScreen({super.key, required this.assetClassId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final classes = ref.watch(assetClassesProvider).value ?? const [];
    final assetClass = classes.where((c) => c.id == assetClassId).firstOrNull;
    final holdingsAsync = ref.watch(valuedHoldingsProvider(assetClassId));

    if (assetClass == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(assetClass.name),
        actions: [
          IconButton(
            tooltip: l10n.assetClassRename,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _rename(context, ref, assetClass),
          ),
          IconButton(
            tooltip: assetClass.hidden
                ? l10n.assetClassUnhide
                : l10n.assetClassHide,
            icon: Icon(
              assetClass.hidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () => _toggleHidden(context, ref, assetClass),
          ),
        ],
      ),
      floatingActionButton: assetClass.kind == AssetKind.lending
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showHoldingEditor(
                context,
                ref,
                assetClass: assetClass,
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.addHolding),
            ),
      body: holdingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.errorGeneric,
          body: '$error',
        ),
        data: (holdings) => _Body(assetClass: assetClass, holdings: holdings),
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    AssetClass assetClass,
  ) async {
    final l10n = AppL10n.of(context);
    final controller = TextEditingController(text: assetClass.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.assetClassRename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.assetClassRename),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );

    if (name == null) return;
    if (name.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.assetClassNameEmpty)),
        );
      }
      return;
    }
    await ref.read(assetClassRepositoryProvider).rename(assetClass.id, name);
  }

  Future<void> _toggleHidden(
    BuildContext context,
    WidgetRef ref,
    AssetClass assetClass,
  ) async {
    final l10n = AppL10n.of(context);
    final repo = ref.read(assetClassRepositoryProvider);

    if (assetClass.hidden) {
      await repo.unhide(assetClass.id);
      return;
    }

    final result = await repo.hide(assetClass.id);
    if (!context.mounted) return;
    if (result is AssetClassNotEmpty) {
      // Nói rõ lý do kèm số khoản đang chứa, không chỉ báo "không được".
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.assetClassCannotHide(result.holdingCount))),
      );
    }
  }
}

class _Body extends ConsumerWidget {
  final AssetClass assetClass;
  final List<ValuedHolding> holdings;

  const _Body({required this.assetClass, required this.holdings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    if (assetClass.kind == AssetKind.lending) {
      final totals = ref.watch(debtTotalsProvider);
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryRow(label: l10n.debtLent, amount: totals.lent),
          _SummaryRow(label: l10n.debtBorrowed, amount: totals.borrowed),
          const Divider(height: 24),
          _SummaryRow(label: l10n.debtNet, amount: totals.net, emphasise: true),
          const SizedBox(height: 16),
          Text(
            l10n.debtLedger,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }

    if (holdings.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        title: l10n.emptyPortfolioTitle,
        body: l10n.emptyPortfolioBody,
      );
    }

    final classTotal = Money.sum(
      holdings.map((h) => h.amountOrNull).whereType<Money>(),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        MoneyText(
          classTotal,
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        if (holdings.where((h) => (h.amountOrNull?.isPositive ?? false)).length
            > 1)
          _InnerPieChart(holdings: holdings, total: classTotal),
        const SizedBox(height: 8),
        for (final holding in holdings)
          _HoldingTile(
            valued: holding,
            classTotal: classTotal,
            assetClass: assetClass,
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final Money amount;
  final bool emphasise;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.emphasise = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          MoneyText(
            amount,
            style: emphasise
                ? theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)
                : theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _InnerPieChart extends StatelessWidget {
  final List<ValuedHolding> holdings;
  final Money total;

  const _InnerPieChart({required this.holdings, required this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = [
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      scheme.primaryContainer,
      scheme.tertiaryContainer,
    ];
    final slices = holdings
        .where((h) => h.amountOrNull?.isPositive ?? false)
        .toList();
    if (slices.isEmpty || total.isZero) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            for (var i = 0; i < slices.length; i++)
              PieChartSectionData(
                value: _weight(slices[i].amountOrNull!, total),
                color: palette[i % palette.length],
                radius: 48,
                title: VnFormat.percent(
                  slices[i].amountOrNull!.ratioTo(total)!,
                ),
                titleStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Chỉ dùng để vẽ — không con số tiền nào đi qua đây. Xem AD-3.
  static double _weight(Money value, Money total) {
    final ratio = value.ratioTo(total);
    return ratio == null ? 0 : double.parse(ratio.toString());
  }
}

class _HoldingTile extends ConsumerWidget {
  final ValuedHolding valued;
  final Money classTotal;
  final AssetClass assetClass;

  const _HoldingTile({
    required this.valued,
    required this.classTotal,
    required this.assetClass,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final holding = valued.holding;
    final amount = valued.amountOrNull;
    final weight = amount?.ratioTo(classTotal);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => showHoldingEditor(
          context,
          ref,
          assetClass: assetClass,
          existing: holding,
        ),
        title: Row(
          children: [
            Flexible(child: Text(holding.label)),
            if (valued.usesManualPrice) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: l10n.manualPriceBadge,
                child: Icon(
                  Icons.edit_note,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (holding.quantity != null)
              Text(
                VnFormat.quantity(
                  holding.quantity!,
                  unit: assetClass.kind.quantityUnit ?? holding.symbol,
                ),
                style: theme.textTheme.bodySmall,
              ),
            _PriceLine(valued: valued, assetClass: assetClass),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (amount == null)
              Text(
                l10n.noPriceYet,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
              )
            else ...[
              MoneyText(
                amount,
                compact: true,
                style: theme.textTheme.titleMedium,
              ),
              if (weight != null)
                Text(
                  VnFormat.percent(weight),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends ConsumerWidget {
  final ValuedHolding valued;
  final AssetClass assetClass;

  const _PriceLine({required this.valued, required this.assetClass});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final price = valued.effectivePrice;

    if (valued.holding.inputMode == InputMode.value) {
      return const SizedBox.shrink();
    }

    if (price == null) {
      // Không để trống không giải thích: nói rõ loại này cần nhập giá tay.
      final message = EffectivePrice.requiresManualPrice(assetClass.kind)
          ? l10n.needsManualPrice
          : l10n.noPriceYet;
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Flexible(
              child: Text(
                message,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => showManualPriceEditor(
                context,
                ref,
                symbol: valued.holding.symbol,
                currency: valued.holding.currency,
              ),
              child: Text(l10n.setManualPrice),
            ),
          ],
        ),
      );
    }

    final reason = valued.value;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${VnFormat.money(price.priceAmount)} '
            '${price.currency == Currency.usd ? '(${price.currency.code})' : ''}',
            style: theme.textTheme.bodySmall,
          ),
          PriceFreshnessLabel(fetchedAt: price.fetchedAt),
          if (reason is HoldingValueUnknown &&
              reason.reason == MissingValueReason.noFxRate)
            Text(
              l10n.noFxRateYet,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
        ],
      ),
    );
  }
}

/// Xác nhận trước khi xoá một Khoản nắm giữ. Xem FR-6.
Future<bool> confirmDeleteHolding(BuildContext context, String symbol) {
  final l10n = AppL10n.of(context);
  return confirmAction(
    context,
    title: l10n.holdingDeleteConfirm(symbol),
    body: l10n.holdingDeleteExplain,
    confirmLabel: l10n.actionDelete,
  );
}
