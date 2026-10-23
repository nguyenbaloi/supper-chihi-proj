---
title: "PRD: App Quản lý Dự án & Mục tiêu Cá nhân"
status: draft
created: 2026-08-28
updated: 2026-08-28
source_brief: "_bmad-output/planning-artifacts/briefs/brief-quan-ly-du-an-muc-tieu-2026-08-28/brief.md"
---

# PRD: App Quản lý Dự án & Mục tiêu Cá nhân

> **SỬA HƯỚNG NGÀY 2026-08-28 — đọc trước mọi thứ khác.**
>
> Sau lần kiểm thử tay đầu tiên, người dùng yêu cầu bảy thay đổi. Một trong đó
> đảo lại nguyên tắc nền của tài liệu này: **tính năng Mục tiêu bị bỏ hẳn**, cả
> mã nguồn lẫn dữ liệu.
>
> Trật tự cũ *"Mục tiêu là gốc, Dự án là nhánh, Hành động là lá"* không còn
> hiệu lực. Trật tự mới: **Chủ đề nhóm Dự án, Dự án chứa Hành động**, và mỗi
> Hành động có độ ưu tiên cùng hạn riêng.
>
> Hệ quả lên tài liệu này:
>
> - **§4.4 (FR-20…FR-26) — bỏ toàn bộ.** Mục tiêu, Mốc tiến độ, tiến độ, nhịp,
>   dự báo về đích, mối nối Dự án–Mục tiêu: không còn.
> - **FR-25** mối nối Dự án–Mục tiêu — bỏ.
> - **FR-29** màn hình Hôm nay — **viết lại**, xem FR-42 và FR-43.
> - **§7 mục 1 và 2** — hết hiệu lực cùng với Mục tiêu.
> - Thêm **§4.9** với FR-41…FR-45.
> - **Bổ sung ngày 2026-09-03:** thêm **§4.10** với FR-46…FR-52 — cấu trúc
>   PARA. `Chủ đề` đổi tên thành **Lĩnh vực** (`Topic` → `Area`) ở mọi chỗ
>   trong tài liệu này, kể cả từ điển §3 và các FR viết trước.
>
> Phần văn bản gốc bên dưới được giữ nguyên làm hồ sơ, **không** phải mô tả sản
> phẩm hiện tại ở những chỗ vừa nêu.


## 0. Mục đích tài liệu

Tài liệu này định nghĩa **cái gì** ứng dụng phải làm được, không định nghĩa **làm bằng cách nào**. Mỗi yêu cầu chức năng (FR) được viết kèm phần *Hệ quả kiểm thử được* — những câu có thể chuyển thẳng thành tiêu chí nghiệm thu và test.

Ba tài liệu phía trước cần đọc cùng: `brief.md` (vấn đề và giải pháp), `addendum.md` (dữ liệu hạt giống thật và ràng buộc kỹ thuật kế thừa), `.memlog.md` (nhật ký quyết định).

Mục 3 — **Từ điển thuật ngữ** — là ràng buộc bắt buộc lên cả code lẫn giao diện. Đưa vào một từ đồng nghĩa ở bất kỳ đâu là vi phạm PRD.

## 1. Tầm nhìn

Một ứng dụng mobile offline biến hai file văn bản tĩnh thành một hệ thống sống, tổ chức theo đúng trật tự người dùng đã tự nghĩ ra: **Mục tiêu là gốc, Dự án là nhánh, Hành động là lá.**

Thước đo thành công duy nhất, đo được: **sau ba tháng, ứng dụng vẫn còn được mở và cập nhật.** Hai file PDF là bằng chứng của một hệ thống đã chết vì chi phí cập nhật quá cao; sản phẩm này chỉ có giá trị nếu chi phí đó thấp hơn.

Thước đo phụ, đo trong một phiên dùng: **mở app → biết hôm nay làm gì, trong mười giây, không cần chạm quá một lần.**

## 2. Người dùng mục tiêu

### 2.1 Công việc cần hoàn thành

| # | Khi nào | Người dùng muốn | Để mà |
|---|---|---|---|
| JTBD-1 | Mỗi sáng, cầm điện thoại | Nhìn thấy đúng vài việc đáng làm hôm nay | Không phải đọc lại toàn bộ danh sách rồi vẫn phân vân |
| JTBD-2 | Vừa làm xong một việc | Đánh dấu xong ngay tại chỗ | Ghi nhận không bị trì hoãn rồi quên mất |
| JTBD-3 | Cuối tuần, ngồi xem lại | Biết dự án nào đang tắc và tắc bao lâu | Quyết định bỏ hẳn, tạm dừng, hay dồn sức vào |
| JTBD-4 | Sau một mốc tài chính | Ghi con số mới vào mục tiêu lớn | Biết mình đang đi nhanh hay chậm so với đích |
| JTBD-5 | Khi nghĩ ra việc cần làm | Ghi vào đúng dự án trong vài giây | Ý nghĩ không bốc hơi trước khi về tới máy tính |
| JTBD-6 | Khi cần tra lại nguyên tắc đã đúc kết | Tìm ra ghi chú cũ | Không phải mở lại file PDF trên máy tính |

### 2.2 Không phục vụ ai ở bản đầu

- **Người muốn quản lý công việc cơ quan.** Ứng dụng này chỉ chứa bảy hướng đi cá nhân. Việc ở công ty không thuộc phạm vi.
- **Nhóm, gia đình, cộng tác nhiều người.** Không tài khoản, không chia sẻ, không phân công.
- **Người cần theo dõi tài sản đầu tư.** Đó là việc của app `personal_finance`. Ở đây chỉ có *ý chí* — mục tiêu, nguyên tắc, hành động — không có *số liệu tài sản*.
- **Người dùng iOS/Android khác.** Sản phẩm phục vụ một người dùng duy nhất, không tính chuyện phát hành rộng ở bản đầu.

### 2.3 Hành trình người dùng chính

**Lần chạy đầu tiên.** Mở app → được hỏi có muốn nạp sẵn bảy dự án và các hành động từ hai file cũ không → chọn nạp → vào ngay màn hình Hôm nay, đã có dữ liệu thật, không phải màn hình trống.

**Một ngày thường.** Mở app → màn hình Hôm nay hiện: 1 hành động quá hạn, 2 hành động đang làm, cảnh báo *"Kênh TikTok — 34 ngày không hoạt động"* → chạm ô tròn bên trái một hành động để đánh dấu xong → đóng app. Tổng cộng hai chạm.

