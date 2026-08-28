---
title: "Addendum — App Quản lý Dự án & Mục tiêu Cá nhân"
created: 2026-08-28
updated: 2026-08-28
role: "Chi tiết người dùng cung cấp, dành cho PRD và Architecture đọc lại. Không lặp lại nội dung brief."
---

# Addendum

## 1. Dữ liệu hạt giống — trích nguyên văn từ hai file nguồn

Đây là nội dung thật sẽ được nạp vào app ở lần chạy đầu (seed). Giữ nguyên chữ của người dùng, kể cả lỗi chính tả, để đối chiếu sau này.

### 1.1 Bảy dự án (`Ý TƯỞNG.pdf`)

| # | Tên nguyên văn | Chủ đề suy ra | Ghi chú |
|---|---|---|---|
| 1 | học tiếng a của con | Gia đình | Con — tiếng Anh |
| 2 | học toán của con | Gia đình | Con — toán tư duy |
| 3 | dạy Huy | Gia đình | Chưa rõ nội dung |
| 4 | kênh Tiktok, youtybe tiếp thị liên kết | Thu nhập | Nối vào mục tiêu dòng tiền |
| 5 | kế hoạch tài chính | Tài chính | Số liệu nằm ở app `personal_finance` |
| 6 | viết app đẩy store kiếm thu nhập | Thu nhập | Nối vào mục tiêu dòng tiền |
| 7 | kiểm soát sức khoẻ bản thân | Sức khoẻ | — |

### 1.2 Hành động kèm trạng thái (`HÀNH ĐỘNG.pdf`)

Thuộc dự án **Kế hoạch tài chính**, dưới nhóm *"Giai đoạn thắt lưng buộc bụng — tập trung mua tài sản"*:

| Hành động | Trạng thái nguyên văn | Ánh xạ |
|---|---|---|
| Chỉ mua 1 màn hình phục vụ công việc | Xong | `done` |
| Sắp xếp lại góc làm việc riêng — Tầng 1 | Xong | `done` |
| Dồn tiền mua máy rửa bát | Chưa | `todo` |
| Sắp xếp lại thời gian làm việc ở cty và cho cá nhân | Đang làm | `doing` |
| Cân nhắc vay đầu tư với số vốn hợp lý khi cảm thấy có cơ hội đến | (không ghi) | `todo` |
| Cân bằng danh mục đầu tư | Đã có ứng dụng tự làm | `done` — chính là app `personal_finance` |

Các dòng còn lại mang tính định hướng, thuộc về **ghi chú dự án** chứ không phải hành động rời:

- *"Ưu tiên số 1 tạo ra dòng tiền, thu nhập thụ động ngoài làm thuê: app và afilate Tiktok, YouTube"*
- *"TÌM THÊM 1 NGUỒN THU NHẬP KHÁC"*
- *"Làm ứng dụng de finace, ứng dụng tài chính đẩy lên store"*
- *"Tích usdt gửi về ví và tiền mặt đợi thời"*
- *"HƯỚNG VỀ GĐ vợ con"*

### 1.3 Mục tiêu

- **`Mục tiêu: 1 tỷ`** — giá trị đích 1.000.000.000, đơn vị VND. Không có hạn chót trong tài liệu, không có điểm xuất phát ghi lại. Ý nghĩa chính xác chưa xác nhận (xem `Rủi ro và ẩn số` trong brief).
- **`TÌM THÊM 1 NGUỒN THU NHẬP KHÁC`** — mục tiêu định tính, không có con số. Cho thấy mô hình dữ liệu mục tiêu phải chấp nhận **cả loại có số lẫn loại không số**.

### 1.4 Ghi chú kiến thức — giữ nguyên, gắn vào dự án Kế hoạch tài chính

Toàn bộ phần `1. Nợ tốt (Good Debt)` và `3. Khi nào nên vay nợ?` là kiến thức tự tổng hợp, dài khoảng một trang. Cùng nhóm với các nguyên tắc thị trường:

- *"Bài học về sự kiên nhẫn chờ tín hiệu rõ ràng, vội vàng hấp tấp là sai lầm"*
- *"Cái khiến mình giàu có chỉ có tài sản tích luỹ là trong Bear market"*
- *"Tích usdt, tiền mặt đợi RSI tuần BTC và chứng khoán chạm đáy"*
- *"Đánh ít đợi thời đánh cú lớn"*
- *"Khi nghèo hãy sống như người giàu, và khi giàu hãy sống như người nghèo"*
- *"Đầu tư như là không đầu tư — tận dụng thời gian, tận dụng lãi kép, tắt hết bảng điện"*

**Hệ quả cho PRD:** ghi chú phải là bản ghi riêng có tiêu đề và nội dung dài (markdown), không phải một trường `notes` một dòng nhét trong dự án.

### 1.5 Liên kết ngoài cần giữ

| Link | Thuộc dự án |
|---|---|
| `https://docs.google.com/spreadsheets/d/1yt51gsccuOJ53uD9Nt9HIxAIwOOTx81a/edit?gid=1374568313` — *Cơ cấu và quản trị rủi ro tài chính.xlsx* | Kế hoạch tài chính |
| `https://appbox.me/zfy7b1yh` | Kênh TikTok/YouTube tiếp thị liên kết |
| `https://appbox.me/grjhi4i5` | Kênh TikTok/YouTube tiếp thị liên kết |
| `https://appbox.me/r068qu7f` | Kênh TikTok/YouTube tiếp thị liên kết |

### 1.6 Sáu thói quen — **roadmap, không vào MVP**

