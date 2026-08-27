---
stepsCompleted: [validate-prerequisites, design-epics, create-stories]
inputDocuments:
  - "_bmad-output/planning-artifacts/prds/prd-danh-muc-dau-tu-2026-08-27/prd.md"
  - "_bmad-output/planning-artifacts/architecture/architecture-danh-muc-dau-tu-2026-08-27/ARCHITECTURE-SPINE.md"
created: 2026-08-27
---

# App Quản lý Danh mục Đầu tư Cá nhân — Phân rã Epic và Story

## Tổng quan

Tài liệu này chia 41 yêu cầu chức năng của PRD thành 7 epic và 40 story lập trình được. Mỗi story có tiêu chí nghiệm thu dạng Given/When/Then để kiểm chứng được, và ghi rõ nó chịu ràng buộc của quyết định kiến trúc nào.

**Nguyên tắc sắp xếp:** mỗi epic tự đứng được và dùng được ngay khi hoàn thành, không phụ thuộc epic phía sau. Trong một epic, story không phụ thuộc story đứng sau nó.

## Bảng độ phủ yêu cầu

| Epic | Tên | Yêu cầu chức năng | Số story |
|---|---|---|---|
| 1 | Dựng danh mục và nhìn thấy tổng tài sản | FR-1..FR-9, FR-15..FR-17, FR-40 | 9 |
| 2 | Giá thị trường tự động | FR-10..FR-14 | 6 |
| 3 | Lãi lỗ theo vốn góp ròng | FR-18, FR-22..FR-27 | 7 |
| 4 | Sổ nợ và cho vay | FR-32..FR-35 | 4 |
| 5 | Mục tiêu và tái cân bằng | FR-19..FR-21, FR-36, FR-37 | 5 |
| 6 | Lịch sử và biểu đồ theo thời gian | FR-28..FR-31 | 5 |
| 7 | Sao lưu và hoàn thiện | FR-38, FR-39, FR-41 | 4 |

**Đã kiểm chứng:** 41/41 yêu cầu được phủ, không yêu cầu nào bị thiếu hoặc phủ trùng.

## Yêu cầu phi chức năng xuyên suốt

Các yêu cầu này không thuộc riêng story nào mà ràng buộc mọi story, thông qua các quyết định kiến trúc:

| Yêu cầu | Ràng buộc bởi | Kiểm chứng ở |
|---|---|---|
| Không dùng số thực dấu phẩy động cho tiền | AD-3 | Story 1.1, và test của mọi story có phép tính |
| Vốn góp lũy kế không lưu cứng | AD-4 | Story 3.2, 3.3 |
| Giá trị tổng hợp luôn suy ra | AD-5 | Story 1.6, 4.3 |
| Mạng chỉ dùng để hỏi giá | AD-8 | Story 2.1, 2.2, 2.3 |
| Không có tác vụ nền | AD-7 | Story 6.2 |
| Mọi thay đổi schema có migration | AD-10 | Story 1.1, và mọi story thêm bảng |
| Mở app tới lúc thấy số liệu dưới 3 giây | NFR hiệu năng | Story 1.7, 2.6 |

---

## Epic 1: Dựng danh mục và nhìn thấy tổng tài sản

**Mục tiêu:** người dùng nhập được toàn bộ tài sản hiện có bằng giá tự nhập, và thấy ngay tổng tài sản cùng biểu đồ tròn cơ cấu — khớp chính xác với Excel. Hoàn thành epic này là đã thay được bảng chính của Excel, kể cả khi chưa có tính năng lấy giá tự động.

**Cố ý chưa gọi mạng ở epic này.** Việc tách rủi ro như vậy có chủ đích: nếu phần lấy giá tự động ở Epic 2 gặp trục trặc với nhà cung cấp API, sản phẩm vẫn đứng vững.

### Story 1.1: Nền tảng dữ liệu và kiểu số học chính xác

Là người phát triển,
tôi muốn có sẵn lớp cơ sở dữ liệu và các kiểu số học không sai số,
để mọi tính năng phía sau xây trên một nền không bao giờ cho ra con số lệch.

**Chịu ràng buộc:** AD-3, AD-10, FR-9

**Tiêu chí nghiệm thu:**

**Given** project đã có drift và decimal trong pubspec
**When** khởi tạo cơ sở dữ liệu lần đầu
**Then** tệp cơ sở dữ liệu được tạo trong thư mục riêng của ứng dụng
**And** `schemaVersion` bằng 1

**Given** một giá trị tiền tệ
**When** lưu vào cơ sở dữ liệu và đọc ra
**Then** giá trị là kiểu số nguyên đơn vị đồng, không mất chính xác

**Given** số lượng `0,12345678` BTC với `decimals` bằng 8
**When** lưu rồi đọc lại
**Then** nhận đúng `0,12345678`, không mất chữ số nào

**Given** phép nhân số lượng với giá
**When** thực hiện phép tính
**Then** phép tính chạy qua kiểu `Decimal`, chỉ làm tròn ở bước cuối

**Given** toàn bộ mã nguồn trong `domain/` và mọi cột bảng drift
**When** tìm từ khóa `double`
**Then** không tìm thấy kết quả nào

**Given** cơ sở dữ liệu ở phiên bản schema cũ
**When** nâng lên phiên bản mới
**Then** dữ liệu còn nguyên vẹn, và có bài test tự động chứng minh điều đó

### Story 1.2: Định dạng số và tiền kiểu Việt Nam

Là người dùng,
tôi muốn thấy số tiền hiển thị theo cách người Việt vẫn viết,
để đọc lướt qua là hiểu ngay mà không phải dịch trong đầu.

**Chịu ràng buộc:** FR-40

**Tiêu chí nghiệm thu:**

**Given** giá trị 680.000.000 đồng
**When** hiển thị dạng đầy đủ
**Then** hiện `680.000.000 đ` với dấu chấm ngăn nghìn

**Given** cùng giá trị đó
**When** hiển thị dạng rút gọn
**Then** hiện `680 tr`
**And** với 1.200.000.000 thì hiện `1,2 tỷ`