**Xem lại cuối tuần.** Mở tab Dự án → lọc `Đang làm` → thấy 3 dự án, mỗi dự án hiện tỷ lệ hoàn thành và ngày hoạt động gần nhất → mở dự án đang tắc → chuyển sang `Tạm dừng` kèm một dòng ghi chú lý do.

**Cập nhật mục tiêu lớn.** Mở tab Mục tiêu → chọn `Mục tiêu 1 tỷ` → thêm một mốc: ngày hôm nay, giá trị 340.000.000 → biểu đồ vẽ lại, app hiện *"34% — còn 660 triệu"* và, nếu có hạn chót, thêm *"nhịp hiện tại về đích chậm 4 tháng"*.

## 3. Từ điển thuật ngữ

Từ trong cột **Thuật ngữ** là từ duy nhất được dùng trong code, giao diện và mọi tài liệu sau. Cột **Định danh** là tên dùng trong mã nguồn.

| Thuật ngữ | Định danh | Nghĩa |
|---|---|---|
| **Dự án** | `Project` | Một hướng đi người dùng đang triển khai. Bảy dự án gốc lấy từ file `Ý TƯỞNG`. Có chủ đề, trạng thái, độ ưu tiên |
| **Hành động** | `Action` | Một việc cụ thể phải làm, luôn thuộc về đúng một Dự án. Tương ứng một dòng gạch đầu dòng trong file `HÀNH ĐỘNG` |
| **Mục tiêu** | `Goal` | Đích đến dài hạn. Có thể có số (1 tỷ VND) hoặc không số (*"tìm thêm một nguồn thu nhập khác"*) |
| **Mốc tiến độ** | `GoalUpdate` | Một lần ghi nhận giá trị của Mục tiêu tại một ngày. Chỉ áp dụng cho Mục tiêu có số |
| **Lĩnh vực** | `Area` | Mảng trách nhiệm phải giữ, không bao giờ kết thúc: Gia đình, Thu nhập, Tài chính, Sức khoẻ, Học tập, Khác. Có tiêu chuẩn cần giữ và nhịp xem lại. **Đổi tên từ `Topic`/Chủ đề ngày 2026-09-03 — từ cũ không còn hiệu lực ở bất kỳ đâu** |
| **Tư liệu** | *(không có lớp)* | Nhãn nhóm ở giao diện, gộp `Note` và `Link`. **Không** là thực thể — AD-20 |
| **Lưu trữ** | `archivedAt` | Cất khỏi tầm mắt. Vuông góc với trạng thái, **không** là một giá trị của `ProjectStatus` — AD-17 |
| **Ghi chú** | `Note` | Nội dung dài dạng markdown gắn vào một Dự án — nguyên tắc, kiến thức, bài học |
| **Liên kết** | `Link` | Một URL ngoài gắn vào một Dự án, kèm nhãn |
| **Trạng thái Dự án** | `ProjectStatus` | `Chưa bắt đầu` · `Đang làm` · `Tạm dừng` · `Xong` · `Bỏ` |
| **Trạng thái Hành động** | `ActionStatus` | `Chưa` · `Đang làm` · `Xong` · `Bỏ` |
| **Độ ưu tiên** | `Priority` | `Cao` · `Trung bình` · `Thấp` |
| **Tỷ lệ hoàn thành** | `completionRatio` | Số Hành động `Xong` chia tổng Hành động chưa `Bỏ` của một Dự án. **Luôn tính, không bao giờ lưu** |
| **Tiến độ** | `progressRatio` | Giá trị Mốc gần nhất chia giá trị đích của Mục tiêu. **Luôn tính, không bao giờ lưu** |
| **Dự án nguội** | — | Dự án `Đang làm` nhưng không có Hành động nào đổi trạng thái trong N ngày (mặc định 21) |
| **Hôm nay** | — | Màn hình mở đầu, gom việc cần chú ý nhất |
| **Đợt đánh giá** | `Review` | Một lần nhìn lại Dự án tại một ngày cụ thể, chấm kết quả cho từng mục và đặt ngày xem lại tiếp theo |
| **Mục đánh giá** | `ReviewItem` | Một dòng trong Đợt đánh giá: nội dung cần đạt kèm kết quả `Đạt` · `Chưa đạt` · `Một phần` |
| **Bản sao lưu** | `Backup` | Một file JSON chứa toàn bộ dữ liệu, do người dùng tự xuất và tự giữ |

## 4. Yêu cầu chức năng

### 4.1 Khởi tạo và dữ liệu hạt giống

Nguyên tắc: người dùng **không bao giờ nhìn thấy một app trống**. Dữ liệu thật đã tồn tại trong hai file PDF; việc bắt gõ lại là lý do đủ để bỏ app ngay ngày đầu.

#### FR-1: Dựng sẵn bộ Chủ đề chuẩn

Ứng dụng tạo sẵn sáu Chủ đề ngay khi cài, người dùng không phải khai báo từ đầu.

**Hệ quả kiểm thử được:**
- Sau khi cài, có đúng sáu Chủ đề: Gia đình, Thu nhập, Tài chính, Sức khoẻ, Học tập, Khác.
- Mỗi Chủ đề có tên, biểu tượng và màu riêng, phân biệt được trên danh sách Dự án.
- Người dùng sửa được tên, màu, biểu tượng của Chủ đề; thêm và xoá được Chủ đề.
- Xoá một Chủ đề đang có Dự án thì các Dự án đó chuyển về `Khác`, không bị xoá theo.

#### FR-2: Nạp bảy Dự án hạt giống ở lần chạy đầu

Màn hình đầu tiên đề nghị nạp sẵn bảy Dự án lấy từ file `Ý TƯỞNG`, kèm Chủ đề đã gán sẵn.

**Hệ quả kiểm thử được:**
- Bảy Dự án được tạo đúng tên đã ghi ở `addendum.md` §1.1, mỗi Dự án gán đúng Chủ đề trong bảng đó.
- Trạng thái khởi tạo của cả bảy là `Đang làm`, độ ưu tiên `Trung bình`.
- Sau khi nạp, tab Dự án hiện đúng bảy bản ghi.

#### FR-3: Nạp Hành động, Ghi chú và Liên kết hạt giống

Cùng thao tác nạp ở FR-2, ứng dụng tạo luôn các Hành động, Ghi chú và Liên kết đã có trong hai file.

