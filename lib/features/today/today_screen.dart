import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/project_action.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/day.dart';
import '../../domain/rules/pace.dart';
import '../../domain/rules/review.dart';
import '../../domain/rules/stale.dart';
import '../../presentation/providers/providers.dart';
import '../actions/action_tile.dart';
import '../goals/goal_detail_screen.dart';
import '../projects/project_detail_screen.dart';

/// FR-29 — lý do tồn tại của ứng dụng ở nhịp dùng hằng ngày.
///
/// Bốn nhóm, đúng thứ tự: Quá hạn → Đang làm → Đến hạn trong 7 ngày →
/// Cần chú ý. Màn hình này **không bao giờ** liệt kê toàn bộ Hành động chưa
/// xong; nhóm rỗng biến mất hoàn toàn.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider)();
    final summaries = ref.watch(allProjectSummariesProvider).value ?? const [];
    final staleDays =
        ref.watch(settingsProvider).value?.staleDays ?? defaultStaleDays;
    final goals = ref.watch(goalsProvider).value ?? const [];

    final projectById = {for (final s in summaries) s.project.id: s};
    final actions = <ProjectAction>[
      for (final s in summaries)
        ...(ref.watch(projectActionsProvider(s.project.id)).value ?? const []),
    ];

    final overdue = actions
        .where((a) =>
            a.status.isOpen &&
            a.dueDate != null &&
            isOverdue(dueDate: a.dueDate!, now: now))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final doing = actions.where((a) => a.status == ActionStatus.doing).toList();

    final dueSoon = actions
        .where((a) =>
            a.status.isOpen &&
            a.dueDate != null &&
            isDueSoon(dueDate: a.dueDate!, now: now))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final staleProjects = summaries
        .where((s) => isProjectStale(
              status: s.project.status,
              lastActivityAt: s.lastActivityAt,
              createdAt: s.project.createdAt,
              now: now,
              staleDays: staleDays,
            ))
        .toList();

    // FR-40: chỉ Đợt gần nhất của mỗi Dự án được xét, và Dự án đã đóng thì
    // không bao giờ nhắc.
    final allReviews = ref.watch(allReviewsProvider).value ?? const [];
    final dueReview = <ProjectSummary>[];
    for (final s in summaries) {
      final ofProject =
          allReviews.where((r) => r.projectId == s.project.id).toList();
      if (isReviewDue(status: s.project.status, reviews: ofProject, now: now)) {
        dueReview.add(s);
      }
    }

    final behindGoals = <Goal>[];
    for (final g in goals) {
      if (g.dueDate == null) continue;
      final updates = ref.watch(goalUpdatesProvider(g.id)).value ?? const [];
      final pace = computePace(goal: g, updates: updates, now: now);
      if (pace.verdict == PaceVerdict.behind ||
          pace.verdict == PaceVerdict.goingBackwards ||
          pace.verdict == PaceVerdict.pastDue) {
        behindGoals.add(g);
      }
    }

    final hasAnything = overdue.isNotEmpty ||
        doing.isNotEmpty ||
        dueSoon.isNotEmpty ||
        staleProjects.isNotEmpty ||
        dueReview.isNotEmpty ||
        behindGoals.isNotEmpty;

    if (!hasAnything) return const _AllClear();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (overdue.isNotEmpty)
          _Group(
            title: S.todayOverdue,
            emphasise: true,
            children: [
              for (final a in overdue)
                _ActionRow(action: a, project: projectById[a.projectId]),
            ],
          ),
        if (doing.isNotEmpty)
          _Group(
            title: S.todayDoing,
            children: [
              for (final a in doing)
                _ActionRow(action: a, project: projectById[a.projectId]),
            ],
          ),
        if (dueSoon.isNotEmpty)
          _Group(
            title: S.todayDueSoon,
            children: [
              for (final a in dueSoon)
                _ActionRow(action: a, project: projectById[a.projectId]),
            ],
          ),
        if (staleProjects.isNotEmpty ||
            dueReview.isNotEmpty ||
            behindGoals.isNotEmpty)
          _Group(
            title: S.todayAttention,
            children: [
              for (final s in dueReview)
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined),
                  title: Text(s.project.name),
                  subtitle: Text(S.reviewDue),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProjectDetailScreen(projectId: s.project.id),
                    ),
                  ),
                ),
              for (final s in staleProjects)
                ListTile(
                  leading: const Icon(Icons.hourglass_bottom_outlined),
                  title: Text(s.project.name),
                  subtitle: Text(
                    '${S.staleProject} ${S.days(idleDays(
                      lastActivityAt: s.lastActivityAt,
                      createdAt: s.project.createdAt,
                      now: now,
                    ))}',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProjectDetailScreen(projectId: s.project.id),
                    ),
                  ),
                ),
              for (final g in behindGoals)
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(g.name),
                  subtitle: Text(
                    '${S.goalBehindPace}'
                    '${g.dueDate == null ? '' : ' · ${VnFormat.date(g.dueDate!)}'}',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GoalDetailScreen(goalId: g.id),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action, this.project});

  final ProjectAction action;
  final ProjectSummary? project;

  @override
  Widget build(BuildContext context) => ActionTile(
        action: action,
        subtitleOverride: project?.project.name,
        onTap: project == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ProjectDetailScreen(projectId: project!.project.id),
                  ),
                ),
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children, this.emphasise = false});

  final String title;
  final List<Widget> children;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: emphasise ? theme.colorScheme.error : theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(S.todayAllClear,
                style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text(S.todayGoToProjects),
            ),
          ],
        ),
      ),
    );
  }
}
