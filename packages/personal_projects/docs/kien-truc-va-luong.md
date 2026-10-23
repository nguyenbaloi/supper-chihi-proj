# Kiến trúc và luồng use case

Bản đồ để soi tổng thể tính năng. Mô tả **trạng thái hôm nay** (schema v6).
Chủ đề đã đổi tên thành **Lĩnh vực** ở Story 8.1; những phần Epic 8 còn nợ
được đánh dấu `[PARA]`.

## 1. Bốn tầng

```
      features/          9 màn hình, ráp từ ba tầng dưới
          │
   presentation/  ────►  domain/  ◄────  data/
   providers              models            db (drift)
   widgets                rules             repositories (cài đặt)
                          repositories      backup · seed
                          (hợp đồng)
```

`domain/` **không import** `package:flutter`, `package:drift`, `data/`,
`presentation/`. Nhờ vậy toàn bộ quy tắc nghiệp vụ test được mà không dựng giả
lập. Provider khai báo tay (không codegen Riverpod).

## 2. Thực thể

```
Area   1──n  Project  1──n  Action
  │              │
  │              └──n  Review  1──n  ReviewItem
  ├──n  Review ──┘  (Đợt thuộc ĐÚNG một chủ thể — AD-19)
  │
  └── Note và Link gắn vào nhiều nhất MỘT chỗ — AD-18:
        một Project · một Area · hoặc không gắn gì (kho chung)

Area có `standard` (mức cần giữ) và `reviewCadenceDays` (nhịp xem lại).
Không có `status`, không có `dueDate` — Lĩnh vực không bao giờ kết thúc.

StatusEvent   bảng chỉ ghi thêm, trỏ tới Project|Action bằng entityType+entityId
```

Ba ràng buộc hình dạng:

- **Hành động luôn thuộc đúng một Dự án**, không có cây con, không `parentId`.
- **`ReviewItem.label` là bản chụp văn bản**, không phải khoá ngoại tới Action — sửa Hành động không làm đổi Đợt đánh giá quá khứ.
- **`StatusEvent` không sửa, không xoá** — là nguồn duy nhất của "ngày hoạt động gần nhất".

## 3. Bốn tab

| Tab | Trả lời câu hỏi | Nguồn |
|---|---|---|
| **Hôm nay** | *Hôm nay tôi làm gì?* | `Action.pinned` + `buildAttention()` |
| **Dự án** | *Mọi thứ đang chạy thế nào?* | `watchSummaries(filter)`, nhóm theo Lĩnh vực |
| **Thống kê** | *Tôi có làm đúng hạn không?* | 6 nhóm `DueOutcome` |
| **Cài đặt** | *Sao lưu, ngưỡng nguội, xoá sạch* | `AppSettings` + `backup` |

Màn hình **Lĩnh vực** vào từ tiêu đề nhóm trên tab Dự án; **Tư liệu** từ biểu
tượng thư mục trên cùng tab đó.

Tìm kiếm nằm ở thanh tiêu đề, không phải một tab.

## 4. Luồng use case

**UC-1 · Chạy lần đầu**
`mở app → đọc seedApplied → chưa có: Onboarding → nhận 7 Dự án hạt giống (hoặc bỏ qua) → HomeShell`
Bỏ qua thì chỉ còn 6 Lĩnh vực dựng sẵn, không Dự án nào.

**UC-2 · Tạo Dự án**
`tab Dự án → + → chọn Lĩnh vực, ưu tiên, hạn (tuỳ chọn) → repository ghi createdAt/updatedAt`
Mặc định: Lĩnh vực `Khác`, `Chưa bắt đầu`, ưu tiên `Trung bình`, không hạn.

**UC-3 · Thêm Hành động rồi kéo lên Hôm nay**
`chi tiết Dự án → tab Hành động → + → đặt ưu tiên và hạn riêng → bấm ghim`
Ghim là **thao tác tay duy nhất** đưa việc vào danh sách *Làm ngay*. Không chỗ
nào trong app tự ghim hộ.

**UC-4 · Làm xong một Hành động**
`Chưa → Đang làm` ghi `startedAt` **một lần duy nhất**
`Đang làm → Xong` ghi `completedAt`, **tự bỏ ghim**, ghi `StatusEvent`
`Xong → Đang làm` **xoá** `completedAt`, `startedAt` giữ nguyên lần đầu
Đây là kịch bản dễ sai nhất, có test riêng.

**UC-5 · Đọc màn hình Hôm nay**
```
┌ Làm ngay ────────  chỉ Action.pinned, xếp theo pinnedAt
└ Cần chú ý ───────  buildAttention(): quá hạn → sắp đến hạn → ưu tiên cao chưa làm
```
Khối dưới là **thông tin**, không phải danh sách việc. Mỗi Hành động chỉ xuất
hiện một lần, ở loại nghiêm trọng nhất — nếu không khối này tự phình ra và mất
tác dụng.

