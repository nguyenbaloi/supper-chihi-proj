/// Hợp đồng trừu tượng của tầng dữ liệu — AD-1.
///
/// File này không được `import` `drift` hay bất cứ thứ gì của Flutter.
library;

import '../models/enums.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/project_action.dart';
import '../models/review.dart';
import '../models/area.dart';

/// Dự án kèm đúng những con số suy ra được để dựng một dòng danh sách —
/// tính tại chỗ mỗi lần đọc, không lưu (AD-3).
final class ProjectSummary {
  const ProjectSummary({
    required this.project,
    required this.area,
    required this.doneCount,
    required this.countedTotal,
    required this.lastActivityAt,
  });

  final Project project;
  final Area area;
  final int doneCount;
  final int countedTotal;
  final DateTime? lastActivityAt;
}

final class ProjectFilter {
  const ProjectFilter({
    this.statuses = const {},
    this.areaIds = const {},
    this.includeClosed = false,
    this.sort = ProjectSort.priority,
  });

  /// Rỗng nghĩa là không lọc theo trạng thái.
  final Set<ProjectStatus> statuses;

  /// Rỗng nghĩa là không lọc theo Lĩnh vực.
  final Set<int> areaIds;

  /// Mặc định ẩn `Xong` và `Bỏ` — FR-10.
  final bool includeClosed;

  final ProjectSort sort;

