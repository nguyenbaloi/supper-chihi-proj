---
title: "Phân rã Epic và Story — App Quản lý Dự án & Mục tiêu Cá nhân"
status: draft
created: 2026-08-28
updated: 2026-08-28
---

# App Quản lý Dự án & Mục tiêu Cá nhân — Phân rã Epic và Story

## Tổng quan

**6 Epic · 33 Story · phủ hết FR-1…FR-34 và NFR-1…NFR-8.**

Thứ tự Epic là thứ tự triển khai. Mỗi Epic kết thúc ở một trạng thái **dùng được thật**, không phải một tầng kỹ thuật xong dở. Epic 1 kết thúc là app chạy được và hiện danh sách Dự án rỗng; Epic 2 kết thúc là app đã thay thế được file `HÀNH ĐỘNG.pdf`.

## Sửa hướng 2026-08-28 sau kiểm thử tay

Người dùng gửi bảy điểm phản hồi. **Epic 3 (Mục tiêu và tiến độ) bị huỷ hoàn
toàn** — tính năng và dữ liệu đều bỏ. Thêm **Epic 8** cho năm yêu cầu mới
FR-41…FR-45. Chi tiết ở đầu PRD.

| Epic | Trạng thái sau sửa hướng |
|---|---|
| 3. Mục tiêu và tiến độ | **HUỶ** — bỏ cả mã nguồn lẫn dữ liệu |
| 8. Sửa hướng sau kiểm thử tay | **Xong** — 5/5 story |

Epic 8 gồm: độ ưu tiên cho Hành động (FR-41), danh sách Làm ngay do người dùng
tự ghim (FR-42), khối cảnh báo tách biệt (FR-43), thống kê theo hạn (FR-44),
danh sách Dự án nhóm theo Chủ đề kèm thanh điều hướng mới (FR-45).

Schema lên phiên bản 3: thêm `actions.priority`, `actions.pinned`,
`actions.pinned_at`; bỏ ba bảng `goals`, `goal_updates`, `project_goals`. Có
test nâng cấp thẳng từ v1 lên v3.

## Tình trạng triển khai — cập nhật 2026-08-28

| Epic | Trạng thái |
|---|---|
| 1. Nền tảng dữ liệu và bộ khung | **Xong** — 7/7 story |
| 2. Dự án và Hành động | **Xong** — 8/8 story |
| 3. Mục tiêu và tiến độ | **Xong** — 6/6 story |
| 4. Hôm nay và tìm kiếm | Gần xong — 4.1, 4.2, 4.3 xong; 4.4 (đo hiệu năng có số liệu) chưa làm |
| 5. Ghi chú, Liên kết, hạt giống | **Xong** — 4/4 story |
| 6. Sao lưu và hoàn thiện | **Xong** — 4/4 story |
| 7. Đợt đánh giá định kỳ | **Xong** — 6/6 story |

Kiểm chứng sau sửa hướng: `fvm flutter analyze` sạch, **131 test xanh**,
`flutter build apk` và `flutter build ios` đều thành công.

Khoảng trống đã biết: test widget cấp ứng dụng bị bỏ vì drift chạy I/O thật nên
treo trong vùng thời gian giả của `testWidgets`. Hành vi tương ứng được test
repository phủ.

## Bảng độ phủ yêu cầu

| Epic | FR được phủ |
|---|---|
| 1. Nền tảng dữ liệu và bộ khung | FR-1, FR-34, NFR-3…NFR-6, NFR-8 |
| 2. Dự án và Hành động | FR-5…FR-19 |
| 3. Mục tiêu và tiến độ | FR-20…FR-26 |
| 4. Hôm nay và tìm kiếm | FR-29, FR-30, NFR-1, NFR-2 |
| 5. Ghi chú, Liên kết, hạt giống | FR-2, FR-3, FR-4, FR-27, FR-28 |
| 6. Sao lưu và hoàn thiện | FR-31, FR-32, FR-33, NFR-7 |
| 7. Đợt đánh giá định kỳ | FR-35…FR-40 |

## Yêu cầu phi chức năng xuyên suốt

Áp cho **mọi** story, không nhắc lại ở từng story:

- Tầng `domain/` không import `package:flutter`, `package:drift`, `data/`, `presentation/` — AD-1.
- Không `double` trong `domain/` và trong cột Drift — AD-4.
- Không tạo cột giá trị suy ra — AD-3.
- Chuỗi hiển thị qua l10n — FR-34.
- Trước khi thêm gói mới: kiểm tra `hook/` — AD-13.
- Mỗi story phải `fvm flutter analyze` sạch và `fvm flutter test` xanh trước khi coi là xong.

