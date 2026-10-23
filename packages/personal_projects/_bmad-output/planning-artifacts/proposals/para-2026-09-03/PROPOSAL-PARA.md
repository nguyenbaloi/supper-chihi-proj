---
title: "Đề xuất: đưa app về cấu trúc PARA"
status: accepted
accepted: 2026-09-03
created: 2026-09-03
decides: "FR-46…FR-52 · AD-17…AD-20 · Epic 8"
targets:
  - "_bmad-output/planning-artifacts/prds/prd-quan-ly-du-an-muc-tieu-2026-08-28/prd.md"
  - "_bmad-output/planning-artifacts/architecture/architecture-du-an-muc-tieu-2026-08-28/ARCHITECTURE-SPINE.md"
  - "_bmad-output/planning-artifacts/epics/epics.md"
  - "CLAUDE.md"
---

# Đề xuất: đưa app về cấu trúc PARA

> **ĐÃ CHỐT ngày 2026-09-03.** §3 đã chép sang PRD thành §4.10, §4 sang
> ARCHITECTURE-SPINE thành AD-17…AD-20, §5 sang `epics.md` thành Epic 8,
> và CLAUDE.md đã có quy tắc tuyệt đối 6 và 7. File này giữ lại làm hồ sơ
> quyết định — **nguồn chính thức từ nay là ba tài liệu kia**, không phải file này.

## 1. Đối chiếu PARA với mô hình đang có

PARA của Tiago Forte chia mọi thứ làm bốn: **P**rojects (có đích, kết thúc
được) · **A**reas (trách nhiệm phải giữ, không bao giờ xong) · **R**esources
(tư liệu tham khảo) · **A**rchives (thứ không còn trong tầm mắt).

| PARA | Trong app hôm nay | Mức khớp |
|---|---|---|
| Projects | `Project` | Khớp gần như hoàn toàn |
| Areas | `Topic` | Khớp **vị trí**, không khớp **bản chất** |
| Resources | `Note` + `Link` | Có nội dung, nhưng bị khoá cứng vào một Dự án |
| Archives | *(không có)* | `done`/`dropped`/`paused` là kết cục vòng đời, không phải kho lưu |

Ba khoảng trống, xếp theo mức nghiêm trọng:

**1 — Tư liệu chết theo Dự án.** `Notes.projectId` và `Links.projectId` đều
`references(Projects, onDelete: cascade)`. Xoá một Dự án cũ là mất sạch ghi
chú của nó, **không có cảnh báo**. Đây là chỗ mất dữ liệu thật, không phải
chuyện sắp xếp.

**2 — `Topic` mới là cái nhãn, chưa là Lĩnh vực.** Nó có đúng `name`,
`colorValue`, `iconKey`, `sortOrder`. Một Lĩnh vực theo PARA phải trả lời được
*"tôi đang cam kết giữ cái gì ở mức nào"* và *"bao lâu tôi nhìn lại một lần"*.
Cả hai đều không có chỗ để ghi.

**3 — Nghi thức trung tâm của PARA đang không làm được.** `Review.projectId`
là bắt buộc, nên chỉ nhìn lại được từng Dự án. PARA sống nhờ buổi nhìn lại
**theo Lĩnh vực** — hỏi *"mảng Sức khoẻ tháng qua có giữ được mức không"*, chứ
không phải *"dự án tập gym xong chưa"*.

## 2. Quyết định thuật ngữ — đã chốt ngày 2026-09-03

`Topic` **đổi hẳn thành `Area`**, nhãn tiếng Việt là **Lĩnh vực**. Không giữ
song song hai từ.

Lý do: CLAUDE.md cấm từ đồng nghĩa. Thêm "Area" mà vẫn để "Topic" là hai từ
cho một thứ, đúng cái bị cấm. Và cái tên phải phản ánh vai trò mới — sau khi
có tiêu chuẩn và nhịp xem lại thì nó không còn là "chủ đề" nữa.

Phạm vi đổi: **19 file, khoảng 140 chỗ**, cộng một bước migration đổi tên bảng
`topics` → `areas`. Cụ thể ở Story 8.1.

Ba từ **không** được nhập vào mã nguồn:

