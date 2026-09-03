import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/strings.dart';
import '../../domain/models/area.dart';
import '../../domain/models/note.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/layout.dart';
import 'markdown_view.dart';

/// Kho Tư liệu — FR-50.
///
/// *Tư liệu* là **nhãn nhóm ở giao diện** gộp Ghi chú và Liên kết, không phải
/// một thực thể: không có lớp, bảng hay provider nào tên `Resource` — AD-20.
///
/// Màn hình này tồn tại vì từ v5 Ghi chú và Liên kết sống lâu hơn Dự án sinh
/// ra nó. Xoá một Dự án cũ là chúng chuyển sang Lĩnh vực, và nếu không có chỗ
/// nào liệt kê chúng thì chúng biến mất khỏi tầm mắt — vá được lỗi mất dữ
/// liệu nhưng vẫn mất trên thực tế.
class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

/// Bộ lọc: `null` là tất cả, `-1` là kho chung, còn lại là id Lĩnh vực.
const int _unattachedFilter = -1;

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  int? _filter;

  @override
  Widget build(BuildContext context) {
    final areas = ref.watch(areasProvider).value ?? const <Area>[];
    final allNotes = ref.watch(allNotesProvider).value ?? const <Note>[];
    final allLinks = ref.watch(allLinksProvider).value ?? const <Link>[];

    bool keepNote(Note n) => switch (_filter) {
          null => true,
          _unattachedFilter => n.isUnattached,
          final id => n.areaId == id,
        };
    bool keepLink(Link l) => switch (_filter) {
          null => true,
          _unattachedFilter => l.isUnattached,
          final id => l.areaId == id,
        };

    final notes = allNotes.where(keepNote).toList();
    final links = allLinks.where(keepLink).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.resources),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: S.resourcesAll,
                  selected: _filter == null,
                  onSelected: () => setState(() => _filter = null),
                ),
                for (final a in areas)
                  _FilterChip(
                    label: a.name,
                    selected: _filter == a.id,
                    onSelected: () => setState(() => _filter = a.id),
                  ),
                _FilterChip(
                  label: S.resourcesUnattached,
                  selected: _filter == _unattachedFilter,
                  onSelected: () =>
                      setState(() => _filter = _unattachedFilter),
                ),
              ],
            ),
          ),
        ),
      ),
      body: notes.isEmpty && links.isEmpty
          ? const EmptyState(
              icon: Icons.folder_open_outlined, title: S.resourcesEmpty)
          : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                if (links.isNotEmpty) ...[
                  SectionHeader(
                    title: S.projectLinks,
                    subtitle: S.resourcesCount(notes.length, links.length),
                    padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                        AppSpacing.lg, AppSpacing.gutter, AppSpacing.sm),
                  ),
                  GroupedCard(
                    children: [
                      for (final l in links)
                        ListTile(
                          leading: const Icon(Icons.link),
                          title: Text(l.label),
                          subtitle: _Origin(
                            projectId: l.projectId,
                            areaId: l.areaId,
                            areas: areas,
                          ),
                          // AD-6: mở ra trình duyệt của hệ điều hành.
                          onTap: () => launchUrl(Uri.parse(l.url),
                              mode: LaunchMode.externalApplication),
                        ),
                    ],
                  ),
                ],
                if (notes.isNotEmpty) ...[
                  SectionHeader(
                    title: S.projectNotes,
                    subtitle: links.isEmpty
                        ? S.resourcesCount(notes.length, links.length)
                        : null,
                    padding: EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        links.isEmpty ? AppSpacing.lg : AppSpacing.sm,
                        AppSpacing.gutter,
                        AppSpacing.sm),
                  ),
                  GroupedCard(
                    children: [
                      for (final n in notes)
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(n.title),
                          subtitle: _Origin(
                            projectId: n.projectId,
                            areaId: n.areaId,
                            areas: areas,
                          ),
                          onTap: () => _preview(context, n),
                        ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> _preview(BuildContext context, Note note) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          builder: (_, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(16),
            children: [
              Text(note.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              MarkdownView(note.bodyMarkdown),
            ],
          ),
        ),
      );
}

/// Nói rõ tư liệu này đang thuộc về đâu.
///
/// Quan trọng với Ghi chú vừa rời một Dự án bị xoá: không có dòng này thì nó
/// nằm lẫn trong danh sách mà không ai biết nó từ đâu ra.
class _Origin extends ConsumerWidget {
  const _Origin({
    required this.projectId,
    required this.areaId,
    required this.areas,
  });

  final int? projectId;
  final int? areaId;
  final List<Area> areas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (projectId != null) {
      final name = ref.watch(projectProvider(projectId!)).value?.name;
      return Text('${S.resourcesFromProject}: ${name ?? ''}',
          maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    if (areaId != null) {
      final name =
          areas.where((a) => a.id == areaId).map((a) => a.name).firstOrNull;
      return Text('${S.resourcesFromArea}: ${name ?? ''}',
          maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return const Text(S.resourcesLoose);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onSelected(),
        ),
      );
}