---

## Epic 1: Nền tảng dữ liệu và bộ khung ứng dụng

**Kết thúc Epic:** app cài được lên máy, mở ra thấy khung ba tab, có sáu Chủ đề dựng sẵn, cơ sở dữ liệu đã tạo và có test migration.

### Story 1.1: Dựng dự án và khoá ngăn xếp

Cấu hình `pubspec.yaml` theo bảng ngăn xếp ở ARCHITECTURE-SPINE, `.fvmrc` ghim 3.38.10, bộ công cụ Android theo AD-14, cây thư mục theo bộ khung.

**Nghiệm thu:**
- `fvm flutter pub get` thành công, không có gói nào trong cây phụ thuộc chứa `hook/`.
- `fvm dart run build_runner build` chạy được tới cùng.
- Không có `package:http` trong `pubspec.yaml` — AD-6.
- Cây thư mục `lib/` khớp đúng bộ khung trong ARCHITECTURE-SPINE.

### Story 1.2: Lớp định dạng số, tiền và ngày kiểu Việt Nam

`core/format/` — dấu chấm phân cách nghìn, dấu phẩy thập phân, ngày `dd/MM/yyyy`, tiền kèm `₫`.

**Nghiệm thu:**
- `1000000000` → `1.000.000.000 ₫`.
- `0.34` (dạng `Decimal`) → `34,0%`.
- `2026-08-28` → `28/08/2026`.
- Rút gọn số lớn khi cần: `340000000` → `340 triệu`.
- Toàn bộ hàm định dạng có test, không hàm nào nhận `double`.

### Story 1.3: Kiểu số chính xác cho giá trị Mục tiêu

`core/money/` hoặc tương đương — bao kiểu `int` + `decimals`, chuyển đổi qua `Decimal` khi nhân chia.

**Nghiệm thu:**
- Chia `340000000 / 1000000000` cho ra đúng `0,34`, không phải `0,33999999`.
- Làm tròn xảy ra đúng một lần, ở lớp định dạng.
- Từ khoá `double` không xuất hiện trong `domain/` — kiểm bằng test quét mã nguồn.
- Có test cho giá trị lớn: `999.999.999.999 ₫` không mất chữ số.

### Story 1.4: Schema cơ sở dữ liệu và migration nền

Bảng Drift theo sơ đồ thực thể: `Topics`, `Projects`, `Actions`, `Goals`, `GoalUpdates`, `ProjectGoals`, `Notes`, `Links`, `StatusEvents`, `Settings`.

**Nghiệm thu:**
- `schemaVersion = 1`, schema đã dump vào `drift_schemas/`.
- Không cột nào tên `completionRatio`, `currentValue`, `progress`, `actionCount` — kiểm bằng test.
- `Actions.projectId` `NOT NULL` + `ON DELETE CASCADE`; xoá Dự án xoá theo Hành động, Ghi chú, Liên kết, mối nối.
- `ProjectGoals` có khoá chính ghép `(projectId, goalId)`.
- Test dựng DB rỗng rồi mở lại thành công.

### Story 1.5: Hợp đồng repository và cài đặt

`domain/repositories/` khai báo trừu tượng, `data/repositories/` cài đặt bằng Drift.

**Nghiệm thu:**
- Mỗi repository trả về kiểu kết quả tường minh, không `throw` để truyền lỗi nghiệp vụ.
- Test cho mỗi repository chạy trên DB trong bộ nhớ, không cần thiết bị.
- `domain/repositories/` không import `drift`.

### Story 1.6: Sáu Chủ đề dựng sẵn — FR-1

**Nghiệm thu:**
- Sau lần chạy đầu, có đúng sáu Chủ đề: Gia đình, Thu nhập, Tài chính, Sức khoẻ, Học tập, Khác.
- Mỗi Chủ đề có tên, màu, biểu tượng riêng.
- Sửa, thêm, xoá Chủ đề hoạt động; xoá Chủ đề đang có Dự án thì các Dự án chuyển về `Khác`, không bị xoá.
- Chủ đề `Khác` không xoá được.

### Story 1.7: Bộ khung ứng dụng, điều hướng và chủ đề giao diện — FR-34

**Nghiệm thu:**
- Ba tab: Hôm nay · Dự án · Mục tiêu. Tab Hôm nay là mặc định.
- Giao diện theo chế độ sáng/tối của hệ thống, đè tay được trong Cài đặt và lựa chọn được ghi nhớ.
- Toàn bộ chuỗi qua l10n; không chuỗi tiếng Việt nào viết thẳng trong widget — kiểm bằng test quét mã nguồn.
- App khởi động tới màn hình đầu dưới 1,5 giây với DB rỗng — NFR-1.

