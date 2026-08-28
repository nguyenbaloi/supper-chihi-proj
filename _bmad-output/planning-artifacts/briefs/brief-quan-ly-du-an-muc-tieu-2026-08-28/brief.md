---
title: "Product Brief: App Quản lý Dự án & Mục tiêu Cá nhân"
status: draft
created: 2026-08-28
updated: 2026-08-28
inputs: "HÀNH ĐỘNG.pdf, Ý TƯỞNG.pdf (người dùng cung cấp 2026-08-28)"
mode: "Fast path — các chỗ suy luận được đánh dấu [GIẢ ĐỊNH]"
---

# Product Brief: App Quản lý Dự án & Mục tiêu Cá nhân

## Tóm tắt điều hành

Đây là ứng dụng mobile (Flutter, Android + iOS, chạy hoàn toàn offline) thay thế hai file văn bản tĩnh — `HÀNH ĐỘNG.pdf` và `Ý TƯỞNG.pdf` — mà người dùng đang dùng làm nơi chứa toàn bộ đời sống dự án cá nhân của mình: bảy hướng đi đang triển khai, danh sách hành động kèm trạng thái viết tay, một mục tiêu tài chính lớn, và các nguyên tắc tự đúc kết.

Hai file đó **đúng về nội dung** — chúng cho thấy một người có kỷ luật suy nghĩ hiếm gặp: biết phân loại nợ tốt / nợ xấu, biết đặt điều kiện trước khi vay, biết ghi lại bài học "vội vàng hấp tấp là sai lầm". Vấn đề nằm ở chỗ chúng là **văn bản chết**. Trạng thái ghi bằng chữ (`Xong`, `Chưa`, `Đang làm`) nên không lọc được, không đếm được, không cảnh báo được. Không có ngày tháng nên không ai biết một việc "Đang làm" đã đang làm bao lâu. Bảy dự án nằm rời rạc, không nối vào mục tiêu nào. Và trên điện thoại thì một file PDF không sửa được — nên ý tưởng chợt đến lúc đang đi đường sẽ mất.

Ứng dụng này trả lời đúng bốn câu hỏi mà hai file kia đặt ra nhưng không tự trả lời được: *Bảy dự án của tôi đang ở đâu? Việc gì đang tắc và tắc bao lâu rồi? Mục tiêu 1 tỷ còn cách bao xa và tôi đang đi nhanh hay chậm? Nếu hôm nay tôi chỉ làm được một việc, thì là việc nào?*

## Vấn đề

Người dùng đã tự xây một hệ thống ghi chép hai lớp: file `Ý TƯỞNG` để bắt ý tưởng và khai sinh dự án, file `HÀNH ĐỘNG` để theo dõi việc phải làm và ghi lại nguyên tắc. Cấu trúc này hợp lý. Nhưng nó đang chạy trên nền tảng sai.

**Trạng thái là chữ tự do, nên không dùng được vào việc gì.**
`Chỉ mua 1 màn hình: Xong` · `Dồn tiền mua máy rửa bát: Chưa` · `Sắp xếp lại thời gian làm việc: Đang làm`. Ba trạng thái này nằm trong cùng một danh sách gạch đầu dòng, phân biệt với nhau bằng mắt người đọc. Muốn biết còn bao nhiêu việc chưa xong phải đọc lại toàn bộ file. Muốn biết tháng này đã hoàn thành mấy việc — không có cách nào.

**Không có thời gian, nên không có áp lực và không có bài học.**
Không dòng nào trong hai file có ngày tháng. `Sắp xếp lại thời gian làm việc ở cty và cho cá nhân: Đang làm` — đang làm từ tuần trước hay từ nửa năm trước? Đây không phải chi tiết vụn: chính người dùng đã viết ra bài học *"kiên nhẫn chờ tín hiệu rõ ràng, vội vàng hấp tấp là sai lầm"*. Muốn biết mình có thật sự kiên nhẫn hay chỉ đang trì hoãn, phải có dấu thời gian để đối chiếu.

**Bảy dự án không nối vào mục tiêu nào.**
File `Ý TƯỞNG` liệt kê rõ bảy dự án: học tiếng Anh của con, học toán của con, dạy Huy, kênh TikTok/YouTube tiếp thị liên kết, kế hoạch tài chính, viết app đẩy store, kiểm soát sức khoẻ bản thân. File `HÀNH ĐỘNG` đặt ra mục tiêu `1 tỷ` và ưu tiên số một là *"tạo ra dòng tiền, thu nhập thụ động ngoài làm thuê"*. Bốn trong bảy dự án phục vụ trực tiếp mục tiêu đó — nhưng không có gì trong tài liệu thể hiện mối nối ấy. Hệ quả: khi phải chọn làm gì trước, không có cơ sở nào ngoài cảm tính.

**Mục tiêu lớn không có mốc, nên không đo được nhịp đi.**
`Mục tiêu: 1 tỷ` là một con số đứng một mình — không hạn chót, không điểm xuất phát ghi lại, không lần cập nhật nào. Nó không nói được người dùng đang đi nhanh hay chậm, cần thêm bao nhiêu mỗi tháng, hay liệu nhịp hiện tại có về đích đúng hạn không.