**Given** tỷ trọng 0,574
**When** hiển thị
**Then** hiện `57,4%` với đúng một chữ số thập phân, dùng dấu phẩy

**Given** số lượng 0,12000000 BTC
**When** hiển thị
**Then** hiện `0,12 BTC`, không hiện các số 0 thừa phía sau

**Given** số lượng 100 cổ phiếu
**When** hiển thị
**Then** hiện `100 cổ`, không có phần thập phân

### Story 1.3: Năm lớp tài sản dựng sẵn

Là người dùng,
tôi muốn ứng dụng có sẵn các lớp tài sản đúng như cách tôi vẫn phân loại,
để bắt đầu dùng được ngay mà không phải khai báo từ con số không.

**Chịu ràng buộc:** FR-1

**Tiêu chí nghiệm thu:**

**Given** ứng dụng vừa được cài
**When** mở lần đầu
**Then** có sẵn đúng năm lớp: Chứng khoán, Vàng, Crypto, Tiền mặt & Tiết kiệm, Cho vay
**And** mỗi lớp có biểu tượng và màu riêng phân biệt được trên biểu đồ

**Given** một lớp tài sản
**When** người dùng đổi tên nó
**Then** tên mới hiện ở mọi màn hình

**Given** một lớp tài sản không chứa khoản nắm giữ nào
**When** người dùng ẩn nó
**Then** lớp đó biến mất khỏi biểu đồ và không tính vào tổng tài sản

**Given** một lớp tài sản đang chứa ít nhất một khoản nắm giữ
**When** người dùng thử ẩn nó
**Then** ứng dụng từ chối và nói rõ lý do kèm số khoản đang chứa

### Story 1.4: Thêm khoản nắm giữ

Là người dùng,
tôi muốn nhập các tài sản mình đang có vào từng lớp,
để ứng dụng biết tôi sở hữu những gì.

**Chịu ràng buộc:** FR-4, FR-9

**Tiêu chí nghiệm thu:**

**Given** đang ở lớp Crypto
**When** thêm khoản nắm giữ với ký hiệu `BTC` và số lượng `0,12345678`
**Then** khoản được lưu với đủ 8 chữ số thập phân
**And** ô nhập hiện đơn vị `BTC`

**Given** đang ở lớp Chứng khoán
**When** nhập số lượng
**Then** chỉ nhận số nguyên, đơn vị hiện là `cổ`

**Given** đang ở lớp Vàng
**When** nhập số lượng
**Then** nhận tối đa 2 chữ số thập phân, đơn vị hiện là `chỉ`

**Given** đang ở lớp Tiền mặt & Tiết kiệm
**When** thêm khoản nắm giữ
**Then** ô nhập là số tiền VND, không hỏi số lượng

**Given** lớp Crypto đã có khoản `BTC`
**When** thêm một khoản `BTC` nữa
**Then** ứng dụng từ chối và báo trùng ký hiệu

**Given** một khoản nắm giữ tính bằng USD
**When** lưu
**Then** mã tiền tệ được ghi là USD, không tự quy đổi ở bước lưu

### Story 1.5: Sửa và xóa khoản nắm giữ

Là người dùng,
tôi muốn sửa hoặc xóa khoản nắm giữ khi mua bán hoặc khi nhập nhầm,
để dữ liệu luôn phản ánh đúng thực tế mà không phải xóa hết làm lại.

**Chịu ràng buộc:** FR-5, FR-6

**Tiêu chí nghiệm thu:**

**Given** khoản nắm giữ `BTC` số lượng `0,12`
**When** sửa số lượng thành `0,13`
**Then** giá trị lớp Crypto, tổng tài sản và mọi tỷ trọng đều cập nhật ngay

**Given** một khoản nắm giữ bất kỳ
**When** sửa số lượng
**Then** vốn góp lũy kế **không** thay đổi

**Given** một khoản nắm giữ
**When** chọn xóa
**Then** ứng dụng hỏi xác nhận trước
**And** sau khi xác nhận, mọi số liệu tổng hợp tự tính lại

**Given** đã có bản chốt lịch sử từ trước
**When** xóa một khoản nắm giữ ở hiện tại
**Then** các bản chốt cũ giữ nguyên giá trị đã lưu

### Story 1.6: Tính giá trị lớp tài sản và tổng tài sản

Là người dùng,
tôi muốn tổng tài sản luôn tự đúng,
để không bao giờ gặp lại lỗi cộng nhầm giữa hai bảng như trong Excel.

**Chịu ràng buộc:** FR-8, AD-5

**Tiêu chí nghiệm thu:**

**Given** lớp Chứng khoán có FPT giá trị 15 triệu và các khoản khác bằng 0
**When** đọc giá trị lớp Chứng khoán
**Then** nhận đúng 15 triệu

**Given** các lớp có giá trị 15, 92, 390 và 183 triệu
**When** đọc tổng tài sản
**Then** nhận đúng 680 triệu

**Given** tổng các khoản nắm giữ trong một lớp
**When** so với giá trị lớp đó
**Then** hai số bằng nhau tuyệt đối, không lệch một đồng

**Given** toàn bộ mã nguồn
**When** tìm cột lưu tổng giá trị của lớp tài sản trong cơ sở dữ liệu
**Then** không tồn tại cột nào như vậy

**Given** một lớp tài sản đang bị ẩn
**When** tính tổng tài sản
**Then** lớp đó không được cộng vào

### Story 1.7: Màn hình tổng quan

Là người dùng,
tôi muốn mở app là thấy ngay tổng tài sản và cơ cấu danh mục,
để trong vài giây biết mình đang đứng ở đâu.

**Chịu ràng buộc:** FR-15, FR-16, FR-17

**Tiêu chí nghiệm thu:**

**Given** danh mục đã có dữ liệu
**When** mở ứng dụng
**Then** tổng tài sản là con số nổi bật nhất màn hình
**And** phía dưới là biểu đồ tròn cơ cấu các lớp tài sản
**And** dưới nữa là danh sách lớp tài sản kèm giá trị và tỷ trọng

