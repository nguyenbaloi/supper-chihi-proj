import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/project_action.dart';
import '../../presentation/providers/providers.dart';

/// FR-14: nhập một Hành động là nhập **cả ba** thứ — tên, hạn và độ ưu tiên.
///
/// Mở thành **màn hình riêng** chứ không phải sheet: tên việc thường dài, cần
/// một ô lớn tự xuống dòng để đọc lại được toàn bộ trước khi lưu.
///
/// Trường bắt buộc duy nhất vẫn là tên; hạn để trống thì Hành động không có
/// hạn, đúng như trước. Không có ô nhập nào cho `createdAt`, `updatedAt`,
/// `startedAt` hay `completedAt` — AD-5 giữ bốn mốc đó cho tầng dữ liệu.
Future<int?> showActionForm(
  BuildContext context, {
  int? projectId,
  ProjectAction? existing,
}) {
  assert(projectId != null || existing != null, 'FR-14');
  return Navigator.of(context).push<int>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ActionFormScreen(projectId: projectId, existing: existing),
    ),
  );
}

class _ActionFormScreen extends ConsumerStatefulWidget {
  const _ActionFormScreen({this.projectId, this.existing});

  final int? projectId;
  final ProjectAction? existing;

  @override
  ConsumerState<_ActionFormScreen> createState() => _ActionFormScreenState();
}

class _ActionFormScreenState extends ConsumerState<_ActionFormScreen> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');
  final _titleFocus = FocusNode();

  /// Hạn và độ ưu tiên **giữ nguyên** sau "Lưu và thêm tiếp", để gõ một loạt
  /// việc cùng hạn cùng mức ưu tiên chỉ phải chọn một lần — FR-14.
  late Priority _priority = widget.existing?.priority ?? Priority.medium;
  late DateTime? _dueDate = widget.existing?.dueDate;
  String? _error;
  bool _busy = false;

  bool get _isNew => widget.existing == null;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _submit({bool next = false}) async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = S.actionTitleRequired);
      _titleFocus.requestFocus();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(actionRepositoryProvider);
    final int id;
    if (_isNew) {
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
    if (!mounted) return;
    if (next) {
      _title.clear();
      _note.clear();
      setState(() => _busy = false);
      _titleFocus.requestFocus();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text(S.actionAddedToast),
          duration: Duration(seconds: 2),
        ));
      return;
    }
    Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? S.actionNew : S.actionEdit),
        actions: [
          TextButton(
            onPressed: _busy ? null : _submit,
            child: const Text(S.save),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              focusNode: _titleFocus,
              autofocus: _isNew,
              minLines: 4,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: S.actionTitle,
                hintText: S.actionTitleHint,
                alignLabelWithHint: true,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _note,
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: S.actionNote,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(S.actionPriority, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
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
            if (_isNew) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : () => _submit(next: true),
                child: const Text(S.actionSaveAndNext),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ba mức ưu tiên, dùng chung cho màn hình nhập và màn hình chi tiết Hành động.
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
