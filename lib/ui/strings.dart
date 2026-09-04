/// Mọi chuỗi hiển thị của app (AD-10).
///
/// Từ vựng phải khớp §3 Từ điển của PRD. Không dùng từ đồng nghĩa: đã là
/// *Quá bán* thì ở đâu cũng là *Quá bán*, không có "bán quá mức" hay "oversold".
class S {
  const S._();

  // Điều hướng
  static const appTitle = 'RSI Alert';
  static const tabOverview = 'Tổng quan';
  static const tabChart = 'Biểu đồ';
  static const tabHistory = 'Lịch sử';

  // Trạng thái RSI — §3 Từ điển
  static const statusOversold = 'Quá bán';
  static const statusNeutral = 'Trung tính';
  static const statusOverbought = 'Quá mua';
  static const statusInsufficient = 'Chưa đủ dữ liệu';

  // Thẻ Mã
  static const rsiWeekly = 'RSI tuần';
  static const provisional = 'tạm tính';
  static const provisionalHint =
      'Tuần chưa kết thúc — giá trị này còn thay đổi và không sinh tín hiệu.';

  // Cảnh báo
  static const signalOversoldTitle = 'Quá bán';
  static const signalOverboughtTitle = 'Quá mua';
  static const tapToView = 'Chạm để xem biểu đồ';

  // Trạng thái dữ liệu
  static const loading = 'Đang tải…';
  static const retry = 'Thử lại';
  static const noDataTitle = 'Chưa có dữ liệu';
  static const noDataBody =
      'Chưa tải được lần nào. Kiểm tra kết nối rồi thử lại.';
  static const offlineNote = 'chưa cập nhật được';

  // Lịch sử
  static const historyTitle = 'Lịch sử tín hiệu';
  static const filterAll = 'Tất cả';
  static const emptyHistoryTitle = 'Chưa có tín hiệu nào';
  static const emptyHistoryBody =
      'Tín hiệu RSI tuần vốn hiếm — có thể vài tháng liền không xảy ra lần '
      'nào. Đây không phải lỗi.';

  // Biểu đồ
  static const runningWeek = 'Tuần đang chạy';
  static const chartOpen = 'Mở';
  static const chartHigh = 'Cao';
  static const chartLow = 'Thấp';
  static const chartClose = 'Đóng';
  static const chartRsi = 'RSI';

  static String updatedAt(String formatted) => 'Dữ liệu lúc $formatted';

  static String weekOf(String formatted) => 'tuần $formatted';

  static String sourceNote(String source) => 'Nguồn: $source';

  static String errorNote(String kind) => switch (kind) {
        'network' => 'Không kết nối được tới nguồn dữ liệu.',
        'http' => 'Nguồn dữ liệu từ chối yêu cầu.',
        'parse' => 'Nguồn dữ liệu trả về nội dung lạ.',
        'empty' => 'Nguồn dữ liệu không có nến nào.',
        _ => 'Không lấy được dữ liệu mới.',
      };
}
