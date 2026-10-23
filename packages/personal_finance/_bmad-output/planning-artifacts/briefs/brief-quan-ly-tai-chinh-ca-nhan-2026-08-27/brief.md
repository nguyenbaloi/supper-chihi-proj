---
title: "Product Brief: App Quản lý Danh mục Đầu tư Cá nhân"
status: draft
created: 2026-08-27
updated: 2026-08-27
status_note: "Đã chốt toàn bộ câu hỏi mở — sẵn sàng cho pha PRD"
supersedes: "brief-v1-expense-tracker.md.bak (bản nháp sổ thu chi — đã loại sau khi có Excel thực tế)"
---

# Product Brief: App Quản lý Danh mục Đầu tư Cá nhân

## Tóm tắt điều hành

Đây là ứng dụng mobile (Flutter, Android + iOS) thay thế hệ thống Excel mà người dùng đã duy trì hơn một năm để theo dõi danh mục đầu tư cá nhân trải trên năm lớp tài sản: chứng khoán, vàng, tiền mã hóa, tiền mặt và các khoản cho vay. Ứng dụng nhận đầu vào là **số lượng nắm giữ** — 0,12 BTC, 100 cổ FPT, 3 lượng vàng — rồi tự lấy giá thị trường, tự quy đổi ngoại tệ, tự tính tỷ trọng từng lớp, tự đối chiếu với tỷ trọng mục tiêu, và tự đo lãi lỗ theo phương pháp vốn góp ròng.

Điểm khác biệt so với một app quản lý chi tiêu thông thường: đây **không phải sổ thu chi hằng ngày**. Nó không quan tâm ly cà phê 35.000đ. Nó trả lời đúng bốn câu hỏi của một người đang cầm vài trăm triệu rải trên nhiều loại tài sản: *Tổng tài sản của tôi bây giờ là bao nhiêu? Cơ cấu đang lệch đâu so với mục tiêu? Tôi đang thực lãi hay thực lỗ, sau khi trừ tiền tự bỏ thêm vào? Ai đang nợ tôi và tôi đang nợ ai?*

Hệ thống Excel hiện tại đã trả lời được cả bốn câu — nhưng bằng công thức ẩn, cộng thủ công giữa các sheet, và giá thị trường phải tra tay. Hệ quả nhìn thấy rõ trong chính dữ liệu: các mốc chốt sổ cách nhau tới **bốn tháng** (30/3/2025 → 21/7/2025). Không phải người dùng lười — mà vì mỗi lần chốt sổ trên Excel là một buổi ngồi máy tính. Ứng dụng này tồn tại để biến việc đó thành một thao tác trên điện thoại.

## Vấn đề

Người dùng đã tự xây một hệ thống Excel hai sheet, khá bài bản: bảng tổng tài sản với biểu đồ tỷ trọng, hai bảng bóc tách chi tiết cho chứng khoán và crypto, bảng lịch sử nạp/rút và lãi lỗ mười mốc thời gian, bảng tỷ trọng mục tiêu, và một sheet riêng cho nợ và cho vay. Hệ thống này **đúng về mặt phương pháp** — vấn đề nằm ở chi phí vận hành nó.

**Ba con số phải cập nhật tay, và đều là nguồn sai lệch âm thầm.**
Giá BTC và ETH biến động từng giờ. Giá cổ phiếu FPT đổi mỗi phiên. Tỷ giá USD/VND — hiện đang nằm ẩn trong công thức Excel ở mức khoảng 26.000 — cũng trôi theo thời gian. Mỗi lần muốn biết tổng tài sản thật, người dùng phải mở ba nguồn khác nhau, tra ba con số, gõ vào ba ô. Không tra thì bảng vẫn hiện ra một con số — chỉ là con số cũ. Đây là kiểu sai nguy hiểm nhất: nó không báo lỗi, nó chỉ lặng lẽ sai.

**Hai sheet cộng thủ công vào nhau.**
Dòng "C VAY + CASH = 183" ở sheet tài sản là kết quả của phép cộng 133 (tổng cho vay ròng ở sheet nợ) + 50 (tiền mặt). Phép cộng này nằm trong đầu người dùng, không nằm trong công thức. Cho anh Thắng vay thêm 2 triệu thì phải nhớ sửa cả hai chỗ. Quên một chỗ là tổng tài sản sai, kéo theo toàn bộ tỷ trọng sai, kéo theo quyết định mua bán sai.

