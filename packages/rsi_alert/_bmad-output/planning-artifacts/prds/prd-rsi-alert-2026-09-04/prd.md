---
title: RSI Alert
created: 2026-09-04
updated: 2026-11-13
---

# PRD: RSI Alert

## 0. Document Purpose

Tài liệu này dành cho pha Architect và pha Dev kế tiếp trong quy trình BMAD. Nó xây trên `brief-rsi-alert-2026-09-04/brief.md` và không lặp lại phần lý do tồn tại của sản phẩm — hãy đọc brief trước. Cấu trúc: §3 Từ điển khoá vốn từ vựng cho toàn bộ tài liệu, §4 gom yêu cầu chức năng (FR) theo tính năng, giả định được gắn thẻ `[GIẢ ĐỊNH]` ngay tại chỗ và liệt kê lại ở §10. Chưa có tài liệu UX riêng; §4.1 mô tả bố cục ở mức đủ cho Dev.

## 1. Vision

RSI Alert cho người dùng biết đúng một điều: **RSI(14) khung tuần của Bitcoin và VNINDEX hiện đang ở đâu, và nó vừa cắt qua ngưỡng 30 hay 70 hay chưa.**

Giá trị nằm ở chỗ app không làm gì khác. Không bảng giá, không tin tức, không danh mục, không khuyến nghị. Mở lên là thấy hai con số và trạng thái của chúng; muốn xem bối cảnh thì có biểu đồ nến tuần kèm khung RSI; muốn tự đánh giá độ tin cậy của tín hiệu thì có lịch sử mọi lần cắt ngưỡng trong quá khứ.

**Bổ sung 2026-11-13 — Vùng DCA theo Cẩm nang.** Người dùng có một cẩm nang DCA tự soạn (5 vùng RSI tuần, kèm Fear & Greed cho BTC). App xếp tuần đã đóng gần nhất vào một trong năm vùng đó và **trích lại luật người dùng đã viết** cho vùng ấy — app không tự đưa lời khuyên (§5). Xem §4.6 và §11.

Điều này quan trọng vì tín hiệu RSI tuần xuất hiện thưa và luôn rơi vào lúc thị trường ồn ào nhất. Một công cụ chỉ hiển thị đúng thứ cần nhìn, và im lặng phần còn lại, chính là thứ giúp giữ được kỷ luật của phương pháp.

## 2. Target User

### 2.1 Jobs To Be Done

- **Chức năng:** biết RSI tuần của BTC và VNINDEX ngay lúc này mà không phải mở TradingView, tìm mã, đổi khung, bật chỉ báo.
- **Chức năng:** biết đã có tín hiệu cắt ngưỡng nào mới kể từ lần cuối mở app hay chưa.
- **Nhận thức:** tự đánh giá xem tín hiệu lần này đáng tin đến đâu, bằng cách nhìn lại các lần cắt ngưỡng trước và phản ứng của giá sau đó.
- **Cảm xúc:** kiểm tra thị trường mà không bị kéo vào trạng thái cảm xúc do bảng giá và tin tức gây ra.
- **Xã hội:** không có. Đây là công cụ riêng tư, không chia sẻ, không so kè.

### 2.2 Non-Users (v1)

- Người lướt sóng trong ngày — khung tuần vô nghĩa với họ.
- Người muốn theo dõi danh mục, lãi lỗ, tài sản. Việc đó thuộc project `personal_finance`.
- Người cần theo dõi nhiều mã cổ phiếu riêng lẻ. v1 chỉ có hai mã cố định.

### 2.3 Key User Journeys

- **UJ-1. Hà mở app buổi sáng thứ Hai và thấy không có gì xảy ra.**
  > Hà, nhà đầu tư cá nhân giữ vị thế dài hạn ở cả BTC lẫn cổ phiếu Việt Nam, pha cà phê xong thì mở RSI Alert theo thói quen. Không cần đăng nhập. App tải dữ liệu trong khoảng một giây và hiện hai thẻ: BTC — RSI 54.2 — Trung tính; VNINDEX — RSI 61.8 — Trung tính. Không có dải cảnh báo nào trên đầu. Hà đóng app sau bảy giây. **Đây là hành trình xảy ra nhiều nhất, và app phải làm nó thật gọn** — im lặng là kết quả đúng, không phải màn hình trống cần lấp đầy.

- **UJ-2. Hà bắt được tín hiệu quá bán của VNINDEX.**
  > Sau một tuần thị trường giảm mạnh, Hà mở app vào sáng thứ Bảy. Trên đầu màn hình là một dải đỏ: "VNINDEX — Quá bán — RSI 28.4 — tuần 25/08–29/08". Thẻ VNINDEX cũng chuyển màu tương ứng. Hà chạm vào thẻ, vào màn hình chi tiết, thấy đường RSI vừa xuyên xuống dưới vạch 30 lần đầu kể từ đầu năm. Hà cuộn ngang về quá khứ, đối chiếu ba lần cắt ngưỡng trước đó và thấy giá đều hồi trong vòng vài tuần. **Giá trị đến ở khoảnh khắc dải đỏ hiện ra mà không cần Hà phải đi tìm.** Hà chuyển sang tab Lịch sử để xem lại toàn bộ các lần chạm ngưỡng trước, rồi đóng app và tự quyết định. App không gợi ý gì cả.