`1. tiết kiệm` · `2. thể dục` · `3. ngủ sớm đúng giờ` · `4. đúng giờ, đúng hẹn` · `5. ở 1 mình` · `6. đọc sách`
Kèm câu định hướng: *"Đi tìm bình yên trong nội tâm, nhẹ nhàng lắng đọng yêu và hiểu cho chính mình"*.

### 1.7 Đối tượng / ý tưởng kinh doanh — thuộc ghi chú dự án số 4

*"Đối tượng kiếm tiền: Phụ nữ, trẻ em, gđ có điều kiện sẵn sàng chi tiền"* · *"Kênh tiktok chủ đề phương pháp tự học toán tư duy và tiếng anh kết hợp với AI miễn phí; sản phẩm liên kết là sách và một số nguồn tài liệu hoặc app của mình phát triển"* · *"AI tạo nội dung video đăng Tiktok tăng follow"*.

## 2. Ràng buộc kỹ thuật kế thừa từ `personal_finance`

Những ràng buộc dưới đây **đã trả giá bằng lỗi thật** trong dự án trước. Chúng không phải sở thích — đưa vào đây để Architect không phải phát hiện lại.

### 2.1 Ngăn xếp bị khoá phiên bản

| Thành phần | Phiên bản | Lý do khoá |
|---|---|---|
| Flutter SDK | 3.38.10 / Dart 3.10.9, qua **FVM** | Máy còn bản 3.29.2 dùng chung cho các dự án eGOV. Chạy `flutter` trần sẽ giải phụ thuộc thất bại |
| `flutter_riverpod` | ^3.3.2, **không dùng codegen** | `riverpod_generator` cần `analyzer ^9/^12`, `drift_dev` cần `^10/^13` — loại trừ nhau. Provider khai báo tay dạng biến `final` cấp cao nhất |
| `drift_flutter` | **0.2.x**, không lên 0.3.x | 0.3.x kéo `sqlite3` 3.x dùng build hooks → `build_runner` chết → mất tầng dữ liệu |
| `path_provider_foundation` | ghim đè **2.5.1** | 2.6.0 kéo `objective_c` dùng build hooks — cùng hậu quả |
| AGP / Kotlin / Gradle | 8.11.1 / 2.2.20 / 8.14 | Bản Flutter template sinh ra quá cũ để biên dịch `share_plus 13.x` |

Lỗi đặc trưng khi vi phạm: `'dart compile' does not support build hooks, use 'dart build' instead.`

**Quy tắc trước khi thêm bất kỳ gói mới nào:**
```bash
ls ~/.pub-cache/hosted/pub.dev/<tên>-<phiên bản>/hook 2>/dev/null
```
Có thư mục `hook/` → không dùng gói đó.

### 2.2 Nguyên tắc kiến trúc mang sang

- **Hướng phụ thuộc một chiều:** `presentation → domain ← data`. File trong `domain/` không `import` `package:flutter`, `package:drift`, cũng không import từ `data/` hay `presentation/`.
- **Giá trị tổng hợp luôn suy ra, không lưu cứng.** Ở dự án trước là vốn góp lũy kế; ở đây là **tiến độ mục tiêu** và **tỷ lệ hoàn thành dự án**. Cấm tạo cột `currentValue` trên bảng `Goal` và cột `completionPercent` trên bảng `Project`.
- **Không `double` cho số tiền.** Mục tiêu tài chính (1 tỷ VND) lưu `int` đơn vị đồng; nếu cần nhân chia thì qua `Decimal`. `double` chỉ được phép ở toạ độ vẽ biểu đồ trong `presentation/`.
- **Chuỗi hiển thị qua lớp l10n**, không viết thẳng tiếng Việt trong widget.
- **Đổi schema DB** phải đủ bốn bước: dump schema → sinh helper test → viết `onUpgrade` → viết test `migrateAndValidate`.

### 2.3 Khác biệt so với dự án trước

- **Không có tầng `data/remote/`.** App này không gọi mạng, điểm. Không có gì để hỏi giá.
- **Không cần `fl_chart`?** Có — mục tiêu cần biểu đồ đường tiến độ. Giữ `fl_chart ^1.2.0`.
- **Cần `share_plus`** để xuất file sao lưu JSON, và `file_picker` hoặc tương đương để nhập lại. [GIẢ ĐỊNH] Cần kiểm tra `file_picker` có build hooks không trước khi chốt; phương án dự phòng là nhập bằng dán nội dung JSON vào ô văn bản.

## 3. Phương án đã cân nhắc và loại

| Phương án | Vì sao loại |
|---|---|
| Gộp thành module trong `personal_finance` | Người dùng chọn app riêng. Ngoài ra hai sản phẩm có nhịp dùng khác hẳn: app kia mở khi thị trường động, app này mở hằng ngày. Trộn vào nhau làm cả hai mờ trọng tâm |
| Đồng bộ đám mây / có tài khoản | Nội dung gồm mục tiêu tài chính thật, tên người thật, kế hoạch gia đình. Chi phí bảo mật không xứng với lợi ích đa thiết bị của một người dùng |
| Đưa Ngân hàng ý tưởng vào MVP | Người dùng không chọn. Ghi chú trong dự án tạm thay được. Là hạng mục roadmap ưu tiên cao nhất |
| Đưa Thói quen hằng ngày vào MVP | Mô hình dữ liệu khác hẳn (lặp theo ngày, không có trạng thái "xong" vĩnh viễn). Nhét chung vào bảng `Action` sẽ làm hỏng ngữ nghĩa trạng thái |
| Dùng Notion / Todoist thay vì tự viết | Cần mạng, dữ liệu ra server ngoài, và không có mô hình mục tiêu-gốc. Ngoài ra chính việc viết app này là **dự án số 6** trong danh sách của người dùng |
