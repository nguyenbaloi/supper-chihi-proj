/// Mã hoá và giải mã file sao lưu — FR-31, FR-32, AD-11.
///
/// Định dạng là một **hợp đồng có phiên bản**, không phải kết quả phụ của cấu
/// trúc bảng. Cố ý không dùng `toJson()` do drift sinh: nó đổi theo phiên bản
/// thư viện, mà file sao lưu phải đọc được sau nhiều năm.
library;

import 'dart:convert';

import '../../core/result/result.dart';

/// Phiên bản định dạng, đi theo `schemaVersion` của cơ sở dữ liệu.
///
/// - **v3** bỏ ba mục `goals`, `goalUpdates`, `projectGoals`. File v2 vẫn nhập
///   được: các mục lạ bị bỏ qua vì bộ nhập chỉ đọc đúng những tên có trong
///   [backupSections].
/// - **v4** cho `notes.projectId` và `links.projectId` nhận `null`, và thêm
///   `notes.areaId` / `links.areaId` — Story 8.4, FR-50. Phải tăng phiên bản
///   ngay ở story này chứ không đợi Story 8.6: một Ghi chú đã chuyển sang
///   Lĩnh vực mà xuất ra file v3 thì **mất chỗ gắn**, đúng kiểu mất im lặng mà
///   FR-50 sinh ra để chặn.
///
/// - **v5** thêm `topics.standard`, `topics.reviewCadenceDays`,
///   `topics.createdAt` và `reviews.areaId` — Story 8.2 và 8.3, FR-47…FR-49.
///   Cùng lý do với v4: schema thêm dữ liệu người dùng thì định dạng phải theo
///   ngay, nếu không xuất ra là mất.
///
/// - **v6** thêm `actions.pinnedOrder` — thứ tự người dùng tự đẩy trong danh
///   sách Làm ngay. Cùng lý do với v4 và v5: đây là sắp xếp do người dùng
///   quyết, xuất ra mà bỏ quên thì khôi phục xong danh sách tự xáo lại.
///
/// File v1…v5 vẫn nhập được. Trường thiếu nhận mặc định **đúng nghĩa**, không
/// phải giá trị bừa: `areaId` là `null`, `standard` là rỗng,
/// `reviewCadenceDays` là `null` (tức không nhắc gì), `createdAt` lấy thời
/// điểm nhập, `pinnedOrder` là `0` (chưa đẩy việc nào lên đầu).
const int backupFormatVersion = 6;

/// Thứ tự chèn tôn trọng khoá ngoại. Xoá thì đi ngược danh sách này.
///
/// **`topics` và `topicId` là cố ý, không phải sót khi đổi tên.** Bảng và lớp
/// Dart đã đổi thành `Area`/`areaId` ở Story 8.1, nhưng khoá JSON là **hợp
/// đồng** — file sao lưu phiên bản 3 nào cũng mang tên cũ và phải đọc lại
/// được sau nhiều năm. Phiên bản 4 vẫn giữ nguyên tên cũ; khoá đổi sang
/// `areas`/`areaId` ở Story 8.6, kèm nhánh đọc cho phiên bản cũ.
const List<String> backupSections = [
  'topics',
  'projects',
  'actions',
  'notes',
  'links',
  'reviews',
  'reviewItems',
  'statusEvents',
];

final class BackupDocument {
  const BackupDocument({
    required this.schemaVersion,
    required this.exportedAt,
    required this.settings,
    required this.sections,
  });

  final int schemaVersion;
  final DateTime exportedAt;
  final Map<String, Object?> settings;

  /// Khoá là tên trong [backupSections].
  final Map<String, List<Map<String, Object?>>> sections;

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'settings': settings,
        for (final name in backupSections) name: sections[name] ?? const [],
      };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// Đọc và **kiểm tra toàn bộ** file trước khi bất kỳ dòng nào được ghi.
