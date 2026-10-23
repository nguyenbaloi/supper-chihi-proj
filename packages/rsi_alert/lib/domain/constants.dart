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
