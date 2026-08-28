import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/project_action.dart';
import '../../domain/rules/completion.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/chips.dart';
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
              Tab(text: S.tabToday),
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

  /// FR-7: hộp xác nhận nêu rõ số bản ghi sẽ mất theo và gợi ý trạng thái `Bỏ`.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(projectActionsProvider(projectId)).value ?? const [];
    final notes = ref.read(projectNotesProvider(projectId)).value ?? const [];
    final links = ref.read(projectLinksProvider(projectId)).value ?? const [];

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.projectDeleteTitle),
        content: Text(
          S.projectDeleteConfirm(actions.length, notes.length, links.length),
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
    await ref
        .read(actionRepositoryProvider)
        .create(projectId: widget.projectId, title: title);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectId)).value;
    final actions =
        ref.watch(projectActionsProvider(widget.projectId)).value ?? const [];
    final theme = Theme.of(context);

    final open = actions.where((a) => a.status.isOpen).toList();
    final closed = actions.where((a) => !a.status.isOpen).toList();
    final tally = tallyCompletion(actions.map((a) => a.status));

    return Column(
      children: [
        if (project != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.description.isNotEmpty) ...[
                  Text(project.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                ],
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip.project(project.status),
                    PriorityChip(project.priority),
                    if (project.dueDate != null)
                      Text('${S.projectDueDate}: ${VnFormat.date(project.dueDate!)}',
                          style: theme.textTheme.bodySmall),
                    Text(
                      tally.isEmpty
                          ? VnFormat.emptyValue
                          : '${tally.doneCount}/${tally.countedTotal} · ${VnFormat.percent(tally.ratio, fractionDigits: 0)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                                .changeStatus(widget.projectId, s),
                          ),
                        ),
                    ],
                  ),
                ),
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
                  controller: _controller,
                  focusNode: _focus,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: S.actionNew,
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              IconButton(
                tooltip: S.add,
                icon: const Icon(Icons.add_circle),
                onPressed: _add,
              ),
            ],
          ),
        ),
        Expanded(
          child: actions.isEmpty
              ? Center(child: Text(S.actionEmpty, style: theme.textTheme.bodyMedium))
              : ReorderableListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 40),
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
                            ListTile(
                              title: Text('${S.actionClosedGroup} (${closed.length})'),
                              trailing: Icon(_showClosed
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                              onTap: () => setState(() => _showClosed = !_showClosed),
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
                        trailing: _ActionMenu(action: a),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ActionMenu extends ConsumerWidget {
  const _ActionMenu({required this.action});

  final ProjectAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      itemBuilder: (_) => [
        for (final s in ActionStatus.values)
          PopupMenuItem(value: 'status:${s.wire}', child: Text(S.actionStatus(s))),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'delete', child: Text(S.delete)),
      ],
      onSelected: (value) async {
        final repo = ref.read(actionRepositoryProvider);
        final messenger = ScaffoldMessenger.of(context);
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
