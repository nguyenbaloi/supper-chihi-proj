import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_action.dart';
import '../../domain/rules/completion.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/chips.dart';
import '../../presentation/widgets/layout.dart';
import '../actions/action_edit_sheet.dart';
import '../actions/action_tile.dart';
import '../notes/project_notes_tab.dart';
import '../reviews/project_reviews_tab.dart';
import 'project_edit_sheet.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId)).value;
    if (project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.name, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: S.edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showProjectEditSheet(context, existing: project),
            ),
            IconButton(
              tooltip: S.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: S.actionsTab),
              Tab(text: S.reviews),
              Tab(text: S.projectNotes),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ActionsTab(projectId: projectId),
            ProjectReviewsTab(projectId: projectId),
            ProjectNotesTab(projectId: projectId),
          ],
        ),
      ),
    );
  }

  /// FR-7 và FR-50: hộp xác nhận nêu rõ Hành động sẽ mất, còn Ghi chú và Liên
  /// kết chỉ chuyển sang Lĩnh vực nào.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(projectActionsProvider(projectId)).value ?? const [];
    final notes = ref.read(projectNotesProvider(projectId)).value ?? const [];
    final links = ref.read(projectLinksProvider(projectId)).value ?? const [];

    final project = ref.read(projectProvider(projectId)).value;
    final areas = ref.read(areasProvider).value ?? const [];
    final areaName = areas
            .where((a) => a.id == project?.areaId)
            .map((a) => a.name)
            .firstOrNull ??
        '';

    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.projectDeleteTitle),
        content: Text(
          S.projectDeleteConfirm(
              actions.length, notes.length, links.length, areaName),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false), child: const Text(S.cancel)),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true), child: const Text(S.delete)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(projectRepositoryProvider).delete(projectId);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _ActionsTab extends ConsumerStatefulWidget {
  const _ActionsTab({required this.projectId});

  final int projectId;

  @override
  ConsumerState<_ActionsTab> createState() => _ActionsTabState();
}

class _ActionsTabState extends ConsumerState<_ActionsTab> {
  bool _showClosed = false;

  /// Bộ lọc danh sách. Tập rỗng nghĩa là không lọc theo tiêu chí đó.
  Set<ActionStatus> _statusFilter = {};
  Set<Priority> _priorityFilter = {};

  bool get _filtering =>
      _statusFilter.isNotEmpty || _priorityFilter.isNotEmpty;

  bool _matches(ProjectAction a) =>
      (_statusFilter.isEmpty || _statusFilter.contains(a.status)) &&
      (_priorityFilter.isEmpty || _priorityFilter.contains(a.priority));

