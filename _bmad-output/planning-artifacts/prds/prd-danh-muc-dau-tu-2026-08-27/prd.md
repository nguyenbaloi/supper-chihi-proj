---
title: "App Quản lý Danh mục Đầu tư Cá nhân"
created: 2026-08-27
updated: 2026-08-27
status: approved
status_note: "Không còn câu hỏi mở — sẵn sàng cho pha Architecture"
source_brief: "_bmad-output/planning-artifacts/briefs/brief-quan-ly-tai-chinh-ca-nhan-2026-08-27/brief.md"
---

# PRD: App Quản lý Danh mục Đầu tư Cá nhân

## 0. Mục đích tài liệu

Tài liệu này dành cho pha Architecture và pha chia Epic/Story phía sau. Nó biến Product Brief thành yêu cầu chức năng có thể lập trình và kiểm thử được.

Cách đọc: mục 3 là từ điển thuật ngữ — mọi mục còn lại dùng đúng các từ đó, không dùng từ đồng nghĩa. Mục 4 nhóm yêu cầu theo tính năng, mỗi yêu cầu chức năng có mã `FR-n` đánh số toàn cục để các tài liệu sau tham chiếu ổn định. Hành trình người dùng có mã `UJ-n`. Chỉ số thành công có mã `SM-n`. Chỗ nào tôi suy luận mà chưa được xác nhận thì gắn nhãn `[GIẢ ĐỊNH]` và gom lại ở mục 9.

Tài liệu nguồn — không lặp lại nội dung ở đây:
- `briefs/.../brief.md` — bối cảnh sản phẩm, vấn đề, phạm vi.
- `briefs/.../excel-analysis.md` — bóc tách hệ thống Excel gốc, công thức đã kiểm chứng.
- `briefs/.../addendum.md` — ràng buộc kỹ thuật, mô hình dữ liệu, bộ dữ liệu kiểm thử.

## 1. Tầm nhìn

Ứng dụng mobile thay thế hệ thống Excel hai sheet mà người dùng đã duy trì hơn một năm để theo dõi danh mục đầu tư cá nhân khoảng 680 triệu đồng, trải trên năm lớp tài sản: chứng khoán, vàng, tiền mã hóa, tiền mặt và tiết kiệm, và các khoản cho vay.

Nguyên tắc thiết kế xuyên suốt: **người dùng nhập thứ chỉ thay đổi khi họ thực sự giao dịch — số lượng nắm giữ — còn mọi thứ biến động theo thị trường thì ứng dụng tự lo.** Excel bắt họ tra giá BTC, tra tỷ giá USD, cộng chéo hai sheet, nhẩm khoảng lệch so với mục tiêu. Ứng dụng này bỏ hết phần lao động đó, giữ nguyên phương pháp tính toán vốn đã đúng.

Thước đo cuối cùng không phải số tính năng, mà là **tần suất theo dõi**. Excel cho ra mười mốc chốt sổ trong mười ba tháng, có khoảng đứt bốn tháng — không phải vì người dùng lười, mà vì mỗi lần chốt sổ là một buổi ngồi máy tính. Ứng dụng thành công khi việc đó rút xuống còn một thao tác trên điện thoại.

## 2. Người dùng mục tiêu

### 2.1 Công việc cần hoàn thành

- **Biết ngay tổng tài sản thật của mình là bao nhiêu**, không phải mở máy tính và tra ba nguồn giá.
- **Thấy cơ cấu danh mục đang lệch đâu so với mục tiêu**, và lệch bao nhiêu tiền — để quyết định mua bán.
- **Biết mình thực lãi hay thực lỗ**, sau khi đã trừ đi phần tiền tự bỏ thêm vào.
- **Nhớ được ai đang nợ mình bao nhiêu** và khoản nào đã thu hồi xong.
- **Yên tâm rằng số liệu tài chính của mình không nằm trên máy chủ của ai khác.**
- **Sửa được số liệu khi nhập sai**, mà không sợ phá vỡ tính đúng đắn của lịch sử.

### 2.2 Không phục vụ ai ở bản đầu

- Người muốn ghi chi tiêu hằng ngày (ăn uống, đi lại) — đây là sản phẩm khác.
- Nhà đầu tư giao dịch trong ngày cần giá theo thời gian thực và sổ lệnh chi tiết.
- Nhóm hoặc gia đình muốn cùng xem chung một danh mục.
- Người cần báo cáo thuế hoặc tính phí giao dịch.

### 2.3 Hành trình người dùng chính

**UJ-1. Lần đầu cài app — dựng lại danh mục từ Excel.**
Người dùng vừa cài app, mở lên lần đầu. Ứng dụng dẫn qua ba bước: khai báo các lớp tài sản đang có, nhập từng khoản nắm giữ, và khai báo vốn góp lũy kế khởi điểm. Họ nhập `0,12 BTC`, `2.500 USD ETH`, `100 cổ FPT`, `7 chỉ vàng`, `50 triệu tiết kiệm`, rồi năm khoản cho vay. Bước cuối ứng dụng hỏi: *"Tổng số tiền bạn đã bỏ ròng vào chứng khoán và crypto tính đến hôm nay là bao nhiêu?"* — họ nhập con số của mình. **Đỉnh điểm:** màn hình tổng quan hiện ra tổng tài sản và biểu đồ tròn cơ cấu, và họ đối chiếu thấy khớp với Excel. **Trạng thái sau đó:** Excel không còn cần mở nữa.

**UJ-2. Liếc nhanh danh mục lúc thị trường biến động.**
Đang ngồi cà phê, thấy tin BTC giảm mạnh. Mở app. **Đỉnh điểm:** trong dưới ba giây thấy tổng tài sản mới, biểu đồ tròn, và mức lãi lỗ hiện tại — không phải nhập gì, không phải tra giá. **Trạng thái sau đó:** biết mình đang ở đâu, đóng app. **Trường hợp ngoại lệ:** không có mạng — ứng dụng vẫn hiện đầy đủ số liệu nhưng ghi rõ *"giá cập nhật 5 giờ trước"* để họ biết đang nhìn số cũ.

**UJ-3. Vừa mua thêm crypto, cập nhật danh mục.**
Vừa mua thêm 0,01 BTC hết 25 triệu. Mở app, vào lớp Crypto, chạm vào dòng BTC, sửa số lượng từ `0,12` thành `0,13`. Sau đó vào sổ vốn, thêm một dòng nạp `+25 triệu`. **Đỉnh điểm:** tổng tài sản, tỷ trọng và vốn góp lũy kế đều tự cập nhật; lãi lỗ không nhảy vọt giả tạo vì phần tiền mới bỏ vào đã được ghi nhận đúng là vốn góp chứ không phải lợi nhuận. **Trạng thái sau đó:** danh mục phản ánh đúng thực tế trong vòng chưa tới 30 giây.

