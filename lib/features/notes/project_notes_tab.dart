import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/strings.dart';
import '../../domain/models/note.dart';
import '../../presentation/providers/providers.dart';
import 'markdown_view.dart';

/// FR-27, FR-28: Ghi chú dài dạng markdown và Liên kết ngoài, cùng gắn vào
/// một Dự án.
class ProjectNotesTab extends ConsumerWidget {
  const ProjectNotesTab({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(projectNotesProvider(projectId)).value ?? const [];
    final links = ref.watch(projectLinksProvider(projectId)).value ?? const [];
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        _SectionHeader(
          title: S.projectLinks,
          onAdd: () => _editLink(context, ref),
        ),
        if (links.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(S.linkEmpty, style: theme.textTheme.bodySmall),
          ),
        for (final l in links)
          ListTile(
            leading: const Icon(Icons.link),
            title: Text(l.label),
            subtitle: Text(l.url, maxLines: 1, overflow: TextOverflow.ellipsis),
            // AD-6: mở ra trình duyệt của hệ điều hành; ứng dụng không tải
            // nội dung nào về.
            onTap: () => launchUrl(Uri.parse(l.url),
                mode: LaunchMode.externalApplication),
            trailing: PopupMenuButton<String>(
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'copy', child: Text(S.linkCopy)),
                PopupMenuItem(value: 'edit', child: Text(S.edit)),
                PopupMenuItem(value: 'delete', child: Text(S.delete)),
              ],
              onSelected: (v) async {
                final messenger = ScaffoldMessenger.of(context);
                switch (v) {
                  case 'copy':
                    await Clipboard.setData(ClipboardData(text: l.url));
                    messenger.showSnackBar(
                        const SnackBar(content: Text(S.linkCopied)));
                  case 'edit':
                    if (context.mounted) await _editLink(context, ref, existing: l);
                  case 'delete':
                    await ref.read(linkRepositoryProvider).delete(l.id);
                }
              },
            ),
          ),
        const Divider(height: 24),
        _SectionHeader(
          title: S.projectNotes,
          onAdd: () => _editNote(context, ref),
        ),
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(S.noteEmpty, style: theme.textTheme.bodySmall),
          ),
        for (final n in notes)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ExpansionTile(
              title: Text(n.title),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownView(n.bodyMarkdown),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _editNote(context, ref, existing: n),
                      child: const Text(S.edit),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(noteRepositoryProvider).delete(n.id),
                      child: const Text(S.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref, {Note? existing}) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final body = TextEditingController(text: existing?.bodyMarkdown ?? '');
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(existing == null ? S.noteNew : S.edit,
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: S.noteTitle, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: body,
                minLines: 6,
                maxLines: 14,
                decoration: const InputDecoration(
                    labelText: S.noteBody, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(S.save),
              ),
            ],
          ),
        ),
      ),
    );
    if (saved != true || title.text.trim().isEmpty) return;
    final repo = ref.read(noteRepositoryProvider);
    if (existing == null) {
      await repo.create(
        projectId: projectId,
        title: title.text.trim(),
        bodyMarkdown: body.text,
      );
    } else {
      await repo.update(
        existing.copyWith(title: title.text.trim(), bodyMarkdown: body.text),
      );
    }
  }

  Future<void> _editLink(BuildContext context, WidgetRef ref, {Link? existing}) async {
    final label = TextEditingController(text: existing?.label ?? '');
    final url = TextEditingController(text: existing?.url ?? '');
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? S.linkNew : S.edit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: label,
                autofocus: true,
                decoration: const InputDecoration(labelText: S.linkLabel),
              ),
              TextField(
                controller: url,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: S.linkUrl, errorText: error),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(S.cancel)),
            FilledButton(
              onPressed: () {
                if (!isValidUrl(url.text.trim())) {
                  setState(() => error = S.linkInvalid);
                  return;
                }
                Navigator.of(ctx).pop(true);
              },
              child: const Text(S.save),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final repo = ref.read(linkRepositoryProvider);
    final text = url.text.trim();
    final name = label.text.trim().isEmpty ? text : label.text.trim();
    if (existing == null) {
      await repo.create(projectId: projectId, label: name, url: text);
    } else {
      await repo.update(existing.copyWith(label: name, url: text));
    }
  }
}

/// FR-28: URL sai định dạng bị từ chối ngay lúc nhập.
bool isValidUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      uri.hasScheme &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
          ],
        ),
      );
}