- **`Resource`** — sẽ là từ đồng nghĩa gộp của `Note` và `Link`. Giữ nguyên hai
  thực thể đó; PARA "Resources" chỉ tồn tại như **tên một màn hình gộp**, gọi
  là *Tư liệu*, ghi vào từ điển đúng dòng *"nhãn nhóm ở giao diện, không phải
  thực thể"*.
- **`archived`** như một trạng thái — sẽ là từ đồng nghĩa của `dropped` và
  `paused`. Xem AD-17.
- **`Inbox`** — PARA đầy đủ có bước thu gom, nhưng nó là chuyện khác. Xem §6.

## 3. Yêu cầu chức năng mới — FR-46…FR-52

*(Chép vào PRD thành §4.10 khi chốt.)*

### FR-46: Chủ đề đổi tên thành Lĩnh vực

Đổi tên thuần tuý, không đổi hành vi nào.

**Hệ quả kiểm thử được:**
- Không còn chuỗi `Topic` hay `Chủ đề` ở bất kỳ đâu trong `lib/`, `test/` và tài liệu.
- Sáu Lĩnh vực dựng sẵn giữ nguyên tên nội dung: Gia đình, Thu nhập, Tài chính, Sức khoẻ, Học tập, Khác.
- `Khác` vẫn là Lĩnh vực dự phòng không xoá được, Dự án rơi về đó khi Lĩnh vực cũ bị xoá.
- Sau migration, **không giá trị nào của người dùng đổi** — kiểm bằng test dựng DB v3 có dữ liệu rồi nâng lên v4 và so từng dòng.
- File sao lưu cũ (`schemaVersion` ≤ 3) đọc được, khoá `topics` trong file cũ nạp vào bảng `areas`.

### FR-47: Lĩnh vực có tiêu chuẩn cần giữ

Trường văn bản trả lời *"mức tôi muốn giữ ở mảng này là gì"*. Đây là thứ phân
biệt một Lĩnh vực với một cái nhãn màu.

**Hệ quả kiểm thử được:**
- Trường `standard` dạng markdown, tuỳ chọn, để trống được.
- Sáu Lĩnh vực dựng sẵn và mọi Lĩnh vực có trước migration đều để trống — không tự sinh nội dung hộ.
- Hiện ở đầu màn hình chi tiết Lĩnh vực; để trống thì không chiếm chỗ, chỉ còn nút thêm.
- **Không có hạn chót, không có trạng thái, không có "xong"** — Lĩnh vực không bao giờ kết thúc. Không thêm cột `status` vào `areas`.

### FR-48: Lĩnh vực có nhịp xem lại

**Hệ quả kiểm thử được:**
- Trường `reviewCadenceDays` kiểu `int` **nullable**. Gợi ý sẵn 7 · 30 · 90, nhập số khác được.
- **Không đặt nhịp thì tuyệt đối không nhắc gì** — cùng một nguyên tắc với "Mục tiêu không có hạn thì không hiện nhịp và dự báo".
- "Đến hạn xem lại" = ngày Đợt đánh giá gần nhất của Lĩnh vực **+** nhịp. Chưa có Đợt nào thì tính từ ngày tạo Lĩnh vực.
- Giá trị này **tính tại chỗ, không lưu cột nào** — AD-3. Xoá Đợt gần nhất thì ngày đến hạn phải tự lùi lại theo Đợt trước đó.

### FR-49: Đợt đánh giá gắn được vào Lĩnh vực

Mở rộng `Review` để nhìn lại được cả Lĩnh vực, không chỉ Dự án.

**Hệ quả kiểm thử được:**
- Mỗi Đợt thuộc **đúng một** chủ thể: một Dự án **hoặc** một Lĩnh vực, không bao giờ cả hai, không bao giờ mồ côi — AD-19.
- Mọi Đợt đang có sau migration đều thuộc Dự án, y như trước.
- Tạo Đợt cho Lĩnh vực thì đề nghị nạp sẵn Mục đánh giá từ tên các Dự án **đang mở** trong Lĩnh vực đó. Nạp là **chép văn bản** vào `ReviewItem.label`, không phải khoá ngoại — sửa Dự án về sau không đổi Đợt cũ.
- Người dùng bỏ chọn hoặc sửa từng Mục được nạp trước khi lưu; không nạp gì cũng được.
- Kế thừa Mục chưa đạt từ đợt trước (FR-37) hoạt động y hệt ở cấp Lĩnh vực.
- Tỷ lệ đạt vẫn tính tại chỗ, không lưu — AD-3.