**Given** các lớp có giá trị 15, 92, 390, 183 triệu
**When** xem biểu đồ tròn
**Then** nhãn hiện `2,2%`, `13,5%`, `57,4%`, `26,9%`

**Given** danh sách lớp tài sản
**When** hiển thị
**Then** sắp xếp theo giá trị giảm dần

**Given** một lớp tài sản có giá trị bằng 0
**When** vẽ biểu đồ tròn
**Then** lớp đó không chiếm chỗ trên biểu đồ

**Given** ứng dụng khởi động nguội trên thiết bị tầm trung
**When** đo thời gian tới lúc màn hình hiện đủ số liệu
**Then** dưới 3 giây

### Story 1.8: Màn hình chi tiết lớp tài sản

Là người dùng,
tôi muốn chạm vào một lớp để xem chi tiết bên trong,
để biết trong lớp Crypto thì BTC và ETH mỗi thứ chiếm bao nhiêu.

**Chịu ràng buộc:** FR-7

**Tiêu chí nghiệm thu:**

**Given** đang ở màn hình tổng quan
**When** chạm vào một phần của biểu đồ tròn hoặc một dòng trong danh sách
**Then** mở màn hình chi tiết của lớp tài sản đó

**Given** màn hình chi tiết một lớp
**When** hiển thị
**Then** có danh sách khoản nắm giữ gồm ký hiệu, số lượng, giá hiệu lực, giá trị quy đổi, tỷ trọng trong nội bộ lớp
**And** có biểu đồ tròn tỷ trọng nội bộ lớp

**Given** lớp Crypto có BTC 12.500 USD và ETH 2.500 USD
**When** xem biểu đồ tròn nội bộ
**Then** hiện `83,3%` và `16,7%`

**Given** một khoản nắm giữ tính bằng USD
**When** hiển thị trong danh sách
**Then** hiện cả giá trị USD và giá trị VND đã quy đổi

### Story 1.9: Luồng khởi tạo lần đầu

Là người dùng mới cài app,
tôi muốn được dẫn qua các bước dựng lại danh mục từ Excel,
để không phải mò xem bắt đầu từ đâu.

**Chịu ràng buộc:** FR-2, FR-3

**Tiêu chí nghiệm thu:**

**Given** ứng dụng chưa từng được khởi tạo
**When** mở lần đầu
**Then** vào luồng khởi tạo ba bước thay vì màn hình tổng quan

**Given** đang ở bước nhập khoản nắm giữ
**When** chọn bỏ qua
**Then** ứng dụng cho qua, không chặn

**Given** đang ở bước cuối
**When** chưa nhập vốn góp khởi điểm
**Then** không hoàn tất được luồng khởi tạo

**Given** ô nhập vốn góp khởi điểm
**When** hiển thị
**Then** có một câu ngắn giải thích ý nghĩa con số kèm ví dụ cụ thể

**Given** người dùng nhập vốn góp khởi điểm bằng 0
**When** bấm tiếp
**Then** ứng dụng cảnh báo hệ quả rồi mới cho qua

**Given** đang ở giữa luồng khởi tạo
**When** đóng ứng dụng rồi mở lại
**Then** quay lại đúng bước đang dở, dữ liệu đã nhập còn nguyên

**Given** hoàn tất khởi tạo
**When** mở ứng dụng những lần sau
**Then** vào thẳng màn hình tổng quan, không hỏi lại

---

## Epic 2: Giá thị trường tự động

**Mục tiêu:** người dùng thôi phải tra giá BTC, giá ETH và tỷ giá USD bằng tay. Đây là phần tạo ra giá trị tự động hóa lớn nhất so với Excel.

**Ràng buộc xuyên suốt epic:** ứng dụng chỉ hỏi ra ngoài *"BTC giá bao nhiêu"*. Không lời gọi mạng nào được mang theo số lượng nắm giữ hay bất kỳ dữ liệu nào của người dùng.

### Story 2.1: Lớp trừu tượng nguồn giá và bộ nhớ đệm

Là người phát triển,
tôi muốn mọi nguồn giá đi qua một lớp trừu tượng chung có bộ nhớ đệm,
để đổi nhà cung cấp sau này không phải sửa tới tầng giao diện.

**Chịu ràng buộc:** AD-6, AD-8, AD-11

**Tiêu chí nghiệm thu:**

**Given** một ký hiệu tài sản
**When** hỏi giá hiệu lực
**Then** đúng một hàm duy nhất trong `domain` quyết định, theo thứ tự: giá nhập tay, rồi giá thị trường lưu gần nhất, rồi `null`

**Given** không có giá nào cho một ký hiệu
**When** hỏi giá hiệu lực
**Then** trả về `null`, tuyệt đối không trả về 0

**Given** một lần lấy giá thành công
**When** lưu vào bộ nhớ đệm
**Then** lưu kèm nguồn và thời điểm lấy

**Given** lời gọi mạng thất bại
**When** hàm trả kết quả
**Then** trả về kiểu kết quả thất bại kèm lý do, không ném ngoại lệ qua ranh giới tầng

**Given** toàn bộ mã nguồn
**When** tìm các lời gọi mạng
**Then** tất cả nằm trong đúng thư mục `data/remote/`

### Story 2.2: Lấy giá crypto tự động

Là người dùng,
tôi muốn giá BTC và ETH tự cập nhật,
để tổng tài sản luôn phản ánh thị trường hiện tại mà tôi không phải làm gì.

**Chịu ràng buộc:** FR-10

**Tiêu chí nghiệm thu:**

**Given** có kết nối mạng
**When** mở ứng dụng
**Then** giá BTC, ETH, USDT được làm mới

**Given** đang ở màn hình tổng quan
**When** kéo xuống
**Then** giá được lấy lại

**Given** một lời gọi lấy giá
**When** kiểm tra nội dung gửi đi
**Then** chỉ chứa ký hiệu tài sản và mã tiền tệ
**And** không chứa số lượng, giá trị, hay bất kỳ định danh người dùng nào

**Given** giá vừa lấy thành công
**When** tính giá trị lớp Crypto
**Then** dùng giá mới, và giá trị lớp cập nhật ngay trên màn hình

