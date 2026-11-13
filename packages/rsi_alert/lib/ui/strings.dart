import '../domain/dca.dart';
import '../domain/fear_greed.dart';
import '../domain/market_symbol.dart';

/// Mọi chuỗi hiển thị của app (AD-10).
///
/// Từ vựng phải khớp §3 Từ điển của PRD. Không dùng từ đồng nghĩa: đã là
/// *Quá bán* thì ở đâu cũng là *Quá bán*, không có "bán quá mức" hay "oversold".
class S {
  const S._();

  // Điều hướng
  static const appTitle = 'Chichi RSI';
  static const tabOverview = 'Tổng quan';
  static const tabChart = 'Biểu đồ';
  static const tabHistory = 'Lịch sử';

  // Trạng thái RSI — §3 Từ điển
  static const statusOversold = 'Quá bán';
  static const statusNeutral = 'Trung tính';
  static const statusOverbought = 'Quá mua';
  static const statusInsufficient = 'Chưa đủ dữ liệu';

  // Cấu hình giao diện
  static const themeTitle = 'Chế độ giao diện';
  static const themeSystem = 'Theo hệ thống';
  static const themeLight = 'Sáng';
  static const themeDark = 'Tối';

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

  // ---------------------------------------------------------------------------
  // Vùng DCA (FR-14 → FR-19).
  //
  // App KHÔNG tự khuyên (PRD §5). Mọi câu hành động dưới đây là luật người dùng
  // tự viết trong Cẩm nang, luôn hiện kèm tiền tố [dcaQuotePrefix].
  // ---------------------------------------------------------------------------
  static const dcaSection = 'Vùng DCA';
  static const dcaGuideTitle = 'Cẩm nang DCA của bạn';
  static const dcaQuotePrefix = 'Theo cẩm nang của bạn: ';
  static const dcaGuideOpen = 'Xem cẩm nang';
  static const dcaClosedWeekNote =
      'Xếp theo RSI tuần của nến đã đóng gần nhất. Tuần đang chạy không sinh cảnh báo.';
  static const dcaDisclaimer =
      'Ngưỡng và tỷ trọng lấy nguyên từ cẩm nang bạn tự soạn. App chỉ xếp vùng '
      'và trích lại luật của bạn — quyết định là của bạn.';
  static const dcaFearGreedNoteBtc =
      'F&G chỉ dùng để tăng cường, không chặn vùng: đáy BTC 11/2022 có F&G 22–26, '
      'cổng "F&G < 20" sẽ bỏ lỡ đúng đáy đó.';
  static const dcaFearGreedNoteVn =
      'Không có nguồn F&G công khai cho VNINDEX — vùng chỉ xếp bằng RSI tuần.';
  static const dcaFearGreedConfirms = 'F&G cực độ cùng chiều';
  static const dcaDivergenceName = 'Phân kỳ giảm tuần';
  static const dcaDivergenceCondition =
      'Giá đóng tuần lập đỉnh mới trong 2 năm, nhưng RSI thấp hơn đỉnh RSI nóng '
      'trước đó (đã vào Vùng 5), và giữa hai đỉnh RSI đã lùi về vùng Nắm giữ.';
  static const dcaDivergenceRule =
      'Xả nốt phần còn lại: chốt 15–20% phần hàng cuối (hoặc giữ tối đa 5–10% '
      'làm vị thế cốt lõi), chuyển sang tiền mặt và chờ RSI tuần về dưới 40.';
  static const dcaStatsTitle = 'Lịch sử trên dữ liệu đang có';
  static const dcaStatsNone = 'chưa đủ 52 tuần dữ liệu phía sau để đo';
  static const reminderTitle = 'Nến tuần đã đóng';
  static const reminderBody =
      'Mở Chichi RSI để xem BTC và VNINDEX đang ở vùng nào trong cẩm nang DCA của bạn.';
  static const reminderChannel = 'Nến tuần đã đóng';
  static const reminderChannelDescription =
      'Nhắc sáng thứ Hai sau khi nến tuần BTC và VNINDEX đóng';