**PDF trên điện thoại là ngõ cụt.**
Đây là nguyên nhân gốc khiến hệ thống này không tự cập nhật được. Việc hoàn thành một hành động, hay một ý tưởng chợt đến, đều xảy ra khi đang cầm điện thoại — không phải lúc ngồi trước máy tính mở file ra sửa. Rào cản này biến một việc lẽ ra làm hằng ngày thành việc thỉnh thoảng mới nhớ.

**Không có nhịp xem lại.**
File chỉ được mở khi người dùng chợt nhớ. Không có gì nhắc rằng một dự án đã hai tháng không có hoạt động nào, hay một hành động đã quá hạn tự đặt.

## Giải pháp

**1. Dự án là đơn vị trung tâm, hành động treo dưới dự án.**
Bảy dự án trong file `Ý TƯỞNG` trở thành bảy bản ghi thật, mỗi bản ghi có chủ đề, độ ưu tiên, trạng thái và danh sách hành động riêng. Danh sách gạch đầu dòng trong file `HÀNH ĐỘNG` trở thành các hành động thuộc dự án `Kế hoạch tài chính`. Cấu trúc hai file được giữ nguyên — chỉ là giờ nó biết tự đếm.

**2. Trạng thái là dữ liệu có kiểu, không phải chữ.**
Bốn trạng thái cố định cho hành động (`Chưa bắt đầu` · `Đang làm` · `Xong` · `Bỏ`) và năm cho dự án (thêm `Tạm dừng`). Đúng ba trạng thái người dùng đang dùng, chỉ khác ở chỗ máy hiểu được. Từ đó lọc được, đếm được, và tính ra tỷ lệ hoàn thành mà không phải đọc lại file.

**3. Mọi thứ đều có dấu thời gian, tự động.**
Ngày tạo, ngày chuyển sang `Đang làm`, ngày hoàn thành — ghi tự động, người dùng không phải gõ. Từ đó ứng dụng trả lời được câu hai file kia không trả lời được: *việc này đã đang làm 47 ngày*, *dự án này 2 tháng không động đến*.

**4. Mục tiêu có con số, có mốc, và có đường đi.**
`Mục tiêu: 1 tỷ` trở thành một bản ghi có giá trị đích, đơn vị, hạn chót và một sổ cập nhật tiến độ. Mỗi lần người dùng ghi một mốc mới, ứng dụng vẽ lại đường đi và nói thẳng: *đang ở 34%, còn 11 tháng, nhịp hiện tại về đích chậm 4 tháng*. Tiến độ **luôn được suy ra từ sổ cập nhật**, không bao giờ lưu cứng — sửa hay xoá một mốc quá khứ thì mọi con số phía sau tự đúng theo.

**5. Nối dự án vào mục tiêu.**
Mỗi dự án gắn được vào một hoặc nhiều mục tiêu. Nhìn từ mục tiêu `1 tỷ` sẽ thấy ngay bốn dự án đang phục vụ nó và tình trạng của từng dự án. Đây là bước biến bảy dòng liệt kê rời rạc thành một cây có gốc.

**6. Màn hình Hôm nay — trả lời câu "giờ làm gì".**
Một màn hình mở đầu gom đúng những gì cần: hành động quá hạn, hành động đang làm, dự án lâu không động đến, mục tiêu lệch nhịp. Không phải danh sách tất cả mọi thứ — mà là thứ tự ưu tiên đã được tính sẵn.

**7. Ghi chú và liên kết ngoài gắn thẳng vào dự án.**
Các đường link đang nằm rải trong file — bảng Google Sheets cơ cấu tài chính, ba link `appbox.me` — được gắn vào đúng dự án của chúng. Cùng chỗ đó là nơi chứa các ghi chú nguyên tắc: phần `nợ tốt / nợ xấu`, các điều kiện vay, bài học thị trường. Chúng không biến mất, chúng chỉ được xếp về đúng dự án.

**8. Offline tuyệt đối, xuất/nhập bằng file.**
Không tài khoản, không server, không đồng bộ, không thu thập dữ liệu. Toàn bộ nằm trong máy. Sao lưu và chuyển máy bằng một file JSON người dùng tự xuất ra và tự giữ.

## Điều làm nên khác biệt

**So với hai file PDF hiện tại** — giữ nguyên toàn bộ cách người dùng đã tư duy (dự án → hành động → trạng thái, ý tưởng sinh ra dự án, mục tiêu lớn dẫn đường), chỉ bỏ đi phần chết: trạng thái không đếm được, thiếu thời gian, thiếu mối nối, và rào cản không sửa được trên điện thoại.

**So với app quản lý công việc phổ thông** (Todoist, Notion, Microsoft To Do) — những app đó tổ chức quanh *task* và *deadline*, xem mục tiêu dài hạn là phần phụ hoặc không có. Ứng dụng này đảo lại: **mục tiêu là gốc, dự án là nhánh, hành động là lá**. Nó không cố trở thành nơi chứa mọi việc trong ngày; nó chỉ chứa những gì thuộc về bảy hướng đi mà người dùng đã chọn.