  ProjectFilter copyWith({
    Set<ProjectStatus>? statuses,
    Set<int>? areaIds,
    bool? includeClosed,
    ProjectSort? sort,
  }) =>
      ProjectFilter(
        statuses: statuses ?? this.statuses,
        areaIds: areaIds ?? this.areaIds,
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

abstract interface class AreaRepository {
  Stream<List<Area>> watchAll();
  Future<List<Area>> getAll();
  Future<Area> create({required String name, required int colorValue, required String iconKey});
  Future<void> update(Area area);

  /// Xoá Lĩnh vực; Dự án thuộc nó chuyển về Lĩnh vực `Khác`, không bị xoá (FR-1).
  /// Lĩnh vực `Khác` không xoá được.
  Future<void> delete(int id);
}

abstract interface class ProjectRepository {
  Stream<List<ProjectSummary>> watchSummaries(ProjectFilter filter);
  Stream<Project?> watchById(int id);
  Future<Project?> getById(int id);

  Future<Project> create({
    required String name,
    String description = '',
    int? areaId,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  });

  Future<void> update(Project project);

  /// Đổi trạng thái kèm ghi `StatusEvent` và cập nhật dấu thời gian — AD-5.
  Future<void> changeStatus(int projectId, ProjectStatus next);

  /// Xoá Dự án và mọi Hành động, Ghi chú, Liên kết, mối nối của nó.
  /// **Không** xoá Mục tiêu đã nối (FR-7).
  /// Xoá Dự án. Ghi chú và Liên kết **không** bị xoá theo: chúng chuyển sang
  /// Lĩnh vực của Dự án — AD-18, FR-50.
  Future<void> delete(int id);

  /// Đếm số Ghi chú và Liên kết sẽ chuyển đi nếu xoá Dự án này.
  Future<AttachedContentCount> attachedContentCount(int projectId);

  Stream<List<StatusEvent>> watchStatusHistory(int projectId);
}

abstract interface class ActionRepository {
  Stream<List<ProjectAction>> watchByProject(int projectId);
  Future<ProjectAction> create({
    required int projectId,
    required String title,
    String note = '',
    Priority priority = Priority.medium,
    DateTime? dueDate,
  });
  Future<void> update(ProjectAction action);
  Future<void> changeStatus(int actionId, ActionStatus next);
  Future<void> moveToProject(int actionId, int targetProjectId);
  Future<void> reorder(int projectId, List<int> orderedIds);
  Future<void> delete(int id);

  /// Khôi phục một Hành động vừa xoá — phục vụ thao tác hoàn tác (FR-15).
  Future<void> restore(ProjectAction action);

  /// Ghim hoặc bỏ ghim khỏi danh sách "làm ngay" của màn hình Hôm nay — FR-42.
  Future<void> setPinned(int actionId, bool pinned);

  /// Mọi Hành động đang ghim, xếp theo thời điểm ghim.
  Stream<List<ProjectAction>> watchPinned();

  /// Mọi Hành động còn mở — nguồn của khối cảnh báo và của thống kê.
  Stream<List<ProjectAction>> watchAllOpen();

  /// Mọi Hành động, không lọc — nguồn của thống kê theo hạn.
  Stream<List<ProjectAction>> watchAll();
}

/// Số Ghi chú và Liên kết sẽ chuyển đi khi xoá một Dự án — FR-50.
///
/// Hộp xác nhận xoá phải nói đúng con số này, vì hành vi đã đổi: trước v5
/// chúng bị xoá theo, từ v5 chúng chuyển sang Lĩnh vực của Dự án.
typedef AttachedContentCount = ({int notes, int links});

abstract interface class NoteRepository {
  Stream<List<Note>> watchByProject(int projectId);

  /// Ghi chú gắn thẳng vào Lĩnh vực, **không** gồm Ghi chú của các Dự án
  /// thuộc Lĩnh vực đó — AD-18 cho phép gắn nhiều nhất một nơi.
  Stream<List<Note>> watchByArea(int areaId);

  /// Kho chung: không thuộc Dự án nào và cũng không thuộc Lĩnh vực nào.
  Stream<List<Note>> watchUnattached();

  Stream<List<Note>> watchAll();

  /// Truyền nhiều nhất một trong [projectId] và [areaId]; cả hai `null` thì
  /// Ghi chú nằm ở kho chung.
  Future<Note> create({
    int? projectId,
    int? areaId,
    required String title,
    String bodyMarkdown = '',
  });

  Future<void> update(Note note);

  /// Chuyển sang chỗ khác. Nội dung và `createdAt` giữ nguyên; `searchText`
  /// được sinh lại — FR-50.
  Future<void> move(int id, {int? projectId, int? areaId});

  Future<void> delete(int id);
}

abstract interface class LinkRepository {
  Stream<List<Link>> watchByProject(int projectId);
  Stream<List<Link>> watchByArea(int areaId);
  Stream<List<Link>> watchUnattached();
  Stream<List<Link>> watchAll();
  Future<Link> create({
    int? projectId,
    int? areaId,
    required String label,
    required String url,
  });
  Future<void> update(Link link);
  Future<void> move(int id, {int? projectId, int? areaId});
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

  /// Đợt đánh giá của một Lĩnh vực — FR-49. **Không** gồm Đợt của các Dự án
  /// thuộc Lĩnh vực đó: hai loại trả lời hai câu hỏi khác nhau.
  Stream<List<ReviewSummary>> watchByArea(int areaId);
  Stream<List<Review>> watchAllReviews();
  Stream<List<ReviewItem>> watchItems(int reviewId);
  Future<List<ReviewItem>> getItems(int reviewId);

  /// Truyền **đúng một** trong [projectId] và [areaId] — AD-19.
  Future<Review> create({
    int? projectId,
    int? areaId,
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

enum SearchKind { project, action, note, link, review }

/// Một kết quả tìm kiếm, kèm đủ thông tin để mở đúng chỗ.
final class SearchHit {
  const SearchHit({
    required this.kind,
    required this.id,
    required this.title,
    required this.snippet,
    this.projectId,
    this.projectName,
  });

  final SearchKind kind;
  final int id;
  final String title;
  final String snippet;

  /// Dự án chứa kết quả.
  final int? projectId;
  final String? projectName;
}

abstract interface class SearchRepository {
  /// FR-30: quét Dự án, Hành động, Ghi chú, Liên kết và Đợt đánh giá.
  /// Không phân biệt hoa thường và không phân biệt dấu — AD-12.
  Future<List<SearchHit>> search(String query);
}
