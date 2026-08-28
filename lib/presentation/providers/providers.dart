/// Provider Riverpod — AD-2: khai báo thủ công dưới dạng biến `final` cấp cao
/// nhất. Không dùng `riverpod_generator`, không `riverpod_annotation`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/backup/backup_service.dart';
import '../../data/db/database.dart';
import '../../data/repositories/drift_action_repository.dart';
import '../../data/repositories/drift_content_repositories.dart';
import '../../data/repositories/drift_goal_repository.dart';
import '../../data/repositories/drift_project_repository.dart';
import '../../data/repositories/drift_review_repository.dart';
import '../../data/repositories/drift_search_repository.dart';
import '../../data/repositories/drift_topic_repository.dart';
import '../../data/seed/seeder.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/note.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_action.dart';
import '../../domain/models/review.dart';
import '../../domain/models/topic.dart';
import '../../domain/repositories/repositories.dart';

/// Ghi đè trong test bằng `AppDatabase(NativeDatabase.memory())`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final topicRepositoryProvider = Provider<TopicRepository>(
  (ref) => DriftTopicRepository(ref.watch(databaseProvider)),
);

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => DriftProjectRepository(ref.watch(databaseProvider)),
);

final actionRepositoryProvider = Provider<ActionRepository>(
  (ref) => DriftActionRepository(ref.watch(databaseProvider)),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => DriftGoalRepository(ref.watch(databaseProvider)),
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

final topicsProvider = StreamProvider<List<Topic>>(
  (ref) => ref.watch(topicRepositoryProvider).watchAll(),
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

  void toggleTopic(int topicId) {
    final next = {...state.topicIds};
    next.contains(topicId) ? next.remove(topicId) : next.add(topicId);
    state = state.copyWith(topicIds: next);
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

final projectNotesProvider = StreamProvider.family<List<Note>, int>(
  (ref, projectId) => ref.watch(noteRepositoryProvider).watchByProject(projectId),
);

final projectLinksProvider = StreamProvider.family<List<Link>, int>(
  (ref, projectId) => ref.watch(linkRepositoryProvider).watchByProject(projectId),
);

final projectStatusHistoryProvider = StreamProvider.family<List<StatusEvent>, int>(
  (ref, projectId) =>
      ref.watch(projectRepositoryProvider).watchStatusHistory(projectId),
);

final projectLinkedGoalIdsProvider = StreamProvider.family<List<int>, int>(
  (ref, projectId) =>
      ref.watch(goalRepositoryProvider).watchLinkedGoalIds(projectId),
);

final projectReviewsProvider = StreamProvider.family<List<ReviewSummary>, int>(
  (ref, projectId) => ref.watch(reviewRepositoryProvider).watchByProject(projectId),
);

final reviewItemsProvider = StreamProvider.family<List<ReviewItem>, int>(
  (ref, reviewId) => ref.watch(reviewRepositoryProvider).watchItems(reviewId),
);

/// Mọi Đợt đánh giá — màn hình Hôm nay cần để tính nhắc đến hạn (FR-40).
final allReviewsProvider = StreamProvider<List<Review>>(
  (ref) => ref.watch(reviewRepositoryProvider).watchAllReviews(),
);

final goalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalRepositoryProvider).watchAll(),
);

final goalProvider = StreamProvider.family<Goal?, int>(
  (ref, id) => ref.watch(goalRepositoryProvider).watchById(id),
);

final goalUpdatesProvider = StreamProvider.family<List<GoalUpdate>, int>(
  (ref, goalId) => ref.watch(goalRepositoryProvider).watchUpdates(goalId),
);

final goalLinkedProjectIdsProvider = StreamProvider.family<List<int>, int>(
  (ref, goalId) => ref.watch(goalRepositoryProvider).watchLinkedProjectIds(goalId),
);

/// Đồng hồ của ứng dụng. Tách ra để test dựng được "hôm nay" cố định.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
