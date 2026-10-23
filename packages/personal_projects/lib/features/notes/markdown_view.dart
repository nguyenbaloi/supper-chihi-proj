import 'package:flutter/material.dart';

/// Dựng hình tập con markdown đủ dùng cho nội dung Ghi chú thật — FR-27.
///
/// Tự viết thay vì thêm thư viện: mọi gói markdown đều phải qua vòng kiểm tra
/// build hooks của AD-13, và tập cú pháp cần dùng chỉ gồm tiêu đề, danh sách,
/// chữ đậm và chữ nghiêng.
class MarkdownView extends StatelessWidget {
  const MarkdownView(this.source, {super.key});

  final String source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocks = <Widget>[];

    for (final rawLine in source.split('\n')) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        blocks.add(const SizedBox(height: 8));
        continue;
      }
      if (line.startsWith('### ')) {
        blocks.add(_text(context, line.substring(4), theme.textTheme.titleSmall));
      } else if (line.startsWith('## ')) {
        blocks.add(_text(context, line.substring(3), theme.textTheme.titleMedium));
      } else if (line.startsWith('# ')) {
        blocks.add(_text(context, line.substring(2), theme.textTheme.titleLarge));
      } else if (line.trimLeft().startsWith('- ')) {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: theme.textTheme.bodyMedium),
                Expanded(
                  child: _text(context, line.trimLeft().substring(2),
                      theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        );
      } else {
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _text(context, line, theme.textTheme.bodyMedium),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }

  Widget _text(BuildContext context, String raw, TextStyle? base) =>
      RichText(text: TextSpan(style: base, children: _inlineSpans(raw, base)));

  /// Xử lý `**đậm**` và `*nghiêng*` trong một dòng.
  List<TextSpan> _inlineSpans(String raw, TextStyle? base) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    var index = 0;
    for (final m in pattern.allMatches(raw)) {
      if (m.start > index) {
        spans.add(TextSpan(text: raw.substring(index, m.start)));
      }
      if (m.group(1) != null) {
        spans.add(TextSpan(
          text: m.group(1),
          style: base?.copyWith(fontWeight: FontWeight.bold),
        ));
      } else {
        spans.add(TextSpan(
          text: m.group(2),
          style: base?.copyWith(fontStyle: FontStyle.italic),
        ));
      }
      index = m.end;
    }
    if (index < raw.length) spans.add(TextSpan(text: raw.substring(index)));
    return spans;
  }
}
