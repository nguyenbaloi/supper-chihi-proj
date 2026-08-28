import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/repositories/repositories.dart';
import '../../presentation/providers/providers.dart';
import 'review_detail_screen.dart';
import 'review_edit_sheet.dart';

/// FR-38: dòng thời gian đánh giá của một Dự án.
class ProjectReviewsTab extends ConsumerWidget {
  const ProjectReviewsTab({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(projectReviewsProvider(projectId)).value ?? const [];
    final theme = Theme.of(context);

    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(S.reviewEmpty,
                  style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(S.reviewFirst),
                onPressed: () => showReviewEditSheet(context, projectId: projectId),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: reviews.length,
          itemBuilder: (context, i) => _ReviewCard(
            summary: reviews[i],
            isLatest: i == 0,
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'review-fab',
            onPressed: () => showReviewEditSheet(context, projectId: projectId),
            icon: const Icon(Icons.add),
            label: const Text(S.reviewNew),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.summary, required this.isLatest});

  final ReviewSummary summary;
  final bool isLatest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(nowProvider)();
    final r = summary.review;
    final due = isLatest &&
        r.nextReviewDate != null &&
        !r.nextReviewDate!.toLocal().isAfter(now);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ReviewDetailScreen(reviewId: r.id, projectId: r.projectId),
          ),
        ),
        title: Text(r.title.isEmpty ? VnFormat.date(r.date) : r.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(VnFormat.date(r.date), style: theme.textTheme.bodySmall),
              Text(
                // FR-39: Đợt không có Mục nào hiện `—`, không hiện `0%`.
                summary.itemCount == 0
                    ? VnFormat.emptyValue
                    : S.reviewMetRatio(summary.metCount, summary.itemCount),
                style: theme.textTheme.bodySmall,
              ),
              if (r.nextReviewDate != null)
                Text(
                  '${S.reviewNextDate}: ${VnFormat.date(r.nextReviewDate!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: due ? theme.colorScheme.error : null,
                    fontWeight: due ? FontWeight.w600 : null,
                  ),
                ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