  static String dcaZoneName(DcaZone zone) => switch (zone) {
        DcaZone.strongBuy => 'Vùng 1 · Gom mạnh',
        DcaZone.probeBuy => 'Vùng 2 · Gom thăm dò',
        DcaZone.hold => 'Vùng 3 · Nắm giữ',
        DcaZone.probeSell => 'Vùng 4 · Chốt thăm dò',
        DcaZone.strongSell => 'Vùng 5 · Xả hàng',
      };

  /// Luật của từng Vùng, trích từ Cẩm nang. BTC theo trang 2–3; VNINDEX theo
  /// bảng "Công thức chung DCA VN-Index theo 5 vùng RSI tuần".
  static String dcaRule(MarketSymbol symbol, DcaZone zone) => switch ((symbol, zone)) {
        (MarketSymbol.btc, DcaZone.strongBuy) =>
          'gom tổng lực 70–80% tổng vốn, chia đều 4–8 tuần, giải ngân đều bất chấp tin xấu.',
        (MarketSymbol.btc, DcaZone.probeBuy) =>
          'gom thăm dò 20–30% tổng vốn, chia đều 2–3 tuần để mở vị thế nền.',
        (MarketSymbol.btc, DcaZone.hold) =>
          'nắm giữ — không mua đuổi, không bán tháo, để lãi chạy.',
        (MarketSymbol.btc, DcaZone.probeSell) =>
          'chốt lời thăm dò — bán rải 20–25% danh mục đang giữ.',
        (MarketSymbol.btc, DcaZone.strongSell) =>
          'xả hàng — bán 60–75% phần còn lại, rải 15–20% mỗi tuần.',
        (MarketSymbol.vnindex, DcaZone.strongBuy) =>
          'mua gom mạnh 70–80% vốn, chia đều 4–6 tuần.',
        (MarketSymbol.vnindex, DcaZone.probeBuy) =>
          'mua thăm dò 20–30% vốn, chia 2–3 tuần.',
        (MarketSymbol.vnindex, DcaZone.hold) =>
          'nắm giữ — ngừng mua đuổi, giữ nguyên danh mục.',
        (MarketSymbol.vnindex, DcaZone.probeSell) =>
          'chốt lời thăm dò — bán 25–30% danh mục đang giữ.',
        (MarketSymbol.vnindex, DcaZone.strongSell) =>
          'xả hàng — bán 60–70% phần còn lại, chia 3–4 tuần.',
      };

  static String dcaWeeksInZone(int weeks) => 'tuần thứ $weeks liên tiếp';

  static String dcaProvisional(DcaZone zone) =>
      'Tuần đang chạy ($provisional): ${dcaZoneName(zone)}';

  static String fearGreedLevel(FearGreedLevel level) => switch (level) {
        FearGreedLevel.extremeFear => 'Sợ hãi cực độ',
        FearGreedLevel.fear => 'Sợ hãi',
        FearGreedLevel.neutral => 'Trung tính',
        FearGreedLevel.greed => 'Tham lam',
        FearGreedLevel.extremeGreed => 'Tham lam cực độ',
      };

  static String fearGreed(int value) =>
      'F&G $value · ${fearGreedLevel(FearGreedLevel.of(value))}';

  static String fearGreedToday(int value) => '${fearGreed(value)} (hôm nay)';

  static String rangeAtMost(String v) => 'RSI ≤ $v';
  static String rangeBetween(String lo, String hi) => 'RSI $lo – $hi';
  static String rangeAbove(String v) => 'RSI > $v';

  static String dcaStats(int weeks, double median, double positive) =>
      '$weeks tuần · 52 tuần sau: trung vị ${median >= 0 ? '+' : ''}'
      '${median.toStringAsFixed(0)}%, ${positive.toStringAsFixed(0)}% cao hơn';

  static String dcaStatsFew(int weeks) => '$weeks tuần · $dcaStatsNone';
}
