---
title: RSI Alert — Theo dõi BTC & VNINDEX khung tuần
status: final
created: 2026-09-04
updated: 2026-09-04
---

# Product Brief: RSI Alert

## Executive Summary

RSI Alert là ứng dụng Flutter cá nhân, chỉ làm đúng một việc: theo dõi **RSI(14) trên khung tuần** của **Bitcoin** và **VNINDEX**, rồi báo cho người dùng biết khi chỉ số này rơi xuống dưới 30 (quá bán) hoặc vượt lên trên 70 (quá mua).

Vấn đề nó giải quyết là vấn đề của **kỷ luật, không phải của thông tin**. Dữ liệu RSI tuần đã có sẵn miễn phí ở TradingView, ở app của công ty chứng khoán, ở hàng chục trang web. Nhưng tín hiệu RSI tuần chỉ xuất hiện vài lần mỗi năm — và đúng vào lúc nó xuất hiện thì thị trường đang ở trạng thái cảm xúc mạnh nhất, là lúc người ta ít mở biểu đồ ra xem nhất. Người dùng không thiếu dữ liệu; người dùng thiếu **một cú hích đúng lúc, không có tiếng ồn nào khác đi kèm**.

Vì vậy sản phẩm cố tình nhỏ. Hai mã. Một khung thời gian. Một chỉ báo. Không bảng giá, không tin tức, không danh mục, không lời khuyên mua bán. Mở app ra là thấy ngay RSI tuần hiện tại của hai mã, biểu đồ nến tuần để tự nhìn bối cảnh, và lịch sử những lần chỉ số này đã chạm ngưỡng trong quá khứ để tự đánh giá xem tín hiệu đó đáng tin đến đâu.

## The Problem

Người dùng đang theo phương pháp giao dịch dựa trên RSI tuần cho hai tài sản: Bitcoin và VNINDEX. Cách làm hiện tại là mở TradingView hoặc app chứng khoán, tự tìm mã, tự đổi khung sang tuần, tự bật chỉ báo RSI, tự đọc con số. Chi phí của việc này không nằm ở mỗi lần thao tác — mà ở chỗ **nó phụ thuộc vào việc nhớ phải làm**.

Hệ quả cụ thể:

- **Bỏ lỡ tín hiệu.** RSI tuần dưới 30 xảy ra rất thưa. Bỏ lỡ một lần là bỏ lỡ cả chu kỳ, không có lần thứ hai trong nhiều tháng.
- **Nhiễu từ chính công cụ.** Mở TradingView hay app chứng khoán ra là gặp bảng giá đỏ xanh, tin tức, danh mục lãi lỗ — tất cả đều kích hoạt cảm xúc, đúng thứ mà phương pháp RSI tuần sinh ra để tránh.
- **Không có trí nhớ.** Không có nơi nào ghi lại "lần trước RSI tuần chạm 28 là ngày nào, sau đó giá đi thế nào". Mỗi lần có tín hiệu là một lần phải đánh giá lại từ đầu bằng cảm tính.
- **Hai tài sản, hai công cụ.** BTC và VNINDEX hiếm khi nằm chung một màn hình, nên không bao giờ nhìn được trạng thái của cả hai cùng lúc.

## The Solution

Một app mobile mở lên là xong trong mười giây.

Màn hình đầu là **hai thẻ**, BTC và VNINDEX, mỗi thẻ hiện RSI(14) tuần mới nhất, kèm màu và nhãn trạng thái (Quá bán / Trung tính / Quá mua). Nếu có tín hiệu mới kể từ lần mở trước, một dải cảnh báo nằm trên cùng nói thẳng chuyện gì đã xảy ra và vào tuần nào.

Chạm vào một thẻ là vào **màn hình chi tiết**: biểu đồ nến tuần ở nửa trên, khung RSI ở nửa dưới với hai vạch ngang 30 và 70, cuộn ngang xem lại nhiều năm lịch sử. Nhìn một cái là thấy được đường RSI đã cắt ngưỡng bao nhiêu lần và giá phản ứng ra sao sau đó.