**UJ-4. Rà lại cơ cấu và quyết định tái cân bằng.**
Cuối tháng, ngồi xem lại danh mục. Vào màn hình mục tiêu. **Đỉnh điểm:** ứng dụng nói thẳng: *"BTC đang 57,4%, vượt mục tiêu 7,4% — tương đương 50 triệu. Vàng và chứng khoán đang thiếu 4,3% — tương đương 29 triệu."* Không phải nhẩm. Họ ghi một dòng kế hoạch: *"Bán bớt BTC, mua thêm 2 chỉ vàng."* **Trạng thái sau đó:** có con số cụ thể để hành động, và ghi chú còn đó để lần sau mở ra kiểm tra đã làm chưa.

**UJ-5. Anh Thắng trả xong khoản vay.**
Anh Thắng trả 63 triệu. Vào sổ nợ, chạm vào dòng của anh Thắng, đánh dấu **đã thu hồi**. **Đỉnh điểm:** tổng tài sản tự trừ đi 63 triệu ở lớp Cho vay, tỷ trọng các lớp tự tính lại; nhưng khoản đó vẫn nằm trong lịch sử để tra cứu về sau. **Trạng thái sau đó:** người dùng còn phải tự nhập 63 triệu đó đã đi đâu — vào tiết kiệm hay vào đầu tư. **Trường hợp ngoại lệ:** nếu chỉ trả một phần, người dùng sửa số tiền xuống thay vì đánh dấu tất toán.

**UJ-6. Phát hiện nhập sai một dòng vốn từ tháng trước.**
Xem lại lịch sử lãi lỗ thấy con số lạ. Truy ra dòng nạp vốn tháng trước đã gõ nhầm `47` thay vì `4,7`. Vào sổ vốn, chạm vào dòng đó, sửa lại. **Đỉnh điểm:** toàn bộ vốn góp lũy kế và lãi lỗ từ dòng đó trở về sau được tính lại ngay, biểu đồ lịch sử vẽ lại. **Trạng thái sau đó:** số liệu đúng trở lại, không phải xóa hết làm lại từ đầu.

## 3. Từ điển thuật ngữ

Mọi mục khác trong tài liệu này dùng đúng các từ dưới đây. Không dùng từ đồng nghĩa.

- **Danh mục** — toàn bộ tài sản của người dùng trong ứng dụng. Chỉ có một Danh mục duy nhất, và điều này đúng cho mọi phiên bản — không phải giới hạn tạm thời của bản đầu.
- **Lớp tài sản** — nhóm phân loại cấp một của Danh mục. Đúng năm lớp ở bản đầu: Chứng khoán, Vàng, Crypto, Tiền mặt & Tiết kiệm, Cho vay. USDT thuộc Lớp tài sản Crypto, không thuộc Tiền mặt & Tiết kiệm. Mỗi Lớp tài sản chứa nhiều Khoản nắm giữ.
- **Khoản nắm giữ** — một tài sản cụ thể trong một Lớp tài sản. Ví dụ: 0,13 BTC; 100 cổ FPT; 7 chỉ vàng. Có hai **chế độ nhập**: theo số lượng hoặc theo giá trị.
- **Chế độ nhập theo số lượng** — người dùng nhập Số lượng; Giá trị quy đổi do ứng dụng tính bằng Số lượng nhân Giá hiệu lực. Áp dụng cho Crypto, Chứng khoán, Vàng.
- **Chế độ nhập theo giá trị** — người dùng nhập thẳng Giá trị quy đổi. Áp dụng cho Tiền mặt & Tiết kiệm.
- **Số lượng** — lượng tài sản nắm giữ, kèm đơn vị: BTC, cổ, chỉ.
- **Giá hiệu lực** — giá một đơn vị tài sản mà ứng dụng đang dùng để tính. Bằng Giá nhập tay nếu có, ngược lại bằng Giá thị trường.
- **Giá thị trường** — giá lấy tự động từ nguồn dữ liệu bên ngoài, kèm thời điểm lấy.
- **Giá nhập tay** — giá do người dùng tự nhập, luôn thắng Giá thị trường cho tới khi bị xóa.
- **Tỷ giá** — tỷ lệ quy đổi USD sang VND.
- **Giá trị quy đổi** — giá trị của một Khoản nắm giữ hoặc một Lớp tài sản, tính bằng VND.
- **Tổng tài sản** — tổng Giá trị quy đổi của toàn bộ Danh mục.
- **Tỷ trọng thực tế** — Giá trị quy đổi của một Lớp tài sản chia cho Tổng tài sản.
- **Tỷ trọng mục tiêu** — tỷ lệ phần trăm người dùng đặt ra cho một Lớp tài sản.
- **Khoảng lệch** — hiệu giữa Tỷ trọng thực tế và Tỷ trọng mục tiêu, biểu diễn cả bằng phần trăm và bằng số tiền.
- **Nhóm đầu tư** — tập các Lớp tài sản tham gia tính Lãi lỗ. Ở bản đầu gồm đúng hai lớp: Chứng khoán và Crypto.
- **Dòng vốn** — một lần người dùng nạp thêm tiền vào hoặc rút tiền ra khỏi Nhóm đầu tư. Số dương là nạp, số âm là rút. Không phân biệt nạp vào lớp nào.
- **Vốn góp khởi điểm** — tổng số tiền ròng người dùng đã bỏ vào Nhóm đầu tư tính đến ngày bắt đầu dùng ứng dụng. Khai báo một lần ở bước khởi tạo.
- **Vốn góp lũy kế** — Vốn góp khởi điểm cộng tổng các Dòng vốn tính đến một thời điểm. Luôn là giá trị tính toán, không bao giờ lưu cứng.
- **Lãi lỗ** — Giá trị quy đổi của Nhóm đầu tư trừ Vốn góp lũy kế, tại cùng một thời điểm.
- **Bản chốt** — bản ghi lại Tổng tài sản, Vốn góp lũy kế, Lãi lỗ và cơ cấu từng Lớp tài sản tại một thời điểm. Có hai loại: **tự động** (ứng dụng tự sinh mỗi ngày) và **thủ công** (người dùng bấm chốt, có kèm ghi chú).
- **Khoản nợ** — một bản ghi cho vay hoặc đi vay với một người cụ thể. Số dương là cho vay, số âm là đi vay. Có trạng thái đang hiệu lực hoặc đã tất toán.
- **Ghi chú kế hoạch** — một dòng việc cần làm do người dùng tự viết, có trạng thái đã hoàn thành hoặc chưa.