---

## Epic 2: Dự án và Hành động

**Kết thúc Epic:** app đã thay thế được hoàn toàn file `HÀNH ĐỘNG.pdf` — nhập dự án, nhập hành động, đánh dấu trạng thái, thấy tỷ lệ hoàn thành và dự án nguội.

### Story 2.1: Tạo, sửa, xoá Dự án — FR-5, FR-6, FR-7

**Nghiệm thu:**
- Chỉ tên là bắt buộc; mặc định Chủ đề `Khác`, trạng thái `Chưa bắt đầu`, ưu tiên `Trung bình`.
- Tên rỗng hoặc chỉ khoảng trắng bị từ chối kèm thông báo.
- Tạo xong mở thẳng chi tiết Dự án vừa tạo.
- `updatedAt` tự cập nhật mỗi lần sửa; không có ô nhập cho trường này — AD-5.
- Xoá hỏi xác nhận, nêu rõ số Hành động, Ghi chú, Liên kết sẽ mất, và nêu `Bỏ` như lựa chọn thay thế.
- Xoá Dự án không xoá Mục tiêu đã nối.

### Story 2.2: Trạng thái Dự án và lịch sử đổi trạng thái — FR-8

**Nghiệm thu:**
- Đúng năm trạng thái, lưu bằng chuỗi `snake_case` — AD-9.
- `startedAt` ghi ở lần đầu vào `Đang làm` và **không đổi** ở các lần sau — có test cho chuỗi `Đang làm → Xong → Đang làm`.
- `completedAt` ghi khi vào `Xong`, xoá khi rời `Xong`.
- Mỗi lần đổi trạng thái sinh một `StatusEvent`; xem lại được trên màn hình chi tiết.
- Đọc lên gặp chuỗi trạng thái lạ thì về mặc định, không ném lỗi.

### Story 2.3: Danh sách Dự án — lọc, sắp xếp, ghi nhớ — FR-9, FR-10

**Nghiệm thu:**
- Lọc theo trạng thái và Chủ đề, chọn nhiều, kết hợp AND.
- Mặc định ẩn `Xong` và `Bỏ`; có công tắc hiện lại.
- Bốn cách sắp xếp: ưu tiên, hoạt động gần nhất, tên, hạn chót.
- Mỗi dòng hiện: tên, Chủ đề, trạng thái, tỷ lệ hoàn thành, số ngày từ hoạt động gần nhất.
- Bộ lọc và cách sắp xếp còn nguyên sau khi đóng và mở lại app.
- Độ ưu tiên phân biệt bằng cả màu lẫn nhãn chữ — NFR-7.

### Story 2.4: Thêm và sửa Hành động — FR-14, FR-15

**Nghiệm thu:**
- Chỉ tiêu đề là bắt buộc.
- Sau khi thêm, ô nhập giữ tiêu điểm để gõ tiếp — nhập năm Hành động liên tiếp không cần chạm lại lần nào.
- Sửa được cả Dự án chủ quản; chuyển xong, tỷ lệ hoàn thành của **cả hai** Dự án được tính lại.
- Xoá có xác nhận và có hoàn tác trong vài giây.
- Không tồn tại `Action.parentId` — AD-8.

### Story 2.5: Trạng thái Hành động và đánh dấu một chạm — FR-16, FR-19

**Nghiệm thu:**
- Đúng bốn trạng thái, lưu bằng chuỗi.
- Ô tròn chạm được đổi giữa `Chưa`/`Đang làm` và `Xong` mà không rời màn hình.
- Có phản hồi rung nhẹ và hoàn tác ngay sau đó.
- Hành động `Đang làm` hiện số ngày kể từ `startedAt`.
- Thao tác ghi phản hồi dưới 100 ms — NFR-2.

### Story 2.6: Hạn hoàn thành và quá hạn — FR-17

**Nghiệm thu:**
- Hạn chót là ngày, không giờ; lưu ở mốc 00:00 giờ địa phương quy về UTC.
- Chưa `Xong`/`Bỏ` mà quá ngày thì đánh dấu quá hạn kèm số ngày trễ.
- `Xong` không bao giờ hiện quá hạn, kể cả hoàn thành sau hạn — có test cho trường hợp này.
- Có test đổi múi giờ: hành động đến hạn hôm nay không nhảy thành quá hạn.

### Story 2.7: Chi tiết Dự án, tỷ lệ hoàn thành và kéo thả — FR-11, FR-12, FR-18

