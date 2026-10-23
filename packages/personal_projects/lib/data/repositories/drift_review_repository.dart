import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/review.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/day.dart';
import '../../domain/rules/slugify.dart';
import '../db/database.dart';

class DriftReviewRepository implements ReviewRepository {
  DriftReviewRepository(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Một câu lệnh duy nhất: Đợt kèm số Mục và số Mục đạt — không N+1.
  static const String _summarySql = '''
SELECT
  r.*,
  (SELECT COUNT(*) FROM review_items i WHERE i.review_id = r.id)                     AS item_count,
  (SELECT COUNT(*) FROM review_items i WHERE i.review_id = r.id AND i.verdict = 'met') AS met_count
FROM reviews r
WHERE r.%s = ?
ORDER BY r.date DESC, r.id DESC
''';

  Stream<List<ReviewSummary>> _watchSummaries(String column, int id) => _db
      .customSelect(
        _summarySql.replaceFirst('%s', column),
        variables: [Variable<int>(id)],
        readsFrom: {_db.reviews, _db.reviewItems},
      )
      .watch()
      .map((rows) => rows.map(_toSummary).toList());

  @override
  Stream<List<ReviewSummary>> watchByProject(int projectId) =>
      _watchSummaries('project_id', projectId);

  @override
  Stream<List<ReviewSummary>> watchByArea(int areaId) =>
      _watchSummaries('area_id', areaId);

  ReviewSummary _toSummary(QueryRow row) => ReviewSummary(
        review: Review(
          id: row.read<int>('id'),
          projectId: row.readNullable<int>('project_id'),
          areaId: row.readNullable<int>('area_id'),
          date: row.read<DateTime>('date'),
          title: row.read<String>('title'),
          summaryMarkdown: row.read<String>('summary_markdown'),
          nextReviewDate: row.readNullable<DateTime>('next_review_date'),
          createdAt: row.read<DateTime>('created_at'),
        ),
        metCount: row.read<int>('met_count'),
        itemCount: row.read<int>('item_count'),
      );

  @override
  Stream<List<Review>> watchAllReviews() => _db.select(_db.reviews).watch().map(
        (rows) => rows.map(_toReview).toList(),
      );

  Review _toReview(ReviewRow r) => Review(
        id: r.id,
        projectId: r.projectId,
        areaId: r.areaId,
        date: r.date,
        title: r.title,
        summaryMarkdown: r.summaryMarkdown,
        nextReviewDate: r.nextReviewDate,
        createdAt: r.createdAt,
      );

  ReviewItem _toItem(ReviewItemRow r) => ReviewItem(
        id: r.id,
        reviewId: r.reviewId,
        label: r.label,
        verdict: ReviewVerdict.fromWire(r.verdict),
        note: r.note,
        sortOrder: r.sortOrder,
        sourceActionId: r.sourceActionId,
      );

  @override
  Stream<List<ReviewItem>> watchItems(int reviewId) => (_db.select(_db.reviewItems)
        ..where((i) => i.reviewId.equals(reviewId))
        ..orderBy([
          (i) => OrderingTerm(expression: i.sortOrder),
          (i) => OrderingTerm(expression: i.id),
        ]))
      .watch()
      .map((rows) => rows.map(_toItem).toList());

  @override
  Future<List<ReviewItem>> getItems(int reviewId) async {
    final rows = await (_db.select(_db.reviewItems)
          ..where((i) => i.reviewId.equals(reviewId))
          ..orderBy([(i) => OrderingTerm(expression: i.sortOrder)]))
        .get();
    return rows.map(_toItem).toList();
  }

  @override
  Future<Review> create({
    int? projectId,
    int? areaId,
    required DateTime date,
    String title = '',
    String summaryMarkdown = '',
    DateTime? nextReviewDate,
  }) async {
    assert((projectId == null) != (areaId == null),
        'AD-19: Đợt thuộc đúng một chủ thể');
    final now = _now().toUtc();
    final day = startOfDay(date);
    final next = nextReviewDate == null ? null : startOfDay(nextReviewDate);
    final id = await _db.into(_db.reviews).insert(
          ReviewsCompanion.insert(
            projectId: Value(projectId),
            areaId: Value(areaId),
            date: day,
            title: Value(title),
            summaryMarkdown: Value(summaryMarkdown),
            nextReviewDate: Value(next),
            createdAt: now,
            searchText: Value(buildSearchText([title, summaryMarkdown])),
          ),
        );
    return Review(
      id: id,
      projectId: projectId,
      areaId: areaId,
      date: day,
      title: title,
      summaryMarkdown: summaryMarkdown,
      nextReviewDate: next,
      createdAt: now,
    );
  }

  @override
  Future<void> update(Review review) async {
    await (_db.update(_db.reviews)..where((r) => r.id.equals(review.id))).write(
      ReviewsCompanion(
        date: Value(startOfDay(review.date)),
        title: Value(review.title),
        summaryMarkdown: Value(review.summaryMarkdown),
        nextReviewDate: Value(review.nextReviewDate == null
            ? null
            : startOfDay(review.nextReviewDate!)),
        searchText:
            Value(buildSearchText([review.title, review.summaryMarkdown])),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.reviews)..where((r) => r.id.equals(id))).go();
  }

  @override
  Future<ReviewItem> addItem({
    required int reviewId,
    required String label,
    ReviewVerdict verdict = ReviewVerdict.notMet,
    String note = '',
    int? sourceActionId,
  }) async {
    final row = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), -1) AS m FROM review_items WHERE review_id = ?',
      variables: [Variable<int>(reviewId)],
      readsFrom: {_db.reviewItems},
    ).getSingle();
    final next = row.read<int>('m') + 1;
    final id = await _db.into(_db.reviewItems).insert(
          ReviewItemsCompanion.insert(
            reviewId: reviewId,
            label: label,
            verdict: verdict.wire,
            note: Value(note),
            sortOrder: Value(next),
            sourceActionId: Value(sourceActionId),
            searchText: Value(buildSearchText([label, note])),
          ),
        );
    return ReviewItem(
      id: id,
      reviewId: reviewId,
      label: label,
      verdict: verdict,
      note: note,
      sortOrder: next,
      sourceActionId: sourceActionId,
    );
  }

  @override
  Future<void> updateItem(ReviewItem item) async {
    await (_db.update(_db.reviewItems)..where((i) => i.id.equals(item.id))).write(
      ReviewItemsCompanion(
        label: Value(item.label),
        verdict: Value(item.verdict.wire),
        note: Value(item.note),
        sortOrder: Value(item.sortOrder),
        searchText: Value(buildSearchText([item.label, item.note])),
      ),
    );
  }

  @override
  Future<void> deleteItem(int id) async {
    await (_db.delete(_db.reviewItems)..where((i) => i.id.equals(id))).go();
  }

  @override
  Future<void> reorderItems(int reviewId, List<int> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.reviewItems)
              ..where((r) => r.id.equals(orderedIds[i]) & r.reviewId.equals(reviewId)))
            .write(ReviewItemsCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// FR-37 + AD-15: chép **bản chụp văn bản**, không tạo liên kết tới Mục cũ.
  /// Mọi Mục chép sang khởi điểm ở `Chưa đạt`.
  @override
  Future<void> carryForward({
    required int targetReviewId,
    required List<ReviewItem> items,
  }) async {
    await _db.transaction(() async {
      for (var i = 0; i < items.length; i++) {
        await _db.into(_db.reviewItems).insert(
              ReviewItemsCompanion.insert(
                reviewId: targetReviewId,
                label: items[i].label,
                verdict: ReviewVerdict.notMet.wire,
                sortOrder: Value(i),
                sourceActionId: Value(items[i].sourceActionId),
                searchText: Value(buildSearchText([items[i].label])),
              ),
            );
      }
    });
  }
}
