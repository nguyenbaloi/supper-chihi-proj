import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_date.dart';
import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/rules/contribution.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/confirm_dialog.dart';
import '../../presentation/widgets/money_text.dart';
import 'cash_flow_editor.dart';

/// Màn hình Lãi lỗ chi tiết.
///
/// Mục đích là để người dùng **tin được** con số lãi lỗ thay vì phải đoán:
/// hiện đủ ba thành phần tạo ra nó, rồi tới toàn bộ chuỗi Dòng vốn kèm lũy kế
/// tại từng dòng. Xem FR-26.
class ProfitLossScreen extends ConsumerWidget {
  const ProfitLossScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final profitLoss = ref.watch(currentProfitLossProvider);
    final settings = ref.watch(settingsProvider).value;
    final series = ref.watch(contributionSeriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profitLoss)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCashFlowEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addCashFlow),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (profitLoss != null) ...[
            _Line(
              label: l10n.investmentGroup,
              amount: profitLoss.investmentGroupValue,
            ),
            _Line(
              label: l10n.cumulativeContribution,
              amount: profitLoss.cumulativeContribution,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.profitLoss, style: theme.textTheme.titleMedium),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MoneyText(
                      profitLoss.amount,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      colorBySign: true,
                      showPlusSign: true,
                    ),
                    if (profitLoss.ratio != null)
                      Text(
                        VnFormat.percent(profitLoss.ratio!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              context.colorForAmount(profitLoss.amount.amount),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.profitLossExplain,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 24),
          if (settings != null)
            // Vốn góp khởi điểm hiện thành một dòng riêng để đối chiếu với
            // Excel gốc. Xem FR-26.
            Card(
              child: ListTile(
                title: Text(l10n.initialContribution),
                subtitle: Text(VnDate.full(settings.startDate)),
                trailing: MoneyText(
                  settings.initialContributionAmount,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(l10n.capitalLedger, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (series.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.cashFlowEmpty,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            for (final point in series.reversed)
              _CashFlowTile(point: point),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final Money amount;

  const _Line({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          MoneyText(amount, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _CashFlowTile extends ConsumerWidget {
  final ContributionPoint point;

  const _CashFlowTile({required this.point});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final flow = point.cashFlow;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => showCashFlowEditor(context, ref, existing: flow),
        leading: Icon(
          flow.isDeposit ? Icons.south_west : Icons.north_east,
          color: context.colorForAmount(flow.amount.amount),
        ),
        title: MoneyText(
          flow.amount,
          colorBySign: true,
          showPlusSign: true,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(VnDate.full(flow.date), style: theme.textTheme.bodySmall),
            if (flow.note != null)
              Text(flow.note!, style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.cumulativeContribution,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            MoneyText(
              point.cumulative,
              compact: true,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Xác nhận trước khi xoá một Dòng vốn — xoá nhầm làm lệch toàn bộ lịch sử
/// lãi lỗ phía sau. Xem FR-23.
Future<bool> confirmDeleteCashFlow(BuildContext context) {
  final l10n = AppL10n.of(context);
  return confirmAction(
    context,
    title: l10n.cashFlowDeleteConfirm,
    body: l10n.cashFlowDeleteExplain,
    confirmLabel: l10n.actionDelete,
  );
}