**Nghiệm thu:**
- Chi tiết hiện đủ trường; Hành động nhóm theo trạng thái, `Xong`/`Bỏ` gom vào mục thu gọn.
- Thêm Hành động mới bằng đúng một chạm, không rời màn hình.
- Tỷ lệ hoàn thành = `Xong` ÷ (tổng trừ `Bỏ`), tính lại mỗi lần hiển thị; Dự án không có Hành động hiện `—` chứ không phải `0%`.
- Đổi trạng thái một Hành động thì tỷ lệ đổi ngay, không cần làm mới.
- Kéo thả đổi thứ tự được lưu và giữ nguyên sau khi mở lại app.

### Story 2.8: Dự án nguội — FR-13

**Nghiệm thu:**
- Dự án `Đang làm` không có `StatusEvent` nào của Hành động trong N ngày bị đánh dấu nguội.
- N mặc định 21, sửa được trong Cài đặt, chấp nhận 7…180, ngoài khoảng bị từ chối.
- `Tạm dừng`, `Xong`, `Bỏ`, `Chưa bắt đầu` không bao giờ nguội — có test cho cả bốn.
- Tính lúc dựng hình, không có tác vụ nền — AD-7.

---

## Epic 3: Mục tiêu và tiến độ

**Kết thúc Epic:** `Mục tiêu: 1 tỷ` sống trong app, có sổ Mốc, biểu đồ đường và con số còn thiếu.

### Story 3.1: Tạo Mục tiêu có số và không số — FR-20

**Nghiệm thu:**
- Mục tiêu có số bắt buộc giá trị đích và đơn vị; hạn chót tuỳ chọn.
- Mục tiêu không số không có thanh phần trăm và không có sổ Mốc — kiểm bằng test giao diện.
- Nhập `1000000000` VND hiển thị đúng `1.000.000.000 ₫`, lưu bằng `int` — AD-4.
- Đơn vị có phần thập phân (kg, giờ) lưu `int` đã nhân hệ số kèm `decimals`.

### Story 3.2: Sổ Mốc tiến độ — FR-21

**Nghiệm thu:**
- Mốc gồm ngày, giá trị, ghi chú tuỳ chọn; ngày mặc định hôm nay.
- Sửa và xoá được Mốc bất kỳ, kể cả Mốc giữa chuỗi và kể cả đổi ngày.
- **Test bắt buộc:** sửa giá trị một Mốc giữa chuỗi → mọi con số dẫn xuất đúng lại.
- **Test bắt buộc:** đổi ngày một Mốc khiến nó không còn là Mốc mới nhất → giá trị hiện tại đổi theo đúng.
- Nhiều Mốc cùng ngày được chấp nhận; Mốc nhập sau thắng.

### Story 3.3: Tiến độ suy ra và hiển thị — FR-22

**Nghiệm thu:**
- Giá trị hiện tại = Mốc có `date` lớn nhất ≤ hôm nay; không Mốc nào thì hiện `—`, không phải `0`.
- Không tồn tại cột `currentValue`/`progress` trong DB — kiểm bằng test quét schema.
- Tiến độ vượt 100% hiển thị đúng, không bị chặn.
- Mốc có ngày trong tương lai không được tính vào giá trị hiện tại — có test.

### Story 3.4: Biểu đồ đường tiến độ — FR-23

**Nghiệm thu:**
- Trục ngang thời gian, trục dọc giá trị; mỗi Mốc một điểm, nối bằng đường.
- Giá trị đích là một đường ngang tham chiếu.
- Có hạn chót thì vẽ thêm đường nhịp lý tưởng từ Mốc đầu tới `(hạn chót, đích)`.
- Dưới hai Mốc thì hiện thông báo cần thêm dữ liệu, không vẽ biểu đồ một điểm.
- `double` chỉ xuất hiện ở toạ độ vẽ trong `presentation/`, không rò sang `domain/`.

### Story 3.5: Nhịp cần đi và dự báo về đích — FR-24

**Nghiệm thu:**
- Có hạn chót + ≥2 Mốc: hiện khoảng còn thiếu, thời gian còn lại, mức cần thêm mỗi tháng.
- Hiện dự báo dạng *"nhịp hiện tại về đích sớm/chậm X tháng"*.
- **Không có hạn chót thì tuyệt đối không hiện nhịp và không hiện dự báo** — chỉ phần trăm và khoảng còn thiếu. Có test cho ràng buộc này.
- Nhịp âm được nói thẳng, không hiện dự báo dương — có test.
- Mọi phép chia qua `Decimal`, làm tròn một lần ở lớp định dạng.

