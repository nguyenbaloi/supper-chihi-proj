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
  int? projectId,
  int? areaId,
  Review? existing,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          _ReviewEditSheet(projectId: projectId, areaId: areaId, existing: existing),
    );

class _ReviewEditSheet extends ConsumerStatefulWidget {
  const _ReviewEditSheet({this.projectId, this.areaId, this.existing});

  final int? projectId;
  final int? areaId;
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

  /// FR-49: tên các Dự án **đang mở** trong Lĩnh vực, đề nghị nạp sẵn thành
  /// Mục đánh giá. Chỉ dùng khi Đợt này thuộc một Lĩnh vực.
  ///
  /// Đây là **chép văn bản**, không phải khoá ngoại tới Dự án — AD-15. Đổi tên
  /// Dự án về sau không được làm đổi một Đợt đã lưu.
  final Set<String> _prefillSelected = {};
  List<String> _prefillLabels = const [];
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
        (widget.projectId != null
                ? ref.read(projectReviewsProvider(widget.projectId!))
                : ref.read(areaReviewsProvider(widget.areaId!)))
            .value ??
            const [];
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

  /// Chỉ gợi ý khi đây là Đợt **đầu tiên** của Lĩnh vực. Từ Đợt thứ hai trở đi
  /// việc kế thừa Mục chưa đạt (FR-37) đã lo phần này, và hiện cả hai danh
  /// sách cùng lúc sẽ tạo ra Mục trùng.
  void _loadPrefill() {
    if (widget.areaId == null || widget.existing != null) return;
    if (_candidates.isNotEmpty) return;
    final summaries = ref.read(areaReviewsProvider(widget.areaId!)).value;
    if (summaries != null && summaries.isNotEmpty) return;
    final projects = ref.read(allProjectSummariesProvider).value ?? const [];
    final labels = projects
        .where((s) => s.project.areaId == widget.areaId && s.project.status.isOpen)
        .map((s) => s.project.name)
        .toList();
    if (labels.length == _prefillLabels.length) return;
    _prefillLabels = labels;
    _prefillSelected.addAll(labels);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final repo = ref.read(reviewRepositoryProvider);
    if (widget.existing == null) {
      final created = await repo.create(
        projectId: widget.projectId,
        areaId: widget.areaId,
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
      // Chép tên Dự án thành Mục — bản chụp văn bản, không nối khoá ngoại.
      for (final label in _prefillLabels) {
        if (!_prefillSelected.contains(label)) continue;
        await repo.addItem(reviewId: created.id, label: label);
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
    _loadPrefill();
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
              ),
            ),
            if (_prefillLabels.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(S.reviewPrefillFromProjects,
                  style: theme.textTheme.titleSmall),
              Text(S.reviewPrefillHint, style: theme.textTheme.bodySmall),
              for (final label in _prefillLabels)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _prefillSelected.contains(label),
                  title: Text(label),
                  onChanged: (v) => setState(() {
                    v == true
                        ? _prefillSelected.add(label)
                        : _prefillSelected.remove(label);
                  }),
                ),
            ],
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