### FR-50: Tư liệu sống độc lập với Dự án

Ghi chú và Liên kết phải sống lâu hơn Dự án sinh ra nó. Dự án xong rồi bài học
vẫn còn giá trị.

**Hệ quả kiểm thử được:**
- `Note` và `Link` gắn vào **một Dự án**, hoặc **một Lĩnh vực**, hoặc **không gắn gì** (kho chung) — nhiều nhất một cái, AD-18.
- **Xoá một Dự án không còn xoá Ghi chú và Liên kết của nó.** Chúng chuyển sang gắn vào Lĩnh vực mà Dự án đó thuộc về.
- Trước khi xoá Dự án, hộp xác nhận nói rõ *"N ghi chú và M liên kết sẽ chuyển sang Lĩnh vực «X»"*.
- Migration **để trống** `areaId` cho Ghi chú và Liên kết đang có: chúng vẫn giữ `projectId`, nên đã có chỗ thuộc về. Điền thêm `areaId` sẽ vi phạm chính ràng buộc nhiều-nhất-một ở AD-18. `areaId` chỉ được ghi vào lúc Dự án cha bị xoá.
- Màn hình *Tư liệu* liệt kê tất cả, lọc theo Lĩnh vực và theo *chưa gắn*.
- Chuyển một Ghi chú giữa Dự án ↔ Lĩnh vực ↔ kho chung được, không mất nội dung, `createdAt` giữ nguyên.
- `searchText` sinh lại đúng sau mỗi lần chuyển.

### FR-51: Lưu trữ là chiều riêng, không phải trạng thái

*"Không còn trong tầm mắt"* và *"đã xong"* là hai chuyện khác nhau. Một Dự án
`Xong` vẫn đáng nhìn thấy vài tuần; một Lĩnh vực không còn liên quan thì cất
đi dù chẳng bao giờ "xong".

**Hệ quả kiểm thử được:**
- Cột `archivedAt` kiểu `DateTime` **nullable** trên `areas`, `projects`, `notes`, `links`. Null nghĩa là còn trong tầm mắt.
- **Không thêm giá trị nào vào `ProjectStatus`.** Lưu trữ một Dự án `Đang làm` thì nó vẫn là `Đang làm` — AD-17.
- Do repository ghi, người dùng chỉ bấm *Lưu trữ* / *Đưa trở lại*. Không có ô nhập ngày — quy tắc dấu thời gian ở AD-5.
- Lưu trữ **không** ghi `StatusEvent`, **không** đụng vào `status`, `startedAt`, `completedAt`. Chỉ `archivedAt` và `updatedAt` đổi.
- Mọi danh sách mặc định ẩn mục đã lưu trữ; có bộ lọc *Hiện cả mục đã lưu trữ*.
- Lưu trữ một Lĩnh vực **không tự lưu trữ Dự án con**. Còn Dự án đang mở thì cảnh báo *"Lĩnh vực này còn N Dự án chưa lưu trữ"* và vẫn cho làm.
- Thống kê và lịch sử vẫn tính mục đã lưu trữ — lưu trữ là chuyện tầm mắt, không phải chuyện dữ liệu.
- Lưu trữ một Dự án thì **tự bỏ ghim** mọi Hành động của nó, cùng lý do với `Xong`/`Bỏ` ở quy tắc 4.

### FR-52: PARA không được đẩy thêm gì vào "Làm ngay"

Nhắc lại ràng buộc cũ để nó không bị lách qua đường vòng.

**Hệ quả kiểm thử được:**
- Danh sách *Làm ngay* vẫn chỉ gồm Hành động có `pinned = true` do người dùng tự ghim.
- Lĩnh vực đến hạn xem lại xuất hiện ở khối *Cần chú ý*, **không** ở *Làm ngay*.
- Nó là một dòng thông tin dẫn tới màn hình Lĩnh vực, không phải một đầu việc tick được.
- Có test khẳng định: đến hạn xem lại bao nhiêu Lĩnh vực đi nữa, số phần tử của *Làm ngay* không đổi.

## 4. Bất biến kiến trúc mới — AD-17…AD-20