## 4. Tính năng

### 4.1 Khởi tạo danh mục

**Mô tả:** Luồng chạy đúng một lần, khi người dùng mở ứng dụng lần đầu. Nó tồn tại vì một lý do nghiệp vụ chứ không phải vì thẩm mỹ: nếu thiếu Vốn góp khởi điểm thì mọi phép tính Lãi lỗ về sau đều sai, và sai theo kiểu không có dấu hiệu báo lỗi. Hiện thực hóa UJ-1.

Luồng gồm ba bước, có thể quay lại bước trước, và trạng thái được lưu tạm để đóng app giữa chừng vẫn tiếp tục được.

**Yêu cầu chức năng:**

#### FR-1: Dựng sẵn năm lớp tài sản

Ứng dụng tạo sẵn năm Lớp tài sản chuẩn ngay khi cài đặt, người dùng không phải khai báo từ con số không.

**Hệ quả kiểm thử được:**
- Sau khi cài, Danh mục có đúng năm Lớp tài sản: Chứng khoán, Vàng, Crypto, Tiền mặt & Tiết kiệm, Cho vay.
- Mỗi Lớp tài sản có sẵn tên, biểu tượng và màu riêng, phân biệt được trên biểu đồ tròn.
- Người dùng đổi được tên và ẩn được một Lớp tài sản không dùng tới; Lớp tài sản bị ẩn không xuất hiện trên biểu đồ và không tính vào Tổng tài sản.
- Lớp tài sản đang chứa Khoản nắm giữ thì không ẩn được, ứng dụng báo lý do cụ thể.

#### FR-2: Nhập Khoản nắm giữ ban đầu

Người dùng nhập các Khoản nắm giữ hiện có vào từng Lớp tài sản.

**Hệ quả kiểm thử được:**
- Bỏ qua được bước này và bổ sung sau; ứng dụng không chặn.
- Với Lớp tài sản dùng Chế độ nhập theo số lượng, ô nhập hiện đúng đơn vị tương ứng: BTC, cổ, chỉ.
- Với Lớp tài sản dùng Chế độ nhập theo giá trị, ô nhập là số tiền VND.

#### FR-3: Khai báo Vốn góp khởi điểm — bắt buộc

Người dùng khai báo tổng số tiền ròng đã bỏ vào Nhóm đầu tư tính đến ngày bắt đầu dùng ứng dụng.

**Hệ quả kiểm thử được:**
- Không hoàn tất được luồng khởi tạo nếu chưa nhập giá trị này.
- Ứng dụng giải thích rõ ý nghĩa con số bằng một câu ngắn ngay tại chỗ nhập, kèm ví dụ.
- Nhập số 0 được, nhưng ứng dụng cảnh báo hệ quả trước khi cho qua.
- Giá trị này sửa được về sau ở phần cài đặt, và mỗi lần sửa đều cảnh báo là toàn bộ lịch sử Lãi lỗ sẽ được tính lại.
- Ngày bắt đầu mặc định là ngày hoàn tất khởi tạo, đổi được.

**Ghi chú:** Con số 333 triệu trong Excel là của ngày 3/2/2026 và người dùng đã nạp thêm vốn sau mốc đó — giá trị thực tế sẽ do người dùng nhập tại thời điểm cài đặt, không hardcode.

---

### 4.2 Quản lý Khoản nắm giữ

**Mô tả:** Nơi người dùng phản ánh các giao dịch mua bán thật vào ứng dụng. Nguyên tắc: người dùng chỉ chạm vào dữ liệu khi thực sự có giao dịch, không phải mỗi lần muốn xem số liệu. Hiện thực hóa UJ-3.

Đây cũng là nơi đáp ứng yêu cầu chỉnh sửa mà người dùng nêu rõ: danh mục Crypto và Chứng khoán phải sửa và xóa được đầy đủ.

**Yêu cầu chức năng:**

#### FR-4: Thêm Khoản nắm giữ

Người dùng thêm một Khoản nắm giữ vào một Lớp tài sản.

**Hệ quả kiểm thử được:**
- Thông tin nhập gồm: ký hiệu hoặc tên, Số lượng hoặc Giá trị quy đổi tùy Chế độ nhập, ghi chú tùy chọn.
- Với Crypto, Số lượng nhận tối đa 8 chữ số thập phân và không mất chữ số nào khi lưu rồi đọc lại.
- Với Chứng khoán, Số lượng là số nguyên.
- Với Vàng, Số lượng nhận tối đa 2 chữ số thập phân, đơn vị chỉ.
- Không cho phép hai Khoản nắm giữ trùng ký hiệu trong cùng một Lớp tài sản.

#### FR-5: Sửa Khoản nắm giữ

Người dùng sửa bất kỳ trường nào của một Khoản nắm giữ đã có. Hiện thực hóa UJ-3.

**Hệ quả kiểm thử được:**
- Sửa được Số lượng, Giá trị quy đổi, ký hiệu, tên hiển thị, ghi chú.
- Ngay sau khi lưu, Giá trị quy đổi của Lớp tài sản, Tổng tài sản và mọi Tỷ trọng thực tế đều phản ánh giá trị mới.
- Sửa Khoản nắm giữ **không** làm thay đổi Vốn góp lũy kế — đây là hai khái niệm độc lập, và nhầm lẫn giữa chúng là lỗi nghiệp vụ nghiêm trọng.

#### FR-6: Xóa Khoản nắm giữ

Người dùng xóa một Khoản nắm giữ.

**Hệ quả kiểm thử được:**
- Có bước xác nhận trước khi xóa.
- Sau khi xóa, mọi số liệu tổng hợp tự tính lại.
- Các Bản chốt đã lưu trong quá khứ **không** bị ảnh hưởng — chúng ghi lại trạng thái tại thời điểm đó, không phải trạng thái hiện tại.

#### FR-7: Xem chi tiết một Lớp tài sản

Người dùng chạm vào một Lớp tài sản để xem các Khoản nắm giữ bên trong. Hiện thực hóa UJ-2.