**UC-6 · Dự án nguội**
`Dự án Đang làm + không Hành động nào đổi trạng thái quá N ngày → gắn nhãn nguội`
N mặc định 21, sửa được trong Cài đặt (7…180). Tính **lúc dựng hình**, không có
tác vụ nền. Chỉ `Đang làm` mới nguội được.

**UC-7 · Ghi chú và Liên kết**
`chi tiết Dự án → tab Ghi chú → soạn markdown` · `Liên kết mở bằng trình duyệt hệ điều hành`
`Tư liệu` (biểu tượng thư mục trên tab Dự án) liệt kê **tất cả** Ghi chú và
Liên kết, lọc theo Lĩnh vực hoặc *chưa xếp chỗ*.
Xoá Dự án **không** xoá chúng — chúng chuyển sang Lĩnh vực của Dự án, và hộp
xác nhận nói rõ chuyển đi đâu (FR-50).

**UC-7b · Lĩnh vực**
`tab Dự án → chạm tiêu đề nhóm → mức cần giữ · nhịp xem lại · Đợt đánh giá của mảng`
Nhịp để trống thì **không hiện ngày nào cả** — không bịa ra một cái hạn người
dùng chưa từng đặt. Hạn xem lại = Đợt gần nhất + nhịp, tính tại chỗ; chưa có
Đợt nào thì đếm từ ngày tạo Lĩnh vực.

**UC-8 · Đợt đánh giá định kỳ**
`chi tiết Dự án → tab Đánh giá → tạo Đợt (ngày, tiêu đề, tóm tắt, ngày xem lại tiếp)`
`→ thêm Mục, mỗi Mục chấm Đạt / Một phần / Chưa đạt`
`→ Đợt sau: kế thừa Mục chưa đạt = CHÉP VĂN BẢN sang Đợt mới`
Sửa Mục ở Đợt mới **không** đụng Đợt cũ. `nextReviewDate` là nguồn duy nhất của
nhắc đến hạn trên màn Hôm nay.

**UC-9 · Tìm kiếm**
`thanh tiêu đề → gõ → khớp trên cột searchText đã bỏ dấu`
Quét năm loại: Dự án, Hành động, Ghi chú, Liên kết, Đợt đánh giá. `searchText` do repository sinh — là
chỉ mục, không phải giá trị nghiệp vụ.

**UC-10 · Sao lưu và khôi phục**
`Xuất → một file JSON duy nhất (backupFormatVersion 5) → share_plus`
Khoá JSON vẫn mang tên cũ `topics`/`topicId`: định dạng file là hợp đồng riêng
với tên bảng, đổi ở Story 8.6.
`Nhập → kiểm tra toàn bộ → THAY THẾ TẤT CẢ trong một giao dịch → sinh lại searchText`
Lỗi giữa chừng cuộn ngược hoàn toàn. File có phiên bản cao hơn app bị **từ
chối**, không cố đọc.

## 5. Không giá trị nào được lưu cứng

| Giá trị | Công thức | Tính ở |
|---|---|---|
| Tỷ lệ hoàn thành Dự án | `\|Xong\| ÷ \|không Bỏ\|`, `Decimal` | `rules/completion.dart` |
| Nguội hay không | `now − hoạt động gần nhất > ngưỡng` | `rules/stale.dart` |
| Khối Cần chú ý | phân loại theo hạn + ưu tiên | `rules/attention.dart` |
| Tỷ lệ đạt của Đợt | `\|Đạt\| ÷ tổng Mục` | `rules/review.dart` |
| Hạn xem lại Lĩnh vực | `Đợt gần nhất + nhịp`, null nếu không đặt nhịp | `rules/cadence.dart` |
| 6 nhóm đúng/muộn hạn | so `completedAt` với `dueDate` | `rules/stats.dart` |

Chưa có dữ liệu thì hiện `—`, **không bao giờ hiện `0%`**. Không bảng nào có
cột `completionRatio`, `actionCount`, `metRatio`.

## 6. Chỗ hở — xem khi review

1. ~~Xoá Dự án là mất Ghi chú~~ — **đã vá ở Story 8.4** (UC-7).
2. **Không có lưu trữ.** Dự án `Xong` hoặc `Bỏ` nằm mãi trong danh sách, chỉ ẩn được bằng bộ lọc.
3. ~~Đợt đánh giá chỉ ở cấp Dự án~~ — **đã làm ở Story 8.3**.
4. ~~`Area` mới chỉ là nhãn màu~~ — **đã làm ở Story 8.2**. Còn nợ: hạn xem lại chưa hiện ở khối *Cần chú ý* (Story 8.7).
5. **Hành động không có Ghi chú riêng**, chỉ một trường `note` một dòng.

Epic 8 còn nợ điểm 2 (Lưu trữ — Story 8.5), phần nhắc của điểm 4 (Story 8.7),
và đổi khoá sao lưu `topics` → `areas` (Story 8.6). Điểm 5 chưa có ai đề xuất.
