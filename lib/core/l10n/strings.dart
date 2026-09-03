/// Lớp l10n — **nơi duy nhất** chứa chuỗi hiển thị.
///
/// Widget không được viết thẳng tiếng Việt. Ứng dụng hiện chỉ có một ngôn ngữ
/// nên lớp này là hằng số tĩnh thay vì bộ sinh mã ARB; khi thêm ngôn ngữ thứ
/// hai, đổi các hằng số ở đây thành tra cứu theo locale — chỗ gọi không đổi.
library;

import '../../domain/models/enums.dart';
import '../../domain/repositories/repositories.dart';
import '../result/result.dart';

abstract final class S {
  static const appTitle = 'Chichi Projects';

  // Điều hướng
  static const tabToday = 'Hôm nay';
  static const tabProjects = 'Dự án';
  static const tabStats = 'Thống kê';
  static const settings = 'Cài đặt';
  static const search = 'Tìm kiếm';

  // Chung
  static const save = 'Lưu';
  static const cancel = 'Huỷ';
  static const delete = 'Xoá';
  static const edit = 'Sửa';
  static const add = 'Thêm';
  static const undo = 'Hoàn tác';
  static const close = 'Đóng';
  static const emptyValue = '—';
  static const required = 'Bắt buộc';
  static const optional = 'Không bắt buộc';

  // Hôm nay
  static const todayDoNow = 'Làm ngay';
  static const todayDoNowHint =
      'Chỉ những việc bạn tự ghim mới xuất hiện ở đây.';
  static const todayEmpty = 'Chưa ghim việc nào để làm ngay.';
  static const todayGoToProjects = 'Mở danh sách dự án để chọn việc';
  static const todayAttention = 'Cần chú ý';
  static const todayAllClear = 'Không có gì cần chú ý.';
  static const staleProject = 'không hoạt động';

  static const pin = 'Ghim vào Làm ngay';
  static const unpin = 'Bỏ khỏi Làm ngay';
  static const pinned = 'Đã ghim';

  static const attentionOverdue = 'Quá hạn';
  static const attentionDueSoon = 'Sắp đến hạn';
  static const attentionHighPriority = 'Ưu tiên cao, chưa bắt đầu';

  static String attentionCount(int n) => '$n việc';
  static String dueInDays(int n) => n == 0 ? 'đến hạn hôm nay' : 'còn $n ngày';

  // Thống kê
  static const statsTitle = 'Thống kê';
  static const statsScopeAll = 'Tất cả';
  static const statsByOutcome = 'Đầu việc theo hạn';
  static const statsByArea = 'Theo lĩnh vực';
  static const statsOnTimeRatio = 'Tỷ lệ đúng hạn';
  static const statsCompletionRatio = 'Tỷ lệ hoàn thành';
  static const statsEmpty = 'Chưa có đầu việc nào để thống kê.';
  static const statsOutcomeOnTime = 'Xong đúng hạn';
  static const statsOutcomeLate = 'Xong muộn';
  static const statsOutcomeOverdue = 'Quá hạn chưa xong';
  static const statsOutcomePending = 'Còn hạn, chưa xong';
  static const statsOutcomeNoDueDate = 'Không đặt hạn';
  static const statsOutcomeDropped = 'Đã bỏ';

  static const actionPriority = 'Độ ưu tiên';

  static String projectCount(int n) => '$n dự án';
  static String projectCountWithTally(int n, int done, int total) =>
      '$n dự án · $done/$total';
  static String highPriorityOpen(int n) => '$n ưu tiên cao';
  static String overdueCount(int n) => '$n quá hạn';
  static String finishedWithDueDate(int n) => '$n việc có hạn đã xong';

  // Dự án
  static const projectNew = 'Dự án mới';
  static const projectName = 'Tên dự án';
  static const projectDescription = 'Mô tả';
  static const projectArea = 'Lĩnh vực';
  static const projectPriority = 'Độ ưu tiên';
  static const projectStatusLabel = 'Trạng thái';
  static const projectDueDate = 'Hạn chót';
  static const projectNoDueDate = 'Không đặt hạn';
  static const projectNameRequired = 'Tên dự án không được để trống';
  static const projectEmptyList = 'Chưa có dự án nào.';
  static const projectHistory = 'Lịch sử trạng thái';
  static const projectNotes = 'Ghi chú';
  static const projectLinks = 'Liên kết';
  static const projectShowClosed = 'Hiện dự án đã đóng';
  static const projectFilter = 'Lọc';
  static const projectSort = 'Sắp xếp';

  static const sortPriority = 'Độ ưu tiên';
  static const sortLastActivity = 'Hoạt động gần nhất';
  static const sortName = 'Tên';
  static const sortDueDate = 'Hạn chót';