**Hệ quả kiểm thử được:**
- Sáu Hành động ở `addendum.md` §1.2 được tạo dưới Dự án `Kế hoạch tài chính`, ánh xạ trạng thái đúng bảng đó (`Xong` → `Xong`, `Chưa` → `Chưa`, `Đang làm` → `Đang làm`).
- Hai Ghi chú được tạo: một chứa toàn bộ phần *Nợ tốt / Khi nào nên vay*, một chứa các nguyên tắc thị trường (§1.4).
- Bốn Liên kết được tạo và gắn đúng Dự án theo bảng §1.5.
- Mục tiêu `1 tỷ` (có số, đơn vị VND, không hạn chót) và `Tìm thêm một nguồn thu nhập khác` (không số) được tạo.
- Mục tiêu `1 tỷ` được nối sẵn vào Dự án `Kế hoạch tài chính`; mục tiêu còn lại nối vào `Kênh TikTok/YouTube tiếp thị liên kết` và `Viết app đẩy store kiếm thu nhập`.

#### FR-4: Bỏ qua nạp hạt giống

Người dùng chọn bỏ qua và bắt đầu từ trống.

**Hệ quả kiểm thử được:**
- Chọn bỏ qua thì chỉ sáu Chủ đề ở FR-1 tồn tại, không Dự án nào được tạo.
- Đề nghị nạp không xuất hiện lại ở các lần mở app sau.
- Trong Cài đặt luôn có mục nạp lại dữ liệu hạt giống; chạy lại **không nhân đôi** bản ghi đã có (đối chiếu theo tên Dự án).

### 4.2 Quản lý Dự án

#### FR-5: Tạo Dự án

**Hệ quả kiểm thử được:**
- Trường bắt buộc duy nhất là **tên**. Mọi trường khác có mặc định hợp lý.
- Mặc định: Chủ đề `Khác`, trạng thái `Chưa bắt đầu`, độ ưu tiên `Trung bình`, không hạn chót.
- Tên rỗng hoặc chỉ khoảng trắng bị từ chối kèm thông báo rõ.
- Tạo xong mở thẳng màn hình chi tiết Dự án vừa tạo.

#### FR-6: Sửa Dự án

**Hệ quả kiểm thử được:**
- Sửa được: tên, mô tả, Chủ đề, độ ưu tiên, hạn chót, trạng thái.
- `updatedAt` của Dự án tự cập nhật sau mỗi lần sửa; người dùng không nhập trường này.
- Đổi Chủ đề không ảnh hưởng tới Hành động, Ghi chú, Liên kết thuộc Dự án.

#### FR-7: Xoá Dự án

**Hệ quả kiểm thử được:**
- Xoá luôn hỏi xác nhận, và câu hỏi nêu rõ số Hành động, Ghi chú, Liên kết sẽ mất theo.
- Xoá Dự án xoá theo toàn bộ Hành động, Ghi chú, Liên kết của nó, và mọi mối nối tới Mục tiêu.
- Xoá Dự án **không** xoá Mục tiêu đã nối, kể cả khi đó là Dự án cuối cùng nối tới Mục tiêu đó.
- Trạng thái `Bỏ` được nêu ra như lựa chọn thay thế trong hộp xác nhận.

#### FR-8: Trạng thái Dự án và dấu thời gian tự động

**Hệ quả kiểm thử được:**
- Đúng năm trạng thái: `Chưa bắt đầu` · `Đang làm` · `Tạm dừng` · `Xong` · `Bỏ`. Không có trạng thái thứ sáu, không có ô nhập tự do.
- Lần đầu chuyển sang `Đang làm`, `startedAt` được ghi; chuyển sang `Xong`, `completedAt` được ghi.
- Quay lại `Đang làm` từ `Xong` thì `completedAt` bị xoá, `startedAt` **giữ nguyên** giá trị lần đầu.
- Mọi lần đổi trạng thái được ghi vào lịch sử của Dự án kèm mốc thời gian, xem lại được.

#### FR-9: Độ ưu tiên

**Hệ quả kiểm thử được:**
- Ba mức: `Cao` · `Trung bình` · `Thấp`, phân biệt bằng màu và nhãn chữ — không chỉ bằng màu.
- Độ ưu tiên là một tiêu chí sắp xếp danh sách Dự án.

#### FR-10: Danh sách Dự án — lọc và sắp xếp

**Hệ quả kiểm thử được:**
- Lọc theo trạng thái (chọn nhiều) và theo Chủ đề (chọn nhiều), hai bộ lọc kết hợp bằng AND.
- Mặc định danh sách ẩn Dự án `Xong` và `Bỏ`; có công tắc hiện lại.
- Sắp xếp theo: độ ưu tiên, hoạt động gần nhất, tên, hạn chót.
- Mỗi dòng hiện: tên, Chủ đề, trạng thái, tỷ lệ hoàn thành, số ngày kể từ hoạt động gần nhất.
- Bộ lọc và cách sắp xếp được nhớ giữa các lần mở app.

#### FR-11: Màn hình chi tiết Dự án

**Hệ quả kiểm thử được:**
- Hiện đủ: tên, mô tả, Chủ đề, trạng thái, độ ưu tiên, hạn chót, tỷ lệ hoàn thành, các Mục tiêu đã nối.
- Danh sách Hành động của Dự án, nhóm theo trạng thái, `Xong` và `Bỏ` gom vào một mục thu gọn được.
- Truy cập được Ghi chú và Liên kết của Dự án ngay trên màn hình này.
- Thêm Hành động mới bằng đúng một chạm, không rời màn hình.

#### FR-12: Tỷ lệ hoàn thành là giá trị suy ra

**Hệ quả kiểm thử được:**
- Tỷ lệ hoàn thành = số Hành động `Xong` ÷ số Hành động không ở trạng thái `Bỏ`, tính lại mỗi lần hiển thị.
- Dự án không có Hành động nào hiện `—`, không hiện `0%`.
- **Không tồn tại cột `completionRatio` hay `completionPercent` trong bất kỳ bảng nào của cơ sở dữ liệu.**
- Đổi trạng thái một Hành động thì tỷ lệ của Dự án cha đổi theo ngay, không cần thao tác làm mới.

#### FR-13: Chỉ báo Dự án nguội

**Hệ quả kiểm thử được:**
- Dự án ở trạng thái `Đang làm` mà không có Hành động nào đổi trạng thái trong N ngày được đánh dấu nguội.
- N mặc định 21, sửa được trong Cài đặt, chấp nhận giá trị từ 7 đến 180.
- Dự án `Tạm dừng`, `Xong`, `Bỏ`, `Chưa bắt đầu` không bao giờ bị đánh dấu nguội.
- Dự án nguội xuất hiện ở màn hình Hôm nay theo FR-29.

