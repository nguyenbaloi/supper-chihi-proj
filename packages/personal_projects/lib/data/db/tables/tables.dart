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

  /// FR-47: *"mức tôi muốn giữ ở mảng này là gì"*. Đây là thứ phân biệt một
  /// Lĩnh vực với một cái nhãn màu.
  ///
  /// Không có `status`, không có `dueDate`: Lĩnh vực **không bao giờ kết
  /// thúc**. Cái kết thúc được là Dự án.
  TextColumn get standard => text().withDefault(const Constant(''))();

  /// FR-48: số ngày giữa hai lần nhìn lại. `null` nghĩa là **không nhắc gì
  /// cả** — cùng nguyên tắc với "Mục tiêu không có hạn thì không hiện nhịp".
  IntColumn get reviewCadenceDays => integer().nullable()();

  /// Mốc để tính hạn xem lại đầu tiên, khi Lĩnh vực chưa có Đợt nào — FR-48.
  DateTimeColumn get createdAt => dateTime()();

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

  /// Thứ tự người dùng **tự đẩy** trong danh sách Làm ngay — nhỏ hơn thì nằm
  /// trên. `0` là chưa can thiệp, và đó là giá trị của mọi việc vừa ghim.
  ///
  /// Tách hẳn khỏi [pinnedAt] có chủ ý: `pinnedAt` là một **sự kiện có thật**
  /// ("bạn ghim lúc 9h"), sửa nó để xếp lại danh sách là ghi một điều không
  /// xảy ra vào cơ sở dữ liệu — và nó còn đi thẳng vào file sao lưu. Cột này
  /// mang đúng nghĩa "chỗ tôi muốn nó nằm", nên xếp lại bao nhiêu lần cũng
  /// không làm hỏng dữ liệu nào khác.
  ///
  /// Cũng không dùng lại [sortOrder]: cột đó là thứ tự **trong một Dự án**
  /// (FR-18), gộp hai thứ tự vào một cột thì kéo thả ở màn Dự án sẽ lặng lẽ
  /// xáo lại màn Hôm nay.
  IntColumn get pinnedOrder => integer().withDefault(const Constant(0))();

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

  /// AD-19: Đợt thuộc **đúng một** chủ thể — một Dự án *hoặc* một Lĩnh vực.
  /// Khác AD-18 ở chỗ không cho phép cả hai cùng `null`: một Đợt mồ côi thì
  /// không hiện ở đâu cả.
  IntColumn get projectId => integer()
      .nullable()
      .references(Projects, #id, onDelete: KeyAction.cascade)();

  /// Nhìn lại cả một mảng đời sống, không chỉ một Dự án — FR-49.
  IntColumn get areaId =>
      integer().nullable().references(Areas, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get summaryMarkdown => text().withDefault(const Constant(''))();

  /// "Mốc time" của chu kỳ — nguồn của nhắc nhở ở FR-40.
  DateTimeColumn get nextReviewDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get searchText => text().withDefault(const Constant(''))();

  /// AD-19: **đúng một** chủ thể. `XOR` chứ không phải "nhiều nhất một" như
  /// AD-18 — Đợt không thuộc đâu cả thì không màn hình nào liệt kê nó.
  @override
  List<String> get customConstraints => const [
        'CHECK ((project_id IS NULL) <> (area_id IS NULL))',
      ];
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