- **UJ-3. Hà mở app khi mất mạng.**
  > Hà mở app trên máy bay. Không tải được dữ liệu mới. App hiện đúng số của lần cập nhật gần nhất, kèm dòng chữ nhỏ "Dữ liệu lúc 09:12, 03/09/2026 — chưa cập nhật được". Biểu đồ và lịch sử tín hiệu vẫn xem được đầy đủ. **Không có màn hình lỗi trắng, không có dialog chặn.** Hà biết mình đang nhìn số cũ và điều đó là đủ.

- **UJ-4. Hà nhìn RSI của nến tuần đang chạy.**
  > Hôm nay là thứ Tư. Hà mở màn hình chi tiết BTC. Nến tuần cuối cùng trên biểu đồ được vẽ mờ và có nhãn "tuần đang chạy"; giá trị RSI kèm chữ *tạm tính*. Hà hiểu con số này còn đổi trước khi tuần kết thúc, và biết rằng app sẽ không sinh tín hiệu từ nó. **Edge case:** nếu RSI tạm tính đang dưới 30 nhưng nến chưa đóng, app hiển thị trạng thái đó ở màn hình chi tiết nhưng **không** hiện dải cảnh báo và **không** ghi vào lịch sử tín hiệu.

## 3. Glossary

- **Nến tuần** — một bản ghi OHLCV ứng với một tuần giao dịch của một Mã, gồm mốc thời gian mở tuần, giá mở, cao nhất, thấp nhất, đóng cửa, khối lượng. Nến tuần của mỗi Mã theo đúng mốc tuần mà Nguồn dữ liệu trả về; không quy đổi giữa các Mã.
- **Nến đang chạy** — Nến tuần cuối cùng trong chuỗi, ứng với tuần chưa kết thúc. Mọi giá trị của nó còn thay đổi.
- **Nến đã đóng** — mọi Nến tuần không phải Nến đang chạy.
- **Mã** — một tài sản được theo dõi. v1 có đúng hai: `BTC` và `VNINDEX`. Quan hệ: một Mã có một Nguồn dữ liệu chính và không hoặc một Nguồn dự phòng.
- **RSI** — Relative Strength Index chu kỳ 14 tính theo phương pháp làm mượt Wilder, trên chuỗi giá đóng cửa của Nến tuần. Mỗi Nến tuần có tối đa một giá trị RSI; 14 nến đầu tiên của chuỗi không có RSI.
- **RSI tạm tính** — giá trị RSI tính trên Nến đang chạy. Hiển thị được, nhưng không bao giờ sinh Tín hiệu.
- **Ngưỡng quá bán** — hằng số 30. **Ngưỡng quá mua** — hằng số 70. v1 không cho sửa.
- **Trạng thái** — một trong `Quá bán` (RSI < 30), `Trung tính` (30 ≤ RSI ≤ 70), `Quá mua` (RSI > 70), `Chưa đủ dữ liệu` (không có giá trị RSI).
- **Tín hiệu** — sự kiện RSI **cắt qua** một Ngưỡng giữa hai Nến đã đóng liền kề. Hai loại: `Quá bán` (nến trước có RSI ≥ 30, nến này có RSI < 30) và `Quá mua` (nến trước có RSI ≤ 70, nến này có RSI > 70). Một Nến đã đóng sinh ra tối đa một Tín hiệu. Quan hệ: một Mã có nhiều Tín hiệu, xếp theo thời gian.
- **Tín hiệu mới** — Tín hiệu có mốc tuần muộn hơn mốc tuần của Tín hiệu cuối cùng mà người dùng đã xem, tính riêng theo từng Mã.
- **Nguồn dữ liệu** — một dịch vụ HTTP công khai trả về chuỗi Nến tuần cho một Mã.
- **Cẩm nang** — bộ luật DCA do người dùng tự soạn (hai tài liệu "Cẩm nang Chiến lược DCA & Phân bổ Vốn Dài hạn 2026–2028" và "Dữ liệu lịch sử các chu kỳ đáy & đỉnh"). App chỉ trích lại, không sửa nội dung.
- **Vùng DCA** — một trong năm vùng xếp theo RSI của Nến đã đóng: `Vùng 1 · Gom mạnh`, `Vùng 2 · Gom thăm dò`, `Vùng 3 · Nắm giữ`, `Vùng 4 · Chốt thăm dò`, `Vùng 5 · Xả hàng`. Ranh giới "≤": BTC 35 / 45 / 70 / 82; VNINDEX 32 / 40 / 68 / 76.
- **F&G** — Fear & Greed Index crypto (alternative.me), 0–100, theo ngày. Chỉ có cho BTC. Mức: ≤24 Sợ hãi cực độ, 25–42 Sợ hãi, 43–70 Trung tính, 71–82 Tham lam, ≥83 Tham lam cực độ.
- **F&G cực độ cùng chiều** — Vùng mua kèm F&G ≤24, hoặc Vùng bán kèm F&G ≥83. Là mức tăng cường, **không** phải điều kiện để có Vùng.
- **Phân kỳ giảm tuần** — tuần giá đóng cửa cao nhất trong 104 tuần trong khi RSI thấp hơn đỉnh RSI cao nhất trước đó trong cửa sổ, đỉnh đó đã vào Vùng 5, và giữa hai đỉnh RSI đã có lúc về Vùng Nắm giữ trở xuống.
- **Lời nhắc tuần** — thông báo cục bộ lúc 09:30 thứ Hai giờ Việt Nam, không mang nội dung Vùng.
- **Kho cục bộ** — nơi lưu Nến tuần và trạng thái đã xem trên máy, dùng để hiển thị khi không gọi được Nguồn dữ liệu.

