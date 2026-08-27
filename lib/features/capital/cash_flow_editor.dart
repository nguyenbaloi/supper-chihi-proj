import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_date.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/cash_flow.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/money_field.dart';
import 'profit_loss_screen.dart';

/// Form thêm hoặc sửa một Dòng vốn.
Future<void> showCashFlowEditor(
  BuildContext context,
  WidgetRef ref, {
  CashFlow? existing,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _CashFlowForm(existing: existing),
      ),
    );

class _CashFlowForm extends ConsumerStatefulWidget {
  final CashFlow? existing;

  const _CashFlowForm({this.existing});

  @override
  ConsumerState<_CashFlowForm> createState() => _CashFlowFormState();
}

class _CashFlowFormState extends ConsumerState<_CashFlowForm> {
  late final TextEditingController _note;
  late DateTime _date;
  late Money _amount;

  /// Nạp hay rút chọn bằng nút, không bắt người dùng gõ dấu trừ. Xem FR-22.
  late bool _isDeposit;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _note = TextEditingController(text: existing?.note ?? '');
    _date = existing?.date ?? DateTime.now().toUtc();
    _amount = existing?.amount.abs() ?? Money.zero;
    _isDeposit = existing?.isWithdrawal != true;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? l10n.addCashFlow : l10n.editCashFlow,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.south_west),
                  label: Text(l10n.cashFlowDeposit),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.north_east),
                  label: Text(l10n.cashFlowWithdraw),
                ),
              ],
              selected: {_isDeposit},
              onSelectionChanged: (selection) =>
                  setState(() => _isDeposit = selection.first),
            ),
            const SizedBox(height: 12),
            MoneyField(
              label: l10n.cashFlowAmount,
              initial: _amount,
              onChanged: (value) => _amount = value,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.cashFlowDate),
              subtitle: Text(VnDate.full(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            TextField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.cashFlowNote),
            ),
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
                FilledButton(onPressed: _save, child: Text(l10n.actionSave)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.toLocal(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _delete() async {
    if (!await confirmDeleteCashFlow(context)) return;
    await ref.read(cashFlowRepositoryProvider).remove(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final repo = ref.read(cashFlowRepositoryProvider);
    final signed = _isDeposit ? _amount.abs() : -_amount.abs();

    if (widget.existing == null) {
      await repo.add(date: _date, amount: signed, note: _note.text);
    } else {
      await repo.update(
        widget.existing!.id,
        date: _date,
        amount: signed,
        note: _note.text,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}