**Hệ quả kiểm thử được:**
- Danh sách hiện: ký hiệu, Số lượng, Giá hiệu lực, Giá trị quy đổi, tỷ trọng trong nội bộ Lớp tài sản.
- Có biểu đồ tròn tỷ trọng nội bộ Lớp tài sản — tương ứng hai biểu đồ Chứng khoán và Tiền kĩ thuật số trong Excel.
- Với Lớp tài sản có Khoản nắm giữ tính bằng USD, hiển thị cả giá trị USD và giá trị VND đã quy đổi.

#### FR-8: Giá trị Lớp tài sản luôn là tổng các Khoản nắm giữ

Ứng dụng không cho phép nhập Giá trị quy đổi của một Lớp tài sản một cách độc lập.

**Hệ quả kiểm thử được:**
- Giá trị quy đổi của một Lớp tài sản luôn bằng tổng Giá trị quy đổi các Khoản nắm giữ thuộc nó.
- Riêng Lớp tài sản Cho vay, Giá trị quy đổi bằng tổng ròng các Khoản nợ đang hiệu lực.
- Không tồn tại màn hình nào cho phép sửa trực tiếp con số tổng của một Lớp tài sản.

**Ghi chú:** Yêu cầu này tồn tại để triệt tiêu đúng lỗi đang có trong Excel — dòng `C VAY + CASH = 183` được cộng thủ công từ hai sheet, và sẽ sai bất cứ lúc nào một bên đổi mà bên kia quên.

#### FR-9: Xử lý số học không mất chính xác

Mọi phép tính tiền tệ và số lượng không được sinh sai số làm tròn tích lũy.

**Hệ quả kiểm thử được:**
- Giá trị tiền tệ lưu dưới dạng số nguyên đơn vị đồng.
- Số lượng lưu dưới dạng số nguyên đã nhân hệ số, hoặc kiểu thập phân chính xác — không dùng số thực dấu phẩy động.
- Phép nhân Số lượng với Giá hiệu lực thực hiện ở độ chính xác đầy đủ, chỉ làm tròn ở bước hiển thị cuối cùng.
- Tổng Giá trị quy đổi các Khoản nắm giữ bằng đúng Giá trị quy đổi của Lớp tài sản, không lệch một đồng nào.

---

### 4.3 Giá thị trường và tỷ giá

**Mô tả:** Phần tạo ra giá trị tự động hóa lớn nhất so với Excel. Nguyên tắc nền: ứng dụng chỉ hỏi ra ngoài *"BTC giá bao nhiêu"* — câu hỏi đó không mang theo thông tin người dùng nắm giữ bao nhiêu. Danh mục không bao giờ rời khỏi máy.

Nguyên tắc thứ hai, quan trọng không kém: **không bao giờ hiển thị giá cũ như thể là giá mới.** Sai lệch âm thầm là kiểu lỗi nguy hiểm nhất trong một ứng dụng tài chính.

**Yêu cầu chức năng:**

#### FR-10: Lấy Giá thị trường cho Crypto

Ứng dụng tự lấy giá BTC, ETH, USDT từ nguồn dữ liệu công khai. Hiện thực hóa UJ-2.

**Hệ quả kiểm thử được:**
- Giá được làm mới khi mở ứng dụng, và làm mới lại được bằng thao tác kéo xuống.
- Yêu cầu gửi đi chỉ chứa ký hiệu tài sản, không chứa Số lượng hay bất kỳ dữ liệu nào của người dùng.
- Mỗi lần lấy thành công đều lưu lại kèm thời điểm.

#### FR-11: Lấy Tỷ giá USD sang VND

Ứng dụng tự lấy Tỷ giá để quy đổi các Khoản nắm giữ tính bằng USD.

**Hệ quả kiểm thử được:**
- Tỷ giá hiển thị được cho người dùng xem, kèm thời điểm cập nhật.
- Người dùng nhập tay đè Tỷ giá được.
- Có giá trị dự phòng dùng khi chưa từng lấy được lần nào.

#### FR-12: Nhập tay đè Giá hiệu lực

Người dùng nhập tay giá cho bất kỳ Khoản nắm giữ nào.

**Hệ quả kiểm thử được:**
- Giá nhập tay luôn thắng Giá thị trường.
- Khoản nắm giữ đang dùng Giá nhập tay có dấu hiệu nhận biết trên giao diện.
- Xóa Giá nhập tay được, khi đó ứng dụng quay lại dùng Giá thị trường.
- Với Chứng khoán và Vàng ở bản đầu, Giá nhập tay là cách duy nhất — ứng dụng nói rõ điều này thay vì để trống không giải thích.

#### FR-13: Hiển thị độ mới của giá

Mọi con số phái sinh từ giá đều đi kèm thông tin về thời điểm giá được cập nhật.

**Hệ quả kiểm thử được:**
- Màn hình tổng quan hiện thời điểm cập nhật gần nhất dưới dạng dễ đọc: *"cập nhật 5 phút trước"*.
- Khi giá cũ quá 24 giờ, có dấu hiệu cảnh báo trực quan. Ngưỡng này dùng chung cho mọi loại tài sản.
- Không có trạng thái nào mà ứng dụng hiển thị số liệu tài chính mà không cho biết nó tính từ giá lúc nào.

#### FR-14: Hoạt động khi không có mạng

Ứng dụng dùng đầy đủ được khi không có kết nối. Hiện thực hóa UJ-2 trường hợp ngoại lệ.

**Hệ quả kiểm thử được:**
- Mọi màn hình hiển thị bình thường, dùng giá lưu lần cuối.
- Có thông báo rõ ràng rằng đang dùng giá lưu, kèm thời điểm.
- Thêm, sửa, xóa Khoản nắm giữ, Dòng vốn, Khoản nợ đều hoạt động bình thường.
- Lỗi lấy giá không bao giờ chặn thao tác nào của người dùng.

---

### 4.4 Màn hình tổng quan

**Mô tả:** Màn hình đầu tiên khi mở ứng dụng. Bố cục giữ đúng thứ tự người dùng đã quen từ Excel: con số tổng ở trên, biểu đồ tròn cơ cấu ở dưới. Hiện thực hóa UJ-2.

**Yêu cầu chức năng:**

#### FR-15: Hiển thị Tổng tài sản

**Hệ quả kiểm thử được:**
- Tổng tài sản là con số nổi bật nhất màn hình.
- Định dạng tiền Việt Nam: dấu chấm ngăn nghìn, hậu tố đ.
- Có chế độ rút gọn dạng `680 tr` hoặc `1,2 tỷ`, chuyển đổi được.
- Kèm thời điểm cập nhật giá theo FR-13.

#### FR-16: Biểu đồ tròn cơ cấu Lớp tài sản

