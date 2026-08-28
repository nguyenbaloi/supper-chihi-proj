import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/review.dart';
import '../../domain/rules/review.dart';
import '../../presentation/providers/providers.dart';

/// FR-35 và FR-37: tạo Đợt đánh giá, kèm bước chép các Mục chưa đạt từ Đợt trước.
Future<void> showReviewEditSheet(
  BuildContext context, {
  required int projectId,
  Review? existing,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ReviewEditSheet(projectId: projectId, existing: existing),
    );

class _ReviewEditSheet extends ConsumerStatefulWidget {
  const _ReviewEditSheet({required this.projectId, this.existing});

  final int projectId;
  final Review? existing;

  @override
  ConsumerState<_ReviewEditSheet> createState() => _ReviewEditSheetState();
}

class _ReviewEditSheetState extends ConsumerState<_ReviewEditSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _summary =
      TextEditingController(text: widget.existing?.summaryMarkdown ?? '');
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  late DateTime? _next = widget.existing?.nextReviewDate;

  /// Nhãn của Mục được chọn để chép sang. Chỉ dùng khi tạo mới.
  final Set<int> _carrySelected = {};
  List<ReviewItem> _candidates = const [];
  bool _loadedCandidates = false;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    if (_loadedCandidates || widget.existing != null) return;
    _loadedCandidates = true;
    final summaries =
        ref.read(projectReviewsProvider(widget.projectId)).value ?? const [];
    if (summaries.isEmpty) return;
    final previous = summaries.first.review;
    final items = await ref.read(reviewRepositoryProvider).getItems(previous.id);
    final candidates = carryForwardCandidates(items);
    if (!mounted) return;
    setState(() {
      _candidates = candidates;
      _carrySelected.addAll(candidates.map((i) => i.id));
    });
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final repo = ref.read(reviewRepositoryProvider);
    if (widget.existing == null) {
      final created = await repo.create(
        projectId: widget.projectId,
        date: _date,
        title: _title.text.trim(),
        summaryMarkdown: _summary.text,
        nextReviewDate: _next,
      );
      final chosen =
          _candidates.where((i) => _carrySelected.contains(i.id)).toList();
      if (chosen.isNotEmpty) {
        await repo.carryForward(targetReviewId: created.id, items: chosen);
      }
    } else {
      await repo.update(widget.existing!.copyWith(
        date: _date,
        title: _title.text.trim(),
        summaryMarkdown: _summary.text,
        nextReviewDate: _next,
        clearNextReviewDate: _next == null,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    _loadCandidates();
    final theme = Theme.of(context);
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.existing == null ? S.reviewNew : S.edit,
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '${S.reviewTitle} (${S.optional})',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _DateRow(
              label: S.reviewDate,
              value: VnFormat.date(_date),
              onPick: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(_date.year - 10),
                  lastDate: DateTime(_date.year + 10),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            _DateRow(
              label: S.reviewNextDate,
              value: _next == null ? S.reviewNoNextDate : VnFormat.date(_next!),
              onClear: _next == null ? null : () => setState(() => _next = null),
              onPick: () async {
                final base = _next ?? DateTime(_date.year, _date.month + 3, _date.day);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: base,
                  firstDate: DateTime(_date.year - 10),
                  lastDate: DateTime(_date.year + 10),
                );
                if (picked != null) setState(() => _next = picked);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _summary,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: S.reviewSummary,
                border: OutlineInputBorder(),
              ),
            ),
            if (_candidates.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(S.reviewCarryForward, style: theme.textTheme.titleSmall),
              Text(S.reviewCarryForwardHint, style: theme.textTheme.bodySmall),
              for (final item in _candidates)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _carrySelected.contains(item.id),
                  title: Text(item.label),
                  onChanged: (v) => setState(() {
                    v == true
                        ? _carrySelected.add(item.id)
                        : _carrySelected.remove(item.id);
                  }),
                ),
            ],
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

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.event_outlined),
        title: Text(label),
        subtitle: Text(value),
        trailing: onClear == null
            ? null
            : IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
        onTap: onPick,
      );
}