## 4. Features

### 4.1 Màn hình Tổng quan

**Description:** Màn hình đầu tiên khi mở app, hiện thực UJ-1 và UJ-2. Bố cục từ trên xuống: vùng dải Tín hiệu mới (ẩn khi không có), rồi hai thẻ Mã theo thứ tự cố định BTC trước, VNINDEX sau. Mỗi thẻ hiện tên Mã, giá đóng cửa của Nến tuần mới nhất, giá trị RSI làm tròn một chữ số thập phân, và nhãn Trạng thái kèm màu. Kéo xuống để làm mới. Dưới cùng là dấu thời gian cập nhật gần nhất.

Màn hình này phải chịu được việc **phần lớn thời gian không có gì để nói**. Trạng thái Trung tính không được trình bày như một sự thiếu vắng cần lấp — nó là kết quả bình thường.

**Functional Requirements:**

#### FR-1: Xem RSI tuần hiện tại của cả hai Mã

Người dùng mở app và thấy ngay giá trị RSI mới nhất cùng Trạng thái của cả `BTC` và `VNINDEX` trên một màn hình. Realizes UJ-1.

**Consequences (testable):**
- Thẻ hiển thị RSI của Nến tuần mới nhất trong chuỗi, làm tròn một chữ số thập phân.
- Khi Nến tuần mới nhất là Nến đang chạy, giá trị hiển thị là RSI tạm tính và thẻ hiện nhãn phụ `tạm tính`.
- Trạng thái được suy ra từ giá trị RSI đang hiển thị theo đúng định nghĩa ở §3, không lưu cứng ở bất kỳ đâu.
- Khi chuỗi có ít hơn 15 Nến tuần, thẻ hiện Trạng thái `Chưa đủ dữ liệu` và không hiện số RSI.
- Thứ tự thẻ cố định: BTC trên, VNINDEX dưới. Không sắp xếp lại theo trạng thái.

#### FR-2: Làm mới dữ liệu khi mở app và khi kéo xuống

Hệ thống tải Nến tuần mới cho cả hai Mã mỗi khi app được mở, và mỗi khi người dùng kéo xuống trên màn hình Tổng quan. Realizes UJ-1, UJ-3.

**Consequences (testable):**
- Tải hai Mã song song; một Mã lỗi không chặn Mã còn lại hiển thị.
- Có dấu hiệu đang tải trong lúc gọi mạng, nhưng dữ liệu cũ từ Kho cục bộ vẫn hiển thị bên dưới thay vì bị thay bằng màn hình trống.
- Tải thành công thì ghi đè Kho cục bộ cho Mã đó và cập nhật dấu thời gian.
- Không tự động tải lại theo chu kỳ khi app đang mở. Chỉ tải khi mở app hoặc khi người dùng chủ động kéo.

**Out of Scope:**
- Tải khi app ở nền hoặc đã đóng.

#### FR-3: Hiển thị được khi không có mạng

Khi mọi Nguồn dữ liệu của một Mã đều thất bại, người dùng vẫn xem được số liệu đã lưu lần trước cho Mã đó. Realizes UJ-3.

**Consequences (testable):**
- Thẻ hiện dữ liệu từ Kho cục bộ kèm dấu thời gian của lần cập nhật thành công gần nhất.
- Hiện thông báo lỗi ở mức chú thích, không phải dialog chặn thao tác.
- Màn hình Chi tiết và Lịch sử tín hiệu vẫn mở và cuộn được đầy đủ trên dữ liệu cục bộ.
- Khi Kho cục bộ rỗng cho Mã đó, thẻ hiện trạng thái rỗng có nút thử lại.

### 4.2 Cảnh báo quá mua / quá bán

**Description:** Sau mỗi lần tải dữ liệu, hệ thống rà chuỗi Nến đã đóng để phát hiện Tín hiệu, so với mốc đã xem của từng Mã, và hiện dải cảnh báo trên đầu màn hình Tổng quan cho các Tín hiệu mới. Hiện thực UJ-2 và ràng buộc ở UJ-4. Đây là cảnh báo **trong app**: người dùng đã chủ động loại bỏ chạy nền và push notification khỏi phạm vi.

**Functional Requirements:**

#### FR-4: Phát hiện Tín hiệu cắt ngưỡng

Hệ thống xác định các Tín hiệu trong chuỗi Nến đã đóng của mỗi Mã theo đúng định nghĩa cắt ngưỡng ở §3. Realizes UJ-2.