### Story 2.3: Lấy tỷ giá USD sang VND

Là người dùng,
tôi muốn tỷ giá tự cập nhật,
để giá trị crypto tính bằng USD quy về VND luôn đúng — thay vì con số 26.000 nằm chết trong công thức Excel.

**Chịu ràng buộc:** FR-11

**Tiêu chí nghiệm thu:**

**Given** có kết nối mạng
**When** mở ứng dụng
**Then** tỷ giá USD/VND được làm mới

**Given** màn hình cài đặt
**When** xem tỷ giá
**Then** hiện giá trị hiện tại kèm thời điểm cập nhật

**Given** người dùng nhập tay một tỷ giá
**When** tính quy đổi
**Then** dùng tỷ giá nhập tay, không dùng tỷ giá lấy tự động

**Given** chưa từng lấy được tỷ giá lần nào và người dùng chưa nhập tay
**When** cần quy đổi
**Then** dùng giá trị dự phòng và ghi rõ đang dùng giá trị dự phòng

### Story 2.4: Nhập tay đè giá

Là người dùng,
tôi muốn tự nhập giá cho vàng và cổ phiếu,
vì hai loại này chưa có nguồn tự động, và đôi khi tôi muốn dùng giá của riêng mình.

**Chịu ràng buộc:** FR-12

**Tiêu chí nghiệm thu:**

**Given** một khoản nắm giữ bất kỳ
**When** nhập tay một giá
**Then** giá đó thắng giá thị trường

**Given** một khoản nắm giữ đang dùng giá nhập tay
**When** hiển thị trong danh sách
**Then** có dấu hiệu nhận biết rõ ràng

**Given** một khoản đang có giá nhập tay
**When** xóa giá nhập tay
**Then** quay lại dùng giá thị trường

**Given** khoản nắm giữ thuộc lớp Chứng khoán hoặc Vàng
**When** chưa có giá nhập tay
**Then** ứng dụng nói rõ cần nhập giá thủ công, không để trống không giải thích

### Story 2.5: Hiển thị độ mới của giá

Là người dùng,
tôi muốn biết con số mình đang nhìn tính từ giá lúc nào,
để không bao giờ ra quyết định dựa trên số liệu cũ mà tưởng là mới.

**Chịu ràng buộc:** FR-13

**Tiêu chí nghiệm thu:**

**Given** giá vừa được cập nhật 5 phút trước
**When** xem màn hình tổng quan
**Then** hiện `cập nhật 5 phút trước`

**Given** giá đã cũ hơn 24 giờ
**When** hiển thị
**Then** có dấu hiệu cảnh báo trực quan

**Given** bất kỳ màn hình nào hiện số liệu tài chính
**When** kiểm tra
**Then** luôn có thông tin về thời điểm giá được cập nhật

### Story 2.6: Hoạt động đầy đủ khi không có mạng

Là người dùng,
tôi muốn app dùng được bình thường cả khi mất mạng,
vì tôi hay xem danh mục ở những nơi sóng kém.

**Chịu ràng buộc:** FR-14, AD-11

**Tiêu chí nghiệm thu:**

**Given** không có kết nối mạng
**When** mở ứng dụng
**Then** mọi màn hình hiển thị bình thường, dùng giá lưu lần cuối
**And** có thông báo rõ đang dùng giá lưu, kèm thời điểm

**Given** không có mạng
**When** thêm, sửa, xóa khoản nắm giữ, dòng vốn, khoản nợ
**Then** mọi thao tác hoạt động bình thường

**Given** lời gọi lấy giá thất bại
**When** người dùng đang thao tác
**Then** không thao tác nào bị chặn, không hộp thoại lỗi nào chặn màn hình

**Given** không có mạng
**When** đo thời gian mở app tới lúc thấy số liệu
**Then** vẫn dưới 3 giây

---

## Epic 3: Lãi lỗ theo vốn góp ròng

**Mục tiêu:** người dùng biết mình thực lãi hay thực lỗ, sau khi đã trừ phần tiền tự bỏ thêm vào. Đây là trái tim sản phẩm và cũng là phần dễ sai nhất.

**Bộ dữ liệu nghiệm thu bắt buộc:** mười dòng lịch sử trong `addendum.md` mục 3. Epic này chỉ được coi là xong khi cả mười dòng cho ra đúng kết quả.

### Story 3.1: Sổ dòng vốn và vốn góp khởi điểm

Là người dùng,
tôi muốn ghi lại mỗi lần nạp thêm tiền vào hoặc rút tiền ra khỏi đầu tư,
để ứng dụng phân biệt được tiền tăng do tôi bỏ thêm với tiền tăng do sinh lời.

**Chịu ràng buộc:** FR-22, AD-4

**Tiêu chí nghiệm thu:**

**Given** màn hình sổ vốn
**When** thêm một dòng vốn
**Then** nhập được ngày, số tiền và ghi chú tùy chọn

**Given** đang nhập một dòng vốn
**When** chọn nạp hay rút
**Then** có nút chuyển đổi rõ ràng, không phải gõ dấu trừ bằng tay

**Given** một dòng vốn đã lưu
**When** kiểm tra cấu trúc bảng
**Then** bảng không có cột nào chia dòng vốn theo lớp tài sản

**Given** cấu trúc cơ sở dữ liệu
**When** tìm cột lưu vốn góp lũy kế
**Then** không tồn tại cột nào như vậy
**And** vốn góp khởi điểm nằm trong bảng thiết lập một dòng duy nhất

### Story 3.2: Tính vốn góp lũy kế

Là người dùng,
tôi muốn vốn góp lũy kế luôn đúng,
kể cả khi tôi sửa lại một dòng vốn từ nhiều tháng trước.

**Chịu ràng buộc:** FR-24, AD-4

**Tiêu chí nghiệm thu:**

**Given** vốn góp khởi điểm 341 và chuỗi dòng vốn `−60, −36, +9, +47, +32`
**When** tính vốn góp lũy kế tại từng mốc
**Then** nhận đúng dãy `281, 245, 254, 301, 333`