**Khoảng lệch so với mục tiêu phải tự nhẩm.**
Người dùng đặt tỷ trọng mục tiêu rõ ràng: BTC 50%, Cash 30%, Vàng + CK 20%. Thực tế đang là 57,4% / 26,9% / 15,7% — tức BTC đang thừa 7,4%, tương đương khoảng 50 triệu cần chuyển sang lớp khác. Con số "50 triệu" đó Excel không nói ra; người dùng phải tự tính. Và vì phải tự tính nên các ghi chú hành động ở cuối sheet đều ở dạng định tính — "mua thêm vàng và chứng khoán", "giảm cho vay về 10%" — chứ không phải một con số cụ thể để hành động.

**Excel trên điện thoại là một cực hình.**
Đây là nguyên nhân gốc của khoảng đứt bốn tháng trong lịch sử chốt sổ. Danh mục đầu tư là thứ người ta muốn liếc nhanh khi thị trường biến động — đúng lúc đang cầm điện thoại, không phải lúc ngồi trước máy tính. Rào cản này biến một việc lẽ ra làm hằng tuần thành việc vài tháng mới làm một lần.

**Lịch sử rời rạc nên không thấy được xu hướng.**
Bảng tổng kết có mười điểm dữ liệu trong hơn một năm. Chúng cho biết từng thời điểm lãi lỗ bao nhiêu, nhưng không vẽ nên đường đi. Nhìn vào dãy `0 → −39 → −31 → −168 → −21 → +30 → +38 → +67 → −34 → −100`, rất khó nói danh mục đang tốt lên hay xấu đi, và biến động lớn hồi 30/3/2025 (−168) đã hồi phục theo hình dạng nào.

## Giải pháp

**1. Nhập số lượng, không nhập giá trị.**
Đây là thay đổi nền tảng so với Excel. Thay vì gõ "BTC = 12.500 USD" rồi phải gõ lại mỗi khi giá đổi, người dùng nhập "0,12 BTC" hoặc "7 chỉ vàng" — những con số chỉ thay đổi khi thực sự mua bán. Giá trị quy đổi ra VND do ứng dụng tự tính lại mỗi lần mở app. Số lần phải chạm vào dữ liệu giảm từ "mỗi lần muốn xem" xuống còn "mỗi lần giao dịch thật".

**2. Giá thị trường tự động, luôn đè tay được.**
Giá BTC, ETH và tỷ giá USD/VND lấy tự động từ nguồn dữ liệu công khai. Với mọi loại tài sản — kể cả cổ phiếu và vàng — người dùng luôn đè được giá thủ công, và giá đè tay thắng giá tự động cho tới khi bị xóa bỏ. Mọi con số đều hiển thị kèm thời điểm cập nhật, để không bao giờ phải đoán xem mình đang nhìn số mới hay số cũ.

**3. Tỷ trọng hai cấp, tự động, có biểu đồ.**
Cấp một là bức tranh toàn danh mục theo lớp tài sản. Chạm vào một lớp là mở ra cấp hai — chi tiết từng khoản nắm giữ trong lớp đó, kèm tỷ trọng nội bộ. Đây chính là cấu trúc ba biểu đồ tròn trong Excel hiện tại, nhưng liên kết sống với nhau thay vì là ba bảng rời.

**4. Đối chiếu mục tiêu và nói thẳng con số cần hành động.**
Người dùng đặt tỷ trọng mục tiêu cho từng lớp. Ứng dụng hiển thị thực tế cạnh mục tiêu và quy khoảng lệch thành số tiền cụ thể: *"BTC đang 57,4%, vượt mục tiêu 7,4% — tương đương 50 triệu. Vàng + CK đang thiếu 4,3% — tương đương 29 triệu."* Đây là bước biến ghi chú định tính thành con số hành động được.

**5. Lãi lỗ theo vốn góp ròng, giữ nguyên phương pháp của người dùng.**
Ứng dụng giữ đúng công thức đã dùng suốt một năm qua: mỗi lần nạp thêm hay rút ra được ghi vào sổ dòng tiền, vốn góp lũy kế cộng dồn theo, và lãi lỗ luôn bằng giá trị hiện tại trừ vốn góp lũy kế. Giữ nguyên cả phạm vi áp dụng: chỉ tính cho chứng khoán và crypto, loại vàng và tiền mặt ra ngoài — đúng như ghi chú gốc trên sheet.