**Consequences (testable):**
- Tín hiệu `Quá bán` chỉ được ghi nhận khi Nến đã đóng liền trước có RSI ≥ 30 và Nến đã đóng hiện tại có RSI < 30.
- Tín hiệu `Quá mua` chỉ khi Nến liền trước có RSI ≤ 70 và nến hiện tại có RSI > 70.
- Chuỗi nhiều nến liên tiếp cùng nằm dưới 30 chỉ sinh **một** Tín hiệu, tại nến cắt xuống đầu tiên.
- Nến đang chạy không bao giờ sinh Tín hiệu, kể cả khi RSI tạm tính đã vượt ngưỡng. Realizes UJ-4.
- Nến đầu tiên có RSI trong chuỗi không sinh Tín hiệu vì không có nến liền trước để so.

#### FR-5: Hiện dải cảnh báo cho Tín hiệu mới

Người dùng thấy dải cảnh báo ở đầu màn hình Tổng quan khi có Tín hiệu mới, và dải đó biến mất sau khi đã xem. Realizes UJ-2.

**Consequences (testable):**
- Dải ghi rõ: tên Mã, loại Tín hiệu, giá trị RSI, và mốc tuần xảy ra.
- Có Tín hiệu mới ở cả hai Mã thì hiện hai dải, BTC trước.
- Chạm vào dải thì mở màn hình Chi tiết của Mã đó và đánh dấu đã xem.
- Sau khi đánh dấu đã xem, dải không hiện lại ở các lần mở app sau, kể cả khi tải lại dữ liệu.
- Mốc đã xem lưu riêng theo từng Mã trong Kho cục bộ và sống qua các lần khởi động lại app.
- Lần chạy đầu tiên sau khi cài app **không** hiện dải cảnh báo cho các Tín hiệu lịch sử — mốc đã xem được khởi tạo bằng Tín hiệu cuối cùng tìm thấy. `[GIẢ ĐỊNH: người dùng không muốn bị dội một loạt cảnh báo từ quá khứ ngay lần mở đầu tiên.]`

### 4.3 Biểu đồ nến tuần và khung RSI

**Description:** Màn hình Chi tiết của một Mã. Nửa trên là biểu đồ nến tuần, nửa dưới là đường RSI với hai vạch ngang 30 và 70. Hai khung chia sẻ cùng một trục thời gian và cuộn/phóng đồng bộ. Hiện thực UJ-2 và UJ-4.

**Functional Requirements:**

#### FR-6: Xem biểu đồ nến tuần

Người dùng xem được biểu đồ nến tuần của một Mã và cuộn ngang về quá khứ. Realizes UJ-2.

**Consequences (testable):**
- Nến tăng và nến giảm phân biệt được bằng màu.
- Mở màn hình thì khung nhìn mặc định là khoảng 60 nến gần nhất, nến mới nhất nằm sát mép phải.
- Cuộn ngang được tới nến đầu tiên của dữ liệu có sẵn và không cuộn quá hai biên.
- Nến đang chạy vẽ khác biệt về thị giác so với Nến đã đóng và có nhãn nêu rõ. Realizes UJ-4.
- Trục dọc tự co giãn theo khoảng giá đang nằm trong khung nhìn.

#### FR-7: Xem khung RSI kèm vạch ngưỡng

Người dùng thấy đường RSI ngay dưới biểu đồ giá, có vạch 30 và 70, dùng chung trục thời gian với biểu đồ nến. Realizes UJ-2, UJ-4.

**Consequences (testable):**
- Trục dọc khung RSI cố định 0–100, không co giãn theo dữ liệu.
- Hai vạch ngang tại 30 và 70 luôn hiển thị và có nhãn số.
- Cuộn hoặc phóng ở một khung thì khung còn lại đi theo, không lệch trục thời gian.
- Đoạn đầu chuỗi chưa có RSI thì không vẽ đường, không vẽ giá trị 0.
- Các Nến đã đóng có Tín hiệu được đánh dấu nhận biết được trên khung RSI.

#### FR-8: Xem chi tiết một nến

Người dùng chạm hoặc giữ vào một vị trí trên biểu đồ để xem số liệu của nến tại đó.

**Consequences (testable):**
- Hiện mốc tuần, giá mở/cao/thấp/đóng và giá trị RSI của đúng nến được chọn.
- Hiển thị đồng thời trên cả hai khung tại cùng một mốc thời gian.
- Bỏ tay ra thì phần hiển thị chi tiết mất đi.

### 4.4 Lịch sử tín hiệu

**Description:** Tab thứ ba, liệt kê mọi Tín hiệu tìm thấy trong toàn bộ dữ liệu đang có của cả hai Mã, mới nhất trên cùng. Đây là thứ cho phép người dùng tự đánh giá độ tin cậy của tín hiệu hiện tại thay vì phải tin app. Hiện thực UJ-2.

**Functional Requirements:**

#### FR-9: Xem danh sách Tín hiệu lịch sử

Người dùng xem được mọi Tín hiệu đã xảy ra trong dữ liệu có sẵn, xếp theo thời gian giảm dần. Realizes UJ-2.

