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
  static const tabGoals = 'Mục tiêu';
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
  static const todayOverdue = 'Quá hạn';
  static const todayDoing = 'Đang làm';
  static const todayDueSoon = 'Đến hạn trong 7 ngày';
  static const todayAttention = 'Cần chú ý';
  static const todayAllClear = 'Không có gì cần chú ý hôm nay.';
  static const todayGoToProjects = 'Xem danh sách dự án';
  static const staleProject = 'không hoạt động';
  static const goalBehindPace = 'đang chậm nhịp';

  // Dự án
  static const projectNew = 'Dự án mới';
  static const projectName = 'Tên dự án';
  static const projectDescription = 'Mô tả';
  static const projectTopic = 'Chủ đề';
  static const projectPriority = 'Độ ưu tiên';
  static const projectStatusLabel = 'Trạng thái';
  static const projectDueDate = 'Hạn chót';
  static const projectNoDueDate = 'Không đặt hạn';
  static const projectNameRequired = 'Tên dự án không được để trống';
  static const projectEmptyList = 'Chưa có dự án nào.';
  static const projectHistory = 'Lịch sử trạng thái';
  static const projectLinkedGoals = 'Mục tiêu đã nối';
  static const projectNotes = 'Ghi chú';
  static const projectLinks = 'Liên kết';
  static const projectShowClosed = 'Hiện dự án đã đóng';
  static const projectFilter = 'Lọc';
  static const projectSort = 'Sắp xếp';

  static const sortPriority = 'Độ ưu tiên';
  static const sortLastActivity = 'Hoạt động gần nhất';
  static const sortName = 'Tên';
  static const sortDueDate = 'Hạn chót';

  /// FR-7: hộp xác nhận phải nêu rõ những gì sẽ mất theo.
  static String projectDeleteConfirm(int actions, int notes, int links) =>
      'Xoá dự án này sẽ xoá theo $actions hành động, $notes ghi chú và '
      '$links liên kết. Mục tiêu đã nối không bị xoá.\n\n'
      'Nếu chỉ muốn dừng lại, hãy chuyển trạng thái sang "Bỏ".';
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

  // Mục tiêu
  static const goalNew = 'Mục tiêu mới';
  static const goalName = 'Tên mục tiêu';
  static const goalNumeric = 'Mục tiêu có số';
  static const goalQualitative = 'Mục tiêu định tính';
  static const goalTarget = 'Giá trị đích';
  static const goalUnit = 'Đơn vị';
  static const goalDueDate = 'Hạn chót';
  static const goalEmptyList = 'Chưa có mục tiêu nào.';
  static const goalNoProjects = 'Chưa có dự án nào phục vụ mục tiêu này';
  static const goalMarks = 'Mốc tiến độ';
  static const goalMarkNew = 'Thêm mốc';
  static const goalMarkValue = 'Giá trị';
  static const goalMarkDate = 'Ngày';
  static const goalMarkNote = 'Ghi chú';
  static const goalNeedTwoMarks = 'Cần ít nhất hai mốc để vẽ biểu đồ.';
  static const goalNoMarks = 'Chưa có mốc nào.';
  static const goalRemaining = 'Còn thiếu';
  static const goalDaysLeft = 'Thời gian còn lại';
  static const goalRequiredPerMonth = 'Cần thêm mỗi tháng';
  static const goalActualPerMonth = 'Nhịp hiện tại';
  static const goalNoDueDateHint =
      'Chưa đặt hạn chót nên chưa tính được nhịp và dự báo.';
  static const goalTargetRequired = 'Giá trị đích không hợp lệ';

  static String goalDaysLeftValue(int days) => '$days ngày';
  static String goalForecastLate(int months) => 'Nhịp hiện tại về đích chậm $months tháng';
  static String goalForecastEarly(int months) => 'Nhịp hiện tại về đích sớm $months tháng';
  static const goalForecastOnTime = 'Nhịp hiện tại vừa đủ về đích đúng hạn';
  static const goalGoingBackwards = 'Giá trị đang đi lùi';
  static const goalReached = 'Đã đạt đích';
  static const goalPastDue = 'Đã qua hạn chót mà chưa đạt đích';

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

  static const searchNoResult = 'Không tìm thấy kết quả nào.';

  static String searchKind(SearchKind kind) => switch (kind) {
        SearchKind.project => 'Dự án',
        SearchKind.action => 'Hành động',
        SearchKind.goal => 'Mục tiêu',
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
