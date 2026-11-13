/// Hằng số của phương pháp RSI — nguồn duy nhất trong toàn app (AD-11).
///
/// Cấm literal 14 / 30 / 70 ở mọi nơi khác trong ngữ cảnh RSI. Khi v2 mở
/// ngưỡng tự đặt, chỉ file này đổi thành đối tượng cấu hình đọc từ kho.
library;

/// Chu kỳ RSI theo phương pháp Wilder.
const int rsiPeriod = 14;

/// Dưới ngưỡng này là Quá bán.
const double oversoldThreshold = 30;

/// Trên ngưỡng này là Quá mua.
const double overboughtThreshold = 70;

/// Số nến tối thiểu để có được giá trị RSI đầu tiên.
const int minCandlesForRsi = rsiPeriod + 1;

// ---------------------------------------------------------------------------
// Vùng DCA theo Cẩm nang của người dùng (FR-14 → FR-18, AD-12).
//
// Ranh giới đọc theo kiểu "≤": RSI đóng tuần ≤ [strongBuyMax] là Vùng 1,
// ≤ [probeBuyMax] là Vùng 2, ≤ [holdMax] là Vùng 3, ≤ [probeSellMax] là
// Vùng 4, còn lại là Vùng 5. Khớp bảng "35.1 – 45.0" của Cẩm nang.
// ---------------------------------------------------------------------------

/// Bốn ranh giới chia RSI tuần thành năm Vùng DCA.
class DcaThresholds {
  const DcaThresholds({
    required this.strongBuyMax,
    required this.probeBuyMax,
    required this.holdMax,
    required this.probeSellMax,
  });

  final double strongBuyMax;
  final double probeBuyMax;
  final double holdMax;
  final double probeSellMax;
}

/// BTC — Cẩm nang trang 2–3: 35 / 45 / 70 / 82.
const btcDcaThresholds = DcaThresholds(
  strongBuyMax: 35,
  probeBuyMax: 45,
  holdMax: 70,
  probeSellMax: 82,
);

/// VNINDEX — bảng riêng trong "Dữ liệu lịch sử các chu kỳ": 32 / 40 / 68 / 76.
/// Đã kiểm chứng trên dữ liệu SSI 2007–2026: với ngưỡng của BTC, VNINDEX chỉ
/// vượt 82 trong 14 tuần suốt 19 năm nên Vùng 5 gần như không bao giờ bật.
const vnindexDcaThresholds = DcaThresholds(
  strongBuyMax: 32,
  probeBuyMax: 40,
  holdMax: 68,
  probeSellMax: 76,
);

/// Fear & Greed crypto: từ mức này trở xuống là "Sợ hãi cực độ" (Cẩm nang
/// trang 1, cột Crypto: 0–24).
const int fearGreedExtremeFearMax = 24;

/// Fear & Greed crypto: "Sợ hãi" tới mức này (25–42).
const int fearGreedFearMax = 42;

/// Fear & Greed crypto: "Trung tính" tới mức này (43–70).
const int fearGreedNeutralMax = 70;

/// Fear & Greed crypto: "Tham lam" tới mức này (71–82).
const int fearGreedGreedMax = 82;

/// Fear & Greed crypto: từ mức này trở lên là "Tham lam cực độ" (83–100).
const int fearGreedExtremeGreedMin = 83;

/// Phân kỳ giảm: tìm đỉnh giá và đỉnh RSI trước trong cửa sổ này (tuần đã
/// đóng). 104 tuần vì đỉnh RSI nóng của BTC 3/2024 cách đỉnh giá 10/2025 tới
/// 82 tuần — cửa sổ 52 tuần bỏ sót.
const int divergenceLookbackWeeks = 104;

/// Số tuần nhìn về sau khi tính thống kê lịch sử của một Vùng (FR-18).
const int zoneStatsHorizonWeeks = 52;
