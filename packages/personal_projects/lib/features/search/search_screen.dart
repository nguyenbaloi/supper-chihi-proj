import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../domain/repositories/repositories.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/layout.dart';
import '../actions/action_detail_screen.dart';
import '../projects/project_detail_screen.dart';

/// FR-30: một ô duy nhất quét mọi loại nội dung.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<SearchHit> _hits = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(String value) async {
    final hits = await ref.read(searchRepositoryProvider).search(value);
    if (mounted) setState(() => _hits = hits);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = <SearchKind, List<SearchHit>>{};
    for (final h in _hits) {
      grouped.putIfAbsent(h.kind, () => []).add(h);
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: theme.textTheme.titleMedium,
          decoration: const InputDecoration(
            hintText: S.search,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          // Kết quả cập nhật khi đang gõ, không cần nút tìm.
          onChanged: _run,
        ),
      ),
      body: _controller.text.trim().isEmpty
          ? const SizedBox.shrink()
          : _hits.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_outlined, title: S.searchNoResult)
              : ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  children: [
                    for (final entry in grouped.entries) ...[
                      SectionHeader(title: S.searchKind(entry.key)),
                      GroupedCard(
                        children: [
                          for (final hit in entry.value)
                            ListTile(
                              title: Text(hit.title.isEmpty ? S.emptyValue : hit.title),
                              subtitle: Text(
                                [
                                  if (hit.projectName != null) hit.projectName!,
                                  if (hit.snippet.isNotEmpty) hit.snippet,
                                ].join(' · '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: switch (hit.kind) {
                                // Kết quả là Hành động thì mở thẳng Hành động đó,
                                // không dừng ở Dự án chứa nó.
                                SearchKind.action => () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            ActionDetailScreen(actionId: hit.id),
                                      ),
                                    ),
                                _ when hit.projectId != null => () =>
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ProjectDetailScreen(
                                            projectId: hit.projectId!),
                                      ),
                                    ),
                                _ => null,
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
    );
  }
}