**Hệ quả kiểm thử được:**
- Mỗi Lớp tài sản là một phần của biểu đồ, dùng đúng màu đã gán ở FR-1.
- Nhãn hiện Tỷ trọng thực tế với một chữ số thập phân, khớp cách hiển thị của Excel.
- Chạm vào một phần của biểu đồ sẽ mở màn hình chi tiết Lớp tài sản đó theo FR-7.
- Lớp tài sản có Giá trị quy đổi bằng 0 không chiếm chỗ trên biểu đồ.

#### FR-17: Danh sách Lớp tài sản kèm số liệu

**Hệ quả kiểm thử được:**
- Dưới biểu đồ là danh sách năm Lớp tài sản, mỗi dòng gồm: tên, Giá trị quy đổi, Tỷ trọng thực tế.
- Sắp xếp theo Giá trị quy đổi giảm dần.

#### FR-18: Chỉ số Lãi lỗ trên màn hình tổng quan

**Hệ quả kiểm thử được:**
- Hiển thị Lãi lỗ hiện tại của Nhóm đầu tư, kèm dấu và màu phân biệt lãi với lỗ.
- Hiển thị cả số tiền tuyệt đối và tỷ lệ phần trăm so với Vốn góp lũy kế.
- Chạm vào để mở màn hình Lãi lỗ chi tiết.

---

### 4.5 Tỷ trọng mục tiêu và Khoảng lệch

**Mô tả:** Phần biến các ghi chú định tính ở cuối sheet Excel — *"mua thêm vàng và chứng khoán"* — thành con số cụ thể để hành động. Hiện thực hóa UJ-4.

**Yêu cầu chức năng:**

#### FR-19: Đặt Tỷ trọng mục tiêu

**Hệ quả kiểm thử được:**
- Người dùng đặt Tỷ trọng mục tiêu cho từng Lớp tài sản, sửa được bất cứ lúc nào.
- Ứng dụng hiện tổng các Tỷ trọng mục tiêu và cảnh báo nếu khác 100%, nhưng không chặn lưu.
- Gộp được nhiều Lớp tài sản vào một mục tiêu chung, vì người dùng đang đặt mục tiêu `Vàng + Chứng khoán = 20%`.

#### FR-20: Tính và hiển thị Khoảng lệch

**Hệ quả kiểm thử được:**
- Với mỗi Lớp tài sản hoặc nhóm có Tỷ trọng mục tiêu, hiển thị: Tỷ trọng thực tế, Tỷ trọng mục tiêu, Khoảng lệch theo phần trăm, và **Khoảng lệch quy ra tiền**.
- Khoảng lệch quy ra tiền tính bằng `(Tỷ trọng thực tế − Tỷ trọng mục tiêu) × Tổng tài sản`.
- Phân biệt trực quan giữa thừa và thiếu.
- Có biểu đồ cột so sánh thực tế với mục tiêu cho toàn bộ các Lớp tài sản.

#### FR-21: Ngưỡng cảnh báo lệch

**Hệ quả kiểm thử được:**
- Người dùng đặt được ngưỡng phần trăm mà vượt qua nó thì Lớp tài sản được đánh dấu là cần chú ý. `[GIẢ ĐỊNH: mặc định 5%]`
- Lớp tài sản vượt ngưỡng có dấu hiệu nhận biết trên màn hình tổng quan.

---

### 4.6 Sổ vốn và Lãi lỗ

**Mô tả:** Trái tim của ứng dụng và là phần dễ sai nhất. Giữ nguyên phương pháp vốn góp ròng người dùng đã dùng suốt một năm. Người dùng đã yêu cầu rõ: lịch sử vốn phải sửa và xóa được. Hiện thực hóa UJ-3 và UJ-6.

**Yêu cầu chức năng:**

#### FR-22: Ghi Dòng vốn

**Hệ quả kiểm thử được:**
- Người dùng thêm một Dòng vốn gồm: ngày, số tiền, ghi chú tùy chọn.
- Số dương là nạp thêm vào, số âm là rút ra; giao diện có nút chuyển đổi rõ ràng thay vì bắt gõ dấu trừ.
- Dòng vốn **không** phân biệt nạp vào Lớp tài sản nào — đúng như cách Excel đang làm.

#### FR-23: Sửa và xóa Dòng vốn

Người dùng sửa hoặc xóa bất kỳ Dòng vốn nào, kể cả dòng cũ nhất. Hiện thực hóa UJ-6.

**Hệ quả kiểm thử được:**
- Sửa được số tiền, ngày và ghi chú.
- Xóa được, có bước xác nhận.
- Sau mỗi thao tác, Vốn góp lũy kế và Lãi lỗ của **mọi thời điểm từ dòng đó trở về sau** đều được tính lại, bao gồm cả các Bản chốt đã lưu.
- Đổi ngày của một Dòng vốn cho kết quả đúng như khi xóa nó rồi thêm lại với ngày mới.

#### FR-24: Vốn góp lũy kế là giá trị tính toán

Ứng dụng không lưu cứng Vốn góp lũy kế cho từng dòng.

**Hệ quả kiểm thử được:**
- Cơ sở dữ liệu chỉ lưu số tiền của từng Dòng vốn và một Vốn góp khởi điểm duy nhất.
- Vốn góp lũy kế tại một thời điểm luôn tính bằng `Vốn góp khởi điểm + tổng các Dòng vốn có ngày nhỏ hơn hoặc bằng thời điểm đó`.
- Kiểm thử bắt buộc: dựng chuỗi Dòng vốn `+341, −60, −36, +9`, sửa dòng thứ hai từ `−60` thành `−50`, xác nhận cả ba giá trị lũy kế phía sau đều đổi theo.

#### FR-25: Tính Lãi lỗ

**Hệ quả kiểm thử được:**
- `Lãi lỗ = Giá trị quy đổi của Nhóm đầu tư − Vốn góp lũy kế`, cùng một thời điểm.
- Nhóm đầu tư ở bản đầu gồm đúng Chứng khoán và Crypto; Vàng, Tiền mặt & Tiết kiệm, Cho vay bị loại trừ.
- Kiểm thử đối chiếu bắt buộc: mười dòng dữ liệu lịch sử trong `addendum.md` mục 3 phải cho ra đúng cột Vốn góp lũy kế và cột Lãi lỗ đã ghi.
- Hiển thị Lãi lỗ theo cả số tiền tuyệt đối và tỷ lệ phần trăm.

#### FR-26: Màn hình Lãi lỗ chi tiết