  /// FR-7 và FR-50: hộp xác nhận phải nêu rõ cái gì mất và cái gì chỉ chuyển đi.
  ///
  /// Hai vế tách bạch có chủ ý. Hành động **mất thật**; Ghi chú và Liên kết
  /// **không mất** mà chuyển sang Lĩnh vực — nói gộp là làm người dùng ngại
  /// xoá một Dự án cũ chỉ vì tưởng sẽ mất bài học đã ghi trong đó.
  static String projectDeleteConfirm(
      int actions, int notes, int links, String areaName) {
    final moved = <String>[
      if (notes > 0) '$notes ghi chú',
      if (links > 0) '$links liên kết',
    ].join(' và ');
    return [
      'Xoá dự án này sẽ xoá theo $actions hành động.',
      if (moved.isNotEmpty)
        '$moved sẽ chuyển sang lĩnh vực "$areaName", không bị xoá.',
      '',
      'Nếu chỉ muốn dừng lại, hãy chuyển trạng thái sang "Bỏ".',
    ].join('\n');
  }
  static const projectDeleteTitle = 'Xoá dự án?';

  // Hành động
  static const actionNew = 'Thêm hành động';
  static const actionTitle = 'Tên hành động';
  static const actionNote = 'Ghi chú';
  static const actionTitleRequired = 'Tên hành động không được để trống';
  static const actionEmpty = 'Chưa có hành động nào.';
  static const actionClosedGroup = 'Đã xong và đã bỏ';
  static const actionMoveTo = 'Chuyển sang dự án khác';
  static const actionDeleted = 'Đã xoá hành động';

  static String actionDoingFor(int days) =>
      days <= 0 ? 'bắt đầu hôm nay' : 'đang làm $days ngày';

  // Ghi chú và liên kết
  static const noteNew = 'Ghi chú mới';
  static const noteTitle = 'Tiêu đề';
  static const noteBody = 'Nội dung';
  static const noteEmpty = 'Chưa có ghi chú nào.';
  static const linkNew = 'Liên kết mới';
  static const linkLabel = 'Nhãn';
  static const linkUrl = 'Địa chỉ';
  static const linkEmpty = 'Chưa có liên kết nào.';
  static const linkInvalid = 'Địa chỉ không hợp lệ';
  static const linkCopied = 'Đã sao chép địa chỉ';
  static const linkCopy = 'Sao chép địa chỉ';

  // Tư liệu — FR-50. "Tư liệu" là nhãn nhóm gộp Ghi chú và Liên kết ở giao
  // diện, KHÔNG phải một thực thể; không có lớp `Resource` nào — AD-20.
  static const resources = 'Tư liệu';

  // Lĩnh vực — FR-47, FR-48.
  static const area = 'Lĩnh vực';
  static const areaStandard = 'Mức cần giữ';
  static const areaStandardHint =
      'Mảng này giữ ở mức nào thì gọi là ổn? Viết cho mình đọc lại sau.';
  static const areaStandardEmpty = 'Chưa ghi mức cần giữ.';
  static const areaCadence = 'Nhịp xem lại';
  static const areaCadenceNone = 'Không nhắc';
  static const areaCadenceNoneHint =
      'Không đặt nhịp thì ứng dụng không nhắc gì cả.';
  static String areaCadenceEvery(int days) => 'Mỗi $days ngày';
  static const areaNextReview = 'Xem lại lần tới';
  static String areaReviewDueIn(int days) => 'Còn $days ngày';
  static const areaReviewDueToday = 'Đến hạn hôm nay';
  static String areaReviewOverdue(int days) => 'Trễ $days ngày';
  static const areaReviewsEmpty = 'Chưa có đợt đánh giá nào cho lĩnh vực này.';
  static const areaReviewNew = 'Đợt đánh giá mới';
  static const areaEdit = 'Sửa lĩnh vực';
  static const areaNoProjects = 'Chưa có dự án nào trong lĩnh vực này.';
  static const reviewPrefillFromProjects = 'Nạp sẵn từ dự án đang mở';
  static const reviewPrefillHint =
      'Chép tên dự án thành mục đánh giá. Sửa tên dự án sau này không làm đổi đợt đã lưu.';
  static const resourcesAll = 'Tất cả';
  static const resourcesUnattached = 'Chưa xếp chỗ';
  static const resourcesEmpty = 'Chưa có tư liệu nào.';
  static const resourcesFromProject = 'Thuộc dự án';
  static const resourcesFromArea = 'Thuộc lĩnh vực';
  static const resourcesLoose = 'Chưa gắn vào đâu';
  static String resourcesCount(int notes, int links) =>
      '$notes ghi chú · $links liên kết';

  static const searchNoResult = 'Không tìm thấy kết quả nào.';

  static String searchKind(SearchKind kind) => switch (kind) {
        SearchKind.project => 'Dự án',
        SearchKind.action => 'Hành động',
        SearchKind.note => 'Ghi chú',
        SearchKind.link => 'Liên kết',
        SearchKind.review => 'Đánh giá',
      };