### Story 3.6: Nối Dự án vào Mục tiêu — FR-25

**Nghiệm thu:**
- Nhiều-nhiều hai chiều; nối và gỡ từ cả hai phía.
- Chi tiết Mục tiêu liệt kê Dự án đã nối kèm trạng thái và tỷ lệ hoàn thành từng Dự án.
- Gỡ mối nối không xoá Dự án cũng không xoá Mục tiêu.
- Mục tiêu chưa có Dự án nào được đánh dấu trực quan.

---

## Epic 4: Màn hình Hôm nay và tìm kiếm

**Kết thúc Epic:** mở app là biết hôm nay làm gì — lý do tồn tại của sản phẩm ở nhịp dùng hằng ngày.

### Story 4.1: Hàm bỏ dấu tiếng Việt và cột chỉ mục — AD-12

**Nghiệm thu:**
- `slugify` trong `domain/rules/` xử lý đủ bộ dấu tiếng Việt kể cả `đ/Đ`, `ươ`, `ăâ`, `ê ô ơ ư`.
- `Kế hoạch tài chính` → `ke hoach tai chinh`.
- Cột `searchText` do repository sinh trong cùng giao dịch với mỗi lần ghi; giao diện không bao giờ gán nó — có test.
- Sửa tên Dự án thì `searchText` đổi theo trong cùng giao dịch.

### Story 4.2: Tìm kiếm toàn cục — FR-30

**Nghiệm thu:**
- Một ô quét: Dự án (tên, mô tả), Hành động (tiêu đề, ghi chú), Mục tiêu (tên), Ghi chú (tiêu đề, nội dung), Liên kết (nhãn).
- Kết quả nhóm theo loại, mỗi kết quả ghi rõ thuộc Dự án nào.
- Gõ `tai chinh` tìm ra `Kế hoạch tài chính`; gõ `TAI CHINH` cũng vậy.
- Kết quả cập nhật khi đang gõ, không cần nút tìm.

### Story 4.3: Màn hình Hôm nay — FR-29

**Nghiệm thu:**
- Bốn nhóm đúng thứ tự: Quá hạn → Đang làm → Đến hạn trong 7 ngày → Cần chú ý.
- *Cần chú ý* gồm Dự án nguội và Mục tiêu có hạn chót đang chậm nhịp.
- Nhóm rỗng biến mất hoàn toàn, không để lại tiêu đề rỗng.
- **Không bao giờ liệt kê toàn bộ Hành động chưa xong** — có test khẳng định điều này với bộ dữ liệu 100 Hành động.
- Mỗi dòng đánh dấu `Xong` được tại chỗ và mở được Dự án cha bằng một chạm.
- Trạng thái trống có nghĩa kèm lối tắt sang danh sách Dự án.

### Story 4.4: Hiệu năng màn hình Hôm nay — NFR-1, NFR-2

**Nghiệm thu:**
- Với 7 Dự án / 100 Hành động / 3 Mục tiêu, cold start tới Hôm nay có dữ liệu dưới 1,5 giây.
- Đánh dấu `Xong` phản hồi dưới 100 ms.
- Truy vấn nguồn cho Hôm nay chạy trong một lượt đọc DB, không N+1 — có test đếm số truy vấn.

---

## Epic 5: Ghi chú, Liên kết và dữ liệu hạt giống

**Kết thúc Epic:** toàn bộ nội dung hai file PDF đã nằm trong app, không sót dòng nào.

### Story 5.1: Ghi chú markdown — FR-27

**Nghiệm thu:**
- Ghi chú có tiêu đề và nội dung markdown, hiển thị đã dựng hình: đậm, nghiêng, danh sách, tiêu đề con.
- Một Dự án chứa nhiều Ghi chú, sắp xếp theo `updatedAt` giảm dần.
- Toàn bộ nội dung *Nợ tốt / Khi nào nên vay* nhập vào giữ nguyên cấu trúc — nghiệm thu bằng chính nội dung ở `addendum.md` §1.4.
- Trước khi thêm thư viện markdown: kiểm tra `hook/` — AD-13.

### Story 5.2: Liên kết ngoài — FR-28

**Nghiệm thu:**
- Liên kết có nhãn và URL, gắn vào một Dự án, kéo thả đổi thứ tự.
- Chạm mở trình duyệt hệ thống; ứng dụng không nhúng trình duyệt và không tải nội dung — AD-6.
- URL sai định dạng bị từ chối ngay lúc nhập kèm thông báo rõ.
- Sao chép URL bằng một thao tác.