**Consequences (testable):**
- Mỗi dòng hiện: Mã, loại Tín hiệu, mốc tuần, giá đóng cửa tuần đó, giá trị RSI tuần đó.
- Mặc định hiện Tín hiệu của cả hai Mã trộn chung, xếp theo mốc tuần giảm dần.
- Lọc được theo Mã.
- Chạm vào một dòng thì mở màn hình Chi tiết của Mã đó, cuộn tới đúng tuần của Tín hiệu.
- Không có Tín hiệu nào thì hiện trạng thái rỗng giải thích rằng tín hiệu RSI tuần vốn hiếm, không phải app hỏng.
- Danh sách sinh ra từ chuỗi Nến tuần đang có, không lưu cứng thành bảng riêng — xoá dữ liệu rồi tải lại phải cho ra đúng danh sách đó.

### 4.5 Lấy dữ liệu thị trường

**Description:** Tầng dữ liệu. Mỗi Mã có một Nguồn chính và có thể có Nguồn dự phòng. Toàn bộ nằm sau một interface chung để đổi nguồn không lan ra ngoài tầng này — cần thiết vì cả hai Nguồn đều là API không chính thức.

**Functional Requirements:**

#### FR-10: Lấy Nến tuần BTC

Hệ thống lấy chuỗi Nến tuần của `BTC` từ Binance public market data.

**Consequences (testable):**
- Gọi `GET https://data-api.binance.vision/api/v3/klines` với `symbol=BTCUSDT`, `interval=1w`, `limit=1000`.
- Đã kiểm chứng ngày 2026-09-04: trả 473 nến tuần từ 2017-08-14. `[GIẢ ĐỊNH: dùng host .vision vì api.binance.com không kết nối được từ mạng người dùng — xem §Rủi ro của brief.]`
- Nến cuối cùng trả về là Nến đang chạy và phải được đánh dấu như vậy dựa trên thời điểm đóng nến mà API trả về so với hiện tại.
- Lỗi mạng hoặc HTTP khác 200 thì ném lỗi có phân loại được, không trả chuỗi rỗng lặng lẽ.

#### FR-11: Lấy Nến tuần VNINDEX

Hệ thống lấy chuỗi Nến tuần của `VNINDEX` từ SSI iBoard, dự phòng bằng VNDirect.

**Consequences (testable):**
- Nguồn chính: `GET https://iboard-api.ssi.com.vn/statistics/charts/history` với `symbol=VNINDEX`, `resolution=W`. Đã kiểm chứng ngày 2026-09-04: trả 518 nến tuần từ 2016-09-05, đúng định dạng UDF `{t,o,h,l,c,v}`.
- Nguồn chính lỗi hoặc trả `code` khác `SUCCESS` thì tự chuyển sang dự phòng VNDirect `dchart-api.vndirect.com.vn/dchart/history` với `resolution=D`, rồi **gộp nến ngày thành nến tuần** trong app. VNDirect không hỗ trợ `resolution=W`; đã kiểm chứng.
- Gộp nến ngày thành tuần: mở = giá mở ngày đầu tuần, cao = max, thấp = min, đóng = giá đóng ngày cuối tuần, khối lượng = tổng. Tuần bắt đầu từ thứ Hai theo giờ Việt Nam.
- TCBS **không** được dùng: `apipubaws.tcbs.com.vn` trả HTTP 403 kèm thử thách Cloudflare kể cả với header trình duyệt đầy đủ. Đã kiểm chứng ngày 2026-09-04.
- Cả hai nguồn cùng lỗi thì rơi về Kho cục bộ theo FR-3.

#### FR-12: Lưu Nến tuần cục bộ

Hệ thống lưu chuỗi Nến tuần đã tải về máy để dùng khi ngoại tuyến. Realizes UJ-3.

**Consequences (testable):**
- Tải thành công thì thay toàn bộ chuỗi đã lưu của Mã đó, không ghép chồng từng phần.
- Khởi động app thì đọc Kho cục bộ và hiển thị trước khi gọi mạng xong.
- Giá trị RSI **không** được lưu — luôn tính lại từ chuỗi Nến tuần. Chỉ lưu OHLCV, mốc đã xem, và dấu thời gian cập nhật.

#### FR-13: Tính RSI(14) theo Wilder

Hệ thống tính RSI chu kỳ 14 trên chuỗi giá đóng cửa Nến tuần theo đúng phương pháp làm mượt Wilder.

**Consequences (testable):**
- Giá trị đầu tiên tại nến thứ 15 dùng trung bình cộng đơn giản của 14 mức tăng và 14 mức giảm đầu tiên.
- Các giá trị sau dùng làm mượt Wilder: `avg = (avg_trước × 13 + giá_trị_hiện_tại) ÷ 14`.
- Khi trung bình mức giảm bằng 0 thì RSI = 100.
- Kết quả khớp TradingView trong ±0.5 điểm cho cả BTC và VNINDEX trên cùng chuỗi dữ liệu — kiểm chứng bằng bộ dữ liệu cố định trong test.
- Chuỗi dưới 15 nến thì trả về chuỗi rỗng, không ném lỗi.
- Hàm thuần tuý: cùng đầu vào cho cùng đầu ra, không đọc thời gian hệ thống, không gọi mạng.