**Given** một thời điểm bất kỳ
**When** tính vốn góp lũy kế
**Then** kết quả bằng vốn góp khởi điểm cộng tổng các dòng vốn có ngày nhỏ hơn hoặc bằng thời điểm đó

**Given** chuỗi dòng vốn `+341, −60, −36, +9`
**When** sửa dòng thứ hai từ `−60` thành `−50`
**Then** cả ba giá trị lũy kế phía sau đều thay đổi theo

**Given** một dòng vốn ở giữa chuỗi
**When** đổi ngày của nó sang một mốc khác
**Then** kết quả giống hệt như khi xóa dòng đó rồi thêm lại với ngày mới

### Story 3.3: Sửa và xóa dòng vốn

Là người dùng,
tôi muốn sửa lại dòng vốn khi phát hiện nhập sai,
để không phải xóa hết lịch sử làm lại từ đầu.

**Chịu ràng buộc:** FR-23

**Tiêu chí nghiệm thu:**

**Given** một dòng vốn bất kỳ, kể cả dòng cũ nhất
**When** sửa số tiền, ngày hoặc ghi chú
**Then** lưu thành công

**Given** vừa sửa một dòng vốn
**When** xem lại vốn góp lũy kế và lãi lỗ
**Then** mọi giá trị từ dòng đó trở về sau đã được tính lại
**And** các bản chốt lịch sử cũng phản ánh giá trị mới

**Given** một dòng vốn
**When** chọn xóa
**Then** ứng dụng hỏi xác nhận trước

**Given** một dòng vốn đã bị xóa
**When** tính lại toàn chuỗi
**Then** kết quả giống như dòng đó chưa từng tồn tại

### Story 3.4: Tính lãi lỗ

Là người dùng,
tôi muốn biết con số lãi lỗ thật của mình,
để đánh giá được các quyết định đầu tư đã qua.

**Chịu ràng buộc:** FR-25

**Tiêu chí nghiệm thu:**

**Given** giá trị nhóm đầu tư và vốn góp lũy kế tại cùng một thời điểm
**When** tính lãi lỗ
**Then** kết quả bằng giá trị nhóm đầu tư trừ vốn góp lũy kế

**Given** nhóm đầu tư mặc định
**When** kiểm tra thành phần
**Then** gồm đúng lớp Chứng khoán và lớp Crypto
**And** không gồm Vàng, Tiền mặt & Tiết kiệm, Cho vay

**Given** mười dòng dữ liệu lịch sử trong addendum mục 3
**When** chạy qua công thức
**Then** cột vốn góp lũy kế cho đúng `341, 341, 341, 341, 341, 281, 245, 254, 301, 333`
**And** cột lãi lỗ cho đúng `0, −39, −31, −168, −21, +30, +38, +67, −34, −100`

**Given** lãi lỗ đã tính
**When** hiển thị
**Then** hiện cả số tiền tuyệt đối và tỷ lệ phần trăm so với vốn góp lũy kế

### Story 3.5: Màn hình lãi lỗ chi tiết

Là người dùng,
tôi muốn xem đầy đủ lịch sử nạp rút và cách con số lãi lỗ được tạo ra,
để tin được vào nó thay vì phải đoán.

**Chịu ràng buộc:** FR-26

**Tiêu chí nghiệm thu:**

**Given** màn hình lãi lỗ
**When** hiển thị
**Then** hiện giá trị nhóm đầu tư hiện tại, vốn góp lũy kế và lãi lỗ
**And** hiện vốn góp khởi điểm như một dòng riêng để đối chiếu

**Given** màn hình lãi lỗ
**When** cuộn xuống
**Then** thấy toàn bộ dòng vốn theo thứ tự thời gian, kèm vốn góp lũy kế tại từng dòng

**Given** đang xem danh sách dòng vốn
**When** chạm vào một dòng
**Then** mở thẳng thao tác sửa và xóa

### Story 3.6: Lãi lỗ trên màn hình tổng quan

Là người dùng,
tôi muốn thấy lãi lỗ ngay khi mở app,
để không phải đi thêm một bước nữa mới biết.

**Chịu ràng buộc:** FR-18

**Tiêu chí nghiệm thu:**

**Given** màn hình tổng quan
**When** hiển thị
**Then** có chỉ số lãi lỗ hiện tại của nhóm đầu tư

**Given** đang lãi
**When** hiển thị
**Then** dùng màu và dấu phân biệt rõ với trạng thái lỗ

**Given** chỉ số lãi lỗ trên màn hình tổng quan
**When** chạm vào
**Then** mở màn hình lãi lỗ chi tiết

### Story 3.7: Cấu hình nhóm đầu tư

Là người dùng,
tôi muốn chọn được lớp tài sản nào tính vào lãi lỗ,
để nếu sau này tôi coi vàng là khoản đầu tư thì đổi được.

**Chịu ràng buộc:** FR-27

**Tiêu chí nghiệm thu:**

**Given** màn hình cài đặt
**When** mở cấu hình nhóm đầu tư
**Then** chọn được lớp tài sản nào tham gia

**Given** ứng dụng vừa cài
**When** kiểm tra mặc định
**Then** đúng hai lớp Chứng khoán và Crypto được chọn

**Given** đang đổi cấu hình nhóm đầu tư
**When** bấm áp dụng
**Then** ứng dụng cảnh báo lãi lỗ toàn bộ lịch sử sẽ được tính lại
**And** sau khi xác nhận, mọi giá trị lãi lỗ trong lịch sử phản ánh cấu hình mới

---

## Epic 4: Sổ nợ và cho vay

**Mục tiêu:** thay thế sheet thứ hai của Excel, và quan trọng hơn — triệt tiêu phép cộng thủ công `133 + 50 = 183` giữa hai sheet. Chỉ khi epic này xong thì tổng tài sản mới thật sự đúng, vì lớp Cho vay chiếm gần 20% danh mục.

### Story 4.1: Quản lý khoản nợ

Là người dùng,
tôi muốn ghi lại ai đang nợ tôi và tôi đang nợ ai,
để không phải nhớ trong đầu hay lật lại tin nhắn cũ.