### 4.3 Quản lý Hành động

#### FR-14: Thêm Hành động

**Hệ quả kiểm thử được:**
- Hành động luôn thuộc đúng một Dự án; không tồn tại Hành động mồ côi.
- Trường bắt buộc duy nhất là **tiêu đề**; hạn chót và ghi chú là tuỳ chọn.
- Thêm xong, ô nhập giữ nguyên tiêu điểm để gõ tiếp Hành động kế — nhập liên tiếp không cần chạm lại.
- Hành động mới có trạng thái `Chưa` và nằm cuối danh sách.

#### FR-15: Sửa và xoá Hành động

**Hệ quả kiểm thử được:**
- Sửa được: tiêu đề, ghi chú, hạn chót, trạng thái, và **Dự án chủ quản** (chuyển Hành động sang Dự án khác).
- Xoá hỏi xác nhận, và có thao tác hoàn tác trong vài giây sau khi xoá.
- Chuyển Hành động sang Dự án khác làm tỷ lệ hoàn thành của **cả hai** Dự án được tính lại.

#### FR-16: Trạng thái Hành động và dấu thời gian tự động

**Hệ quả kiểm thử được:**
- Đúng bốn trạng thái: `Chưa` · `Đang làm` · `Xong` · `Bỏ`.
- Chuyển sang `Đang làm` lần đầu ghi `startedAt`; chuyển sang `Xong` ghi `completedAt`.
- Bỏ đánh dấu `Xong` thì `completedAt` bị xoá.
- Hành động `Đang làm` hiện số ngày kể từ `startedAt` — trả lời trực tiếp câu hỏi *"đang làm bao lâu rồi"*.

#### FR-17: Hạn hoàn thành và quá hạn

**Hệ quả kiểm thử được:**
- Hạn chót là ngày, không có giờ.
- Hành động chưa `Xong`/`Bỏ` mà hạn chót nhỏ hơn hôm nay được đánh dấu quá hạn, kèm số ngày trễ.
- Hành động `Xong` không bao giờ hiện quá hạn, kể cả khi hoàn thành sau hạn.
- Hành động quá hạn xuất hiện ở đầu màn hình Hôm nay theo FR-29.

#### FR-18: Sắp xếp thủ công thứ tự Hành động

**Hệ quả kiểm thử được:**
- Kéo thả để đổi thứ tự Hành động trong một Dự án; thứ tự được lưu và giữ nguyên sau khi mở lại app.
- Thứ tự thủ công là cách sắp xếp mặc định trong màn hình chi tiết Dự án.

#### FR-19: Đánh dấu Xong bằng một chạm

**Hệ quả kiểm thử được:**
- Mỗi Hành động có ô tròn chạm được, đổi trạng thái giữa `Chưa`/`Đang làm` và `Xong` mà không mở màn hình nào khác.
- Thao tác này khả dụng ở cả màn hình Hôm nay lẫn chi tiết Dự án.
- Có phản hồi rung nhẹ và hoàn tác được ngay sau đó.

### 4.4 Mục tiêu và tiến độ

#### FR-20: Tạo Mục tiêu — có số và không số

**Hệ quả kiểm thử được:**
- Mục tiêu **có số** yêu cầu: giá trị đích và đơn vị (VND, giờ, kg, lần, …). Hạn chót tuỳ chọn.
- Mục tiêu **không số** chỉ có tên, mô tả và hạn chót tuỳ chọn; không có thanh phần trăm, không có sổ Mốc.
- Mục tiêu có số đơn vị VND lưu giá trị bằng **số nguyên đơn vị đồng**, không dùng số thực.
- Mục tiêu 1.000.000.000 VND nhập và hiển thị đúng là `1.000.000.000 ₫`, không mất chữ số.

#### FR-21: Sổ Mốc tiến độ

**Hệ quả kiểm thử được:**
- Mỗi Mốc gồm: ngày, giá trị, ghi chú tuỳ chọn. Ngày mặc định là hôm nay.
- Sửa và xoá được Mốc bất kỳ, kể cả Mốc ở giữa chuỗi và kể cả đổi ngày của nó.
- Sau khi sửa/xoá/đổi ngày một Mốc quá khứ, **mọi con số dẫn xuất phía sau tự đúng theo** mà không cần thao tác nào khác.
- Nhiều Mốc cùng một ngày được chấp nhận; Mốc mới hơn theo thời điểm nhập được coi là giá trị của ngày đó.

#### FR-22: Tiến độ luôn suy ra

**Hệ quả kiểm thử được:**
- Giá trị hiện tại của Mục tiêu = giá trị của Mốc có ngày lớn nhất (≤ hôm nay). Không có Mốc nào thì giá trị hiện tại là `—`, không phải `0`.
- Tiến độ = giá trị hiện tại ÷ giá trị đích, tính lại mỗi lần hiển thị.
- **Không tồn tại cột `currentValue`, `progress` hay `progressPercent` trong bất kỳ bảng nào của cơ sở dữ liệu.**
- Tiến độ vượt 100% được hiển thị đúng như vậy, không bị chặn ở 100%.

#### FR-23: Biểu đồ đường tiến độ

**Hệ quả kiểm thử được:**
- Trục ngang là thời gian, trục dọc là giá trị; mỗi Mốc là một điểm, nối bằng đường.
- Giá trị đích hiện thành một đường ngang tham chiếu.
- Có hạn chót thì hiện thêm đường nhịp lý tưởng nối từ Mốc đầu tiên tới điểm (hạn chót, giá trị đích).
- Dưới hai Mốc thì hiện thông báo cần thêm dữ liệu, không vẽ biểu đồ một điểm.

#### FR-24: Nhịp cần đi và dự báo về đích

**Hệ quả kiểm thử được:**
- Có hạn chót và ít nhất hai Mốc: hiện *khoảng còn thiếu*, *thời gian còn lại*, và *mức cần thêm mỗi tháng để về đích*.
- Dựa trên nhịp trung bình giữa các Mốc thực tế, hiện dự báo dạng *"nhịp hiện tại về đích sớm/chậm X tháng"*.
- Không có hạn chót thì **chỉ** hiện phần trăm và khoảng còn thiếu; ứng dụng tuyệt đối không suy đoán nhịp.
- Nhịp trung bình âm (đang đi lùi) được nói thẳng, không giấu và không hiện dự báo dương.

