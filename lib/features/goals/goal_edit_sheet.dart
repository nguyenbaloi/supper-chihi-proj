import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../core/money/scaled_value.dart';
import '../../domain/models/goal.dart';
import '../../presentation/providers/providers.dart';

Future<void> showGoalEditSheet(BuildContext context, {Goal? existing}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _GoalEditSheet(existing: existing),
    );

class _GoalEditSheet extends ConsumerStatefulWidget {
  const _GoalEditSheet({this.existing});

  final Goal? existing;

  @override
  ConsumerState<_GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends ConsumerState<_GoalEditSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _target = TextEditingController(
    text: widget.existing?.targetRaw == null
        ? ''
        : VnFormat.groupDigits(widget.existing!.targetRaw!.toString()),
  );
  late final TextEditingController _unit =
      TextEditingController(text: widget.existing?.unit ?? 'VND');
  late bool _isNumeric = widget.existing?.isNumeric ?? true;
  late DateTime? _dueDate = widget.existing?.dueDate;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = S.required);
      return;
    }
    int? targetRaw;
    if (_isNumeric) {
      final parsed = ScaledValue.tryParse(_target.text, 0);
      if (parsed == null || parsed.raw <= 0) {
        setState(() => _error = S.goalTargetRequired);
        return;
      }
      targetRaw = parsed.raw;
    }

    final repo = ref.read(goalRepositoryProvider);
    if (widget.existing == null) {
      await repo.create(
        name: name,
        isNumeric: _isNumeric,
        targetRaw: targetRaw,
        unit: _unit.text.trim().isEmpty ? 'VND' : _unit.text.trim(),
        dueDate: _dueDate,
      );
    } else {
      await repo.update(
        widget.existing!.copyWith(
          name: name,
          isNumeric: _isNumeric,
          targetRaw: targetRaw,
          clearTarget: !_isNumeric,
          unit: _unit.text.trim().isEmpty ? 'VND' : _unit.text.trim(),
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.existing == null ? S.goalNew : S.edit,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: widget.existing == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: S.goalName,
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(S.goalNumeric),
              subtitle: const Text(S.goalQualitative),
              value: _isNumeric,
              onChanged: (v) => setState(() => _isNumeric = v),
            ),
            if (_isNumeric) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _target,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: S.goalTarget, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _unit,
                decoration: const InputDecoration(
                    labelText: S.goalUnit, border: OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text(S.goalDueDate),
              subtitle: Text(
                _dueDate == null ? S.goalNoDueDateHint : VnFormat.date(_dueDate!),
              ),
              trailing: _dueDate == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime(now.year + 1, now.month, now.day),
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 30),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _submit, child: const Text(S.save)),
          ],
        ),
      ),
    );
  }
}