### Story 5.3: Bộ dữ liệu hạt giống — FR-2, FR-3

**Nghiệm thu:**
- Bảy Dự án đúng tên và đúng Chủ đề theo `addendum.md` §1.1.
- Sáu Hành động dưới `Kế hoạch tài chính`, ánh xạ trạng thái đúng bảng §1.2.
- Hai Ghi chú theo §1.4; bốn Liên kết gắn đúng Dự án theo §1.5.
- Hai Mục tiêu theo §1.3, một có số một không số, nối sẵn vào Dự án theo FR-3.
- Bộ hạt giống là dữ liệu tĩnh trong `data/seed/`, có test khẳng định đủ số lượng từng loại.

### Story 5.4: Luồng chạy lần đầu — FR-2, FR-4

**Nghiệm thu:**
- Lần chạy đầu đề nghị nạp hạt giống; chọn nạp thì vào thẳng Hôm nay đã có dữ liệu.
- Chọn bỏ qua thì chỉ còn sáu Chủ đề, không Dự án nào, và đề nghị không xuất hiện lại.
- Cài đặt luôn có mục nạp lại hạt giống; chạy lại **không nhân đôi** bản ghi — đối chiếu theo tên Dự án, có test chạy hai lần liên tiếp.
- `Settings.seedApplied` là nguồn duy nhất quyết định có hiện đề nghị hay không.

---

## Epic 6: Sao lưu, khôi phục và hoàn thiện

**Kết thúc Epic:** dữ liệu chuyển máy được, và sản phẩm sẵn sàng dùng thật.

### Story 6.1: Xuất Bản sao lưu — FR-31

**Nghiệm thu:**
- Một file JSON chứa đủ mười loại bản ghi và cài đặt.
- Mở đầu bằng `{"schemaVersion": <int>, "exportedAt": "<ISO8601>"}`.
- Tên file `sao-luu-YYYY-MM-DD.json`.
- Chia sẻ qua chức năng của hệ điều hành.
- Có test: xuất bộ dữ liệu hạt giống → JSON hợp lệ, đủ số lượng từng loại.

### Story 6.2: Nhập khôi phục nguyên tử — FR-32

**Nghiệm thu:**
- **Test bắt buộc:** xuất → xoá sạch → nhập → so khớp toàn bộ, kể cả `createdAt` và `sortOrder`.
- Trước khi ghi đè có xác nhận nêu rõ dữ liệu hiện tại sẽ bị thay thế.
- File sai định dạng, thiếu trường, hoặc `schemaVersion` cao hơn ứng dụng → từ chối kèm lý do cụ thể, **dữ liệu hiện tại không đụng tới** — có test.
- Toàn bộ nhập chạy trong một giao dịch; lỗi giữa chừng cuộn ngược hoàn toàn — có test chèn lỗi cố ý.
- Nhập là thay thế toàn bộ, không trộn.

### Story 6.3: Cài đặt và xoá sạch dữ liệu — FR-34

**Nghiệm thu:**
- Cài đặt chứa: ngưỡng ngày nguội, chế độ sáng/tối, nạp lại hạt giống, xuất, nhập, xoá sạch.
- Xoá sạch có xác nhận hai bước và gợi ý xuất sao lưu trước.
- Sau khi xoá sạch, sáu Chủ đề mặc định được dựng lại.

### Story 6.4: Rà soát offline và tiếp cận — FR-33, NFR-3, NFR-7

**Nghiệm thu:**
- Test quét mã nguồn: không `package:http`, không `HttpClient`, không `WebSocket`, không thư viện phân tích hành vi.
- Bật chế độ máy bay, chạy hết luồng chính, không lỗi nào — kiểm thủ công có ghi lại.
- Mọi trạng thái và độ ưu tiên đều có nhãn chữ hoặc biểu tượng kèm màu.
- Vùng chạm nhỏ nhất 44×44 điểm; app đọc được bằng trình đọc màn hình ở các luồng chính.
- `fvm flutter analyze` sạch, toàn bộ test xanh.

---

## Epic 7: Đợt đánh giá định kỳ

**Nguồn:** `Dạy huy.pdf`, thêm vào ngày 2026-08-28 sau khi người dùng làm rõ dự
án `Dạy Huy` là *"lập kế hoạch và theo dõi tiến bộ của con trai theo mốc thời gian"*.

**Kết thúc Epic:** hai đợt đánh giá 15/5 và 7/8 trong file gốc sống trong app,
và tạo đợt thứ ba chỉ mất vài chạm nhờ kế thừa các mục chưa đạt.

### Story 7.1: Schema Đợt đánh giá và migration lên phiên bản 2