**Chịu ràng buộc:** FR-32, FR-34

**Tiêu chí nghiệm thu:**

**Given** màn hình sổ nợ
**When** thêm một khoản
**Then** nhập được tên người, loại cho vay hay đi vay, số tiền, ngày, ghi chú

**Given** đang nhập một khoản nợ
**When** chọn loại
**Then** có nút chọn cho vay hoặc đi vay, không phải gõ dấu âm bằng tay

**Given** một khoản nợ đã có
**When** sửa hoặc xóa
**Then** thao tác thành công, xóa có bước xác nhận

**Given** người vay trả một phần
**When** người dùng sửa số tiền xuống mức còn lại
**Then** khoản nợ cập nhật, không yêu cầu ghi lại lịch sử từng lần trả

**Given** các khoản `63, 30, 30, 0, 20` cho vay và `−10` đi vay
**When** xem tổng
**Then** hiện tổng cho vay 143, tổng đi vay 10, tổng ròng 133

### Story 4.2: Đánh dấu đã tất toán

Là người dùng,
tôi muốn đánh dấu khoản nào đã thu hồi xong,
để nó rời khỏi tài sản hiện tại nhưng tôi vẫn tra cứu lại được.

**Chịu ràng buộc:** FR-33

**Tiêu chí nghiệm thu:**

**Given** một khoản cho vay đang hiệu lực
**When** đánh dấu đã tất toán
**Then** lưu kèm ngày tất toán
**And** khoản đó bị loại khỏi giá trị lớp Cho vay và khỏi tổng tài sản

**Given** khoản anh Thắng 63 triệu vừa được tất toán
**When** xem tổng tài sản
**Then** tổng giảm đúng 63 triệu
**And** tỷ trọng mọi lớp tài sản được tính lại

**Given** một khoản đã tất toán
**When** vào mục lịch sử của sổ nợ
**Then** vẫn xem lại được, tách khỏi danh sách đang hiệu lực

**Given** một khoản bị đánh dấu tất toán nhầm
**When** bỏ đánh dấu
**Then** khoản quay lại danh sách đang hiệu lực và được cộng lại vào tổng tài sản

**Given** vừa tất toán một khoản
**When** ứng dụng xử lý xong
**Then** không hỏi số tiền thu về đi đâu, không tự tạo thao tác nào khác

### Story 4.3: Liên kết sổ nợ vào tổng tài sản

Là người dùng,
tôi muốn tổng tài sản tự cộng đúng phần cho vay,
để không bao giờ gặp lại lỗi quên cập nhật một trong hai bảng.

**Chịu ràng buộc:** FR-35, AD-5

**Tiêu chí nghiệm thu:**

**Given** các khoản nợ đang hiệu lực có tổng ròng 133 triệu
**When** đọc giá trị lớp Cho vay
**Then** nhận đúng 133 triệu

**Given** toàn bộ mã nguồn và giao diện
**When** tìm cách nhập tay giá trị lớp Cho vay
**Then** không tồn tại đường nào

**Given** thêm, sửa, xóa hoặc tất toán một khoản nợ
**When** xem màn hình tổng quan
**Then** tổng tài sản và mọi tỷ trọng đã phản ánh thay đổi ngay

### Story 4.4: Màn hình sổ nợ

Là người dùng,
tôi muốn một màn hình gọn nhìn ra ngay tình hình nợ nần,
để biết còn bao nhiêu tiền đang nằm ngoài.

**Chịu ràng buộc:** FR-32

**Tiêu chí nghiệm thu:**

**Given** màn hình sổ nợ
**When** hiển thị
**Then** phần trên là tổng cho vay, tổng đi vay và tổng ròng
**And** phần dưới là danh sách các khoản đang hiệu lực

**Given** danh sách khoản nợ
**When** hiển thị
**Then** cho vay và đi vay phân biệt được bằng màu hoặc biểu tượng

**Given** có khoản đã tất toán
**When** xem màn hình sổ nợ
**Then** có lối vào riêng để xem lịch sử các khoản đã tất toán

---

## Epic 5: Mục tiêu và tái cân bằng

**Mục tiêu:** biến những dòng ghi chú định tính ở cuối sheet Excel — *"mua thêm vàng và chứng khoán"* — thành con số cụ thể để hành động.

**Xếp sau Epic 4 có lý do:** khoảng lệch tính trên tổng tài sản, mà tổng tài sản chỉ đúng khi lớp Cho vay đã có số liệu thật.

### Story 5.1: Đặt tỷ trọng mục tiêu

Là người dùng,
tôi muốn đặt tỷ lệ mong muốn cho từng lớp tài sản,
để ứng dụng biết thế nào là cân bằng theo ý tôi.

**Chịu ràng buộc:** FR-19

**Tiêu chí nghiệm thu:**

**Given** màn hình mục tiêu
**When** đặt tỷ trọng mục tiêu cho một lớp
**Then** lưu thành công và sửa lại được bất cứ lúc nào

**Given** tổng các tỷ trọng mục tiêu khác 100%
**When** lưu
**Then** ứng dụng cảnh báo nhưng vẫn cho lưu

**Given** người dùng muốn đặt mục tiêu chung cho Vàng và Chứng khoán
**When** gộp hai lớp vào một nhóm mục tiêu
**Then** đặt được một tỷ trọng duy nhất cho cả nhóm

**Given** mục tiêu BTC 50%, Tiền mặt & Cho vay 30%, Vàng & Chứng khoán 20%
**When** lưu
**Then** cả ba được ghi nhận đúng

### Story 5.2: Tính khoảng lệch

Là người dùng,
tôi muốn biết mình lệch bao nhiêu tiền so với mục tiêu,
để có con số cụ thể mà hành động thay vì nhẩm trong đầu.

**Chịu ràng buộc:** FR-20

**Tiêu chí nghiệm thu:**

**Given** tỷ trọng thực tế 57,4% và mục tiêu 50%, tổng tài sản 680 triệu
**When** tính khoảng lệch
**Then** cho ra `+7,4%` và khoảng 50 triệu

