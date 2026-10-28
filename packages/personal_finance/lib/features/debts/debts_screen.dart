import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app_core/mini_app_core.dart';

import '../../core/format/vn_date.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/debt.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/empty_state.dart';
import '../../presentation/widgets/money_text.dart';
import 'debt_editor.dart';

/// Sổ nợ — thay thế sheet thứ hai của Excel. Xem FR-32.
class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
    final totals = ref.watch(debtTotalsProvider);
    final active = debts.where((d) => d.isActive).toList();
    final settled = debts.where((d) => d.isSettled).toList();

    return Scaffold(
      appBar: AppBar(
        leading: MiniAppScope.exitButtonOf(context),
        title: Text(l10n.debtLedger),
        actions: [
          if (settled.isNotEmpty)
            IconButton(
              tooltip: l10n.debtSettledHistory,
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _SettledDebtsScreen(debts: settled),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDebtEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addDebt),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TotalRow(label: l10n.debtLent, amount: totals.lent),
                  _TotalRow(label: l10n.debtBorrowed, amount: totals.borrowed),
                  const Divider(height: 20),
                  _TotalRow(
                    label: l10n.debtNet,
                    amount: totals.net,
                    emphasise: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (active.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.handshake_outlined,
                title: l10n.debtEmpty,
              ),
            )
          else
            for (final debt in active)
              _DebtTile(debt: debt)
          ,
          if (active.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                // Nói rõ con số này chảy thẳng vào Tổng tài sản — đây là chỗ
                // Excel gốc phải cộng tay giữa hai sheet. Xem FR-35.
                l10n.debtNet,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final Money amount;
  final bool emphasise;

  const _TotalRow({
    required this.label,
    required this.amount,
    this.emphasise = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

class _DebtTile extends ConsumerWidget {
  final Debt debt;

  const _DebtTile({required this.debt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => showDebtEditor(context, ref, existing: debt),
        leading: CircleAvatar(
          backgroundColor: debt.isLent
              ? context.profitColor.withValues(alpha: 0.15)
              : context.lossColor.withValues(alpha: 0.15),
          child: Icon(
            debt.isLent ? Icons.call_made : Icons.call_received,
            color: debt.isLent ? context.profitColor : context.lossColor,
            size: 20,
          ),
        ),
        title: Text(debt.personName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${debt.isLent ? l10n.debtLent : l10n.debtBorrowed}'
              ' · ${VnDate.full(debt.date)}',
              style: theme.textTheme.bodySmall,
            ),
            if (debt.note != null)
              Text(debt.note!, style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: MoneyText(
          debt.amount.abs(),
          compact: true,
          style: theme.textTheme.titleMedium?.copyWith(
            color: debt.isLent ? context.profitColor : context.lossColor,
          ),
        ),
      ),
    );
  }
}

class _SettledDebtsScreen extends ConsumerWidget {
  final List<Debt> debts;

  const _SettledDebtsScreen({required this.debts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debtSettledHistory)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final debt in debts)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => showDebtEditor(context, ref, existing: debt),
                title: Text(debt.personName),
                subtitle: Text(
                  l10n.debtSettledOn(VnDate.full(debt.settledAt!)),
                  style: theme.textTheme.bodySmall,
                ),
                trailing: MoneyText(debt.amount.abs(), compact: true),
              ),
            ),
        ],
      ),
    );
  }
}
