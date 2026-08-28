/// Hợp đồng trừu tượng của tầng dữ liệu — AD-1.
///
/// File này không được `import` `drift` hay bất cứ thứ gì của Flutter.
library;

import '../models/enums.dart';
import '../models/goal.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/project_action.dart';
import '../models/review.dart';
import '../models/topic.dart';

/// Dự án kèm đúng những con số suy ra được để dựng một dòng danh sách —
/// tính tại chỗ mỗi lần đọc, không lưu (AD-3).
final class ProjectSummary {
  const ProjectSummary({
    required this.project,
    required this.topic,
    required this.doneCount,
    required this.countedTotal,
    required this.lastActivityAt,
  });

  final Project project;
  final Topic topic;
  final int doneCount;
  final int countedTotal;
  final DateTime? lastActivityAt;
}

final class ProjectFilter {
  const ProjectFilter({
    this.statuses = const {},
    this.topicIds = const {},
    this.includeClosed = false,
    this.sort = ProjectSort.priority,
  });

  /// Rỗng nghĩa là không lọc theo trạng thái.
  final Set<ProjectStatus> statuses;

  /// Rỗng nghĩa là không lọc theo Chủ đề.
  final Set<int> topicIds;

  /// Mặc định ẩn `Xong` và `Bỏ` — FR-10.
  final bool includeClosed;

  final ProjectSort sort;

  ProjectFilter copyWith({
    Set<ProjectStatus>? statuses,
    Set<int>? topicIds,
    bool? includeClosed,
    ProjectSort? sort,
  }) =>
      ProjectFilter(
        statuses: statuses ?? this.statuses,
        topicIds: topicIds ?? this.topicIds,
        includeClosed: includeClosed ?? this.includeClosed,
        sort: sort ?? this.sort,
      );
}

enum ProjectSort {
  priority('priority'),
  lastActivity('last_activity'),
  name('name'),
  dueDate('due_date');

  const ProjectSort(this.wire);
  final String wire;

  static ProjectSort fromWire(String? value) {
    for (final s in ProjectSort.values) {
      if (s.wire == value) return s;
    }
    return ProjectSort.priority;
  }
}

abstract interface class TopicRepository {
  Stream<List<Topic>> watchAll();
  Future<List<Topic>> getAll();
  Future<Topic> create({required String name, required int colorValue, required String iconKey});
  Future<void> update(Topic topic);

  /// Xoá Chủ đề; Dự án thuộc nó chuyển về Chủ đề `Khác`, không bị xoá (FR-1).
  /// Chủ đề `Khác` không xoá được.
  Future<void> delete(int id);
}

abstract interface class ProjectRepository {
  Stream<List<ProjectSummary>> watchSummaries(ProjectFilter filter);
  Stream<Project?> watchById(int id);
  Future<Project?> getById(int id);

  Future<Project> create({
    required String name,
    String description = '',
    int? topicId,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  });

  Future<void> update(Project project);

  /// Đổi trạng thái kèm ghi `StatusEvent` và cập nhật dấu thời gian — AD-5.
  Future<void> changeStatus(int projectId, ProjectStatus next);

  /// Xoá Dự án và mọi Hành động, Ghi chú, Liên kết, mối nối của nó.
  /// **Không** xoá Mục tiêu đã nối (FR-7).
  Future<void> delete(int id);

  Stream<List<StatusEvent>> watchStatusHistory(int projectId);
}

abstract interface class ActionRepository {
  Stream<List<ProjectAction>> watchByProject(int projectId);
  Future<ProjectAction> create({
    required int projectId,
    required String title,
    String note = '',
    DateTime? dueDate,
  });
  Future<void> update(ProjectAction action);
  Future<void> changeStatus(int actionId, ActionStatus next);
  Future<void> moveToProject(int actionId, int targetProjectId);
  Future<void> reorder(int projectId, List<int> orderedIds);
  Future<void> delete(int id);

