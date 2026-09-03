import 'package:drift/drift.dart';

/// Bảng Drift — sơ đồ thực thể ở ARCHITECTURE-SPINE.
///
/// AD-3: **không** cột `completionRatio`, `actionCount`, `currentValue`,
/// `progress`. Mọi giá trị suy ra được tính tại chỗ.
///
/// AD-4: không cột nào kiểu `real`. Giá trị tiền là `int` đơn vị đồng.
///
/// AD-9: trạng thái lưu bằng chuỗi định danh ổn định, không bằng chỉ số enum.

@DataClassName('AreaRow')
class Areas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get colorValue => integer()();
  TextColumn get iconKey => text().withLength(max: 40)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Lĩnh vực `Khác` — không xoá được, là nơi Dự án chuyển về (FR-1).
  BoolColumn get isSystemFallback => boolean().withDefault(const Constant(false))();
}

@DataClassName('ProjectRow')
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get areaId =>
      integer().references(Areas, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => text().withLength(max: 20)();
  TextColumn get priority => text().withLength(max: 10)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Chỉ mục tìm kiếm bỏ dấu — AD-12. Do repository sinh, không phải giá trị
  /// nghiệp vụ nên không vi phạm AD-3.
  TextColumn get searchText => text().withDefault(const Constant(''))();
}

@DataClassName('ActionRow')
class Actions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// AD-8: Hành động luôn thuộc đúng một Dự án, không có Hành động mồ côi
  /// và không có `parentId`.
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 300)();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get status => text().withLength(max: 20)();

  /// Độ ưu tiên riêng của Hành động — FR-41. Trước v3 chỉ Dự án mới có.
  TextColumn get priority => text().withLength(max: 10).withDefault(const Constant('medium'))();

  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Người dùng tự ghim "làm ngay" — FR-42. Đây là **nguồn duy nhất** của
  /// danh sách chính trên màn hình Hôm nay; app không tự thêm gì vào đó.
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  /// Thời điểm ghim, để xếp thứ tự trong danh sách Hôm nay.
  DateTimeColumn get pinnedAt => dateTime().nullable()();

  /// Thứ tự kéo thả — FR-18.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get searchText => text().withDefault(const Constant(''))();
}

@DataClassName('NoteRow')
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// AD-18: Ghi chú **sống lâu hơn** Dự án sinh ra nó. Trước v5 cột này là
  /// `NOT NULL` với `onDelete: cascade`, nghĩa là dọn một Dự án cũ là mất sạch
  /// bài học đã ghi trong đó — mất im lặng, không cảnh báo.
  IntColumn get projectId => integer()
      .nullable()
      .references(Projects, #id, onDelete: KeyAction.setNull)();

  /// Gắn thẳng vào Lĩnh vực, không qua Dự án nào — FR-50.
  IntColumn get areaId =>
      integer().nullable().references(Areas, #id, onDelete: KeyAction.setNull)();

  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get bodyMarkdown => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get searchText => text().withDefault(const Constant(''))();

  /// AD-18: gắn vào Dự án, **hoặc** Lĩnh vực, **hoặc** không gắn gì — nhiều
  /// nhất một cái. Viết thành ràng buộc thật ở tầng bảng chứ không chỉ là quy
  /// ước, vì quy ước thì mã nào cũng lách được.
  @override
  List<String> get customConstraints =>
      const ['CHECK (project_id IS NULL OR area_id IS NULL)'];
}

@DataClassName('LinkRow')
class Links extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// AD-18 — xem ghi chú ở [Notes.projectId].
  IntColumn get projectId => integer()
      .nullable()
      .references(Projects, #id, onDelete: KeyAction.setNull)();

  IntColumn get areaId =>
      integer().nullable().references(Areas, #id, onDelete: KeyAction.setNull)();

  TextColumn get label => text().withLength(min: 1, max: 200)();
  TextColumn get url => text().withLength(min: 1, max: 2000)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get searchText => text().withDefault(const Constant(''))();

  @override
  List<String> get customConstraints =>
      const ['CHECK (project_id IS NULL OR area_id IS NULL)'];
}

/// Bảng chỉ ghi thêm. Nguồn duy nhất của "ngày hoạt động gần nhất" (FR-13)
/// và của lịch sử đổi trạng thái (FR-8).
@DataClassName('StatusEventRow')
class StatusEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text().withLength(max: 10)();
  IntColumn get entityId => integer()();
  TextColumn get fromStatus => text().withLength(max: 20)();
  TextColumn get toStatus => text().withLength(max: 20)();
  DateTimeColumn get at => dateTime()();
}

/// Một lần nhìn lại Dự án tại một mốc thời gian — FR-35, AD-15.
///
/// Khác `Actions`: `Actions` có vòng đời một chiều kết thúc ở `Xong`, còn
/// bảng này ghi lại **chu kỳ lặp** — cùng một nội dung được chấm lại nhiều lần.
@DataClassName('ReviewRow')
class Reviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get summaryMarkdown => text().withDefault(const Constant(''))();

  /// "Mốc time" của chu kỳ — nguồn của nhắc nhở ở FR-40.
  DateTimeColumn get nextReviewDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get searchText => text().withDefault(const Constant(''))();
}

/// Một dòng trong Đợt đánh giá — FR-36.
@DataClassName('ReviewItemRow')
class ReviewItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reviewId =>
      integer().references(Reviews, #id, onDelete: KeyAction.cascade)();

  /// **Bản chụp văn bản** tại thời điểm đánh giá — AD-15. Sửa Hành động về sau
  /// không được làm đổi nhật ký quá khứ.
  TextColumn get label => text().withLength(min: 1, max: 500)();
  TextColumn get verdict => text().withLength(max: 20)();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Chỉ để mở nhanh Hành động liên quan. Không tham gia phép tính nào và
  /// không có ràng buộc khoá ngoại — Hành động có thể đã bị xoá.
  IntColumn get sourceActionId => integer().nullable()();
  TextColumn get searchText => text().withDefault(const Constant(''))();
}

@DataClassName('SettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get staleDays => integer().withDefault(const Constant(21))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get seedApplied => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