*(Chép vào ARCHITECTURE-SPINE §"Bất biến và quy tắc" khi chốt.)*

### AD-17 — Lưu trữ vuông góc với trạng thái

- **Ràng buộc:** `areas`, `projects`, `notes`, `links`
- **Ngăn chặn:** thêm `archived` vào `ProjectStatus` sẽ (a) tạo từ đồng nghĩa với `dropped` và `paused`, (b) làm sai **mọi** phép tính đang dựa trên tập trạng thái đóng — tỷ lệ hoàn thành, cảnh báo nguội, thống kê theo hạn — mà không báo lỗi ở đâu cả
- **Quy tắc:** lưu trữ là cột `archivedAt` nullable, do repository ghi, không ghi `StatusEvent`, không đọc và không ghi cột `status`

Một Dự án có thể vừa `Đang làm` vừa đã lưu trữ. Nghe lạ nhưng đúng: người dùng
cất nó khỏi tầm mắt mà không nói dối về việc nó đang dở.

### AD-18 — Tư liệu không chết theo Dự án

- **Ràng buộc:** `notes`, `links`
- **Ngăn chặn:** `onDelete: cascade` hiện tại làm mất ghi chú im lặng mỗi lần dọn dẹp một Dự án cũ — đúng kiểu hỏng mà quy tắc tuyệt đối của project sinh ra để chặn
- **Quy tắc:** `projectId` và `areaId` đều nullable, **nhiều nhất một cái khác null**, biểu diễn bằng `customConstraints` ở tầng bảng chứ không chỉ bằng quy ước. `projectId` đổi sang `onDelete: setNull`; repository chịu trách nhiệm điền `areaId` trước khi xoá Dự án

### AD-19 — Đợt đánh giá thuộc đúng một chủ thể

- **Ràng buộc:** `reviews`
- **Ngăn chặn:** Đợt mồ côi không hiện ở đâu, hoặc Đợt thuộc hai nơi bị đếm hai lần trong thống kê
- **Quy tắc:** `projectId` và `areaId` đều nullable nhưng **đúng một cái khác null** (XOR, khác AD-18 ở chỗ không cho phép cả hai cùng null), biểu diễn bằng `customConstraints`. Cả hai cùng `onDelete: cascade` — xoá chủ thể thì Đợt của nó đi theo

### AD-20 — Không có thực thể `Resource`

- **Ràng buộc:** `lib/domain/models/`, từ điển thuật ngữ
- **Ngăn chặn:** một lớp `Resource` gộp `Note` và `Link` là đúng định nghĩa từ đồng nghĩa mà CLAUDE.md cấm
- **Quy tắc:** PARA "Resources" chỉ tồn tại như tên màn hình *Tư liệu* ở tầng l10n. Không lớp, không bảng, không provider mang tên đó

## 5. Epic 8 — chia việc

*(Chép vào `epics.md` khi chốt.)*

**Kết thúc Epic:** người dùng mở app, thấy sáu **Lĩnh vực** mỗi cái có tiêu
chuẩn và nhịp xem lại riêng; xoá một Dự án cũ mà ghi chú vẫn còn; cất những
thứ đã nguội đi mà không phải nói dối rằng chúng đã `Bỏ`.

### Story 8.1: Đổi tên Topic → Area, migration lên phiên bản 4

**Nghiệm thu:**
- Bảng `topics` → `areas`; `projects.topic_id` → `projects.area_id`; `schemaVersion` lên 4.
- Lớp `Topic` → `Area`, `TopicRow` → `AreaRow`, `DriftTopicRepository` → `DriftAreaRepository`, `topicsProvider` → `areasProvider`, nhãn l10n *Chủ đề* → *Lĩnh vực*.
- Không còn `Topic` như một **định danh sống**: không lớp, bảng, cột, provider
  hay nhãn l10n nào mang tên đó. Nhãn tiếng Việt là *Lĩnh vực*.