Tab thứ ba là **lịch sử tín hiệu**: danh sách mọi lần RSI tuần cắt xuống dưới 30 hoặc lên trên 70 trong toàn bộ dữ liệu tải về, mỗi dòng ghi mã, loại tín hiệu, tuần xảy ra, giá đóng cửa và giá trị RSI lúc đó.

Một nguyên tắc xuyên suốt: **tín hiệu chỉ được chốt trên nến tuần đã đóng.** Nến tuần đang chạy có RSI nhảy liên tục và có thể quay đầu trước khi tuần kết thúc; app vẫn hiển thị giá trị tạm tính đó nhưng ghi rõ là *tạm tính* và không bao giờ sinh tín hiệu từ nó.

## What Makes This Different

Thành thật mà nói: **không có moat kỹ thuật nào ở đây.** Công thức RSI là kiến thức phổ thông, dữ liệu là API công khai miễn phí, và TradingView làm mọi thứ app này làm — làm tốt hơn nhiều.

Lợi thế duy nhất, và là lợi thế thật, là **sự cố tình thiếu tính năng**. TradingView không thể bỏ bảng giá đi vì đó là sản phẩm của họ. App chứng khoán không thể bỏ danh mục lãi lỗ đi vì đó là lý do họ tồn tại. Một app tự viết thì có thể — và chính việc nó *không* làm gì khác mới là thứ khiến nó dùng được cho phương pháp này.

Lợi thế thứ hai là **ghép đúng cặp**. BTC và VNINDEX cạnh nhau trên một màn hình là tổ hợp không sản phẩm thương mại nào phục vụ, vì gần như không ai ngoài nhà đầu tư Việt Nam cần nó.

## Who This Serves

**Người dùng chính — và trong bản MVP là người dùng duy nhất: chính người viết ra nó.** Nhà đầu tư cá nhân ở Việt Nam, giữ vị thế dài hạn ở cả crypto lẫn chứng khoán trong nước, giao dịch theo tín hiệu chu kỳ chứ không lướt sóng, mở app vài lần một tuần chứ không vài lần một giờ. Thành công với người này là: **không bỏ lỡ một tín hiệu RSI tuần nào, và không bị app nào khác dụ vào việc nhìn giá mỗi ngày.**

Người dùng thứ cấp *(nếu về sau chia sẻ ra)*: nhà đầu tư Việt Nam khác cũng dùng RSI tuần làm bộ lọc chu kỳ. Không phải đối tượng của MVP và không được để định hình thiết kế lúc này.

## Success Criteria

Đây là công cụ cá nhân, nên tiêu chí đo cũng ở quy mô đó:

- **Đúng số.** RSI(14) tuần app tính ra khớp với TradingView trong sai số ±0.5 điểm cho cả hai mã. Sai số này là tiêu chí sống còn — một con số sai âm thầm thì tệ hơn hẳn việc không có app.
- **Không bỏ lỡ.** Mọi lần cắt ngưỡng 30/70 trên nến tuần đã đóng đều xuất hiện trong lịch sử tín hiệu, không sót lần nào khi đối chiếu thủ công với biểu đồ.
- **Còn dùng sau ba tháng.** Vẫn mở app ít nhất một lần mỗi tuần vào tháng thứ ba — nếu bỏ, nghĩa là nó chưa thay được thói quen cũ.
- **Không phình ra.** Sau ba tháng app vẫn chỉ có ba màn hình. Mọi tính năng thêm vào phải bước qua §Scope.

**Phản chỉ tiêu (không được tối ưu):** số lần mở app mỗi ngày. App này thành công khi người dùng *ít* nhìn nó, không phải nhiều. Bất kỳ thay đổi nào làm tăng tần suất mở app đều đáng nghi.

## Scope

**Trong phạm vi bản đầu**