**Given** một lớp đang thiếu so với mục tiêu
**When** tính khoảng lệch
**Then** cho ra giá trị âm, và hiển thị phân biệt rõ với trạng thái thừa

**Given** khoảng lệch quy ra tiền
**When** kiểm tra công thức
**Then** bằng hiệu tỷ trọng nhân với tổng tài sản

### Story 5.3: Màn hình mục tiêu

Là người dùng,
tôi muốn nhìn một màn hình là thấy ngay đang lệch chỗ nào,
để quyết định mua bán gì trong tháng này.

**Chịu ràng buộc:** FR-20

**Tiêu chí nghiệm thu:**

**Given** màn hình mục tiêu
**When** hiển thị
**Then** mỗi lớp hoặc nhóm có mục tiêu hiện đủ: tỷ trọng thực tế, tỷ trọng mục tiêu, khoảng lệch theo phần trăm, và khoảng lệch quy ra tiền

**Given** màn hình mục tiêu
**When** cuộn xuống
**Then** có biểu đồ cột so sánh thực tế với mục tiêu cho toàn bộ các lớp

**Given** một lớp đang thừa so với mục tiêu
**When** hiển thị trên biểu đồ cột
**Then** phân biệt trực quan với lớp đang thiếu

### Story 5.4: Ngưỡng cảnh báo lệch

Là người dùng,
tôi muốn được nhắc khi một lớp lệch quá xa,
để không bỏ lỡ thời điểm cần cơ cấu lại.

**Chịu ràng buộc:** FR-21

**Tiêu chí nghiệm thu:**

**Given** màn hình cài đặt
**When** đặt ngưỡng cảnh báo lệch
**Then** lưu được giá trị phần trăm, mặc định 5%

**Given** một lớp lệch 7,4% và ngưỡng đang là 5%
**When** xem màn hình tổng quan
**Then** lớp đó có dấu hiệu nhận biết cần chú ý

**Given** mọi lớp đều lệch dưới ngưỡng
**When** xem màn hình tổng quan
**Then** không có dấu hiệu cảnh báo nào

### Story 5.5: Ghi chú kế hoạch

Là người dùng,
tôi muốn ghi lại việc cần làm ngay cạnh con số sinh ra nó,
để lần sau mở app còn nhớ mình đã định làm gì.

**Chịu ràng buộc:** FR-36, FR-37

**Tiêu chí nghiệm thu:**

**Given** màn hình mục tiêu
**When** thêm một ghi chú kế hoạch
**Then** nhập được văn bản tự do và lưu thành công

**Given** một ghi chú đã có
**When** sửa hoặc xóa
**Then** thao tác thành công

**Given** một ghi chú
**When** đánh dấu hoàn thành
**Then** ghi chú chuyển xuống nhóm đã hoàn thành riêng

**Given** danh sách ghi chú
**When** hiển thị
**Then** sắp xếp theo ngày tạo, mới nhất lên trên

**Given** màn hình mục tiêu
**When** hiển thị
**Then** các ghi chú chưa hoàn thành nằm ngay dưới phần khoảng lệch

---

## Epic 6: Lịch sử và biểu đồ theo thời gian

**Mục tiêu:** giải quyết khoảng đứt bốn tháng trong lịch sử Excel. Thêm một thứ Excel không có: mỗi bản chốt lưu cả cơ cấu từng lớp tại thời điểm đó, nên dựng lại được bức tranh quá khứ.

### Story 6.1: Bảng bản chốt

Là người phát triển,
tôi muốn cấu trúc lưu bản chốt là ảnh chụp bất biến,
để sửa dữ liệu hiện tại không làm biến dạng lịch sử.

**Chịu ràng buộc:** AD-12

**Tiêu chí nghiệm thu:**

**Given** cấu trúc bảng bản chốt
**When** kiểm tra
**Then** lưu giá trị đã tính sẵn, không lưu tham chiếu tới khoản nắm giữ
**And** không có cột vốn góp lũy kế và cột lãi lỗ

**Given** một bản chốt và các dòng chi tiết theo lớp tài sản
**When** lưu
**Then** mỗi lớp có một dòng ghi giá trị tại thời điểm đó

**Given** một bản chốt đã lưu
**When** xóa một khoản nắm giữ ở hiện tại
**Then** bản chốt giữ nguyên giá trị đã ghi

**Given** một bản chốt đã lưu
**When** sửa một dòng vốn có ngày trước bản chốt đó
**Then** vốn góp lũy kế và lãi lỗ của bản chốt được tính lại theo giá trị mới

### Story 6.2: Sinh bản chốt tự động

Là người dùng,
tôi muốn ứng dụng tự ghi lại giá trị danh mục mỗi ngày,
để có biểu đồ liền mạch mà không phải nhớ bấm chốt sổ.

**Chịu ràng buộc:** FR-28, AD-7

**Tiêu chí nghiệm thu:**

**Given** hôm nay chưa có bản chốt nào
**When** mở ứng dụng
**Then** một bản chốt tự động được sinh, ghi tổng tài sản và giá trị từng lớp

**Given** hôm nay đã có bản chốt tự động
**When** mở lại ứng dụng lần nữa trong ngày
**Then** không sinh thêm bản chốt mới

**Given** người dùng không mở ứng dụng trong ba ngày
**When** mở lại vào ngày thứ tư
**Then** chỉ sinh bản chốt cho ngày thứ tư
**And** ba ngày trống không được nội suy hay lấp bằng giá trị giả

**Given** toàn bộ mã nguồn và cấu hình hai nền tảng
**When** tìm đăng ký tác vụ nền
**Then** không tồn tại đăng ký nào

**Given** một bản chốt tự động
**When** thử sửa hoặc xóa
**Then** ứng dụng không cung cấp thao tác nào để làm việc đó

### Story 6.3: Chốt sổ thủ công

Là người dùng,
tôi muốn tự chốt một mốc kèm ghi chú khi có sự kiện đáng nhớ,
để sau này nhìn lại biết chuyện gì đã xảy ra lúc đó.

**Chịu ràng buộc:** FR-29

**Tiêu chí nghiệm thu:**