  int _byPriorityThenOrder(ProjectAction a, ProjectAction b) {
    final p = a.priority.sortRank.compareTo(b.priority.sortRank);
    if (p != 0) return p;
    return a.sortOrder.compareTo(b.sortOrder);
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectId)).value;
    final actions =
        ref.watch(projectActionsProvider(widget.projectId)).value ?? const [];
    final theme = Theme.of(context);

    final visible = actions.where(_matches);
    final open = visible.where((a) => a.status.isOpen).toList()
      ..sort(_byPriorityThenOrder);
    final closed = visible.where((a) => !a.status.isOpen).toList()
      ..sort(_byPriorityThenOrder);
    // Lọc theo Xong hoặc Bỏ mà nhóm đóng vẫn gấp thì như không thấy gì.
    final showClosed =
        _showClosed || _statusFilter.any((s) => !s.isOpen);

    // Cả tab là **một** vùng cuộn: thẻ đầu Dự án và nút thêm việc cuộn đi
    // cùng danh sách. Trước đây chúng chiếm chỗ cố định phía trên nên danh
    // sách việc chỉ còn một khe hẹp để cuộn.
    return CustomScrollView(
      slivers: [
        if (project != null)
          SliverToBoxAdapter(child: _ProjectHeader(project: project)),
        SliverToBoxAdapter(child: _addButton(theme)),
        if (actions.isNotEmpty)
          SliverToBoxAdapter(child: _filters(theme, actions)),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        if (actions.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.checklist_rtl_outlined,
              title: S.actionEmpty,
              message: S.actionEmptyHint,
            ),
          )
        else if (open.isEmpty && closed.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Text(
                S.actionFilterEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              sliver: SliverMainAxisGroup(
                slivers: [
                  // Đang lọc thì danh sách chỉ là một phần, kéo thả trên đó
                  // sẽ làm sai thứ tự của những việc đang bị ẩn.
                  if (_filtering)
                    SliverList.builder(
                      itemCount: open.length,
                      itemBuilder: (context, index) {
                        final a = open[index];
                        return ActionTile(
                          key: ValueKey(a.id),
                          action: a,
                          showPriority: true,
                          trailing: _ActionMenu(action: a),
                        );
                      },
                    )
                  else
                    SliverReorderableList(
                      itemCount: open.length,
                      onReorder: (oldIndex, newIndex) async {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final ids = open.map((a) => a.id).toList();
                        final moved = ids.removeAt(oldIndex);
                        ids.insert(newIndex, moved);
                        await ref.read(actionRepositoryProvider).reorder(
                            widget.projectId,
                            [...ids, ...closed.map((a) => a.id)]);
                      },
                      // Giữ nguyên cách kéo của bản trước trên điện thoại:
                      // nhấn giữ một dòng rồi kéo. Không đặt tay cầm kéo
                      // riêng vì kéo dọc tức thì sẽ cướp mất cử chỉ cuộn.
                      itemBuilder: (context, index) {
                        final a = open[index];
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(a.id),
                          index: index,
                          child: ActionTile(
                            action: a,
                            showPriority: true,
                            trailing: _ActionMenu(action: a),
                          ),
                        );
                      },
                    ),
                  SliverToBoxAdapter(
                      child: _closedGroup(theme, closed, showClosed)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Lối vào màn hình nhập Hành động — FR-14. Trông như một ô nhập để người
  /// dùng nhận ra ngay chỗ thêm việc, nhưng chạm vào thì mở màn hình riêng
  /// với ô lớn tự xuống dòng.
  Widget _addButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () => showActionForm(context, projectId: widget.projectId),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.add_circle, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    S.actionNew,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hai hàng chip lọc theo trạng thái và độ ưu tiên, mỗi chip kèm số việc.
  Widget _filters(ThemeData theme, List<ProjectAction> actions) {
    Widget row(String label, List<Widget> chips) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(label,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.outline)),
                ),
                for (final c in chips)
                  Padding(padding: const EdgeInsets.only(right: 6), child: c),
              ],
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        row(S.actionFilterStatus, [
          for (final s in ActionStatus.values)
            FilterChip(
              label: Text(
                  '${S.actionStatus(s)} · ${actions.where((a) => a.status == s).length}'),
              selected: _statusFilter.contains(s),
              onSelected: (on) => setState(() => _statusFilter =
                  on ? {..._statusFilter, s} : ({..._statusFilter}..remove(s))),
            ),
        ]),
        row(S.actionFilterPriority, [
          for (final p in Priority.values)
            FilterChip(
              label: Text(
                  '${S.priority(p)} · ${actions.where((a) => a.priority == p).length}'),
              selected: _priorityFilter.contains(p),
              onSelected: (on) => setState(() => _priorityFilter = on
                  ? {..._priorityFilter, p}
                  : ({..._priorityFilter}..remove(p))),
            ),
          if (_filtering)
            ActionChip(
              avatar: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: const Text(S.actionFilterClear),
              onPressed: () => setState(() {
                _statusFilter = {};
                _priorityFilter = {};
              }),
            ),
        ]),
        if (_filtering)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
            child: Text(
              S.actionFilterReorderHint,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
      ],
    );
  }

  /// Nhóm việc đã đóng, gấp lại ở cuối danh sách.
  Widget _closedGroup(
      ThemeData theme, List<ProjectAction> closed, bool showClosed) {
    if (closed.isEmpty) return const SizedBox(height: AppSpacing.sm);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        InkWell(
          onTap: () => setState(() => _showClosed = !_showClosed),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter, vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${S.actionClosedGroup} · ${closed.length}',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
                Icon(
                  showClosed ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        if (showClosed)
          for (final a in closed)
            ActionTile(action: a, trailing: _ActionMenu(action: a)),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

/// Đầu màn hình Dự án: mô tả, tiến độ, nhãn, và hàng đổi trạng thái.
///
/// Gom vào một thẻ để tách hẳn khỏi danh sách việc bên dưới — trước đây bốn
/// thứ này trôi trên nền chung và trông như phần đầu của danh sách.
class _ProjectHeader extends ConsumerWidget {
  const _ProjectHeader({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actions =
        ref.watch(projectActionsProvider(project.id)).value ?? const [];
    final tally = tallyCompletion(actions.map((a) => a.status));

    return SectionCard(
      margin: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md,
          AppSpacing.gutter, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.description.isNotEmpty) ...[
            Text(
              project.description,
              style: theme.textTheme.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ProgressRow(
            ratio: tally.isEmpty
                ? null
                : tally.doneCount / tally.countedTotal,
            label: tally.isEmpty
                ? VnFormat.emptyValue
                : '${tally.doneCount}/${tally.countedTotal} · '
                    '${VnFormat.percent(tally.ratio, fractionDigits: 0)}',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip.project(project.status),
              PriorityChip(project.priority),
              if (project.dueDate != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_outlined,
                        size: 13, color: theme.colorScheme.outline),
                    const SizedBox(width: 3),
                    Text(VnFormat.date(project.dueDate!),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final s in ProjectStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(S.projectStatus(s)),
                      selected: project.status == s,
                      onSelected: (_) => ref
                          .read(projectRepositoryProvider)
                          .changeStatus(project.id, s),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionMenu extends ConsumerWidget {
  const _ActionMenu({required this.action});

  final ProjectAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: action.pinned
          ? Icon(Icons.push_pin, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.more_vert),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text(S.actionEdit)),
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(action.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 18),
              const SizedBox(width: 8),
              Text(action.pinned ? S.unpin : S.pin),
            ],
          ),
        ),
        const PopupMenuDivider(),
        for (final s in ActionStatus.values)
          PopupMenuItem(value: 'status:${s.wire}', child: Text(S.actionStatus(s))),
        const PopupMenuDivider(),
        for (final p in Priority.values)
          PopupMenuItem(
              value: 'priority:${p.wire}',
              child: Text('${S.actionPriority}: ${S.priority(p)}')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'delete', child: Text(S.delete)),
      ],
      onSelected: (value) async {
        final repo = ref.read(actionRepositoryProvider);
        final messenger = ScaffoldMessenger.of(context);
        if (value == 'edit') {
          await showActionForm(context, existing: action);
          return;
        }
        if (value == 'pin') {
          await repo.setPinned(action.id, !action.pinned);
          return;
        }
        if (value.startsWith('priority:')) {
          await repo.update(action.copyWith(
            priority: Priority.fromWire(value.substring('priority:'.length)),
          ));
          return;
        }
        if (value == 'delete') {
          await repo.delete(action.id);
          messenger.showSnackBar(
            SnackBar(
              content: const Text(S.actionDeleted),
              action: SnackBarAction(
                label: S.undo,
                onPressed: () => repo.restore(action),
              ),
            ),
          );
          return;
        }
        await repo.changeStatus(
          action.id,
          ActionStatus.fromWire(value.substring('status:'.length)),
        );
      },
    );
  }
}
