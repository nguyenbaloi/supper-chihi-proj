import 'package:drift/drift.dart';

import '../../domain/repositories/repositories.dart';
import '../../domain/rules/slugify.dart';
import '../db/database.dart';

class DriftSearchRepository implements SearchRepository {
  DriftSearchRepository(this._db);

  final AppDatabase _db;

  /// Một câu lệnh duy nhất gom cả sáu loại.
  ///
  /// Đối chiếu trên cột `search_text` đã bỏ dấu (AD-12), nên gõ `tai chinh`
  /// tìm ra `Kế hoạch tài chính`.
  static const String _sql = '''
SELECT 'project' AS kind, p.id AS id, p.name AS title, p.description AS snippet,
       p.id AS project_id, p.name AS project_name
  FROM projects p WHERE p.search_text LIKE ?1
UNION ALL
SELECT 'action', a.id, a.title, a.note, p.id, p.name
  FROM actions a JOIN projects p ON p.id = a.project_id
 WHERE a.search_text LIKE ?1
UNION ALL
SELECT 'note', n.id, n.title, n.body_markdown, p.id, p.name
  FROM notes n JOIN projects p ON p.id = n.project_id
 WHERE n.search_text LIKE ?1
UNION ALL
SELECT 'link', l.id, l.label, l.url, p.id, p.name
  FROM links l JOIN projects p ON p.id = l.project_id
 WHERE l.search_text LIKE ?1
UNION ALL
SELECT 'review', r.id, r.title, r.summary_markdown, p.id, p.name
  FROM reviews r JOIN projects p ON p.id = r.project_id
 WHERE r.search_text LIKE ?1
UNION ALL
SELECT 'review', i.review_id, i.label, i.note, p.id, p.name
  FROM review_items i
  JOIN reviews r ON r.id = i.review_id
  JOIN projects p ON p.id = r.project_id
 WHERE i.search_text LIKE ?1
LIMIT 200
''';

  @override
  Future<List<SearchHit>> search(String query) async {
    final needle = slugify(query);
    if (needle.isEmpty) return const [];

    final rows = await _db.customSelect(
      _sql,
      variables: [Variable<String>('%$needle%')],
      readsFrom: {
        _db.projects,
        _db.actions,
        _db.notes,
        _db.links,
        _db.reviews,
        _db.reviewItems,
      },
    ).get();

    return rows.map((r) {
      final snippet = r.read<String>('snippet');
      return SearchHit(
        kind: _kind(r.read<String>('kind')),
        id: r.read<int>('id'),
        title: r.read<String>('title'),
        snippet: snippet.length > 140 ? '${snippet.substring(0, 140)}…' : snippet,
        projectId: r.readNullable<int>('project_id'),
        projectName: r.readNullable<String>('project_name'),
      );
    }).toList();
  }

  static SearchKind _kind(String wire) => switch (wire) {
        'action' => SearchKind.action,
        'note' => SearchKind.note,
        'link' => SearchKind.link,
        'review' => SearchKind.review,
        _ => SearchKind.project,
      };
}