**So với Notion** — Notion làm được tất cả những điều trên, nhưng phải tự dựng, phải có mạng, và dữ liệu nằm trên server nước ngoài. Nội dung ở đây gồm mục tiêu tài chính thật, tên người thật và kế hoạch gia đình — thuộc loại không nên rời khỏi máy.

**Ăn khớp với app đã có.** Người dùng đã có một ứng dụng theo dõi danh mục đầu tư tự viết (`personal_finance`). Ứng dụng này **không** lặp lại việc đó: nó không theo dõi tài sản, không lấy giá thị trường, không tính lãi lỗ. Dự án `Kế hoạch tài chính` ở đây chỉ giữ phần *ý chí* — mục tiêu, nguyên tắc, hành động phải làm — còn *số liệu* vẫn thuộc về app kia. [GIẢ ĐỊNH] Ranh giới này được giữ trong MVP; việc nhập số dư tổng từ app kia để cập nhật mục tiêu `1 tỷ` là thao tác tay, mỗi lần một dòng.

Nói thẳng: đây không phải sản phẩm thương mại. Nó phục vụ một người dùng cụ thể với hai file cụ thể. Giá trị của nó là **vừa khít** với cách người đó đã tổ chức đời sống dự án của mình.

## Phục vụ ai

**Người dùng duy nhất — một kỹ sư phần mềm đang đồng thời chạy bảy hướng đi cá nhân.**

Chân dung rút ra từ chính hai file: đang ở *"giai đoạn thắt lưng buộc bụng — tập trung mua tài sản"*, ưu tiên số một là tạo dòng tiền ngoài lương, hướng mọi thứ *"về gia đình, vợ con"*. Đã có kỷ luật ghi chép và tự đúc kết nguyên tắc. Không cần ai dạy về quản lý mục tiêu — cần một công cụ theo kịp tốc độ suy nghĩ của mình và không bắt phải mở máy tính.

Thành công với người này là: **mở app, trong mười giây biết hôm nay nên làm gì và mục tiêu lớn còn cách bao xa** — rồi đóng app đi làm việc đó.

## Phạm vi MVP

Hai khối, đã chốt:

| Khối | Nội dung |
|---|---|
| **Dự án & Hành động** | 7 dự án, chủ đề, độ ưu tiên, trạng thái, danh sách hành động có trạng thái và hạn, ghi chú, link ngoài |
| **Mục tiêu & Tiến độ** | Mục tiêu có giá trị đích + hạn chót, sổ cập nhật tiến độ, biểu đồ đường, nối vào dự án |

Kèm theo, không thể thiếu: màn hình **Hôm nay**, tìm kiếm, và **sao lưu / khôi phục bằng file JSON**.

**Ngoài phạm vi MVP** (có chủ đích, xếp vào roadmap):

- **Ngân hàng ý tưởng** — bắt ý tưởng nhanh, gắn tag, chuyển thành dự án. Là bước tiếp theo tự nhiên nhất; MVP tạm thời dùng ghi chú trong dự án để thay.
- **Thói quen hằng ngày** — sáu mục cuối file `HÀNH ĐỘNG` (tiết kiệm, thể dục, ngủ sớm, đúng giờ, ở một mình, đọc sách) dạng chuỗi ngày. Mô hình dữ liệu khác hẳn (lặp lại theo ngày, không có "xong" vĩnh viễn) nên tách riêng.
- Nhắc nhở qua thông báo hệ thống · thống kê năng suất · đồng bộ nhiều máy · liên thông tự động với `personal_finance`.

## Rủi ro và ẩn số

**Rủi ro lớn nhất là app bị bỏ rơi sau hai tuần.** Đây là rủi ro thật của mọi công cụ năng suất tự viết, và nó đã xảy ra một lần rồi — chính hai file PDF là bằng chứng của một hệ thống dừng cập nhật. Cách phòng: nhập liệu phải ít chạm hơn sửa file PDF, và màn hình Hôm nay phải có ích ngay cả trong ngày người dùng không nhập gì.

**Ẩn số: mục tiêu `1 tỷ` tính trên cái gì?** Tổng tài sản ròng, hay chỉ phần đầu tư, hay thu nhập tích luỹ? [GIẢ ĐỊNH] MVP xử lý theo hướng tổng quát: mục tiêu là một con số có đơn vị do người dùng tự định nghĩa, app không áp đặt ý nghĩa. Cần xác nhận trước khi làm màn hình chi tiết mục tiêu.

**Ẩn số: hạn chót của mục tiêu `1 tỷ`.** Chưa có trong tài liệu. Không có hạn thì không tính được nhịp cần đi. [GIẢ ĐỊNH] Hạn chót để trống được, khi đó app chỉ hiện % và tuyệt đối không suy đoán nhịp.

**Ẩn số: dự án `dạy Huy` là gì.** Chưa rõ Huy là ai và nội dung dạy là gì — đủ để tạo bản ghi nhưng chưa đủ để biết dự án này cần trường dữ liệu đặc thù nào. [GIẢ ĐỊNH] Xử lý như dự án thường trong MVP.