- Hai mã cố định: BTC (BTCUSDT) và VNINDEX. Không thêm, không bớt, không tự chọn.
- Một khung thời gian: tuần. Một chỉ báo: RSI(14) theo phương pháp Wilder.
- Hai ngưỡng cố định: 30 và 70.
- Biểu đồ nến tuần + khung RSI, cuộn ngang xem lịch sử.
- Cảnh báo quá mua / quá bán, tính tại thời điểm mở app.
- Lịch sử tín hiệu trong toàn bộ dữ liệu tải về.
- Lưu dữ liệu cục bộ để mở app lúc không mạng vẫn xem được số lần cuối.

**Ngoài phạm vi, có chủ đích**

- Chạy nền / push notification khi app đóng — người dùng đã chủ động loại bỏ.
- Ngưỡng tự đặt, thêm mã, thêm khung thời gian, thêm chỉ báo.
- Bất kỳ dạng khuyến nghị mua bán, chấm điểm, hay "app nghĩ rằng" nào.
- Danh mục, lãi lỗ, số dư, kết nối tài khoản môi giới. Việc đó thuộc về project `personal_finance` bên cạnh.
- Tin tức, mạng xã hội, bảng giá thời gian thực.
- Tài khoản người dùng, đồng bộ đám mây, đăng nhập.

## Rủi ro đã biết

- **Cả hai nguồn dữ liệu đều là API không chính thức.** SSI iBoard và Binance đều không cam kết gì với app này; họ đổi đường dẫn hay chặn là app mất dữ liệu. Giảm thiểu bằng cách bọc sau một interface chung, có nguồn dự phòng cho VNINDEX (VNDirect), và luôn còn dữ liệu đã lưu cục bộ để hiển thị.
- **TCBS — nguồn người dùng chọn ban đầu — không dùng được.** Đã kiểm chứng ngày 2026-09-04: `apipubaws.tcbs.com.vn` trả HTTP 403 kèm trang thử thách Cloudflare, kể cả khi gửi đầy đủ header trình duyệt. Một HTTP client trong Flutter cũng sẽ gặp đúng như vậy.
- **`api.binance.com` không kết nối được từ mạng hiện tại** (kết nối bị ngắt, không phải lỗi HTTP). `data-api.binance.vision` — máy chủ dữ liệu thị trường công khai của chính Binance — hoạt động bình thường và được dùng thay thế.
- **Định nghĩa "tuần" của hai thị trường không trùng nhau.** Nến tuần BTC chạy theo giờ UTC từ thứ Hai; tuần của VNINDEX theo lịch giao dịch Việt Nam. App không được ép hai bên về chung một mốc; mỗi mã giữ đúng mốc tuần của nguồn.
- **RSI tuần vốn ít tín hiệu.** Có thể vài tháng liền không có gì xảy ra. Đó là đặc tính của phương pháp, không phải lỗi — nhưng nó có nghĩa app sẽ trông "chết" phần lớn thời gian, và thiết kế phải chấp nhận điều đó thay vì bịa việc ra cho màn hình bận rộn.

## Vision

Nếu dùng được, hướng đi hai đến ba năm không phải là thêm tính năng mà là **thêm độ tin cậy vào đúng việc đang làm**: nguồn dữ liệu ổn định hơn, đối chiếu chéo nhiều nguồn để bắt số liệu sai, và — nếu thói quen đã hình thành và việc mở app thủ công trở thành nút thắt thật sự — mới tính đến cảnh báo chủ động, đúng thứ đã cố tình gạt ra khỏi MVP.

Mở rộng có thể chấp nhận, theo thứ tự ưu tiên: ngưỡng tự đặt → thêm mã do người dùng chọn → phân kỳ RSI. Mỗi bước đều phải trả lời được câu hỏi "cái này có làm người dùng mở app nhiều hơn không?" — nếu có, nó không được vào.

Thứ app này **không bao giờ trở thành**: một terminal giao dịch, một mạng xã hội đầu tư, hay một thứ đưa ra khuyến nghị. Ranh giới đó là điều kiện tồn tại của sản phẩm, không phải sở thích thiết kế.
