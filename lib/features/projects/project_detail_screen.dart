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
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _showClosed = false;

  /// Hạn và độ ưu tiên của lần thêm kế tiếp — FR-14.
  ///
  /// Hai giá trị này **giữ nguyên** sau mỗi lần thêm, để gõ một loạt việc
  /// cùng hạn cùng mức ưu tiên chỉ phải chọn một lần. Chúng luôn hiện ngay
  /// dưới ô nhập nên không có gì bị đặt hộ sau lưng người dùng.
  Priority _newPriority = Priority.medium;
  DateTime? _newDueDate;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// FR-14: sau khi thêm, ô nhập giữ tiêu điểm để gõ tiếp Hành động kế.
  Future<void> _add() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    _controller.clear();
    await ref.read(actionRepositoryProvider).create(
          projectId: widget.projectId,
          title: title,
          priority: _newPriority,
          dueDate: _newDueDate,
        );
    _focus.requestFocus();
  }

  Future<void> _pickNewDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _newDueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) setState(() => _newDueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectId)).value;
    final actions =
        ref.watch(projectActionsProvider(widget.projectId)).value ?? const [];
    final theme = Theme.of(context);

    final open = actions.where((a) => a.status.isOpen).toList()
      ..sort((a, b) {
        final p = a.priority.sortRank.compareTo(b.priority.sortRank);
        if (p != 0) return p;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    final closed = actions.where((a) => !a.status.isOpen).toList()
      ..sort((a, b) {
        final p = a.priority.sortRank.compareTo(b.priority.sortRank);
        if (p != 0) return p;
        return a.sortOrder.compareTo(b.sortOrder);
      });

    return Column(
      children: [
        if (project != null) _ProjectHeader(project: project),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: S.actionNew,
                        prefixIcon: Icon(Icons.add, size: 20),
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    tooltip: S.add,
                    icon: const Icon(Icons.arrow_upward, size: 20),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(46, 46),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: _add,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ActionPrioritySelector(
                    value: _newPriority,
                    onChanged: (p) => setState(() => _newPriority = p),
                  ),
                  InputChip(
                    avatar: const Icon(Icons.event_outlined, size: 18),
                    label: Text(_newDueDate == null
                        ? S.actionDueDate
                        : VnFormat.date(_newDueDate!)),
                    onPressed: _pickNewDueDate,
                    onDeleted: _newDueDate == null
                        ? null
                        : () => setState(() => _newDueDate = null),
                  ),
                  // Lối vào ô nhập đầy đủ — nơi duy nhất thêm được Ghi chú
                  // ngay lúc tạo việc.
                  ActionChip(
                    avatar: const Icon(Icons.notes_outlined, size: 16),
                    label: const Text(S.actionNote),
                    onPressed: () => showActionEditSheet(
                      context,
                      projectId: widget.projectId,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: actions.isEmpty
              ? const EmptyState(
                  icon: Icons.checklist_rtl_outlined,
                  title: S.actionEmpty,
                  message: S.actionEmptyHint,
                )
              : Container(
                  margin: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0,
                      AppSpacing.gutter, AppSpacing.md),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ReorderableListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  buildDefaultDragHandles: true,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final ids = open.map((a) => a.id).toList();
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    await ref
                        .read(actionRepositoryProvider)
                        .reorder(widget.projectId, [...ids, ...closed.map((a) => a.id)]);
                  },
                  footer: closed.isEmpty
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(height: 1),
                            InkWell(
                              onTap: () =>
                                  setState(() => _showClosed = !_showClosed),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.gutter,
                                    vertical: AppSpacing.md),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${S.actionClosedGroup} · ${closed.length}',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                                color:
                                                    theme.colorScheme.outline),
                                      ),
                                    ),
                                    Icon(
                                      _showClosed
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 20,
                                      color: theme.colorScheme.outline,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showClosed)
                              for (final a in closed)
                                ActionTile(
                                  action: a,
                                  trailing: _ActionMenu(action: a),
                                ),
                          ],
                        ),
                  children: [
                    for (final a in open)
                      ActionTile(
                        key: ValueKey(a.id),
                        action: a,
                        showPriority: true,
                        trailing: _ActionMenu(action: a),
                      ),
                  ],
                ),
              ),
        ),
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
          await showActionEditSheet(context, existing: action);
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
