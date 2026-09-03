import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/project.dart';
import '../../presentation/providers/providers.dart';

/// FR-5, FR-6: trường bắt buộc duy nhất là **tên**; mọi trường khác có mặc
/// định hợp lý. Không có ô nhập nào cho `createdAt`/`updatedAt` — AD-5.
Future<int?> showProjectEditSheet(BuildContext context, {Project? existing}) =>
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProjectEditSheet(existing: existing),
    );

class _ProjectEditSheet extends ConsumerStatefulWidget {
  const _ProjectEditSheet({this.existing});

  final Project? existing;

  @override
  ConsumerState<_ProjectEditSheet> createState() => _ProjectEditSheetState();
}

class _ProjectEditSheetState extends ConsumerState<_ProjectEditSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late Priority _priority = widget.existing?.priority ?? Priority.medium;
  late int? _areaId = widget.existing?.areaId;
  late DateTime? _dueDate = widget.existing?.dueDate;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = S.projectNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(projectRepositoryProvider);
    int id;
    if (widget.existing == null) {
      final created = await repo.create(
        name: name,
        description: _description.text.trim(),
        areaId: _areaId,
        priority: _priority,
        dueDate: _dueDate,
      );
      id = created.id;
    } else {
      await repo.update(
        widget.existing!.copyWith(
          name: name,
          description: _description.text.trim(),
          areaId: _areaId,
          priority: _priority,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
        ),
      );
      id = widget.existing!.id;
    }
    if (mounted) Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final areas = ref.watch(areasProvider).value ?? const [];
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? S.projectNew : S.edit,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: widget.existing == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: S.projectName,
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: S.projectDescription,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _areaId,
              decoration: const InputDecoration(
                labelText: S.projectArea,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final t in areas)
                  DropdownMenuItem(value: t.id, child: Text(t.name)),
              ],
              onChanged: (v) => setState(() => _areaId = v),
            ),
            const SizedBox(height: 12),
            SegmentedButton<Priority>(
              segments: [
                for (final p in Priority.values)
                  ButtonSegment(value: p, label: Text(S.priority(p))),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(S.projectDueDate),
              subtitle: Text(
                _dueDate == null ? S.projectNoDueDate : VnFormat.date(_dueDate!),
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
                  initialDate: _dueDate ?? now,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 20),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: const Text(S.save),
            ),
          ],
        ),
      ),
    );
  }
}
