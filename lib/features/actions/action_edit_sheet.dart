import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/project_action.dart';
import '../../presentation/providers/providers.dart';

/// FR-14: nhập một Hành động là nhập **cả ba** thứ — tên, hạn và độ ưu tiên.
///
/// Trường bắt buộc duy nhất vẫn là tên; hạn để trống thì Hành động không có
/// hạn, đúng như trước. Không có ô nhập nào cho `createdAt`, `updatedAt`,
/// `startedAt` hay `completedAt` — AD-5 giữ bốn mốc đó cho tầng dữ liệu.
Future<int?> showActionEditSheet(
  BuildContext context, {
  int? projectId,
  ProjectAction? existing,
}) {
  assert(projectId != null || existing != null, 'FR-14');
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ActionEditSheet(projectId: projectId, existing: existing),
  );
}

class _ActionEditSheet extends ConsumerStatefulWidget {
  const _ActionEditSheet({this.projectId, this.existing});

  final int? projectId;
  final ProjectAction? existing;

  @override
  ConsumerState<_ActionEditSheet> createState() => _ActionEditSheetState();
}

class _ActionEditSheetState extends ConsumerState<_ActionEditSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');
  late Priority _priority = widget.existing?.priority ?? Priority.medium;
  late DateTime? _dueDate = widget.existing?.dueDate;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = S.actionTitleRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(actionRepositoryProvider);
    final int id;
    if (widget.existing == null) {
      final created = await repo.create(
        projectId: widget.projectId!,
        title: title,
        note: _note.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      );
      id = created.id;
    } else {
      await repo.update(
        widget.existing!.copyWith(
          title: title,
          note: _note.text.trim(),
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
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? S.actionNew : S.actionEdit,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: widget.existing == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: S.actionTitle,
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: S.actionNote,
              ),
            ),
            const SizedBox(height: 12),
            ActionPrioritySelector(
              value: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 4),
            ActionDueDateField(
              value: _dueDate,
              onChanged: (d) => setState(() => _dueDate = d),
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

/// Ba mức ưu tiên, dùng chung cho sheet nhập và ô thêm nhanh của Dự án.
class ActionPrioritySelector extends StatelessWidget {
  const ActionPrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Priority value;
  final ValueChanged<Priority> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<Priority>(
        showSelectedIcon: false,
        segments: [
          for (final p in Priority.values)
            ButtonSegment(value: p, label: Text(S.priority(p))),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      );
}

/// Ô chọn hạn hoàn thành. Hạn là **ngày**, không có giờ — FR-17.
class ActionDueDateField extends StatelessWidget {
  const ActionDueDateField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.event_outlined),
        title: const Text(S.actionDueDate),
        subtitle: Text(
          value == null ? S.actionNoDueDate : VnFormat.date(value!),
        ),
        trailing: value == null
            ? null
            : IconButton(
                tooltip: S.delete,
                icon: const Icon(Icons.clear),
                onPressed: () => onChanged(null),
              ),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? now,
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 20),
          );
          if (picked != null) onChanged(picked);
        },
      );
}