**Given** đang ở màn hình lịch sử
**When** bấm chốt sổ
**Then** nhập được ghi chú tự do và bản chốt được lưu

**Given** danh sách bản chốt
**When** hiển thị
**Then** bản chốt thủ công phân biệt được với bản chốt tự động

**Given** một bản chốt thủ công
**When** chọn xóa
**Then** xóa được, có bước xác nhận

### Story 6.4: Biểu đồ đường theo thời gian

Là người dùng,
tôi muốn thấy đường đi của tài sản và lãi lỗ,
để biết danh mục đang tốt lên hay xấu đi — thứ mà mười điểm rời rạc trong Excel không nói được.

**Chịu ràng buộc:** FR-30

**Tiêu chí nghiệm thu:**

**Given** đã có ít nhất hai bản chốt
**When** mở màn hình lịch sử
**Then** có biểu đồ đường tổng tài sản theo thời gian
**And** có biểu đồ đường lãi lỗ theo thời gian

**Given** biểu đồ đường
**When** chọn khoảng thời gian
**Then** chọn được 1 tháng, 3 tháng, 6 tháng, 1 năm, toàn bộ

**Given** biểu đồ đường
**When** chạm vào một điểm
**Then** hiện số liệu chi tiết của ngày đó

**Given** có khoảng trống giữa hai bản chốt
**When** vẽ biểu đồ
**Then** nối thẳng giữa hai bản chốt liền kề, không tạo điểm giả

**Given** chưa đủ dữ liệu để vẽ
**When** mở màn hình lịch sử
**Then** hiện thông báo giải thích, không hiện biểu đồ trống

**Given** đã có 365 bản chốt
**When** vẽ biểu đồ
**Then** không giật

### Story 6.5: Xem lại một bản chốt

Là người dùng,
tôi muốn mở lại một mốc trong quá khứ,
để xem lúc đó cơ cấu danh mục của mình thế nào.

**Chịu ràng buộc:** FR-31

**Tiêu chí nghiệm thu:**

**Given** danh sách bản chốt
**When** chạm vào một bản
**Then** mở màn hình chi tiết hiện cơ cấu từng lớp tại thời điểm đó

**Given** một bản chốt cũ
**When** xem chi tiết
**Then** hiện tổng tài sản, giá trị từng lớp, vốn góp lũy kế và lãi lỗ tại thời điểm đó

**Given** đã thêm và xóa nhiều khoản nắm giữ sau ngày của bản chốt
**When** xem lại bản chốt đó
**Then** giá trị hiển thị vẫn là giá trị đã ghi lúc chốt

---

## Epic 7: Sao lưu và hoàn thiện

**Mục tiêu:** đối trọng bắt buộc của kiến trúc chỉ lưu trên máy. Không có epic này thì mất máy là mất trắng toàn bộ lịch sử.

### Story 7.1: Xuất dữ liệu ra tệp

Là người dùng,
tôi muốn xuất toàn bộ dữ liệu ra tệp,
để tự cất bản sao ở nơi tôi chọn, phòng khi mất máy.

**Chịu ràng buộc:** FR-38

**Tiêu chí nghiệm thu:**

**Given** danh mục đã có dữ liệu
**When** chọn xuất dữ liệu
**Then** tệp chứa đủ khoản nắm giữ, dòng vốn, khoản nợ, bản chốt và ghi chú kế hoạch

**Given** tệp vừa xuất
**When** mở bằng Excel
**Then** đọc được và dấu tiếng Việt hiển thị đúng

**Given** tệp vừa xuất
**When** chọn chia sẻ
**Then** gửi được qua các ứng dụng sẵn có của hệ điều hành

### Story 7.2: Nhắc sao lưu

Là người dùng,
tôi muốn được nhắc khi đã lâu chưa sao lưu,
vì tôi sẽ không tự nhớ cho tới lúc quá muộn.

**Chịu ràng buộc:** FR-38

**Tiêu chí nghiệm thu:**

**Given** đã 30 ngày kể từ lần xuất dữ liệu gần nhất
**When** mở ứng dụng
**Then** hiện nhắc nhở sao lưu

**Given** vừa xuất dữ liệu
**When** kiểm tra
**Then** mốc đếm được đặt lại

**Given** nhắc nhở sao lưu đang hiện
**When** người dùng bỏ qua
**Then** không chặn thao tác nào

### Story 7.3: Chế độ sáng và tối

Là người dùng,
tôi muốn chọn giao diện sáng hay tối,
để xem danh mục buổi tối không bị chói mắt.

**Chịu ràng buộc:** FR-39

**Tiêu chí nghiệm thu:**

**Given** màn hình cài đặt
**When** chọn chế độ hiển thị
**Then** có ba lựa chọn sáng, tối, theo hệ thống

**Given** đang ở chế độ tối
**When** xem biểu đồ tròn, biểu đồ cột và biểu đồ đường
**Then** mọi biểu đồ đọc được rõ ràng, màu phân biệt được

**Given** đã chọn một chế độ
**When** đóng và mở lại ứng dụng
**Then** giữ nguyên lựa chọn

### Story 7.4: Màn hình cài đặt

Là người dùng,
tôi muốn sửa được các thiết lập nền,
để chỉnh lại khi ban đầu nhập sai hoặc khi hoàn cảnh thay đổi.

**Chịu ràng buộc:** FR-41

**Tiêu chí nghiệm thu:**

**Given** màn hình cài đặt
**When** hiển thị
**Then** sửa được vốn góp khởi điểm, ngày bắt đầu, tỷ giá nhập tay, ngưỡng cảnh báo lệch, cấu hình nhóm đầu tư

**Given** đang sửa vốn góp khởi điểm
**When** bấm lưu
**Then** ứng dụng cảnh báo toàn bộ lịch sử lãi lỗ sẽ được tính lại
**And** sau khi xác nhận, mọi giá trị lãi lỗ phản ánh con số mới

**Given** bất kỳ thiết lập nào ảnh hưởng tới lịch sử
**When** thay đổi
**Then** luôn có cảnh báo trước khi áp dụng