**6. Lịch sử liền mạch thay vì mười điểm rời rạc.**
Ứng dụng tự lưu lại giá trị danh mục mỗi ngày, tạo thành đường biểu đồ liên tục. Người dùng vẫn chốt được các mốc thủ công kèm ghi chú khi có sự kiện đáng nhớ — nhưng không còn phụ thuộc vào việc nhớ chốt sổ để có dữ liệu.

**7. Sổ nợ và cho vay liên kết thẳng vào tổng tài sản.**
Mỗi khoản cho vay hoặc đi vay là một bản ghi có tên người, số tiền, ngày, ghi chú. Tổng ròng của sổ này tự chảy vào lớp tài sản tương ứng — không còn phép cộng thủ công giữa hai sheet. Giữ nguyên quy ước dấu đang dùng: dương là cho vay, âm là đi vay.

## Điều làm nên khác biệt

**So với Excel hiện tại** — giữ nguyên toàn bộ phương pháp đã được chứng minh là đúng, chỉ bỏ đi phần lao động thủ công: tra giá, quy đổi tỷ giá, cộng chéo giữa các sheet, nhẩm khoảng lệch.

**So với các app quản lý chi tiêu phổ biến** (Money Lover, Sổ Thu Chi MISA) — những app đó xoay quanh giao dịch chi tiêu hằng ngày và xem đầu tư là phần phụ. Ứng dụng này đảo ngược trọng tâm: đầu tư là trung tâm, chi tiêu hằng ngày không có mặt.

**So với các app portfolio tracker quốc tế** (Delta, CoinStats) — những app đó mạnh về crypto nhưng gần như không xử lý được ba thứ đặc thù ở đây: **vàng vật chất** tính theo lượng, **cổ phiếu sàn Việt Nam**, và **các khoản cho vay cá nhân** — vốn là chuyện rất phổ biến trong đời sống tài chính Việt Nam nhưng không có trong mô hình dữ liệu của app nước ngoài. Với người dùng này, khoản cho vay chiếm tỷ trọng đáng kể trong tổng tài sản, không thể bỏ qua.

**Riêng tư theo kiến trúc.** Danh mục nằm trong máy, không tài khoản, không đồng bộ. Ứng dụng có gọi mạng, nhưng chỉ để hỏi "BTC giá bao nhiêu" — câu hỏi đó không mang theo thông tin người dùng nắm giữ bao nhiêu. Không có server nào biết bạn có gì.

Nói thẳng: đây không phải lợi thế cạnh tranh thương mại. Sản phẩm phục vụ một người dùng cụ thể với một hệ thống Excel cụ thể. Giá trị của nó là **vừa khít** với cách người đó đã tư duy về tài sản của mình suốt một năm qua.

## Phục vụ ai

**Người dùng chính — nhà đầu tư cá nhân tự quản lý danh mục.**
Đang nắm khoảng 680 triệu rải trên năm lớp tài sản, với crypto chiếm tỷ trọng lớn nhất (57%). Đã có kỷ luật đầu tư: đặt tỷ trọng mục tiêu, theo dõi lãi lỗ theo vốn góp ròng, ghi kế hoạch tái cân bằng. Không cần ai dạy về đầu tư — cần một công cụ theo kịp tốc độ suy nghĩ của mình.

Thành công với họ là: mở app, trong mười giây biết được tổng tài sản, cơ cấu đang lệch đâu và lãi lỗ bao nhiêu — không phải mở máy tính, không phải tra giá, không phải nhẩm.

## Tiêu chí thành công

**Tín hiệu quan trọng nhất — tần suất theo dõi tăng lên.**
Excel cho ra mười mốc chốt sổ trong mười ba tháng, khoảng cách lớn nhất là bốn tháng. Mục tiêu của ứng dụng: người dùng mở app xem danh mục **ít nhất mỗi tuần một lần**, và lịch sử giá trị không còn khoảng đứt nào quá một tháng.

