import 'package:drift/drift.dart';

/// Bảng Drift — sơ đồ thực thể ở ARCHITECTURE-SPINE.
///
/// AD-3: **không** cột `completionRatio`, `actionCount`, `currentValue`,
/// `progress`. Mọi giá trị suy ra được tính tại chỗ.
///
/// AD-4: không cột nào kiểu `real`. Giá trị tiền là `int` đơn vị đồng.
///
/// AD-9: trạng thái lưu bằng chuỗi định danh ổn định, không bằng chỉ số enum.

@DataClassName('TopicRow')
class Topics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get colorValue => integer()();
  TextColumn get iconKey => text().withLength(max: 40)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Chủ đề `Khác` — không xoá được, là nơi Dự án chuyển về (FR-1).
  BoolColumn get isSystemFallback => boolean().withDefault(const Constant(false))();
}

@DataClassName('ProjectRow')
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get topicId =>
      integer().references(Topics, #id, onDelete: KeyAction.restrict)();
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
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Thứ tự kéo thả — FR-18.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get searchText => text().withDefault(const Constant(''))();
}

@DataClassName('GoalRow')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().withDefault(const Constant(''))();

  /// `false` với mục tiêu định tính — FR-20.
  BoolColumn get isNumeric => boolean().withDefault(const Constant(true))();

  /// Giá trị đích đã nhân hệ số. Không bao giờ là `real` — AD-4.
  IntColumn get targetRaw => integer().nullable()();
  IntColumn get decimals => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().withDefault(const Constant('VND'))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get searchText => text().withDefault(const Constant(''))();
}

@DataClassName('GoalUpdateRow')
class GoalUpdates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  IntColumn get valueRaw => integer()();
  IntColumn get decimals => integer().withDefault(const Constant(0))();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Bảng nối nhiều-nhiều giữa Dự án và Mục tiêu — FR-25.
@DataClassName('ProjectGoalRow')
class ProjectGoals extends Table {
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {projectId, goalId};
}

@DataClassName('NoteRow')
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get bodyMarkdown => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get searchText => text().withDefault(const Constant(''))();
}

@DataClassName('LinkRow')
class Links extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text().withLength(min: 1, max: 200)();
  TextColumn get url => text().withLength(min: 1, max: 2000)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get searchText => text().withDefault(const Constant(''))();
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

@DataClassName('SettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get staleDays => integer().withDefault(const Constant(21))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get seedApplied => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