#### FR-25: Nối Dự án vào Mục tiêu

**Hệ quả kiểm thử được:**
- Một Dự án nối được vào nhiều Mục tiêu; một Mục tiêu nhận được nhiều Dự án.
- Màn hình chi tiết Mục tiêu liệt kê các Dự án đã nối, kèm trạng thái và tỷ lệ hoàn thành của từng Dự án.
- Gỡ mối nối không xoá Dự án cũng không xoá Mục tiêu.
- Mục tiêu không có Dự án nào nối tới được đánh dấu trực quan — đó là mục tiêu chưa có đường đi.

#### FR-26: Số học tiền tệ không mất chính xác

**Hệ quả kiểm thử được:**
- Giá trị đích và giá trị Mốc của Mục tiêu đơn vị VND lưu bằng số nguyên đơn vị đồng.
- Phép chia khi tính tiến độ và nhịp dùng kiểu số thập phân chính xác, làm tròn đúng một lần ở lớp hiển thị.
- Kiểu `double` không xuất hiện trong tầng nghiệp vụ và không xuất hiện ở bất kỳ cột nào của cơ sở dữ liệu.
- 340.000.000 ÷ 1.000.000.000 hiển thị `34,0%` — không phải `33,9%` hay `34,00000001%`.

### 4.5 Ghi chú và Liên kết

#### FR-27: Ghi chú gắn vào Dự án

**Hệ quả kiểm thử được:**
- Ghi chú có tiêu đề và nội dung dài, viết bằng markdown, hiển thị đã dựng hình (đậm, danh sách, tiêu đề con).
- Một Dự án chứa nhiều Ghi chú; sắp xếp theo thời điểm cập nhật gần nhất.
- Toàn bộ nội dung phần *Nợ tốt / Khi nào nên vay* nhập vào giữ nguyên cấu trúc danh sách và tiêu đề con.
- Ghi chú tìm được bằng tìm kiếm toàn cục theo FR-30.

#### FR-28: Liên kết ngoài

**Hệ quả kiểm thử được:**
- Liên kết có nhãn và URL, gắn vào một Dự án.
- Chạm vào Liên kết mở trình duyệt hệ thống; ứng dụng không nhúng trình duyệt và không tự tải nội dung.
- URL sai định dạng bị từ chối ngay lúc nhập kèm thông báo rõ.
- Sao chép URL vào bộ nhớ tạm bằng một thao tác.

### 4.6 Màn hình Hôm nay và tìm kiếm

#### FR-29: Màn hình Hôm nay

Đây là màn hình mở đầu và là lý do tồn tại của ứng dụng ở nhịp dùng hằng ngày.

**Hệ quả kiểm thử được:**
- Bốn nhóm, theo đúng thứ tự này: **Quá hạn** → **Đang làm** → **Đến hạn trong 7 ngày** → **Cần chú ý**.
- Nhóm *Cần chú ý* gồm: Dự án nguội theo FR-13, và Mục tiêu có hạn chót đang chậm nhịp theo FR-24.
- Nhóm rỗng không hiện tiêu đề rỗng — nó biến mất hoàn toàn.
- Không còn gì cần chú ý thì hiện một trạng thái trống có nghĩa, kèm lối tắt tới danh sách Dự án.
- Mỗi dòng Hành động đánh dấu `Xong` được ngay tại chỗ theo FR-19, và mở được Dự án cha bằng một chạm.
- Màn hình này không bao giờ liệt kê **toàn bộ** Hành động chưa xong — chỉ đúng bốn nhóm trên.

#### FR-30: Tìm kiếm toàn cục

**Hệ quả kiểm thử được:**
- Một ô tìm kiếm duy nhất quét đồng thời: tên và mô tả Dự án, tiêu đề và ghi chú Hành động, tên Mục tiêu, tiêu đề và nội dung Ghi chú, nhãn Liên kết.
- Kết quả nhóm theo loại, ghi rõ mỗi kết quả thuộc Dự án nào.
- Tìm kiếm **không phân biệt hoa thường và không phân biệt dấu tiếng Việt**: gõ `tai chinh` tìm ra `Kế hoạch tài chính`.
- Kết quả cập nhật khi đang gõ, không cần nhấn nút tìm.

### 4.7 Dữ liệu, sao lưu và cài đặt

#### FR-31: Xuất Bản sao lưu

**Hệ quả kiểm thử được:**
- Xuất ra một file JSON duy nhất chứa **toàn bộ** dữ liệu: Chủ đề, Dự án, Hành động, Mục tiêu, Mốc, Ghi chú, Liên kết, mối nối, và cài đặt.
- File có trường phiên bản schema ở đầu.
- Tên file chứa ngày xuất, dạng `sao-luu-YYYY-MM-DD.json`.
- Xuất xong, người dùng chia sẻ file qua chức năng chia sẻ của hệ điều hành (AirDrop, email, lưu vào Files).

#### FR-32: Nhập khôi phục

**Hệ quả kiểm thử được:**
- Nhập một file JSON đã xuất trước đó khôi phục đúng trạng thái tại thời điểm xuất — kiểm chứng bằng chu trình xuất → xoá sạch → nhập → so khớp toàn bộ.
- Trước khi ghi đè, ứng dụng hỏi xác nhận và nêu rõ dữ liệu hiện tại sẽ bị thay thế.
- File sai định dạng hoặc sai phiên bản schema bị từ chối kèm lý do cụ thể, và **dữ liệu hiện tại không bị đụng tới**.
- Nhập là thao tác nguyên tử: hoặc thành công toàn bộ, hoặc không thay đổi gì.

#### FR-33: Hoạt động hoàn toàn offline

**Hệ quả kiểm thử được:**
- Ứng dụng không thực hiện bất kỳ lời gọi mạng nào — không đồng bộ, không phân tích hành vi, không thu thập số liệu sử dụng, không quảng cáo.
- Bật chế độ máy bay, mọi chức năng hoạt động đầy đủ, không thông báo lỗi nào.
- Ngoại lệ duy nhất: mở URL của Liên kết ra **trình duyệt ngoài** theo FR-28 — bản thân ứng dụng không tải nội dung đó.
- Ứng dụng không xin quyền mạng nào ngoài mức mặc định của nền tảng.

#### FR-34: Cài đặt và giao diện

