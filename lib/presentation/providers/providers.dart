/// Provider Riverpod — AD-2: khai báo thủ công dưới dạng biến `final` cấp cao
/// nhất. Không dùng `riverpod_generator`, không `riverpod_annotation`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/backup/backup_service.dart';
import '../../data/db/database.dart';
import '../../data/repositories/drift_action_repository.dart';
import '../../data/repositories/drift_content_repositories.dart';
import '../../data/repositories/drift_project_repository.dart';
import '../../data/repositories/drift_review_repository.dart';
import '../../data/repositories/drift_search_repository.dart';
import '../../data/repositories/drift_area_repository.dart';
import '../../data/seed/seeder.dart';
import '../../domain/models/note.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_action.dart';
import '../../domain/models/review.dart';
import '../../domain/models/area.dart';
import '../../domain/repositories/repositories.dart';

/// Ghi đè trong test bằng `AppDatabase(NativeDatabase.memory())`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final areaRepositoryProvider = Provider<AreaRepository>(
  (ref) => DriftAreaRepository(ref.watch(databaseProvider)),
);

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => DriftProjectRepository(ref.watch(databaseProvider)),
);

final actionRepositoryProvider = Provider<ActionRepository>(
  (ref) => DriftActionRepository(ref.watch(databaseProvider)),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => DriftNoteRepository(ref.watch(databaseProvider)),
);

final linkRepositoryProvider = Provider<LinkRepository>(
  (ref) => DriftLinkRepository(ref.watch(databaseProvider)),
);

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => DriftReviewRepository(ref.watch(databaseProvider)),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => DriftSearchRepository(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(databaseProvider)),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

final seederProvider = Provider<Seeder>(
  (ref) => Seeder(ref.watch(databaseProvider)),
);

final settingsProvider = StreamProvider<AppSettingsData>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

final areasProvider = StreamProvider<List<Area>>(
  (ref) => ref.watch(areaRepositoryProvider).watchAll(),
);

/// Bộ lọc danh sách Dự án. Ghi nhớ giữa các lần mở app được xử lý ở
/// `ProjectFilterController` khi Story 2.3 hoàn tất phần lưu cài đặt.
final projectFilterProvider =
    NotifierProvider<ProjectFilterController, ProjectFilter>(
  ProjectFilterController.new,
);

class ProjectFilterController extends Notifier<ProjectFilter> {
  @override
  ProjectFilter build() => const ProjectFilter();

  void setSort(ProjectSort sort) => state = state.copyWith(sort: sort);

  void toggleIncludeClosed() =>
      state = state.copyWith(includeClosed: !state.includeClosed);

  void toggleArea(int areaId) {
    final next = {...state.areaIds};
    next.contains(areaId) ? next.remove(areaId) : next.add(areaId);
    state = state.copyWith(areaIds: next);
  }

  void clear() => state = const ProjectFilter();
}

final projectSummariesProvider = StreamProvider<List<ProjectSummary>>((ref) {
  final filter = ref.watch(projectFilterProvider);
  return ref.watch(projectRepositoryProvider).watchSummaries(filter);
});

/// Tất cả Dự án, không lọc — dùng cho màn hình Hôm nay và ô chọn Dự án.
final allProjectSummariesProvider = StreamProvider<List<ProjectSummary>>(
  (ref) => ref
      .watch(projectRepositoryProvider)
      .watchSummaries(const ProjectFilter(includeClosed: true)),
);

final projectProvider =
    StreamProvider.family<Project?, int>((ref, id) => ref.watch(projectRepositoryProvider).watchById(id));

final projectActionsProvider = StreamProvider.family<List<ProjectAction>, int>(
  (ref, projectId) => ref.watch(actionRepositoryProvider).watchByProject(projectId),
);

/// Một Hành động duy nhất — màn hình chi tiết Hành động (FR-14, FR-16).
final actionProvider = StreamProvider.family<ProjectAction?, int>(
  (ref, id) => ref.watch(actionRepositoryProvider).watchById(id),
);

final projectNotesProvider = StreamProvider.family<List<Note>, int>(
  (ref, projectId) => ref.watch(noteRepositoryProvider).watchByProject(projectId),
);

/// Toàn bộ Tư liệu, không lọc theo chỗ gắn — nguồn của màn hình Tư liệu
/// (FR-50). Lọc theo Lĩnh vực / chưa xếp chỗ làm ở tầng hiển thị vì danh sách
/// nhỏ và bộ lọc đổi liên tục.
final allNotesProvider = StreamProvider<List<Note>>(
  (ref) => ref.watch(noteRepositoryProvider).watchAll(),
);

final allLinksProvider = StreamProvider<List<Link>>(
  (ref) => ref.watch(linkRepositoryProvider).watchAll(),
);

final projectLinksProvider = StreamProvider.family<List<Link>, int>(
  (ref, projectId) => ref.watch(linkRepositoryProvider).watchByProject(projectId),
);

final projectStatusHistoryProvider = StreamProvider.family<List<StatusEvent>, int>(
  (ref, projectId) =>
      ref.watch(projectRepositoryProvider).watchStatusHistory(projectId),
);

final projectReviewsProvider = StreamProvider.family<List<ReviewSummary>, int>(
  (ref, projectId) => ref.watch(reviewRepositoryProvider).watchByProject(projectId),
);

/// Đợt đánh giá của một Lĩnh vực — FR-49. Tách hẳn với
/// `projectReviewsProvider`: hai loại trả lời hai câu hỏi khác nhau và không
/// bao giờ trộn vào một danh sách.
final areaReviewsProvider = StreamProvider.family<List<ReviewSummary>, int>(
  (ref, areaId) => ref.watch(reviewRepositoryProvider).watchByArea(areaId),
);

final reviewItemsProvider = StreamProvider.family<List<ReviewItem>, int>(
  (ref, reviewId) => ref.watch(reviewRepositoryProvider).watchItems(reviewId),
);

/// Mọi Đợt đánh giá — màn hình Hôm nay cần để tính nhắc đến hạn (FR-40).
final allReviewsProvider = StreamProvider<List<Review>>(
  (ref) => ref.watch(reviewRepositoryProvider).watchAllReviews(),
);

/// Hành động đang ghim — nguồn duy nhất của danh sách "Làm ngay" (FR-42).
final pinnedActionsProvider = StreamProvider<List<ProjectAction>>(
  (ref) => ref.watch(actionRepositoryProvider).watchPinned(),
);

/// Mọi Hành động còn mở — nguồn của khối cảnh báo (FR-43).
final openActionsProvider = StreamProvider<List<ProjectAction>>(
  (ref) => ref.watch(actionRepositoryProvider).watchAllOpen(),
);

/// Mọi Hành động — nguồn của thống kê (FR-44).
final allActionsProvider = StreamProvider<List<ProjectAction>>(
  (ref) => ref.watch(actionRepositoryProvider).watchAll(),
);

/// Đồng hồ của ứng dụng. Tách ra để test dựng được "hôm nay" cố định.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