**Nghiệm thu:**
- Hai bảng `reviews` và `review_items` theo sơ đồ thực thể; `schemaVersion` tăng lên 2.
- `review_items.review_id` cascade; xoá Đợt xoá theo Mục. Xoá Dự án xoá theo cả hai.
- Không cột `metCount`, `metRatio`, `itemCount` — kiểm bằng test schema guard.
- **Test `migrateAndValidate` từ phiên bản 1 lên 2**, dựng DB bản 1 có dữ liệu rồi nâng cấp, dữ liệu cũ còn nguyên — AD-10.

### Story 7.2: Tạo, sửa, xoá Đợt đánh giá — FR-35

**Nghiệm thu:**
- Ngày đánh giá mặc định hôm nay; tiêu đề và tóm tắt markdown tuỳ chọn; ngày xem lại tiếp theo tuỳ chọn.
- Tiêu đề để trống thì hiển thị bằng ngày đánh giá.
- Danh sách Đợt của một Dự án sắp xếp theo ngày giảm dần.

### Story 7.3: Mục đánh giá ba kết quả — FR-36, FR-39

**Nghiệm thu:**
- Ba kết quả `met` · `not_met` · `partial`, lưu bằng chuỗi ổn định, đọc chuỗi lạ về `not_met` không ném lỗi.
- Mỗi kết quả có nhãn chữ kèm màu, không chỉ màu.
- Tỷ lệ đạt = `Đạt` ÷ tổng Mục, tính tại chỗ; `Một phần` vào mẫu số không vào tử số; không Mục nào thì `—`.
- Kéo thả đổi thứ tự Mục được lưu.

### Story 7.4: Kế thừa mục chưa đạt — FR-37

**Nghiệm thu:**
- Tạo Đợt mới trên Dự án đã có Đợt trước sẽ đề nghị chép các Mục `Chưa đạt` và `Một phần`.
- Mục `Đạt` không được chép — có test.
- Mục chép sang mang kết quả khởi điểm `Chưa đạt` và giữ thứ tự tương đối.
- Bỏ chọn hết thì Đợt mới trống.
- Sửa nội dung một Hành động **không** làm đổi Mục đánh giá quá khứ — AD-15, có test.

### Story 7.5: Dòng thời gian và nhắc đến hạn — FR-38, FR-40

**Nghiệm thu:**
- Thẻ riêng trên màn hình Dự án liệt kê các Đợt theo thời gian kèm tỷ lệ đạt.
- Dự án có Đợt gần nhất mang ngày xem lại ≤ hôm nay xuất hiện ở nhóm *Cần chú ý* của Hôm nay.
- Chỉ Đợt gần nhất được xét — có test với Dự án có ba Đợt.
- Dự án `Xong` và `Bỏ` không sinh nhắc nhở — có test.

### Story 7.6: Nạp hai đợt đánh giá thật của dự án Dạy Huy

**Nghiệm thu:**
- Dự án `Dạy Huy` có Chủ đề Gia đình, mô tả hai điểm trọng tâm, và bốn nhóm mục tiêu 2-3 tháng tới thành Hành động.
- Đợt `15/05` có 5 Mục đúng kết quả trong file: 2 `Đạt`, 3 `Chưa đạt`.
- Đợt `07/08` có 5 Mục đúng kết quả: 3 `Đạt`, 2 `Chưa đạt`.
- Ghi chú `Những việc cha mẹ đang làm sai` được nạp đầy đủ 5 điểm.
- Chạy lại bộ hạt giống không nhân đôi Đợt đánh giá.

## Epic 8: Cấu trúc PARA

**Nguồn:** đề xuất `_bmad-output/planning-artifacts/proposals/para-2026-09-03/PROPOSAL-PARA.md`,
chốt ngày 2026-09-03. Ràng buộc bởi AD-17…AD-20, thực hiện FR-46…FR-52.

**Kết thúc Epic:** người dùng mở app, thấy sáu **Lĩnh vực** mỗi cái có tiêu
chuẩn và nhịp xem lại riêng; xoá một Dự án cũ mà ghi chú vẫn còn; cất những
thứ đã nguội đi mà không phải nói dối rằng chúng đã `Bỏ`.

### Story 8.1: Đổi tên Topic → Area, migration lên phiên bản 4