- Ba nhóm được phép giữ tên cũ, vì chúng nói về **quá khứ** chứ không phải
  về mô hình hiện tại — mỗi chỗ phải có ghi chú giải thích tại chỗ:
  1. Bước migration, vì phải gọi đúng tên bảng cũ để đổi tên nó;
  2. Khoá JSON `topics`/`topicId` của định dạng sao lưu v1…v3 — file cũ
     mang tên đó và phải đọc được sau nhiều năm (đổi ở Story 8.6);
  3. Fixture test dựng lại schema cũ và file sao lưu cũ.
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
- Migration **để trống** `area_id`: bản ghi nào còn `project_id` thì đã có chỗ thuộc về, và điền thêm sẽ phạm CHECK của AD-18. `area_id` chỉ ghi lúc xoá Dự án cha.
- **Test v4 → v5**: Ghi chú và Liên kết cũ giữ nguyên `project_id`, `area_id` là `null`, nội dung và `createdAt` không đổi.
- **Test ràng buộc thật**: chèn một Ghi chú có cả `project_id` lẫn `area_id` phải bị cơ sở dữ liệu từ chối, không chỉ bị quy ước trong mã ngăn.
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

## 6. Cái đề xuất này cố ý không làm

- **Không có Inbox.** PARA đầy đủ có bước thu gom nhanh trước khi phân loại. Nó giải một vấn đề khác (bắt ý tưởng thoáng qua) và sẽ kéo theo một màn hình, một bảng, một luồng phân loại. Tách ra bàn riêng.
- **Không có hệ thống thẻ.** Lĩnh vực đã là một chiều phân loại; thêm thẻ là chiều thứ hai chồng lên, và PARA không cần nó.
- **Không nối Tư liệu vào nhiều nơi cùng lúc.** Nhiều-nhất-một giữ cho mô hình đọc được. Nhiều-nhiều cần bảng nối và một màn hình quản lý mối nối.
- **Không đụng vào `Action`.** PARA dừng ở cấp Dự án; Hành động vẫn thuộc đúng một Dự án theo AD-8.
- **Không đổi màn hình Hôm nay.** FR-52 tồn tại chính là để chặn điều đó.

## 7. Khi chốt thì phải làm gì

1. Chép §3 vào `prd.md` thành **§4.10**, và thêm một dòng vào khối cảnh báo đầu file như lần sửa hướng 2026-08-28 đã làm.
2. Chép §4 vào `ARCHITECTURE-SPINE.md`, mục *Bất biến và quy tắc*. Cập nhật *Sơ đồ thực thể* và *Cây thư mục*.
3. Chép §5 vào `epics.md` thành **Epic 8**.
4. Sửa `CLAUDE.md`: từ điển thuật ngữ (`Topic` → `Area`, ghi chú về *Tư liệu*), mục *Trật tự tổ chức*, và thêm quy tắc tuyệt đối thứ 7 về lưu trữ.
5. Cập nhật bảng *Bản đồ tính năng sang kiến trúc* ở cuối SPINE.

Trước khi bắt đầu Story 8.1, chạy đủ bốn bước đổi schema đã ghi trong
`CLAUDE.md` §*Đổi cấu trúc cơ sở dữ liệu* — chụp schema, sinh helper, viết
`onUpgrade`, viết `migrateAndValidate`.

## 8. Rủi ro đã biết

| Rủi ro | Mức | Cách chặn |
|---|---|---|
| Migration v3→v4 đụng năm bảng cùng lúc, hỏng giữa chừng | Cao | Chia làm bốn bước `onUpgrade` độc lập trong cùng một giao dịch; mỗi Story có test `migrateAndValidate` riêng |
| Đổi `cascade` sang `setNull` để lọt Ghi chú mồ côi cả hai chiều | Trung bình | Migration điền `areaId` **trước**; repository điền lại trước mỗi lần xoá Dự án; test xoá Dự án kiểm cả ba bản ghi |
| Ràng buộc XOR/nhiều-nhất-một chỉ nằm trong đầu người viết | Trung bình | Viết bằng `customConstraints` ở tầng bảng, cộng test chèn dữ liệu sai và mong đợi thất bại |
| Đổi tên 140 chỗ làm sót một nhánh nào đó | Thấp | `grep -ri "topic\|chủ đề" lib/ test/ docs/` là tiêu chí nghiệm thu của Story 8.1, cộng `fvm flutter analyze` sạch |
| Người dùng lẫn *Lưu trữ* với *Bỏ* | Thấp | Hai chỗ khác nhau trong giao diện; nhãn *Lưu trữ* kèm mô tả một dòng *"cất khỏi danh sách, không đổi trạng thái"* |