**Hệ quả kiểm thử được:**
- Hiện Giá trị quy đổi hiện tại của Nhóm đầu tư, Vốn góp lũy kế, và Lãi lỗ.
- Hiện rõ Vốn góp khởi điểm như một dòng riêng, để người dùng luôn đối chiếu được con số neo.
- Hiện danh sách toàn bộ Dòng vốn theo thứ tự thời gian, kèm Vốn góp lũy kế tại từng dòng.
- Từ danh sách này mở thẳng được thao tác sửa và xóa theo FR-23.

#### FR-27: Cấu hình Nhóm đầu tư

**Hệ quả kiểm thử được:**
- Người dùng chọn được Lớp tài sản nào tham gia Nhóm đầu tư.
- Mặc định đúng hai lớp Chứng khoán và Crypto.
- Đổi cấu hình sẽ tính lại Lãi lỗ toàn bộ lịch sử, và ứng dụng cảnh báo trước khi áp dụng.

---

### 4.7 Bản chốt và lịch sử

**Mô tả:** Giải quyết trực tiếp khoảng đứt bốn tháng trong lịch sử Excel. Thêm một thứ Excel không có: mỗi Bản chốt lưu cả cơ cấu từng Lớp tài sản tại thời điểm đó, nên sau này dựng lại được bức tranh quá khứ.

**Yêu cầu chức năng:**

#### FR-28: Tự sinh Bản chốt hằng ngày

**Hệ quả kiểm thử được:**
- Mỗi ngày ứng dụng sinh một Bản chốt tự động, ghi lại Tổng tài sản, Vốn góp lũy kế, Lãi lỗ và Giá trị quy đổi của từng Lớp tài sản.
- Bản chốt được sinh khi người dùng mở ứng dụng, không cần chạy nền.
- Ngày người dùng không mở ứng dụng thì không có Bản chốt, và ứng dụng **không nội suy** để lấp chỗ trống. Biểu đồ đường nối thẳng giữa hai Bản chốt liền kề.
- Mỗi ngày chỉ có tối đa một Bản chốt tự động.
- Bản chốt tự động không sửa và không xóa được.

#### FR-29: Chốt thủ công kèm ghi chú

**Hệ quả kiểm thử được:**
- Người dùng bấm chốt bất cứ lúc nào, kèm ghi chú tự do.
- Bản chốt thủ công phân biệt được với Bản chốt tự động trên danh sách lịch sử.
- Bản chốt thủ công xóa được.

#### FR-30: Biểu đồ đường theo thời gian

**Hệ quả kiểm thử được:**
- Biểu đồ đường Tổng tài sản theo thời gian.
- Biểu đồ đường Lãi lỗ theo thời gian.
- Chọn được khoảng thời gian: 1 tháng, 3 tháng, 6 tháng, 1 năm, toàn bộ.
- Chạm vào một điểm trên biểu đồ hiện số liệu chi tiết của ngày đó.
- Khi chưa đủ dữ liệu để vẽ, hiển thị thông báo giải thích thay vì biểu đồ trống.

#### FR-31: Xem lại một Bản chốt

**Hệ quả kiểm thử được:**
- Mở được một Bản chốt cũ để xem cơ cấu Lớp tài sản tại thời điểm đó.
- Bản chốt cũ không bị ảnh hưởng khi người dùng thêm, sửa, xóa Khoản nắm giữ ở hiện tại.
- Ngoại lệ: sửa Dòng vốn có ảnh hưởng tới cột Vốn góp lũy kế và Lãi lỗ của Bản chốt cũ, theo FR-23 — vì đó là sửa chính lịch sử.

---

### 4.8 Sổ nợ và cho vay

**Mô tả:** Thay thế sheet thứ hai của Excel, và triệt tiêu phép cộng thủ công giữa hai sheet. Hiện thực hóa UJ-5.

**Yêu cầu chức năng:**

#### FR-32: Quản lý Khoản nợ

**Hệ quả kiểm thử được:**
- Thêm, sửa, xóa được Khoản nợ với các trường: tên người, loại cho vay hoặc đi vay, số tiền, ngày, ghi chú.
- Giao diện dùng nút chọn cho vay hoặc đi vay, không bắt người dùng gõ dấu âm.
- Danh sách hiện tổng cho vay, tổng đi vay và tổng ròng.

#### FR-33: Đánh dấu đã tất toán

**Hệ quả kiểm thử được:**
- Người dùng đánh dấu một Khoản nợ là đã tất toán, kèm ngày tất toán.
- Khoản nợ đã tất toán bị loại khỏi Giá trị quy đổi của Lớp tài sản Cho vay, và do đó khỏi Tổng tài sản.
- Khoản nợ đã tất toán vẫn xem lại được ở mục lịch sử, tách khỏi danh sách đang hiệu lực.
- Bỏ đánh dấu tất toán được, nếu người dùng thao tác nhầm.
- Ứng dụng **không hỏi** số tiền thu về đi đâu và không tự tạo thao tác nào khác; người dùng tự cập nhật Lớp tài sản tương ứng nếu muốn.

#### FR-34: Trả một phần

**Hệ quả kiểm thử được:**
- Người dùng sửa số tiền của Khoản nợ xuống mức còn lại.
- Ứng dụng không yêu cầu ghi lại lịch sử từng lần trả. `[NON-GOAL cho MVP: sổ theo dõi từng lần trả góp]`

#### FR-35: Liên kết tự động vào Tổng tài sản

**Hệ quả kiểm thử được:**
- Giá trị quy đổi của Lớp tài sản Cho vay luôn bằng tổng ròng các Khoản nợ đang hiệu lực.
- Không tồn tại thao tác nào cho phép nhập tay con số này.
- Mọi thay đổi trong Sổ nợ phản ánh ngay vào Tổng tài sản và mọi Tỷ trọng thực tế.

---

### 4.9 Ghi chú kế hoạch

**Mô tả:** Thay thế các dòng chữ đỏ ở cuối sheet Excel. Hiện thực hóa UJ-4.

**Yêu cầu chức năng:**

#### FR-36: Quản lý Ghi chú kế hoạch

**Hệ quả kiểm thử được:**
- Thêm, sửa, xóa được Ghi chú kế hoạch dạng văn bản tự do.
- Đánh dấu hoàn thành được; ghi chú đã hoàn thành chuyển xuống nhóm riêng.
- Danh sách sắp xếp theo ngày tạo, mới nhất lên trên.

#### FR-37: Ghi chú hiển thị ở màn hình mục tiêu