### 4.6 Vùng DCA theo Cẩm nang (bổ sung 2026-11-13)

**Description:** Mỗi thẻ Mã có thêm phần *Vùng DCA*: vùng của tuần đã đóng gần nhất, số tuần liên tiếp trong vùng, và luật của Cẩm nang cho vùng đó với tiền tố cố định "Theo cẩm nang của bạn:". Có dải cảnh báo riêng khi tuần mới đóng nằm ngoài Vùng Nắm giữ. Có bảng Cẩm nang mở từ thẻ. Không thêm màn hình thứ tư — bảng là bottom sheet của màn Tổng quan.

#### FR-14: Xếp Vùng DCA cho mỗi tuần đã đóng

**Consequences (testable):**
- Vùng suy từ RSI của Nến đã đóng theo ranh giới "≤" ở §3. Ranh giới riêng cho từng Mã.
- Nến đang chạy không được xếp Vùng chính thức. Thẻ chỉ hiện thêm một dòng "Tuần đang chạy (tạm tính): …" khi vùng tạm tính khác vùng chính thức.
- Vùng không bao giờ được lưu (AD-2). Xoá dữ liệu rồi tải lại phải ra đúng các Vùng đó.

#### FR-15: Fear & Greed cho BTC

**Consequences (testable):**
- F&G của một tuần là giá trị ngày Chủ nhật đóng nến. Nếu thiếu thì lùi tối đa 3 ngày, không bao giờ lấy giá trị sau khi nến đóng.
- F&G **không** chặn Vùng; nó chỉ gắn nhãn "F&G cực độ cùng chiều". Lý do: đáy BTC 11/2022 có F&G 22–26, một cổng "F&G < 20" bắt buộc sẽ bỏ lỡ đáy đó (§11).
- VNINDEX không có F&G. Bảng Cẩm nang ghi rõ VNINDEX chỉ xếp vùng bằng RSI.
- Tải F&G lỗi không làm hỏng gì: dùng bản đã lưu; không có thì Vùng vẫn xếp bằng RSI.

#### FR-16: Phân kỳ giảm tuần

**Consequences (testable):**
- Phát hiện theo định nghĩa ở §3, chỉ trên Nến đã đóng.
- Khi có, thẻ và dải cảnh báo hiện luật "Xả nốt phần còn lại" của Cẩm nang.
- **Lệch có chủ đích so với Cẩm nang:** Cẩm nang yêu cầu xác nhận khi "RSI cắt xuống dưới 70". Dữ liệu cho thấy ở đỉnh cuối chu kỳ RSI không hề vượt 70 (BTC 11/2021: 68.8; 10/2025: 64.3), nên điều kiện đó không bao giờ bật. App báo ngay tại tuần giá lập đỉnh mới.

#### FR-17: Dải cảnh báo Vùng DCA

**Consequences (testable):**
- Hiện khi tuần đã đóng gần nhất ở Vùng 1, 2, 4, 5 hoặc có phân kỳ, và mốc tuần đó muộn hơn mốc `lastSeenDca.<Mã>`.
- Mỗi tuần mới trong vùng là một dải mới, vì Cẩm nang giải ngân theo từng tuần.
- Lần chạy đầu vẫn hiện, vì đó là trạng thái hiện tại chứ không phải lịch sử. Khác với FR-5.
- Chạm vào dải thì đánh dấu đã xem và mở bảng Cẩm nang của Mã đó.
- Vùng Nắm giữ không có dải — im lặng vẫn là kết quả đúng (UJ-1).

#### FR-18: Bảng Cẩm nang và thống kê lịch sử

**Consequences (testable):**
- Liệt kê đủ 5 vùng, khoảng RSI, luật trích lại, và luật phân kỳ. Đánh dấu vùng hiện tại.
- Mỗi vùng có thống kê tính trên chính chuỗi nến đang có: số tuần từng ở vùng, trung vị % thay đổi giá sau 52 tuần, tỉ lệ % lần giá cao hơn. Thiếu dữ liệu phía sau thì ghi rõ, không bịa số.

#### FR-19: Lời nhắc sáng thứ Hai

**Consequences (testable):**
- Thông báo cục bộ lặp lại mỗi thứ Hai 09:30 giờ Việt Nam: sau khi nến BTC đóng (07:00) và nến VNINDEX được coi là đóng (09:00, AD-4).
- Đặt lịch mỗi lần mở mini app, idempotent theo một id cố định. Không có quyền thông báo thì chỉ mất lời nhắc, app vẫn chạy.
- Nội dung **không** chứa Vùng hay RSI: lúc đặt lịch chưa biết nến tuần sau đóng ở đâu, và không có chạy nền. Vùng được tính khi người dùng mở app.

## 5. Non-Goals (Explicit)

