import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/area.dart';
import '../../domain/rules/cadence.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/layout.dart';
import '../notes/markdown_view.dart';
import '../reviews/review_detail_screen.dart';
import '../reviews/review_edit_sheet.dart';

/// Màn hình một Lĩnh vực — FR-47, FR-48, FR-49.
///
/// Ba thứ Lĩnh vực có mà Chủ đề cũ không có: **mức cần giữ**, **nhịp xem lại**,
/// và **Đợt đánh giá của riêng nó**. Thiếu cả ba thì nó chỉ là một cái nhãn màu.
///
/// Không có nút "Xong" và không có trạng thái. Lĩnh vực không kết thúc — cái
/// kết thúc được là Dự án nằm trong nó.
class AreaDetailScreen extends ConsumerWidget {
  const AreaDetailScreen({super.key, required this.areaId});

  final int areaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areas = ref.watch(areasProvider).value ?? const <Area>[];
    final match = areas.where((a) => a.id == areaId);
    if (match.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final area = match.first;
    final reviews = ref.watch(areaReviewsProvider(areaId)).value ?? const [];
    final theme = Theme.of(context);
    final color = Color(area.colorValue);

    // AD-3: tính tại chỗ từ Đợt mới nhất. Không cột nào lưu con số này, nên
    // xoá Đợt gần nhất là nó tự lùi lại ngay.
    final lastReviewDate =
        reviews.isEmpty ? null : reviews.first.review.date;
    final next = nextAreaReviewDate(
      cadenceDays: area.reviewCadenceDays,
      lastReviewDate: lastReviewDate,
      areaCreatedAt: area.createdAt,
    );
    final daysLeft = daysUntilAreaReview(
      cadenceDays: area.reviewCadenceDays,
      lastReviewDate: lastReviewDate,
      areaCreatedAt: area.createdAt,
      now: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(area.name),
        actions: [
          IconButton(
            tooltip: S.areaEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showAreaEditSheet(context, ref, area),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl * 2),
        children: [
          // FR-47 — mức cần giữ. Rỗng thì không chiếm chỗ, chỉ còn lời mời ghi.
          SectionHeader(
            title: S.areaStandard,
            color: color,
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg,
                AppSpacing.gutter, AppSpacing.sm),
          ),
          SectionCard(
            child: area.standard.isEmpty
                ? Text(S.areaStandardEmpty, style: theme.textTheme.bodySmall)
                : MarkdownView(area.standard),
          ),

          // FR-48 — nhịp. Không đặt thì nói thẳng là không nhắc, và **không
          // hiện ngày nào cả**: bịa ra một cái hạn người dùng chưa từng đặt là
          // đúng thứ nguyên tắc này cấm.
          SectionHeader(title: S.areaCadence, color: color),
          GroupedCard(
            dividerIndent: AppSpacing.gutter,
            children: [
              ListTile(
                title: Text(area.reviewCadenceDays == null
                    ? S.areaCadenceNone
                    : S.areaCadenceEvery(area.reviewCadenceDays!)),
                subtitle: area.reviewCadenceDays == null
                    ? const Text(S.areaCadenceNoneHint)
                    : null,
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => showAreaEditSheet(context, ref, area),
              ),
              if (next != null)
                ListTile(
                  leading: const Icon(Icons.event_repeat_outlined),
                  title: const Text(S.areaNextReview),
                  subtitle: Text(VnFormat.date(next)),
                  trailing: _DueBadge(daysLeft: daysLeft!),
                ),
            ],
          ),

          // FR-49 — Đợt đánh giá của Lĩnh vực. Tách hẳn với Đợt của Dự án.
          SectionHeader(
            title: S.reviews,
            color: color,
            trailing: TextButton.icon(
              onPressed: () => showReviewEditSheet(context, areaId: areaId),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(S.areaReviewNew),
            ),
          ),
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
              child: DottedHint(
                  text: S.areaReviewsEmpty, icon: Icons.history_outlined),
            )
          else
            GroupedCard(
              children: [
                for (final s in reviews)
                  ListTile(
                    leading: const Icon(Icons.history_outlined),
                    title: Text(s.review.title.isEmpty
                        ? VnFormat.date(s.review.date)
                        : s.review.title),
                    subtitle: Text(s.itemCount == 0
                        ? VnFormat.date(s.review.date)
                        : '${VnFormat.date(s.review.date)} · ${s.metCount}/${s.itemCount}'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReviewDetailScreen(
                            reviewId: s.review.id, areaId: areaId),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // NFR-7: mỗi mức có nhãn chữ riêng, không chỉ phân biệt bằng màu.
    final (text, color) = switch (daysLeft) {
      < 0 => (S.areaReviewOverdue(-daysLeft), theme.colorScheme.error),
      0 => (S.areaReviewDueToday, theme.colorScheme.error),
      _ => (S.areaReviewDueIn(daysLeft), theme.colorScheme.onSurfaceVariant),
    };
    return Text(text,
        style: theme.textTheme.labelMedium?.copyWith(color: color));
  }
}

/// Sửa tên, mức cần giữ và nhịp xem lại.
///
/// Không có ô nhập nào cho `createdAt` — AD-5: dấu thời gian do hệ thống ghi.
Future<void> showAreaEditSheet(
    BuildContext context, WidgetRef ref, Area area) async {
  final nameCtrl = TextEditingController(text: area.name);
  final standardCtrl = TextEditingController(text: area.standard);
  int? cadence = area.reviewCadenceDays;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
      ),
      child: StatefulBuilder(
        builder: (ctx, setState) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: S.area),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: standardCtrl,
                decoration: const InputDecoration(
                  labelText: S.areaStandard,
                  helperText: S.areaStandardHint,
                  helperMaxLines: 2,
                ),
                maxLines: 5,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Text(S.areaCadence,
                  style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  // "Không nhắc" là một lựa chọn ngang hàng, không phải trạng
                  // thái thiếu dữ liệu — FR-48.
                  ChoiceChip(
                    label: const Text(S.areaCadenceNone),
                    selected: cadence == null,
                    onSelected: (_) => setState(() => cadence = null),
                  ),
                  for (final d in suggestedCadenceDays)
                    ChoiceChip(
                      label: Text(S.areaCadenceEvery(d)),
                      selected: cadence == d,
                      onSelected: (_) => setState(() => cadence = d),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text(S.cancel)),
                  const SizedBox(width: 8),
                  FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(S.save)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (saved != true) return;
  final name = nameCtrl.text.trim();
  await ref.read(areaRepositoryProvider).update(
        area.copyWith(
          name: name.isEmpty ? area.name : name,
          standard: standardCtrl.text.trim(),
          reviewCadenceDays: cadence,
          clearReviewCadence: cadence == null,
        ),
      );
}