**Độ chính xác — điều kiện tiên quyết, không phải mục tiêu phấn đấu.**
- Mọi số liệu tổng hợp phải khớp tuyệt đối với cách tính trong Excel khi cùng đầu vào. Bộ mười dòng lịch sử nạp/rút hiện có sẽ được dùng làm bộ kiểm thử đối chiếu.
- Giá trị tiền tệ không được có sai số làm tròn tích lũy.
- Khi giá thị trường lấy về thất bại, ứng dụng phải nói rõ đang dùng giá cũ từ lúc nào — tuyệt đối không hiển thị số cũ như thể là số mới.

**Trải nghiệm:**
- Từ lúc mở app đến lúc thấy tổng tài sản và tỷ trọng: **dưới 3 giây**, kể cả khi không có mạng (dùng giá lưu lần cuối).
- Cập nhật một khoản nắm giữ sau khi mua bán: dưới 15 giây.

**Cột mốc nghiệm thu bản đầu tiên:** nhập tay toàn bộ trạng thái hiện tại từ hai sheet Excel vào ứng dụng, và mọi con số tổng hợp — tổng 680 triệu, tỷ trọng 2,2% / 13,5% / 57,4% / 26,9%, tổng nợ ròng 133 — khớp chính xác với Excel. Lịch sử quá khứ không nhập lại; ứng dụng bắt đầu ghi nhận từ thời điểm cài đặt, với vốn góp lũy kế khởi điểm do người dùng khai báo.

## Phạm vi

**Trong phạm vi bản đầu tiên (MVP):**

*Danh mục và tài sản*
- Năm lớp tài sản: Chứng khoán · Vàng · Crypto · Tiền mặt & Tiết kiệm · Cho vay/Nợ.
- Khoản nắm giữ nhập theo **số lượng** với crypto, cổ phiếu và **vàng (theo chỉ)**; nhập theo **giá trị** với tiền mặt, tiền gửi tiết kiệm và các khoản cho vay.
- Đa tiền tệ VND và USD, tự quy đổi về VND để tổng hợp.
- Đè giá thủ công cho mọi loại tài sản, kèm hiển thị thời điểm cập nhật.

*Tính toán và hiển thị*
- Tỷ trọng hai cấp: theo lớp tài sản và theo từng khoản trong lớp.
- Biểu đồ tròn cho tổng danh mục và cho từng lớp — tương ứng ba biểu đồ trong Excel.
- Tỷ trọng mục tiêu theo lớp, đối chiếu với thực tế, quy khoảng lệch thành số tiền cụ thể.

*Lãi lỗ và lịch sử*
- Sổ dòng tiền nạp/rút: ngày, số tiền, ghi chú. Một con số chung cho cả nhóm đầu tư, không tách theo lớp — giữ đúng cách Excel đang làm.
- **Sửa và xóa được mọi bản ghi**: khoản nắm giữ crypto, khoản nắm giữ chứng khoán, và từng dòng lịch sử nạp/rút vốn. Khi sửa một dòng quá khứ, toàn bộ vốn góp lũy kế và lãi lỗ từ dòng đó trở đi tự tính lại.
- Vốn góp lũy kế và lãi lỗ tính theo phương pháp vốn góp ròng, chỉ áp dụng cho nhóm Chứng khoán + Crypto.
- Tự lưu giá trị danh mục hằng ngày; chốt mốc thủ công kèm ghi chú khi cần.
- Biểu đồ đường giá trị danh mục và lãi lỗ theo thời gian.

*Nợ và cho vay*
- Bản ghi theo người: tên, số tiền, ngày, ghi chú, quy ước dương/âm.
- Đánh dấu **đã thu hồi / đã trả xong**: khoản đó rời khỏi tổng tài sản nhưng vẫn nằm trong lịch sử để tra cứu.
- Tổng ròng tự chảy vào tổng tài sản.

*Nền tảng*
- Giao diện tiếng Việt, định dạng VND.
- Lưu trữ cục bộ; xuất ra CSV để sao lưu.

*Khởi tạo*
- Luồng thiết lập lần đầu: khai báo các lớp tài sản, tỷ trọng mục tiêu, và **vốn góp lũy kế khởi điểm** — con số này bắt buộc phải có, nếu bỏ trống thì mọi phép tính lãi lỗ về sau đều sai.
- Chế độ sáng và tối.