**Nghiệm thu:**
- Bảng `topics` → `areas`; `projects.topic_id` → `projects.area_id`; `schemaVersion` lên 4.
- Lớp `Topic` → `Area`, `TopicRow` → `AreaRow`, `DriftTopicRepository` → `DriftAreaRepository`, `topicsProvider` → `areasProvider`, nhãn l10n *Chủ đề* → *Lĩnh vực*.
- `grep -ri "topic\|chủ đề" lib/ test/ docs/` không còn kết quả nào.
- **Test `migrateAndValidate` từ v3 lên v4**, dựng DB v3 có dữ liệu rồi nâng cấp, so từng dòng — AD-10.
- Chụp lại `drift_schemas/` và sinh lại helper kiểm thử.

### Story 8.2: Tiêu chuẩn và nhịp xem lại — FR-47, FR-48

**Nghiệm thu:**
- Cột `standard` (text, mặc định rỗng) và `review_cadence_days` (int nullable) trên `areas`.
- Không cột `nextReviewDate` hay `isDueForReview` trên `areas` — kiểm bằng test schema guard, AD-3.
- Ngày đến hạn xem lại tính tại chỗ; **test: xoá Đợt gần nhất thì ngày đến hạn lùi về theo Đợt trước đó**.
- Nhịp để trống thì không sinh nhắc nhở nào — test khẳng định.

### Story 8.3: Đợt đánh giá cấp Lĩnh vực — FR-49

**Nghiệm thu:**
- `reviews.project_id` chuyển sang nullable, thêm `reviews.area_id` nullable, ràng buộc XOR ở tầng bảng — AD-19.
- Mọi Đợt có sẵn sau migration vẫn thuộc đúng Dự án cũ.
- Nạp sẵn Mục từ tên Dự án đang mở là **chép văn bản**; **test: nạp xong rồi đổi tên Dự án, Mục cũ không đổi**.
- Kế thừa Mục chưa đạt hoạt động ở cấp Lĩnh vực.

### Story 8.4: Gỡ Tư liệu khỏi ràng buộc Dự án — FR-50

**Nghiệm thu:**
- `notes.project_id` và `links.project_id` nullable, `onDelete: setNull`; thêm `area_id` nullable; ràng buộc nhiều-nhất-một — AD-18.
- Migration điền `area_id` cho mọi Ghi chú và Liên kết đang có, lấy từ Lĩnh vực của Dự án cha.
- **Test: tạo Dự án có 2 Ghi chú và 1 Liên kết, xoá Dự án, cả ba còn nguyên và đã gắn vào Lĩnh vực cũ.**
- Hộp xác nhận xoá Dự án nói đúng số lượng sẽ chuyển đi.
- Màn hình *Tư liệu* với bộ lọc theo Lĩnh vực và *chưa gắn*.
- `searchText` sinh lại sau mỗi lần chuyển chỗ.

### Story 8.5: Lưu trữ — FR-51

**Nghiệm thu:**
- `archived_at` nullable trên bốn bảng; `ProjectStatus` **không đổi** — test khẳng định enum vẫn đúng năm giá trị.
- Lưu trữ không ghi `StatusEvent`, không đụng `status`, `startedAt`, `completedAt`.
- **Test: lưu trữ một Dự án `Đang làm` rồi đưa trở lại — `status` vẫn `Đang làm`, `startedAt` không đổi.**
- Danh sách mặc định ẩn mục đã lưu trữ; bộ lọc hiện lại được.
- Lưu trữ Dự án tự bỏ ghim Hành động của nó.
- Lưu trữ Lĩnh vực còn Dự án mở thì cảnh báo mà vẫn cho làm; Dự án con **không** bị lưu trữ theo.

### Story 8.6: Sao lưu phiên bản 4 và đọc lại file cũ

**Nghiệm thu:**
- `backupFormatVersion` 3 → 4; khoá mới `areas`, `standard`, `reviewCadenceDays`, `areaId`, `archivedAt`.
- Đọc được file v1, v2, v3: khoá `topics` nạp vào `areas`, `archivedAt` thiếu thì để null, `areaId` của Ghi chú suy từ Dự án cha.
- File v5 trở lên bị **từ chối**, không cố đọc.
- **Test: xuất → xoá sạch → nhập, so khớp toàn bộ kể cả `createdAt`, `sortOrder`, `archivedAt`.**
- `searchText` sinh lại khi nhập, không lấy từ file.

### Story 8.7: Lĩnh vực đến hạn xem lại vào khối Cần chú ý — FR-52

**Nghiệm thu:**
- Dòng nhắc nằm ở *Cần chú ý*, dẫn tới màn hình Lĩnh vực, không tick được.
- **Test: 6 Lĩnh vực cùng đến hạn, số phần tử của *Làm ngay* không đổi.**
- Mỗi Lĩnh vực chỉ xuất hiện một lần.
