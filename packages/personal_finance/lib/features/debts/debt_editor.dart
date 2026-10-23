import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_date.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/debt.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/confirm_dialog.dart';
import '../../presentation/widgets/form_sheet.dart';
import '../../presentation/widgets/money_field.dart';

Future<void> showDebtEditor(
  BuildContext context,
  WidgetRef ref, {
  Debt? existing,
}) =>
    showFormSheet<void>(
      context,
      builder: (_) => _DebtForm(existing: existing),
    );

class _DebtForm extends ConsumerStatefulWidget {
  final Debt? existing;

  const _DebtForm({this.existing});

  @override
  ConsumerState<_DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends ConsumerState<_DebtForm> {
  late final TextEditingController _name;
  late final TextEditingController _note;
  late DateTime _date;
  late Money _amount;

  /// Cho vay hay đi vay chọn bằng nút, không gõ dấu âm. Xem FR-32.
  late bool _isLent;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.personName ?? '');
    _note = TextEditingController(text: existing?.note ?? '');
    _date = existing?.date ?? DateTime.now().toUtc();
    _amount = existing?.amount.abs() ?? Money.zero;
    _isLent = existing?.isBorrowed != true;
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final existing = widget.existing;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existing == null ? l10n.addDebt : l10n.editDebt,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l10n.debtLent)),
                ButtonSegment(value: false, label: Text(l10n.debtBorrowed)),
              ],
              selected: {_isLent},
              onSelectionChanged: (s) => setState(() => _isLent = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.debtPersonName),
            ),
            const SizedBox(height: 12),
            MoneyField(
              label: l10n.debtAmount,
              initial: _amount,
              onChanged: (value) => _amount = value,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.debtDate),
              subtitle: Text(VnDate.full(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            TextField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.debtNote),
            ),
            if (existing != null) ...[
              const SizedBox(height: 12),
              // Tất toán không hỏi tiền thu về đi đâu và không tự tạo thao tác
              // nào khác. Xem FR-33.
              FilledButton.tonalIcon(
                onPressed: _toggleSettled,
                icon: Icon(
                  existing.isSettled ? Icons.undo : Icons.task_alt,
                ),
                label: Text(
                  existing.isSettled ? l10n.debtUnsettle : l10n.debtSettle,
                ),
              ),
            ],
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
                if (existing != null)
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

  Future<void> _toggleSettled() async {
    final repo = ref.read(debtRepositoryProvider);
    final existing = widget.existing!;
    if (existing.isSettled) {
      await repo.unsettle(existing.id);
    } else {
      await repo.settle(existing.id, DateTime.now().toUtc());
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l10n = AppL10n.of(context);
    final existing = widget.existing!;
    final confirmed = await confirmAction(
      context,
      title: l10n.debtDeleteConfirm(existing.personName),
      confirmLabel: l10n.actionDelete,
    );
    if (!confirmed) return;
    await ref.read(debtRepositoryProvider).remove(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.debtNameEmpty);
      return;
    }

    final repo = ref.read(debtRepositoryProvider);
    final signed = _isLent ? _amount.abs() : -_amount.abs();

    if (widget.existing == null) {
      await repo.add(
        personName: _name.text,
        amount: signed,
        date: _date,
        note: _note.text,
      );
    } else {
      await repo.update(
        widget.existing!.id,
        personName: _name.text,
        amount: signed,
        date: _date,
        note: _note.text,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}