**Hệ quả kiểm thử được:**
- Các Ghi chú kế hoạch chưa hoàn thành hiện ngay dưới phần Khoảng lệch, để người dùng thấy kế hoạch cạnh con số sinh ra nó.

---

### 4.10 Sao lưu và xuất dữ liệu

**Mô tả:** Đối trọng bắt buộc của kiến trúc chỉ lưu trên máy. Không có phần này thì mất máy là mất trắng.

**Yêu cầu chức năng:**

#### FR-38: Xuất toàn bộ dữ liệu ra tệp

**Hệ quả kiểm thử được:**
- Xuất được toàn bộ Khoản nắm giữ, Dòng vốn, Khoản nợ, Bản chốt và Ghi chú kế hoạch.
- Tệp xuất ra chia sẻ được qua các ứng dụng sẵn có của hệ điều hành.
- Định dạng đọc được bằng Excel, giữ đúng dấu tiếng Việt.
- Ứng dụng nhắc sao lưu khi đã lâu chưa xuất. `[GIẢ ĐỊNH: ngưỡng 30 ngày]`

---

### 4.11 Cài đặt và giao diện

**Yêu cầu chức năng:**

#### FR-39: Chế độ sáng và tối

**Hệ quả kiểm thử được:**
- Ba lựa chọn: sáng, tối, theo hệ thống.
- Biểu đồ đọc được rõ ràng ở cả hai chế độ.

#### FR-40: Định dạng số kiểu Việt Nam

**Hệ quả kiểm thử được:**
- Dấu chấm ngăn nghìn, dấu phẩy thập phân.
- Tỷ trọng hiển thị một chữ số thập phân, khớp Excel.
- Số lượng hiển thị đúng số chữ số thập phân của từng loại tài sản, không hiện số 0 thừa phía sau.

#### FR-41: Sửa các thiết lập nền

**Hệ quả kiểm thử được:**
- Sửa được Vốn góp khởi điểm, ngày bắt đầu, Tỷ giá nhập tay, ngưỡng cảnh báo lệch, cấu hình Nhóm đầu tư.
- Mỗi thiết lập ảnh hưởng tới lịch sử đều có cảnh báo trước khi áp dụng.

## 5. Yêu cầu phi chức năng xuyên suốt

**Hiệu năng**
- Từ khi chạm biểu tượng ứng dụng đến khi màn hình tổng quan hiện đầy đủ số liệu: dưới 3 giây, kể cả khi không có mạng.
- Mọi thao tác thêm, sửa, xóa cho phản hồi trên giao diện dưới 300 mili giây.
- Vẽ biểu đồ đường với 365 Bản chốt không gây giật.

**Tính đúng đắn — mức ưu tiên cao nhất**
- Không có phép tính tiền tệ nào dùng số thực dấu phẩy động.
- Mọi công thức tổng hợp phải khớp tuyệt đối với cách tính trong Excel khi cùng đầu vào.
- Một thao tác sửa dữ liệu quá khứ phải kéo theo tính lại đầy đủ mọi giá trị phụ thuộc, không để lại số cũ ở bất kỳ màn hình nào.

**Riêng tư**
- Không có tài khoản, không đăng nhập, không đồng bộ.
- Yêu cầu mạng duy nhất được phép là lấy Giá thị trường và Tỷ giá, và chỉ chứa ký hiệu tài sản.
- Không thu thập số liệu sử dụng, không gắn công cụ phân tích hành vi, không quảng cáo.

**Độ tin cậy**
- Tắt ứng dụng đột ngột giữa lúc đang nhập không được làm hỏng dữ liệu đã lưu.
- Nâng cấp phiên bản không được làm mất dữ liệu; mọi thay đổi cấu trúc dữ liệu phải có đường chuyển đổi.
- Lỗi mạng không bao giờ chặn thao tác của người dùng.

**Khả năng dùng**
- Toàn bộ giao diện tiếng Việt.
- Thao tác được bằng một tay; các nút chính nằm trong tầm ngón cái.
- Bàn phím số bật sẵn ở mọi ô nhập tiền và số lượng.

## 6. Không làm gì

- **Không phải sổ thu chi hằng ngày.** Ứng dụng không ghi nhận việc mua ly cà phê. Ranh giới này giữ chặt vì mỗi tính năng chi tiêu thêm vào đều kéo sản phẩm về phía một thứ khác.
- **Không trở thành công cụ giao dịch.** Không đặt lệnh, không kết nối tài khoản chứng khoán hay sàn crypto.
- **Không tư vấn đầu tư.** Ứng dụng chỉ ra Khoảng lệch so với mục tiêu do chính người dùng đặt, không khuyến nghị mua bán gì.
- **Không đa người dùng.** Một máy, một Danh mục, một người.
- **Không có máy chủ.** Không tài khoản, không đồng bộ, không sao lưu đám mây ở bản đầu.
- **Không tính thuế và phí giao dịch.**
- **Không ghi ngày mua của Khoản nắm giữ.** Ứng dụng theo dõi trạng thái hiện tại, không theo dõi lịch sử giao dịch của từng tài sản.
- **Không bao giờ có nhiều Danh mục.** Một máy, một Danh mục — kể cả ở các phiên bản sau.

## 7. Phạm vi MVP

### 7.1 Trong phạm vi

- Khởi tạo Danh mục với năm Lớp tài sản và Vốn góp khởi điểm bắt buộc.
- Quản lý Khoản nắm giữ đầy đủ thêm, sửa, xóa cho cả năm Lớp tài sản.
- Giá thị trường tự động cho Crypto và Tỷ giá USD; nhập tay đè giá cho mọi loại tài sản.
- Màn hình tổng quan với Tổng tài sản, biểu đồ tròn, danh sách Lớp tài sản, chỉ số Lãi lỗ.
- Chi tiết từng Lớp tài sản kèm biểu đồ tròn nội bộ.
- Tỷ trọng mục tiêu, Khoảng lệch quy ra tiền, biểu đồ cột so sánh.
- Sổ vốn đầy đủ thêm, sửa, xóa; Lãi lỗ theo phương pháp vốn góp ròng.
- Bản chốt tự động hằng ngày và chốt thủ công; biểu đồ đường lịch sử.
- Sổ nợ và cho vay với trạng thái tất toán, liên kết tự động vào Tổng tài sản.
- Ghi chú kế hoạch.
- Xuất dữ liệu ra tệp để sao lưu.
- Chế độ sáng tối, định dạng số kiểu Việt Nam.

### 7.2 Ngoài phạm vi MVP

