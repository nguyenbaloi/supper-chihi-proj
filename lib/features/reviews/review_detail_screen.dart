import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/review.dart';
import '../../domain/rules/review.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/chips.dart';
import '../notes/markdown_view.dart';
import 'review_edit_sheet.dart';

class ReviewDetailScreen extends ConsumerStatefulWidget {
  const ReviewDetailScreen({
    super.key,
    required this.reviewId,
    required this.projectId,
  });

  final int reviewId;
  final int projectId;

  @override
  ConsumerState<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends ConsumerState<ReviewDetailScreen> {
  final _newItem = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _newItem.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final label = _newItem.text.trim();
    if (label.isEmpty) return;
    _newItem.clear();
    await ref
        .read(reviewRepositoryProvider)
        .addItem(reviewId: widget.reviewId, label: label);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final summaries =
        ref.watch(projectReviewsProvider(widget.projectId)).value ?? const [];
    final match = summaries.where((s) => s.review.id == widget.reviewId);
    if (match.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final review = match.first.review;
    final items = ref.watch(reviewItemsProvider(widget.reviewId)).value ?? const [];
    final tally = tallyReview(items.map((i) => i.verdict));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(review.title.isEmpty ? VnFormat.date(review.date) : review.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showReviewEditSheet(
              context,
              projectId: widget.projectId,
              existing: review,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(reviewRepositoryProvider).delete(widget.reviewId);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    Text('${S.reviewDate}: ${VnFormat.date(review.date)}',
                        style: theme.textTheme.bodySmall),
                    Text(
                      review.nextReviewDate == null
                          ? S.reviewNoNextDate
                          : '${S.reviewNextDate}: ${VnFormat.date(review.nextReviewDate!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      tally.isEmpty
                          ? VnFormat.emptyValue
                          : '${S.reviewMetRatio(tally.metCount, tally.total)} · ${VnFormat.percent(tally.ratio, fractionDigits: 0)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (review.summaryMarkdown.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  MarkdownView(review.summaryMarkdown),
                ],
              ],
            ),
          ),
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItem,
                    focusNode: _focus,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: S.reviewItemNew,
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addItem,
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(S.reviewItemEmpty, style: theme.textTheme.bodyMedium))
                : ReorderableListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 40),
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final ids = items.map((i) => i.id).toList();
                      final moved = ids.removeAt(oldIndex);
                      ids.insert(newIndex, moved);
                      await ref
                          .read(reviewRepositoryProvider)
                          .reorderItems(widget.reviewId, ids);
                    },
                    children: [
                      for (final item in items)
                        _ItemTile(key: ValueKey(item.id), item: item),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({super.key, required this.item});

  final ReviewItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(item.label, style: theme.textTheme.bodyLarge),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              children: [
                for (final v in ReviewVerdict.values)
                  GestureDetector(
                    onTap: () => ref
                        .read(reviewRepositoryProvider)
                        .updateItem(item.copyWith(verdict: v)),
                    child: Opacity(
                      opacity: item.verdict == v ? 1 : 0.35,
                      child: VerdictChip(v),
                    ),
                  ),
              ],
            ),
            if (item.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(item.note, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
      trailing: PopupMenuButton<String>(
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'note', child: Text(S.reviewItemNote)),
          PopupMenuItem(value: 'delete', child: Text(S.delete)),
        ],
        onSelected: (v) async {
          final repo = ref.read(reviewRepositoryProvider);
          if (v == 'delete') {
            await repo.deleteItem(item.id);
            return;
          }
          final controller = TextEditingController(text: item.note);
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(S.reviewItemNote),
              content: TextField(
                controller: controller,
                autofocus: true,
                minLines: 2,
                maxLines: 6,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(S.cancel)),
                FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(S.save)),
              ],
            ),
          );
          if (ok == true) {
            await repo.updateItem(item.copyWith(note: controller.text.trim()));
          }
        },
      ),
    );
  }
}
