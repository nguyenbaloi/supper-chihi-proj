import 'package:drift/drift.dart';

import '../../core/result/result.dart';
import '../../domain/rules/slugify.dart';
import '../db/database.dart';
import '../seed/seeder.dart';
import 'backup_codec.dart';

/// Xuất và nhập toàn bộ dữ liệu — FR-31, FR-32, AD-11.
class BackupService {
  BackupService(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// FR-31: một file JSON chứa **toàn bộ** dữ liệu.
  Future<BackupDocument> buildDocument() async {
    final settings = await (_db.select(_db.appSettings)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();

    return BackupDocument(
      schemaVersion: backupFormatVersion,
      exportedAt: _now().toUtc(),
      settings: {
        'staleDays': settings?.staleDays ?? 21,
        'themeMode': settings?.themeMode ?? 'system',
        'seedApplied': settings?.seedApplied ?? false,
      },
      sections: {
        'topics': [
          for (final r in await _db.select(_db.areas).get())
            {
              'id': r.id,
              'name': r.name,
              'colorValue': r.colorValue,
              'iconKey': r.iconKey,
              'sortOrder': r.sortOrder,
              'isSystemFallback': r.isSystemFallback,
            }
        ],
        'projects': [
          for (final r in await _db.select(_db.projects).get())
            {
              'id': r.id,
              'topicId': r.areaId,
              'name': r.name,
              'description': r.description,
              'status': r.status,
              'priority': r.priority,
              'dueDate': isoOrNull(r.dueDate),
              'createdAt': isoOrNull(r.createdAt),
              'updatedAt': isoOrNull(r.updatedAt),
              'startedAt': isoOrNull(r.startedAt),
              'completedAt': isoOrNull(r.completedAt),
            }
        ],
        'actions': [
          for (final r in await _db.select(_db.actions).get())
            {
              'id': r.id,
              'projectId': r.projectId,
              'title': r.title,
              'note': r.note,
              'status': r.status,
              'priority': r.priority,
              'pinned': r.pinned,
              'pinnedAt': isoOrNull(r.pinnedAt),
              'dueDate': isoOrNull(r.dueDate),
              'sortOrder': r.sortOrder,
              'createdAt': isoOrNull(r.createdAt),
              'updatedAt': isoOrNull(r.updatedAt),
              'startedAt': isoOrNull(r.startedAt),
              'completedAt': isoOrNull(r.completedAt),
            }
        ],
        'notes': [
          for (final r in await _db.select(_db.notes).get())
            {
              'id': r.id,
              'projectId': r.projectId,
              'areaId': r.areaId,
              'title': r.title,
              'bodyMarkdown': r.bodyMarkdown,
              'createdAt': isoOrNull(r.createdAt),
              'updatedAt': isoOrNull(r.updatedAt),
            }
        ],
        'links': [
          for (final r in await _db.select(_db.links).get())
            {
              'id': r.id,
              'projectId': r.projectId,
              'areaId': r.areaId,
              'label': r.label,
              'url': r.url,
              'sortOrder': r.sortOrder,
            }
        ],
        'reviews': [
          for (final r in await _db.select(_db.reviews).get())
            {
              'id': r.id,
              'projectId': r.projectId,
              'date': isoOrNull(r.date),
              'title': r.title,
              'summaryMarkdown': r.summaryMarkdown,
              'nextReviewDate': isoOrNull(r.nextReviewDate),
              'createdAt': isoOrNull(r.createdAt),
            }
        ],
        'reviewItems': [
          for (final r in await _db.select(_db.reviewItems).get())
            {
              'id': r.id,
              'reviewId': r.reviewId,
              'label': r.label,
              'verdict': r.verdict,
              'note': r.note,
              'sortOrder': r.sortOrder,
              'sourceActionId': r.sourceActionId,
            }
        ],
        'statusEvents': [
          for (final r in await _db.select(_db.statusEvents).get())
            {
              'id': r.id,
              'entityType': r.entityType,
              'entityId': r.entityId,
              'fromStatus': r.fromStatus,
              'toStatus': r.toStatus,
              'at': isoOrNull(r.at),
            }
        ],
      },
    );
  }

  Future<String> exportJson() async => (await buildDocument()).encode();

  /// Tên file theo FR-31: `sao-luu-YYYY-MM-DD.json`.
  String fileNameFor(DateTime date) {
    final d = date.toLocal();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return 'sao-luu-${d.year}-$mm-$dd.json';
  }

  /// FR-32: **thay thế toàn bộ**, không trộn.
  ///
  /// Toàn bộ chạy trong một giao dịch. Kiểm tra xong hết mới ghi; lỗi giữa
  /// chừng cuộn ngược hoàn toàn — AD-11.
  Future<Result<int>> import(String raw) async {
    final decoded = decodeBackup(raw);
    if (decoded is Err<BackupDocument>) return Err(decoded.failure);
    final doc = (decoded as Ok<BackupDocument>).value;

    try {
      await _db.transaction(() async {
        // Xoá ngược thứ tự khoá ngoại.
        for (final name in backupSections.reversed) {
          await _deleteAll(name);
        }
        await _db.delete(_db.appSettings).go();

        for (final name in backupSections) {
          await _insertAll(name, doc.sections[name] ?? const []);
        }

        final s = doc.settings;
        await _db.into(_db.appSettings).insert(
              AppSettingsCompanion.insert(
                id: const Value(1),
                staleDays: Value(readInt(s, 'staleDays', fallback: 21)),
                themeMode: Value(readString(s, 'themeMode', fallback: 'system')),
                seedApplied: Value(readBool(s, 'seedApplied', fallback: true)),
              ),
            );
      });
    } on Object catch (e) {
      return Err(AppFailure(FailureCode.storage, detail: e.toString()));
    }

    // Bộ Lĩnh vực chuẩn phải luôn tồn tại, kể cả khi file sao lưu trống — FR-1.
    await Seeder(_db, clock: _now).ensureAreas();

    final total =
        doc.sections.values.fold<int>(0, (sum, rows) => sum + rows.length);
    return Ok(total);
  }

  /// Xoá sạch dữ liệu rồi dựng lại sáu Lĩnh vực mặc định — FR-34.
  Future<void> wipeAll() async {
    await _db.transaction(() async {
      for (final name in backupSections.reversed) {
        await _deleteAll(name);
      }
      await _db.delete(_db.appSettings).go();
    });
    await Seeder(_db, clock: _now).ensureAreas();
  }

  Future<void> _deleteAll(String section) async {
    switch (section) {
      case 'topics':
        await _db.delete(_db.areas).go();
      case 'projects':
        await _db.delete(_db.projects).go();
      case 'actions':
        await _db.delete(_db.actions).go();
      case 'notes':
        await _db.delete(_db.notes).go();
      case 'links':
        await _db.delete(_db.links).go();
      case 'reviews':
        await _db.delete(_db.reviews).go();
      case 'reviewItems':
        await _db.delete(_db.reviewItems).go();
      case 'statusEvents':
        await _db.delete(_db.statusEvents).go();
    }
  }

  Future<void> _insertAll(String section, List<Map<String, Object?>> rows) async {
    for (final r in rows) {
      switch (section) {
        case 'topics':
          await _db.into(_db.areas).insert(AreasCompanion.insert(
                id: Value(readInt(r, 'id')),
                name: readString(r, 'name'),
                colorValue: readInt(r, 'colorValue'),
                iconKey: readString(r, 'iconKey'),
                sortOrder: Value(readInt(r, 'sortOrder')),
                isSystemFallback: Value(readBool(r, 'isSystemFallback')),
              ));
        case 'projects':
          await _db.into(_db.projects).insert(ProjectsCompanion.insert(
                id: Value(readInt(r, 'id')),
                areaId: readInt(r, 'topicId'),
                name: readString(r, 'name'),
                description: Value(readString(r, 'description')),
                status: readString(r, 'status'),
                priority: readString(r, 'priority'),
                dueDate: Value(readDateOrNull(r, 'dueDate')),
                createdAt: readDate(r, 'createdAt'),
                updatedAt: readDate(r, 'updatedAt'),
                startedAt: Value(readDateOrNull(r, 'startedAt')),
                completedAt: Value(readDateOrNull(r, 'completedAt')),
                searchText: Value(_search([
                  readString(r, 'name'),
                  readString(r, 'description'),
                ])),
              ));
        case 'actions':
          await _db.into(_db.actions).insert(ActionsCompanion.insert(
                id: Value(readInt(r, 'id')),
                projectId: readInt(r, 'projectId'),
                title: readString(r, 'title'),
                note: Value(readString(r, 'note')),
                status: readString(r, 'status'),
                priority: Value(readString(r, 'priority', fallback: 'medium')),
                pinned: Value(readBool(r, 'pinned')),
                pinnedAt: Value(readDateOrNull(r, 'pinnedAt')),
                dueDate: Value(readDateOrNull(r, 'dueDate')),
                sortOrder: Value(readInt(r, 'sortOrder')),
                createdAt: readDate(r, 'createdAt'),
                updatedAt: readDate(r, 'updatedAt'),
                startedAt: Value(readDateOrNull(r, 'startedAt')),
                completedAt: Value(readDateOrNull(r, 'completedAt')),
                searchText: Value(
                    _search([readString(r, 'title'), readString(r, 'note')])),
              ));
        case 'notes':
          await _db.into(_db.notes).insert(NotesCompanion.insert(
                id: Value(readInt(r, 'id')),
                // File v1…v3 luôn có `projectId` và không có `areaId`; v4 có
                // thể thiếu một trong hai, nhưng không bao giờ có cả hai.
                projectId: Value(readIntOrNull(r, 'projectId')),
                areaId: Value(readIntOrNull(r, 'areaId')),
                title: readString(r, 'title'),
                bodyMarkdown: Value(readString(r, 'bodyMarkdown')),
                createdAt: readDate(r, 'createdAt'),
                updatedAt: readDate(r, 'updatedAt'),
                searchText: Value(_search(
                    [readString(r, 'title'), readString(r, 'bodyMarkdown')])),
              ));
        case 'links':
          await _db.into(_db.links).insert(LinksCompanion.insert(
                id: Value(readInt(r, 'id')),
                projectId: Value(readIntOrNull(r, 'projectId')),
                areaId: Value(readIntOrNull(r, 'areaId')),
                label: readString(r, 'label'),
                url: readString(r, 'url'),
                sortOrder: Value(readInt(r, 'sortOrder')),
                searchText: Value(
                    _search([readString(r, 'label'), readString(r, 'url')])),
              ));
        case 'reviews':
          await _db.into(_db.reviews).insert(ReviewsCompanion.insert(
                id: Value(readInt(r, 'id')),
                projectId: readInt(r, 'projectId'),
                date: readDate(r, 'date'),
                title: Value(readString(r, 'title')),
                summaryMarkdown: Value(readString(r, 'summaryMarkdown')),
                nextReviewDate: Value(readDateOrNull(r, 'nextReviewDate')),
                createdAt: readDate(r, 'createdAt'),
                searchText: Value(_search([
                  readString(r, 'title'),
                  readString(r, 'summaryMarkdown'),
                ])),
              ));
        case 'reviewItems':
          await _db.into(_db.reviewItems).insert(ReviewItemsCompanion.insert(
                id: Value(readInt(r, 'id')),
                reviewId: readInt(r, 'reviewId'),
                label: readString(r, 'label'),
                verdict: readString(r, 'verdict'),
                note: Value(readString(r, 'note')),
                sortOrder: Value(readInt(r, 'sortOrder')),
                sourceActionId: Value(readIntOrNull(r, 'sourceActionId')),
                searchText: Value(
                    _search([readString(r, 'label'), readString(r, 'note')])),
              ));



        case 'statusEvents':
          await _db.into(_db.statusEvents).insert(StatusEventsCompanion.insert(
                id: Value(readInt(r, 'id')),
                entityType: readString(r, 'entityType'),
                entityId: readInt(r, 'entityId'),
                fromStatus: readString(r, 'fromStatus'),
                toStatus: readString(r, 'toStatus'),
                at: readDate(r, 'at'),
              ));
      }
    }
  }

  /// Chỉ mục tìm kiếm được **sinh lại** khi nhập, không lấy từ file: nó là
  /// dữ liệu dẫn xuất, và thuật toán bỏ dấu có thể đã đổi (AD-12).
  static String _search(List<String> parts) => buildSearchText(parts);
}