**Hệ quả kiểm thử được:**
- Toàn bộ chuỗi hiển thị bằng tiếng Việt, đi qua lớp l10n — không viết thẳng trong widget.
- Ngày hiển thị dạng `dd/MM/yyyy`; số dùng dấu chấm phân cách nghìn và dấu phẩy thập phân theo chuẩn Việt Nam.
- Giao diện theo chế độ sáng/tối của hệ thống, đè tay được trong Cài đặt.
- Cài đặt chứa: ngưỡng ngày nguội (FR-13), nạp lại dữ liệu hạt giống (FR-4), xuất/nhập sao lưu (FR-31, FR-32), và xoá sạch dữ liệu có xác nhận hai bước.

### 4.8 Đợt đánh giá định kỳ

Nhóm này sinh ra từ file `Dạy huy.pdf` — nhật ký theo dõi tiến bộ của con trai
với hai đợt nhìn lại cách nhau gần ba tháng (15/5 lúc 28 tháng, 7/8 lúc 2 tuổi
rưỡi). Cấu trúc của nó khác hẳn Hành động: **cùng một nội dung được chấm đi
chấm lại ở nhiều mốc thời gian**, và kết quả không phải `Xong`/`Chưa` mà là
`Đạt`/`Chưa đạt`/`Một phần`.

Hành động trả lời *"việc này làm xong chưa"*. Đợt đánh giá trả lời *"ba tháng
qua có tiến bộ không"*. Nhét cái sau vào cái trước sẽ làm hỏng ngữ nghĩa của cả
hai — đó là lý do đây là một nhóm thực thể riêng.

#### FR-35: Tạo Đợt đánh giá cho một Dự án

**Hệ quả kiểm thử được:**
- Đợt đánh giá thuộc đúng một Dự án, có **ngày đánh giá** (mặc định hôm nay), tiêu đề tuỳ chọn, và phần tóm tắt dạng markdown.
- Có trường **ngày xem lại tiếp theo** — tuỳ chọn. Đây là "mốc time" của chu kỳ.
- Một Dự án chứa nhiều Đợt đánh giá; sắp xếp theo ngày giảm dần.
- Tiêu đề để trống thì hiển thị bằng ngày đánh giá.

#### FR-36: Mục đánh giá với ba kết quả

**Hệ quả kiểm thử được:**
- Mỗi Mục đánh giá có nội dung (bắt buộc), kết quả, và ghi chú tuỳ chọn.
- Đúng ba kết quả: `Đạt` · `Chưa đạt` · `Một phần`. Lưu bằng chuỗi ổn định `met` · `not_met` · `partial`.
- Kết quả phân biệt bằng cả màu lẫn nhãn chữ — NFR-7.
- Kéo thả đổi thứ tự Mục trong một Đợt.
- Xoá Đợt đánh giá xoá theo toàn bộ Mục của nó.

#### FR-37: Kế thừa mục chưa đạt từ đợt trước

Đây là hành vi lặp lại rõ nhất trong tài liệu gốc: *"Tổng kết: 2 đạt 3 chưa
đạt, tiếp tục cải thiện những cái chưa đạt"*.

**Hệ quả kiểm thử được:**
- Khi tạo Đợt mới trên một Dự án đã có Đợt trước, ứng dụng đề nghị chép sang các Mục có kết quả `Chưa đạt` và `Một phần`.
- Mục được chép sang mang kết quả khởi điểm `Chưa đạt`, giữ nguyên nội dung và thứ tự tương đối.
- Mục `Đạt` **không** được chép.
- Người dùng bỏ chọn từng Mục trước khi chép; bỏ chọn hết thì Đợt mới trống.

#### FR-38: Dòng thời gian đánh giá

**Hệ quả kiểm thử được:**
- Màn hình Dự án có một thẻ riêng liệt kê các Đợt theo thứ tự thời gian, mỗi Đợt hiện ngày và tỷ lệ đạt.
- Mở một Đợt thấy đầy đủ Mục, kết quả, ghi chú và phần tóm tắt.
- Dự án chưa có Đợt nào hiện trạng thái trống kèm nút tạo Đợt đầu tiên.

#### FR-39: Tỷ lệ đạt là giá trị suy ra

**Hệ quả kiểm thử được:**
- Tỷ lệ đạt của một Đợt = số Mục `Đạt` ÷ tổng số Mục, tính lại mỗi lần hiển thị.
- `Một phần` tính vào mẫu số nhưng không tính vào tử số.
- Đợt không có Mục nào hiện `—`, không hiện `0%`.
- **Không tồn tại cột `metCount`, `metRatio` hay `itemCount` trong bất kỳ bảng nào.**

#### FR-40: Đến hạn đánh giá xuất hiện ở màn hình Hôm nay

**Hệ quả kiểm thử được:**
- Dự án có Đợt đánh giá gần nhất mang **ngày xem lại tiếp theo** ≤ hôm nay được đưa vào nhóm *Cần chú ý* của màn hình Hôm nay.
- Chỉ Đợt **gần nhất** của mỗi Dự án được xét; các Đợt cũ hơn không sinh nhắc nhở.
- Dự án `Xong`, `Bỏ` không bao giờ sinh nhắc nhở đánh giá.

### 4.9 Sửa hướng sau kiểm thử tay — FR-41…FR-45

Năm yêu cầu này thay thế phần bị bỏ ở §4.4 và viết lại FR-29.

#### FR-41: Hành động có độ ưu tiên riêng

Trước đây chỉ Dự án mới có độ ưu tiên. Nhưng người dùng chọn *việc nào làm
trước* ở cấp Hành động, không phải cấp Dự án.

**Hệ quả kiểm thử được:**
- Ba mức dùng chung với Dự án: `Cao` · `Trung bình` · `Thấp`, mặc định `Trung bình`.
- Đặt được lúc tạo và sửa được sau đó.
- Phân biệt bằng cả màu lẫn nhãn chữ — NFR-7.
- Hiện trên dòng Hành động ở màn hình Hôm nay và trong chi tiết Dự án.

#### FR-42: Danh sách "Làm ngay" do người dùng tự ghim

**Hệ quả kiểm thử được:**
- Mỗi Hành động ghim và bỏ ghim được bằng một thao tác, từ cả hai màn hình.
- Danh sách Làm ngay trên màn hình Hôm nay **chỉ** gồm Hành động đang ghim.
- **Ứng dụng không bao giờ tự ghim hộ.** Sau khi nạp dữ liệu hạt giống, không việc nào được ghim sẵn — có test.
- Xếp theo thời điểm ghim, ghim trước lên trước.
- Đánh dấu `Xong` hoặc `Bỏ` thì tự bỏ ghim; chuyển sang `Đang làm` thì **giữ** ghim.
- Khôi phục một Hành động vừa xoá giữ nguyên trạng thái ghim.

