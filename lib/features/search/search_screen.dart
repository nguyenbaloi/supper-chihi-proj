import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../domain/repositories/repositories.dart';
import '../../presentation/providers/providers.dart';
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
          decoration: const InputDecoration(
            hintText: S.search,
            border: InputBorder.none,
          ),
          // Kết quả cập nhật khi đang gõ, không cần nút tìm.
          onChanged: _run,
        ),
      ),
      body: _controller.text.trim().isEmpty
          ? const SizedBox.shrink()
          : _hits.isEmpty
              ? Center(
                  child: Text(S.searchNoResult, style: theme.textTheme.bodyLarge))
              : ListView(
                  children: [
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          S.searchKind(entry.key),
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
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
                          onTap: hit.projectId == null
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ProjectDetailScreen(
                                          projectId: hit.projectId!),
                                    ),
                                  ),
                        ),
                    ],
                  ],
                ),
    );
  }
}