**Rõ ràng nằm ngoài phạm vi bản đầu:**
- Sổ thu chi hằng ngày (ăn uống, đi lại) — đây là sản phẩm khác.
- Tài khoản, đăng nhập, đồng bộ đám mây, dùng chung danh mục nhiều người.
- Kết nối trực tiếp sàn giao dịch hay công ty chứng khoán qua API tài khoản.
- Sổ lệnh mua bán chi tiết theo từng giao dịch và tính giá vốn bình quân từng mã.
- Tính thuế, tính phí giao dịch.
- Cảnh báo giá, thông báo đẩy khi thị trường biến động.
- Tự động lấy giá cổ phiếu sàn Việt Nam — bản đầu nhập tay, cân nhắc cho v1.1.
- Ngoại tệ ngoài VND và USD.
- Nhập dữ liệu hàng loạt từ CSV — dữ liệu ban đầu chỉ khoảng 15 dòng, nhập tay nhanh hơn viết tính năng.
- Lãi suất, kỳ hạn và lãi dồn cho khoản tiền gửi tiết kiệm.
- Nhập lại lịch sử chốt sổ quá khứ.
- Ghi lãi suất và kỳ hạn cho các khoản cho vay.

Ranh giới này giữ chặt vì một lý do: sản phẩm chỉ thành công nếu nó **thay thế được Excel**, không phải nếu nó có nhiều tính năng hơn Excel. Mọi thứ Excel hiện không làm mà bản đầu cũng không làm, đều không phải thiếu sót.

## Tầm nhìn

**Ngay sau MVP (v1.1 – v1.2):** tự động lấy giá cổ phiếu sàn Việt Nam; khóa ứng dụng bằng vân tay hoặc Face ID; sổ lệnh mua bán để tính giá vốn bình quân và tách bạch lãi đã thực hiện với lãi chưa thực hiện; lãi suất và ngày đáo hạn cho các khoản cho vay và tiền gửi tiết kiệm, kèm nhắc thu hồi và nhắc đáo hạn — bám sát ghi chú "thu hồi 50 triệu từ giờ đến cuối năm" trong Excel hiện tại.

**Xa hơn (1–2 năm):** gợi ý tái cân bằng thành từng lệnh cụ thể ("bán 0,02 BTC, mua 1 lượng vàng"); so sánh hiệu quả danh mục với các chỉ số tham chiếu như VN-Index hay giá BTC; sao lưu mã hóa đầu-cuối vào Google Drive hoặc iCloud của chính người dùng — không bao giờ là server trung tâm của bên thứ ba.

**Điều sẽ không thay đổi:** danh mục nằm trên máy người dùng. Không quảng cáo, không bán dữ liệu, không bắt buộc tạo tài khoản.

---

## Các điểm đã chốt sau vòng làm rõ cuối

| Điểm | Kết luận |
|---|---|
| Vàng | Nắm giữ tính theo **chỉ**; người dùng vốn đã tự nhẩm theo đơn vị này. App nhập số chỉ, giá vàng/chỉ nhập tay. |
| Số `170` và `TS: 30 triệu` trong Excel | Nháp thừa, không mang nghĩa nghiệp vụ. Bỏ qua. |
| Khoản 50 triệu | Không phải tiền mặt để không mà là **tiền gửi tiết kiệm ngắn hạn**. Lớp tài sản đặt tên "Tiền mặt & Tiết kiệm". Theo dõi lãi suất và kỳ hạn để v1.1. |
| Phạm vi tính lãi lỗ | Chốt cứng: **chỉ Chứng khoán + Crypto** — đây là hai lớp người dùng coi là tài sản đầu tư thật sự. |
| Lịch sử quá khứ | Bỏ hoàn toàn, bắt đầu từ hiện tại. Kéo theo: loại chức năng nhập CSV khỏi MVP, và **bắt buộc có bước khai báo vốn góp lũy kế khởi điểm**. Con số 333 triệu trong Excel là của 3/2/2026; người dùng đã nạp thêm vốn từ đó tới nay, nên số thực tế sẽ được hỏi lại lúc cài đặt. |
| Sổ nạp/rút | Một con số chung, không tách theo lớp tài sản — đúng như Excel. |
| Cho vay đã thu hồi | Có đánh dấu trạng thái; rời khỏi tổng tài sản, ở lại trong lịch sử. |
| Quyền chỉnh sửa | Danh mục crypto, danh mục chứng khoán và lịch sử vốn đều **sửa và xóa được**. Đây là ràng buộc kiến trúc, không phải tính năng phụ — xem addendum mục 3. |