#### FR-43: Khối cảnh báo tách biệt

**Hệ quả kiểm thử được:**
- Ba loại, theo đúng thứ tự nghiêm trọng: **Quá hạn** → **Sắp đến hạn** (7 ngày) → **Ưu tiên cao chưa bắt đầu**.
- Mỗi Hành động chỉ xuất hiện **một lần**, ở loại nghiêm trọng nhất — có test cho việc vừa quá hạn vừa ưu tiên cao.
- Việc đã ghim không lặp lại ở khối cảnh báo.
- Việc `Xong` và `Bỏ` không bao giờ cảnh báo. Ưu tiên cao nhưng `Đang làm` cũng không.
- Đến hạn **đúng hôm nay** tính là *sắp đến hạn*, không phải *quá hạn*.
- Trong cùng một loại, ưu tiên cao lên trước, rồi tới hạn gần nhất.

#### FR-44: Thống kê đầu việc theo hạn

Trục phân loại là **quan hệ giữa lúc xong và hạn đã đặt**, không phải
`Xong`/`Chưa`. Câu hỏi cần trả lời: *"việc đến hạn thì mình có làm xong không,
hay để trôi?"*

**Hệ quả kiểm thử được:**
- Sáu nhóm: `Xong đúng hạn` · `Xong muộn` · `Quá hạn chưa xong` · `Còn hạn, chưa xong` · `Không đặt hạn` · `Đã bỏ`.
- Xong **trong ngày hạn** tính là đúng hạn, không phải muộn.
- Tỷ lệ đúng hạn chỉ tính trên việc **có hạn và đã xong**; chưa có việc nào như vậy thì hiện `—`, không hiện `0%`.
- Tỷ lệ hoàn thành **không** tính việc đã `Bỏ` vào mẫu số.
- Có bảng phân tích theo Chủ đề.
- Mỗi nhóm luôn kèm nhãn chữ và con số, không chỉ phân biệt bằng màu — NFR-7.

#### FR-45: Danh sách Dự án nhóm theo Chủ đề

**Hệ quả kiểm thử được:**
- Dự án nhóm dưới tiêu đề Chủ đề, giữ đúng thứ tự Chủ đề người dùng đặt.
- Chủ đề không có Dự án nào (sau khi lọc) thì không hiện tiêu đề rỗng.
- Tiêu đề Chủ đề hiện số Dự án và tổng tiến độ của cả nhóm.
- Mỗi Dự án hiện thanh tiến độ, trạng thái, độ ưu tiên, số việc quá hạn và số việc ưu tiên cao còn mở.
- Thanh điều hướng: **Hôm nay · Dự án · Thống kê · Cài đặt**. Không còn tab Mục tiêu; Cài đặt chuyển từ thanh trên xuống thanh dưới.

### 4.10 Cấu trúc PARA — FR-46…FR-52

Bảy yêu cầu này đưa app về bốn nhóm của PARA: **P**rojects (có đích) ·
**A**reas (trách nhiệm phải giữ) · **R**esources (tư liệu) · **A**rchives
(ngoài tầm mắt). Chốt ngày 2026-09-03.

Ba khoảng trống được vá, xếp theo mức nghiêm trọng: **tư liệu chết theo Dự
án** (mất dữ liệu im lặng), **`Topic` mới là cái nhãn chứ chưa là Lĩnh vực**,
và **nghi thức nhìn lại theo Lĩnh vực đang không làm được**.

Từ điển ở §3 đổi theo: `Topic` → `Area`, nhãn tiếng Việt **Lĩnh vực**. Không
giữ song song hai từ. Ba từ **không** được nhập vào mã: `Resource` (đồng
nghĩa gộp của `Note` và `Link`), `archived` như một trạng thái (đồng nghĩa
của `dropped`/`paused`), `Inbox` (ngoài phạm vi — xem §6).

#### FR-46: Chủ đề đổi tên thành Lĩnh vực

Đổi tên thuần tuý, không đổi hành vi nào.

**Hệ quả kiểm thử được:**
- Không còn chuỗi `Topic` hay `Chủ đề` ở bất kỳ đâu trong `lib/`, `test/` và tài liệu.
- Sáu Lĩnh vực dựng sẵn giữ nguyên tên nội dung: Gia đình, Thu nhập, Tài chính, Sức khoẻ, Học tập, Khác.
- `Khác` vẫn là Lĩnh vực dự phòng không xoá được, Dự án rơi về đó khi Lĩnh vực cũ bị xoá.
- Sau migration, **không giá trị nào của người dùng đổi** — kiểm bằng test dựng DB v3 có dữ liệu rồi nâng lên v4 và so từng dòng.
- File sao lưu cũ (`schemaVersion` ≤ 3) đọc được, khoá `topics` trong file cũ nạp vào bảng `areas`.

#### FR-47: Lĩnh vực có tiêu chuẩn cần giữ

Trường văn bản trả lời *"mức tôi muốn giữ ở mảng này là gì"*. Đây là thứ phân
biệt một Lĩnh vực với một cái nhãn màu.

**Hệ quả kiểm thử được:**
- Trường `standard` dạng markdown, tuỳ chọn, để trống được.
- Sáu Lĩnh vực dựng sẵn và mọi Lĩnh vực có trước migration đều để trống — không tự sinh nội dung hộ.
- Hiện ở đầu màn hình chi tiết Lĩnh vực; để trống thì không chiếm chỗ, chỉ còn nút thêm.
- **Không có hạn chót, không có trạng thái, không có "xong"** — Lĩnh vực không bao giờ kết thúc. Không thêm cột `status` vào `areas`.

#### FR-48: Lĩnh vực có nhịp xem lại

**Hệ quả kiểm thử được:**
- Trường `reviewCadenceDays` kiểu `int` **nullable**. Gợi ý sẵn 7 · 30 · 90, nhập số khác được.
- **Không đặt nhịp thì tuyệt đối không nhắc gì** — cùng một nguyên tắc với "Mục tiêu không có hạn thì không hiện nhịp và dự báo".
- "Đến hạn xem lại" = ngày Đợt đánh giá gần nhất của Lĩnh vực **+** nhịp. Chưa có Đợt nào thì tính từ ngày tạo Lĩnh vực.
- Giá trị này **tính tại chỗ, không lưu cột nào** — AD-3. Xoá Đợt gần nhất thì ngày đến hạn phải tự lùi lại theo Đợt trước đó.