  /// Khôi phục một Hành động vừa xoá — phục vụ thao tác hoàn tác (FR-15).
  Future<void> restore(ProjectAction action);
}

abstract interface class GoalRepository {
  Stream<List<Goal>> watchAll();
  Stream<Goal?> watchById(int id);
  Stream<List<GoalUpdate>> watchUpdates(int goalId);
  Future<List<GoalUpdate>> getUpdates(int goalId);

  Future<Goal> create({
    required String name,
    String description = '',
    required bool isNumeric,
    int? targetRaw,
    int decimals = 0,
    String unit = 'VND',
    DateTime? dueDate,
  });
  Future<void> update(Goal goal);
  Future<void> delete(int id);

  Future<GoalUpdate> addUpdate({
    required int goalId,
    required DateTime date,
    required int valueRaw,
    String note = '',
  });
  Future<void> updateMark(GoalUpdate mark);
  Future<void> deleteMark(int id);

  Future<void> linkProject(int projectId, int goalId);
  Future<void> unlinkProject(int projectId, int goalId);
  Stream<List<int>> watchLinkedProjectIds(int goalId);
  Stream<List<int>> watchLinkedGoalIds(int projectId);
}

abstract interface class NoteRepository {
  Stream<List<Note>> watchByProject(int projectId);
  Future<Note> create({required int projectId, required String title, String bodyMarkdown = ''});
  Future<void> update(Note note);
  Future<void> delete(int id);
}

abstract interface class LinkRepository {
  Stream<List<Link>> watchByProject(int projectId);
  Future<Link> create({required int projectId, required String label, required String url});
  Future<void> update(Link link);
  Future<void> delete(int id);
}

/// Cài đặt — một hàng duy nhất, id luôn bằng 1.
final class AppSettingsData {
  const AppSettingsData({
    required this.staleDays,
    required this.themeMode,
    required this.seedApplied,
  });

  final int staleDays;
  final AppThemeMode themeMode;
  final bool seedApplied;

  AppSettingsData copyWith({int? staleDays, AppThemeMode? themeMode, bool? seedApplied}) =>
      AppSettingsData(
        staleDays: staleDays ?? this.staleDays,
        themeMode: themeMode ?? this.themeMode,
        seedApplied: seedApplied ?? this.seedApplied,
      );
}

abstract interface class SettingsRepository {
  Stream<AppSettingsData> watch();
  Future<AppSettingsData> get();
  Future<void> save(AppSettingsData settings);
}

/// Đợt đánh giá kèm số Mục đã đếm sẵn để dựng một dòng danh sách.
/// Tính tại chỗ mỗi lần đọc, không lưu (AD-3).
final class ReviewSummary {
  const ReviewSummary({
    required this.review,
    required this.metCount,
    required this.itemCount,
  });

  final Review review;
  final int metCount;
  final int itemCount;
}

abstract interface class ReviewRepository {
  Stream<List<ReviewSummary>> watchByProject(int projectId);
  Stream<List<Review>> watchAllReviews();
  Stream<List<ReviewItem>> watchItems(int reviewId);
  Future<List<ReviewItem>> getItems(int reviewId);

  Future<Review> create({
    required int projectId,
    required DateTime date,
    String title = '',
    String summaryMarkdown = '',
    DateTime? nextReviewDate,
  });
  Future<void> update(Review review);
  Future<void> delete(int id);

  Future<ReviewItem> addItem({
    required int reviewId,
    required String label,
    ReviewVerdict verdict = ReviewVerdict.notMet,
    String note = '',
    int? sourceActionId,
  });
  Future<void> updateItem(ReviewItem item);
  Future<void> deleteItem(int id);
  Future<void> reorderItems(int reviewId, List<int> orderedIds);

  /// FR-37: chép các Mục chưa đạt của Đợt trước sang Đợt mới, đặt lại kết quả
  /// khởi điểm là `Chưa đạt`.
  Future<void> carryForward({
    required int targetReviewId,
    required List<ReviewItem> items,
  });
}