- **Không tự đưa ra khuyến nghị.** App không chấm điểm, không xếp hạng, không tự nói "nên mua". Ngoại lệ duy nhất, do người dùng chọn ngày 2026-11-13: câu hành động **trích nguyên luật trong Cẩm nang của người dùng**, luôn kèm tiền tố "Theo cẩm nang của bạn:" (§4.6). Mọi câu hành động khác vẫn là lỗi.
- **Không trở thành app theo dõi tài sản.** Không danh mục, không lãi lỗ, không số dư, không kết nối tài khoản môi giới. Việc đó thuộc project `personal_finance`.
- **Không có tài khoản, không đồng bộ đám mây, không backend.** Mọi thứ chạy trên máy.
- **Không thu thập dữ liệu người dùng.** Không analytics, không crash reporting gửi đi, không quảng cáo.
- **Không có tin tức, mạng xã hội, bảng giá thời gian thực.**
- **Không chạy nền.** Lời nhắc thứ Hai (FR-19) là thông báo cục bộ do hệ điều hành lên lịch — app không chạy code khi đang đóng. Không thêm workmanager, background fetch hay backend.

## 6. MVP Scope

### 6.1 In Scope

- Màn hình Tổng quan với hai thẻ Mã cố định.
- Cảnh báo trong app cho Tín hiệu mới, tính lúc mở app.
- Màn hình Chi tiết: biểu đồ nến tuần + khung RSI có vạch 30/70, cuộn và phóng đồng bộ.
- Tab Lịch sử tín hiệu, lọc được theo Mã.
- Lưu cục bộ và hoạt động được khi ngoại tuyến.
- Hỗ trợ Android và iOS.

### 6.2 Out of Scope for MVP

- Chạy nền và push từ server. Đã có lời nhắc cục bộ thứ Hai (FR-19), nhưng lời nhắc đó không mang nội dung Vùng.
- Ngưỡng tự đặt — hoãn sang v2, đã có trong lộ trình ở brief.
- Thêm Mã do người dùng chọn — hoãn sang v2.
- Thêm khung thời gian hoặc chỉ báo khác — không có kế hoạch.
- ~~Phân kỳ RSI — v3~~ Đưa vào từ 2026-11-13, chỉ phân kỳ giảm (FR-16).
- Sửa ngưỡng hoặc tỷ trọng của Cẩm nang trong app — ngưỡng vẫn là hằng số (AD-11).
- Chế độ sáng/tối tuỳ chọn — bản đầu theo hệ thống.
- Đa ngôn ngữ — chỉ tiếng Việt.

## 7. Success Metrics

**Primary**

- **SM-1: Độ chính xác RSI.** RSI(14) tuần do app tính khớp TradingView trong ±0.5 điểm cho cả hai Mã, kiểm bằng đối chiếu thủ công trên 20 nến gần nhất. Validates FR-13.
- **SM-2: Không sót tín hiệu.** 100% các lần cắt ngưỡng 30/70 trên Nến đã đóng xuất hiện trong Lịch sử tín hiệu, đối chiếu thủ công với biểu đồ TradingView của 3 năm gần nhất. Validates FR-4, FR-9.

**Secondary**

- **SM-3: Còn dùng sau ba tháng.** Mở app ít nhất một lần mỗi tuần trong tháng thứ ba kể từ khi cài. Validates FR-1.
- **SM-4: Chịu được ngoại tuyến.** Mở app khi tắt mạng vẫn xem được đủ ba màn hình trên dữ liệu cũ, không có màn hình lỗi chặn. Validates FR-3, FR-12.

**Counter-metrics (do not optimize)**

- **SM-C1: Số lần mở app mỗi ngày.** Không được tối ưu tăng. App này thành công khi người dùng nhìn nó *ít* đi, không phải nhiều lên. Đối trọng với SM-3: SM-3 đo *đều đặn*, không đo *nhiều*.
- **SM-C2: Số tính năng.** Không được tối ưu tăng. Ba màn hình là ràng buộc thiết kế, không phải điểm khởi đầu. Đối trọng với toàn bộ §4.

## 8. Open Questions

1. ~~Nến tuần của SSI mốc theo thứ Hai hay Chủ Nhật?~~ **Đã trả lời 2026-09-04:** mốc mở tuần là **thứ Hai 02:00 UTC**, tức 09:00 giờ Việt Nam — đúng giờ mở cửa phiên. Bộ gộp nến ngày của VNDirect dùng cùng mốc thứ Hai giờ Việt Nam.

   **Phát sinh từ việc kiểm chứng:** chuỗi tuần của SSI **thiếu hẳn** tuần nghỉ Tết mỗi năm (khoảng trống 14 ngày), và có khoảng trống lớn ở dữ liệu cũ 2007–2009. Đây là dữ liệu **đúng** — thị trường không giao dịch tuần đó nên không có nến, và TradingView cũng vậy. Hệ quả bắt buộc: biểu đồ phải đánh chỉ số theo **vị trí nến**, không theo trục thời gian tuyến tính, nếu không các tuần Tết sẽ tạo ra khoảng trắng giả trên đồ thị.
2. SSI có giới hạn tần suất gọi không? Chưa gặp giới hạn nào trong lúc thử, nhưng app phải chịu được HTTP 429 mà không sập.
3. Khi SSI và VNDirect trả số lệch nhau ở cùng một tuần thì tin bên nào? v1 đơn giản là ưu tiên nguồn chính; có nên cảnh báo lệch không?
4. Nến đang chạy của VNINDEX vào ngày thứ Bảy hoặc Chủ Nhật — thị trường đã nghỉ nhưng tuần chưa qua. Có nên coi là đã đóng để sinh tín hiệu sớm hai ngày không, hay giữ nguyên tắc chờ hết tuần lịch?