  // Đợt đánh giá
  static const reviews = 'Đánh giá';
  static const reviewNew = 'Đợt đánh giá mới';
  static const reviewDate = 'Ngày đánh giá';
  static const reviewTitle = 'Tiêu đề';
  static const reviewSummary = 'Tổng kết';
  static const reviewNextDate = 'Ngày xem lại tiếp theo';
  static const reviewNoNextDate = 'Chưa đặt mốc xem lại';
  static const reviewEmpty = 'Chưa có đợt đánh giá nào.';
  static const reviewFirst = 'Tạo đợt đánh giá đầu tiên';
  static const reviewItems = 'Các mục đánh giá';
  static const reviewItemNew = 'Thêm mục';
  static const reviewItemLabel = 'Nội dung';
  static const reviewItemNote = 'Ghi chú';
  static const reviewItemEmpty = 'Chưa có mục nào.';
  static const reviewCarryForward = 'Chép các mục chưa đạt từ đợt trước';
  static const reviewCarryForwardHint =
      'Bỏ chọn mục không muốn theo dõi tiếp. Mục đã đạt không được chép.';
  static const reviewDue = 'đến hạn xem lại';

  static String reviewMetRatio(int met, int total) => '$met/$total đạt';

  static String reviewVerdict(ReviewVerdict v) => switch (v) {
        ReviewVerdict.met => 'Đạt',
        ReviewVerdict.partial => 'Một phần',
        ReviewVerdict.notMet => 'Chưa đạt',
      };

  // Onboarding
  static const onboardingTitle = 'Bắt đầu từ dữ liệu có sẵn';
  static const onboardingBody =
      'Bảy dự án, các hành động, ghi chú và mục tiêu trong hai file HÀNH ĐỘNG '
      'và Ý TƯỞNG đã sẵn sàng để nạp vào ứng dụng.';
  static const onboardingSeed = 'Nạp dữ liệu có sẵn';
  static const onboardingSkip = 'Bắt đầu từ trống';

  // Cài đặt
  static const settingsStaleDays = 'Số ngày coi là dự án nguội';
  static const settingsTheme = 'Giao diện';
  static const settingsThemeSystem = 'Theo hệ thống';
  static const settingsThemeLight = 'Sáng';
  static const settingsThemeDark = 'Tối';
  static const settingsReseed = 'Nạp lại dữ liệu có sẵn';
  static const settingsReseedDone = 'Đã nạp xong, không tạo bản ghi trùng';

  // Sao lưu và khôi phục
  static const backupSection = 'Dữ liệu';
  static const backupExport = 'Xuất bản sao lưu';
  static const backupExportHint =
      'Một file JSON chứa toàn bộ dữ liệu. Tự giữ file này để chuyển máy.';
  static const backupImport = 'Nhập từ bản sao lưu';
  static const backupImportHint = 'Thay thế toàn bộ dữ liệu hiện tại.';
  static const backupImportTitle = 'Thay thế toàn bộ dữ liệu?';
  static const backupImportConfirm =
      'Toàn bộ dữ liệu hiện tại trong máy sẽ bị thay bằng nội dung file sao lưu. '
      'Thao tác này không hoàn tác được.\n\n'
      'Nếu chưa chắc, hãy xuất một bản sao lưu trước.';
  static const backupImportReplace = 'Thay thế';
  static const backupNoFile = 'Chưa chọn file nào';
  static const backupWipe = 'Xoá sạch dữ liệu';
  static const backupWipeStep1 =
      'Xoá toàn bộ dự án, hành động, mục tiêu, ghi chú và đợt đánh giá. '
      'Nên xuất một bản sao lưu trước.';
  static const backupWipeStep2 =
      'Bước cuối: xác nhận lần nữa để xoá sạch. Không có đường khôi phục nếu '
      'chưa xuất sao lưu.';
  static const backupWipeConfirm = 'Xoá sạch';
  static const backupWipeDone = 'Đã xoá sạch dữ liệu';

  static String backupExported(String fileName) => 'Đã xuất $fileName';
  static String backupImported(int count) => 'Đã khôi phục $count bản ghi';
  static String backupFailed(String reason) => 'Không nhập được: $reason';

  static String backupFailureReason(FailureCode code) => switch (code) {
        FailureCode.malformedBackup => 'file sai định dạng hoặc thiếu dữ liệu',
        FailureCode.backupTooNew =>
          'file thuộc phiên bản mới hơn, cần cập nhật ứng dụng',
        _ => 'lỗi khi ghi dữ liệu',
      };
  static const settingsStaleRange = 'Nhận giá trị từ 7 đến 180';

  static String days(int value) => '$value ngày';

  // Nhãn enum
  static String projectStatus(ProjectStatus s) => switch (s) {
        ProjectStatus.notStarted => 'Chưa bắt đầu',
        ProjectStatus.active => 'Đang làm',
        ProjectStatus.paused => 'Tạm dừng',
        ProjectStatus.done => 'Xong',
        ProjectStatus.dropped => 'Bỏ',
      };

  static String actionStatus(ActionStatus s) => switch (s) {
        ActionStatus.todo => 'Chưa',
        ActionStatus.doing => 'Đang làm',
        ActionStatus.done => 'Xong',
        ActionStatus.dropped => 'Bỏ',
      };

  static String priority(Priority p) => switch (p) {
        Priority.high => 'Cao',
        Priority.medium => 'Trung bình',
        Priority.low => 'Thấp',
      };
}