///
/// AD-11: sai bất kỳ chỗ nào thì từ chối kèm lý do cụ thể, dữ liệu hiện tại
/// không đụng tới.
Result<BackupDocument> decodeBackup(String raw) {
  final Object? parsed;
  try {
    parsed = jsonDecode(raw);
  } on FormatException catch (e) {
    return Err(AppFailure(FailureCode.malformedBackup, detail: 'JSON hỏng: ${e.message}'));
  }

  if (parsed is! Map<String, Object?>) {
    return const Err(AppFailure(FailureCode.malformedBackup,
        detail: 'Nội dung gốc không phải một đối tượng JSON'));
  }

  final version = parsed['schemaVersion'];
  if (version is! int) {
    return const Err(AppFailure(FailureCode.malformedBackup,
        detail: 'Thiếu trường schemaVersion hoặc không phải số nguyên'));
  }
  if (version > backupFormatVersion) {
    return Err(AppFailure(FailureCode.backupTooNew,
        detail: 'File thuộc phiên bản $version, ứng dụng mới đọc được tới $backupFormatVersion'));
  }
  if (version < 1) {
    return Err(AppFailure(FailureCode.malformedBackup,
        detail: 'schemaVersion không hợp lệ: $version'));
  }

  final exportedAtRaw = parsed['exportedAt'];
  final exportedAt =
      exportedAtRaw is String ? DateTime.tryParse(exportedAtRaw) : null;
  if (exportedAt == null) {
    return const Err(AppFailure(FailureCode.malformedBackup,
        detail: 'Thiếu trường exportedAt hoặc sai định dạng ngày giờ'));
  }

  final settingsRaw = parsed['settings'];
  if (settingsRaw != null && settingsRaw is! Map<String, Object?>) {
    return const Err(AppFailure(FailureCode.malformedBackup,
        detail: 'Trường settings không phải một đối tượng'));
  }

  final sections = <String, List<Map<String, Object?>>>{};
  for (final name in backupSections) {
    final value = parsed[name];
    // Thiếu hẳn một mục là hợp lệ: file của phiên bản cũ chưa có `reviews`.
    if (value == null) {
      sections[name] = const [];
      continue;
    }
    if (value is! List) {
      return Err(AppFailure(FailureCode.malformedBackup,
          detail: 'Mục "$name" phải là một danh sách'));
    }
    final rows = <Map<String, Object?>>[];
    for (final row in value) {
      if (row is! Map<String, Object?>) {
        return Err(AppFailure(FailureCode.malformedBackup,
            detail: 'Mục "$name" chứa một phần tử không phải đối tượng'));
      }
      rows.add(row);
    }
    sections[name] = rows;
  }

  // Ràng buộc bắt buộc của những mục không được phép thiếu trường.
  final missing = _firstMissingRequiredField(sections);
  if (missing != null) {
    return Err(AppFailure(FailureCode.malformedBackup, detail: missing));
  }

  return Ok(BackupDocument(
    schemaVersion: version,
    exportedAt: exportedAt,
    settings: (settingsRaw as Map<String, Object?>?) ?? const {},
    sections: sections,
  ));
}

const Map<String, List<String>> _requiredFields = {
  'topics': ['id', 'name', 'colorValue', 'iconKey'],
  'projects': ['id', 'topicId', 'name', 'status', 'priority', 'createdAt', 'updatedAt'],
  'actions': ['id', 'projectId', 'title', 'status', 'createdAt', 'updatedAt'],
  // `projectId` rời khỏi danh sách bắt buộc từ v4: nó được phép `null` khi Ghi
  // chú gắn vào Lĩnh vực hoặc nằm ở kho chung — AD-18. File v1…v3 vẫn luôn có
  // trường này nên không có phép kiểm nào bị mất.
  'notes': ['id', 'title', 'createdAt', 'updatedAt'],
  'links': ['id', 'label', 'url'],
  // `projectId` rời khỏi danh sách bắt buộc từ v5: Đợt của Lĩnh vực dùng
  // `areaId` thay thế — AD-19. File v1…v4 luôn có `projectId`.
  'reviews': ['id', 'date', 'createdAt'],
  'reviewItems': ['id', 'reviewId', 'label', 'verdict'],
  'statusEvents': ['id', 'entityType', 'entityId', 'fromStatus', 'toStatus', 'at'],
};

String? _firstMissingRequiredField(
    Map<String, List<Map<String, Object?>>> sections) {
  for (final entry in _requiredFields.entries) {
    for (final row in sections[entry.key] ?? const <Map<String, Object?>>[]) {
      for (final field in entry.value) {
        if (!row.containsKey(field) || row[field] == null) {
          return 'Mục "${entry.key}" có bản ghi thiếu trường bắt buộc "$field"';
        }
      }
    }
  }
  return null;
}

/// Đọc một trường bắt buộc kiểu số nguyên.
int readInt(Map<String, Object?> row, String key, {int fallback = 0}) {
  final v = row[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

int? readIntOrNull(Map<String, Object?> row, String key) {
  final v = row[key];
  if (v == null) return null;
  return readInt(row, key);
}

String readString(Map<String, Object?> row, String key, {String fallback = ''}) {
  final v = row[key];
  return v is String ? v : fallback;
}

bool readBool(Map<String, Object?> row, String key, {bool fallback = false}) {
  final v = row[key];
  if (v is bool) return v;
  if (v is int) return v != 0;
  return fallback;
}

DateTime readDate(Map<String, Object?> row, String key) {
  final v = row[key];
  final parsed = v is String ? DateTime.tryParse(v) : null;
  // Trường bắt buộc đã được kiểm ở `decodeBackup`; nhánh này chỉ để an toàn.
  return (parsed ?? DateTime.fromMillisecondsSinceEpoch(0)).toUtc();
}

DateTime? readDateOrNull(Map<String, Object?> row, String key) {
  final v = row[key];
  if (v is! String) return null;
  return DateTime.tryParse(v)?.toUtc();
}

String? isoOrNull(DateTime? value) => value?.toUtc().toIso8601String();