#### FR-49: Đợt đánh giá gắn được vào Lĩnh vực

Mở rộng `Review` để nhìn lại được cả Lĩnh vực, không chỉ Dự án.

**Hệ quả kiểm thử được:**
- Mỗi Đợt thuộc **đúng một** chủ thể: một Dự án **hoặc** một Lĩnh vực, không bao giờ cả hai, không bao giờ mồ côi — AD-19.
- Mọi Đợt đang có sau migration đều thuộc Dự án, y như trước.
- Tạo Đợt cho Lĩnh vực thì đề nghị nạp sẵn Mục đánh giá từ tên các Dự án **đang mở** trong Lĩnh vực đó. Nạp là **chép văn bản** vào `ReviewItem.label`, không phải khoá ngoại — sửa Dự án về sau không đổi Đợt cũ.
- Người dùng bỏ chọn hoặc sửa từng Mục được nạp trước khi lưu; không nạp gì cũng được.
- Kế thừa Mục chưa đạt từ đợt trước (FR-37) hoạt động y hệt ở cấp Lĩnh vực.
- Tỷ lệ đạt vẫn tính tại chỗ, không lưu — AD-3.

#### FR-50: Tư liệu sống độc lập với Dự án

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

#### FR-51: Lưu trữ là chiều riêng, không phải trạng thái

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

#### FR-52: PARA không được đẩy thêm gì vào "Làm ngay"

Nhắc lại ràng buộc cũ để nó không bị lách qua đường vòng.

**Hệ quả kiểm thử được:**
- Danh sách *Làm ngay* vẫn chỉ gồm Hành động có `pinned = true` do người dùng tự ghim.
- Lĩnh vực đến hạn xem lại xuất hiện ở khối *Cần chú ý*, **không** ở *Làm ngay*.
- Nó là một dòng thông tin dẫn tới màn hình Lĩnh vực, không phải một đầu việc tick được.
- Có test khẳng định: đến hạn xem lại bao nhiêu Lĩnh vực đi nữa, số phần tử của *Làm ngay* không đổi.

## 5. Yêu cầu phi chức năng

| # | Yêu cầu | Cách kiểm chứng |
|---|---|---|
| NFR-1 | Mở app tới màn hình Hôm nay có dữ liệu dưới 1,5 giây trên máy tầm trung | Đo cold start với bộ dữ liệu 7 Dự án / 100 Hành động |
| NFR-2 | Mọi thao tác ghi phản hồi dưới 100 ms | Đánh dấu Xong không có độ trễ nhìn thấy được |
| NFR-3 | Dữ liệu không bao giờ rời khỏi máy | Kiểm tra tĩnh: không có `package:http`, không `dart:io` `HttpClient` trong toàn bộ mã nguồn |
| NFR-4 | Không mất dữ liệu khi nâng cấp phiên bản | Mỗi lần tăng `schemaVersion` phải có test `migrateAndValidate` cho cặp phiên bản đó |
| NFR-5 | Toàn bộ quy tắc nghiệp vụ test được không cần giả lập thiết bị | Tầng `domain/` không import Flutter, drift, hay tầng khác |
| NFR-6 | Chạy được trên Android 8+ và **iOS 14+** | Cấu hình `minSdkVersion` và deployment target tương ứng. Sửa từ iOS 13 lên 14 ngày 2026-08-28: `file_picker_darwin` yêu cầu tối thiểu 14.0, mà không có nó thì không nhập được file sao lưu (FR-32). Đánh đổi có ý thức — iOS 13 ra năm 2019 |
| NFR-7 | Trạng thái và độ ưu tiên không chỉ phân biệt bằng màu | Mỗi mức luôn kèm nhãn chữ hoặc biểu tượng |
| NFR-8 | Không phụ thuộc gói có build hooks | Kiểm tra `hook/` trong mỗi gói trước khi thêm — xem `addendum.md` §2.1 |

## 6. Ngoài phạm vi bản đầu

Ghi rõ để không bị hiểu là bỏ sót:

- **Ngân hàng ý tưởng** — hạng mục roadmap ưu tiên cao nhất. MVP tạm dùng Ghi chú trong Dự án.
- **Thói quen hằng ngày** — sáu mục ở `addendum.md` §1.6. Mô hình dữ liệu lặp theo ngày, không nhét chung vào `Action`.
- Thông báo nhắc nhở của hệ điều hành.
- Thống kê năng suất, biểu đồ chuỗi ngày, báo cáo tuần/tháng.
- Đồng bộ nhiều thiết bị, tài khoản, chia sẻ.
- Liên thông tự động với `personal_finance` — cập nhật Mục tiêu tài chính vẫn là nhập tay từng Mốc.
- Đính kèm ảnh, file, ghi âm.
- Hành động lặp lại theo chu kỳ.

## 7. Giả định cần người dùng xác nhận

Sáu điểm dưới đây được quyết theo hướng an toàn nhất để không chặn việc triển khai. Xác nhận hoặc sửa lại trước khi làm tới Story tương ứng.

1. ~~**§4.4 FR-20**~~ — **ĐÃ CHỐT 2026-08-28.** Mục tiêu `1 tỷ` là **tổng tài sản ròng**. Giá trị được người dùng ghi lại và nhập tay từng Mốc, đối chiếu từ app `personal_finance`. Ứng dụng không tự lấy số từ đâu cả.
2. ~~**§4.4 FR-24**~~ — **ĐÃ CHỐT 2026-08-28.** Hạn chót là **31/12/2027**. Từ đây nhịp và dự báo về đích có hiệu lực cho mục tiêu này.
3. ~~**§4.1 FR-3**~~ — **ĐÃ CHỐT 2026-08-28.** Dự án `Dạy Huy` là dự án **lập kế hoạch và theo dõi tiến bộ của con trai theo mốc thời gian**, nguồn `Dạy huy.pdf`. Chính nó sinh ra nhóm yêu cầu §4.8.
4. **§4.2 FR-13** — Ngưỡng Dự án nguội mặc định 21 ngày. Con số này là suy đoán, sửa được trong Cài đặt.
5. **§4.3 FR-14** — Hành động không có Hành động con. Nếu một việc quá lớn thì nó nên là Dự án, không phải cây con nhiều tầng.
6. **§4.7 FR-32** — Nhập khôi phục là **thay thế toàn bộ**, không phải trộn. Trộn hai nguồn dữ liệu sinh ra bài toán xung đột không đáng giải cho một người dùng.