## 9. Cross-Cutting NFRs

- **Hiệu năng:** mở app tới lúc thấy số cũ từ Kho cục bộ dưới 1 giây trên máy tầm trung. Biểu đồ cuộn mượt ở 60fps với 500 nến.
- **Độ tin cậy:** một Nguồn dữ liệu chết không được làm app crash hay chặn màn hình. Mọi lỗi mạng đều có đường thoát về dữ liệu cục bộ.
- **Riêng tư:** app không gửi bất kỳ dữ liệu nào ra ngoài trừ các lời gọi đọc dữ liệu thị trường. Không định danh người dùng.
- **Ngôn ngữ:** toàn bộ giao diện tiếng Việt.
- **Kích thước:** không thêm thư viện chỉ để dùng một hàm. Số phụ thuộc giữ ở mức tối thiểu.

## 10. Assumptions Index

- §4.2 FR-5 — Lần chạy đầu không dội cảnh báo lịch sử; mốc đã xem khởi tạo bằng Tín hiệu cuối cùng tìm thấy.
- §4.5 FR-10 — Dùng `data-api.binance.vision` thay `api.binance.com` do host chính không kết nối được từ mạng người dùng.
- §4.5 FR-11 — Gộp nến ngày thành tuần ở nguồn dự phòng lấy mốc tuần bắt đầu từ thứ Hai giờ Việt Nam; chờ Open Question 1 xác nhận.
- §2.3 UJ-4 — Người dùng muốn thấy RSI tạm tính của nến đang chạy chứ không muốn app giấu đi, miễn là ghi rõ đó là tạm tính.
- §4.6 FR-16 — Lệch khỏi điều kiện xác nhận "RSI cắt xuống dưới 70" của Cẩm nang; xem lý do tại FR-16.
- §4.6 FR-19 — 09:30 thứ Hai là đủ muộn để cả hai Mã đã đóng nến, và đủ sớm để là "sáng thứ Hai" như người dùng yêu cầu.

## 11. Kiểm chứng Cẩm nang trên dữ liệu thật (2026-11-13)

Chạy bằng `fvm dart run tool/phan_tich_dca.dart`. Công cụ dùng đúng `computeRsi` của app trên nến đã đóng. Dữ liệu: Binance 8/2017–11/2026, SSI 2007–11/2026, alternative.me 2/2018–11/2026.

**Vùng mua đáng tin.** Sau các tuần ở Vùng 1, giá 52 tuần sau có trung vị +59% với BTC (89% số lần cao hơn) và +21% với VNINDEX (91%).

**Vùng bán theo RSI thuần thì không đáng tin.** Sau các tuần BTC có RSI > 82, giá 52 tuần sau vẫn cao hơn ở 79% số lần (trung vị +28%). Tín hiệu đầu tiên bật ở 11/2020 khi giá khoảng $18k, còn đỉnh thật là $69k. Ngược lại, phân kỳ giảm theo FR-16 bắt được cả hai đỉnh 2021 và vùng đỉnh 2025: với BTC, 14/18 tuần báo phân kỳ có giá thấp hơn sau 52 tuần. Với VNINDEX là 22/35 — yếu hơn: phân kỳ 2017 báo sớm khoảng 20%.

**Mô phỏng nạp đều mỗi tuần** (tiền chốt lời quay lại quỹ chờ, mua lại ở vùng đáy). Bội số là giá trị cuối kỳ trên số tiền đã nạp:

| Chiến lược | BTC từ 6/2018 | VNINDEX từ 2010 |
|---|---|---|
| DCA đều 100% | ×4.40 | ×2.33 |
| 50% DCA nền + 50% chờ vùng đáy, không bán | ×4.13 | ×2.23 |
| Bán theo vùng RSI như Cẩm nang | ×2.59 | ×1.72 |
| Chỉ bán khi RSI > 82 và F&G > 82 | ×3.44 | — |

**Sai lệch của Cẩm nang so với dữ liệu thật:**
- Cẩm nang ghi RSI BTC 11/2026 là 54–56. Thực tế tuần đóng 02/11 là 47.9, tuần đang chạy tạm tính 42.1.
- Cẩm nang thiếu đáy BTC 2/2026 (RSI 26.8) và đợt VNINDEX 8–10/2025 có RSI 78–83.
- Số liệu VNINDEX lệch: 3/2020 thực tế RSI 14.5 (Cẩm nang ghi 22.8); 10/2023 thực tế 37.7 (ghi 34.8); đầu 2022 thực tế 69.9 (ghi 74.5).
- Không có nguồn dữ liệu công khai cho "F&G VN-Index".

Hệ quả cho thiết kế: F&G là mức tăng cường chứ không phải cổng bắt buộc (FR-15); dùng phân kỳ thay cho điều kiện "cắt xuống 70" (FR-16); thống kê lịch sử hiện trong app để người dùng tự cân nhắc luật bán của mình (FR-18).