- **Giá cổ phiếu Việt Nam tự động** — API không ổn định, điều khoản không rõ ràng. Nhập tay ở bản đầu. Để v1.1. `[GHI CHÚ CHO PM: đây là mục dễ gây khó chịu nhất trong danh sách này, cân nhắc lại nếu tìm được nguồn đáng tin]`
- **Giá vàng tự động** — không có nguồn công khai đáng tin cho giá SJC. Để v1.1.
- **Nhập dữ liệu hàng loạt từ tệp** — dữ liệu ban đầu chỉ khoảng 15 dòng, nhập tay nhanh hơn viết tính năng.
- **Sổ lệnh mua bán và giá vốn bình quân** — Excel hiện không làm; đưa vào sẽ vượt mục tiêu thay thế Excel. Để v1.1.
- **Lãi suất và kỳ hạn cho tiền gửi tiết kiệm và khoản cho vay** — để v1.1, kèm nhắc đáo hạn.
- **Khóa ứng dụng bằng sinh trắc học** — để v1.1. `[GHI CHÚ CHO PM: dữ liệu tài chính nằm trên máy không khóa, cân nhắc kéo lên MVP nếu kịp]`
- **Cảnh báo giá và thông báo đẩy** — kéo theo chạy nền và xin quyền, chi phí không tương xứng. Để v2.
- **Sao lưu tự động lên đám mây riêng của người dùng** — để v2, phải mã hóa đầu cuối.
- **Gợi ý tái cân bằng thành lệnh cụ thể** — để v2.
- **Ngoại tệ ngoài VND và USD** — không có nhu cầu.

## 8. Chỉ số thành công

**Chính**

- **SM-1: Tần suất theo dõi.** Người dùng mở ứng dụng xem Danh mục ít nhất một lần mỗi tuần. Đối chiếu mốc nền: Excel cho mười lần chốt sổ trong mười ba tháng, khoảng đứt lớn nhất bốn tháng. Kiểm chứng FR-15, FR-16, FR-18.
- **SM-2: Tính đúng đắn tuyệt đối.** Toàn bộ số liệu tổng hợp khớp chính xác với Excel khi cùng đầu vào; bộ mười dòng lịch sử trong addendum cho ra đúng kết quả. Đây là điều kiện tiên quyết, không phải mục tiêu phấn đấu. Kiểm chứng FR-9, FR-24, FR-25.
- **SM-3: Thời gian mở tới lúc thấy số liệu.** Dưới 3 giây, kể cả không có mạng. Kiểm chứng FR-14, FR-15.

**Phụ**

- **SM-4: Liên tục của lịch sử.** Không có khoảng trống nào quá 30 ngày trong chuỗi Bản chốt. Kiểm chứng FR-28.
- **SM-5: Thời gian cập nhật sau giao dịch.** Dưới 15 giây từ khi mở ứng dụng đến khi lưu xong thay đổi Số lượng và Dòng vốn tương ứng. Kiểm chứng FR-5, FR-22.
- **SM-6: Excel bị bỏ hẳn.** Sau một tháng dùng ứng dụng, người dùng không còn mở file Excel cũ. Đây là thước đo thật sự của việc thay thế.

**Chỉ số đối trọng — không được tối ưu**

- **SM-C1: Số lượng tính năng.** Không lấy việc thêm tính năng làm thành tích. Đối trọng với xu hướng phình phạm vi; mỗi tính năng thêm vào đều làm chậm SM-3 và làm loãng SM-1.
- **SM-C2: Tần suất gọi mạng.** Không tăng số lần gọi API để làm số liệu "tươi hơn". Đối trọng với SM-3 — giá cũ vài giờ mà hiển thị trung thực thì tốt hơn là gọi mạng liên tục làm chậm ứng dụng và hao pin.

## 9. Các điểm đã chốt

Không còn câu hỏi mở. Sáu vấn đề nảy sinh trong quá trình viết đã được quyết, tất cả đều theo hướng giữ phạm vi gọn:

| Vấn đề | Quyết định | Ảnh hưởng |
|---|---|---|
| Ngày mua của Khoản nắm giữ | **Không ghi.** Ứng dụng theo dõi trạng thái hiện tại, không theo dõi lịch sử từng tài sản. | Bỏ một trường khỏi mô hình dữ liệu. Đường tới sổ lệnh và giá vốn bình quân ở v1.1 sẽ phải thêm lại từ đầu — chấp nhận. |
| USDT thuộc lớp nào | **Lớp tài sản Crypto**, không tách sang Tiền mặt & Tiết kiệm. | Giữ đúng cấu trúc Excel gốc. |
| Hỏi tiền đi đâu khi tất toán Khoản nợ | **Không hỏi.** Người dùng tự cập nhật. | FR-33 giữ nguyên, không thêm luồng phụ. |
| Ngưỡng cảnh báo giá cũ | **Giữ 24 giờ**, dùng chung mọi loại tài sản. | Bỏ được cấu hình ngưỡng riêng theo từng lớp. |
| Bản chốt ngày không mở app | **Không sinh, không nội suy.** Biểu đồ nối thẳng giữa hai Bản chốt liền kề. | Bỏ được toàn bộ logic chạy nền và logic nội suy. Đơn giản hóa đáng kể. |
| Nhiều Danh mục | **Không bao giờ.** Một máy, một Danh mục. | Mô hình dữ liệu không cần khóa ngoại tới bảng Danh mục ở bất kỳ bảng nào. |

## 10. Chỉ mục các giả định

Toàn bộ nhãn `[GIẢ ĐỊNH]` trong tài liệu, gom lại để xác nhận:

**Đã xác nhận:**

1. ~~**§4.3 FR-13** — Ngưỡng cảnh báo giá cũ 24 giờ.~~ **Chốt: giữ 24 giờ.**
2. ~~**§4.7 FR-28** — Chấp nhận thiếu Bản chốt những ngày không mở app.~~ **Chốt: không sinh, không nội suy.**

**Còn chờ xác nhận:**

3. **§4.5 FR-21** — Ngưỡng cảnh báo lệch mặc định là 5%.
4. **§4.10 FR-38** — Nhắc sao lưu sau 30 ngày không xuất dữ liệu.
5. **§2.3 UJ-1** — Số `0,12 BTC` và `100 cổ FPT` là minh họa suy từ giá trị trong Excel, không phải số lượng thật. Không ảnh hưởng tới lập trình.
6. **§4.1 FR-1** — Năm Lớp tài sản là đủ, người dùng không cần thêm lớp mới ở bản đầu.
