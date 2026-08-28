# Kiểm thử thủ công

Danh sách này dành cho những thứ **unit test không chạm tới được**: bảng chia
sẻ của hệ điều hành, hộp chọn file, cảm giác thao tác, và độ nhanh thật.

Ghi kết quả thẳng vào cột cuối. Chỗ nào sai thì ghi rõ **thấy gì**, không cần
đoán nguyên nhân.

## Chạy app

```bash
cd ~/StudioProjects/personal_projects
fvm flutter devices                    # xem máy nào đang nhận
fvm flutter run                        # chạy lên máy đầu tiên
fvm flutter run -d <device-id>         # chọn máy cụ thể
```

Đang chạy thì bấm `r` để nạp nóng, `R` để khởi động lại, `q` để thoát.

## 1. Lần chạy đầu

| # | Việc làm | Mong đợi | Kết quả |
|---|---|---|---|
| 1.1 | Mở app lần đầu | Hiện lời mời nạp dữ liệu có sẵn, **không** phải màn hình trống | |
| 1.2 | Bấm *Nạp dữ liệu có sẵn* | Vào thẳng Hôm nay, đã có nội dung | |
| 1.3 | Sang tab Dự án | Đúng 7 dự án | |
| 1.4 | Đóng hẳn app rồi mở lại | Không hỏi nạp lại nữa | |

## 2. Màn hình Hôm nay

| # | Việc làm | Mong đợi | Kết quả |
|---|---|---|---|
| 2.1 | Nhìn tổng thể | Chỉ có nhóm nào **thật sự có việc**; nhóm rỗng biến mất hẳn | |
| 2.2 | Đếm số dòng | **Không** liệt kê hết mọi hành động chưa xong | |
| 2.3 | Chạm ô tròn bên trái một dòng | Gạch ngang ngay, có rung nhẹ, không mở màn hình nào | |
| 2.4 | Chạm vào chữ của dòng đó | Mở đúng dự án chứa nó | |
| 2.5 | Tìm nhóm *Cần chú ý* | Có dòng *Dạy Huy — đến hạn xem lại* (mốc 07/11) | |

## 3. Dự án và hành động

| # | Việc làm | Mong đợi | Kết quả |
|---|---|---|---|
| 3.1 | Mở *Kế hoạch tài chính* | 6 hành động, 3 gạch ngang | |
| 3.2 | Gõ tên một việc mới rồi Enter | Thêm xong, con trỏ **vẫn ở ô nhập** để gõ tiếp | |
| 3.3 | Gõ tiếp 2 việc nữa liên tiếp | Không phải chạm lại lần nào | |
| 3.4 | Kéo thả đổi thứ tự | Thoát app rồi mở lại, thứ tự giữ nguyên | |
| 3.5 | Menu ba chấm → Xoá | Có nút *Hoàn tác* trong vài giây, bấm vào thì việc quay lại | |
| 3.6 | Đổi trạng thái dự án sang *Tạm dừng* | Dự án biến khỏi danh sách mặc định; bật *Hiện dự án đã đóng* thì thấy lại | |
| 3.7 | Thử tạo dự án tên rỗng | Bị từ chối kèm thông báo | |
| 3.8 | Xoá một dự án | Hộp xác nhận **nói rõ số** hành động, ghi chú, liên kết sẽ mất | |

## 4. Mục tiêu

| # | Việc làm | Mong đợi | Kết quả |
|---|---|---|---|
| 4.1 | Mở *Mục tiêu 1 tỷ* | Hiện `—`, chưa có mốc nào, **không** hiện `0%` | |
| 4.2 | Thêm mốc: hôm nay, `340.000.000` | Hiện `34,0%`, còn thiếu `660.000.000 ₫` | |
| 4.3 | Thêm mốc thứ hai lùi về vài tháng trước, giá trị nhỏ hơn | Biểu đồ hiện ra, có đường nhịp lý tưởng tới 31/12/2027 | |
| 4.4 | Đọc thẻ nhịp | Có *cần thêm mỗi tháng* và *về đích sớm/chậm X tháng* | |
| 4.5 | Sửa mốc **ở giữa** chuỗi | Mọi con số phía sau tự đúng theo | |
| 4.6 | Mở *Tìm thêm một nguồn thu nhập khác* | **Không** có thanh phần trăm, **không** có sổ mốc | |

## 5. Đợt đánh giá — dự án Dạy Huy

| # | Việc làm | Mong đợi | Kết quả |
|---|---|---|---|
| 5.1 | Mở *Dạy Huy* → thẻ *Đánh giá* | Hai đợt: 07/08 (3 đạt) và 15/05 (2 đạt) | |
| 5.2 | Mở đợt 15/05 | 5 mục, ghi chú đầy đủ, ba nút Đạt / Một phần / Chưa đạt | |
| 5.3 | Chạm nút kết quả khác | Đổi ngay, tỷ lệ đạt phía trên tính lại | |
| 5.4 | Tạo đợt mới | Tự đề nghị chép các mục **chưa đạt** của đợt 07/08; mục đã đạt không có mặt | |
| 5.5 | Bỏ chọn hết rồi lưu | Đợt mới trống | |

## 6. Sao lưu và chuyển máy — quan trọng nhất

| # | Việc làm | Mong đợi | Kết quả |
|---|---|---|---|
| 6.1 | Cài đặt → *Xuất bản sao lưu* | Bảng chia sẻ của hệ điều hành mở ra, tên file `sao-luu-YYYY-MM-DD.json` | |
| 6.2 | Gửi file cho chính mình qua Drive hoặc AirDrop | Nhận được, mở ra đọc thấy chữ có dấu bình thường | |
| 6.3 | Cài đặt → *Xoá sạch dữ liệu* | Hỏi **hai lần**, có gợi ý xuất sao lưu trước | |
| 6.4 | Sau khi xoá | App trống, nhưng vẫn còn sáu chủ đề | |
| 6.5 | Cài đặt → *Nhập từ bản sao lưu* → chọn file vừa gửi | Hỏi xác nhận thay thế, sau đó khôi phục đủ | |
| 6.6 | Đối chiếu bằng mắt | Đủ 7 dự án, hai đợt đánh giá của Dạy Huy, các mốc mục tiêu | |
| 6.7 | Thử nhập một file lung tung (đổi tên một file `.txt` bất kỳ thành `.json`) | Báo lỗi rõ ràng, **dữ liệu hiện tại không mất** | |

## 7. Ngoại tuyến và linh tinh

| # | Việc làm | Mong đợi | Kết quả |
|---|---|---|---|
| 7.1 | Bật chế độ máy bay, dùng hết các màn hình | Không lỗi nào, không màn hình chờ nào treo | |
| 7.2 | Tìm kiếm, gõ `tai chinh` không dấu | Ra *Kế hoạch tài chính* | |
| 7.3 | Gõ `cai bim` | Ra nội dung trong dự án Dạy Huy | |
| 7.4 | Chạm một liên kết `appbox.me` | Mở trình duyệt ngoài, không nhúng trong app | |
| 7.5 | Đổi giao diện sang Tối trong Cài đặt | Đổi ngay, mở lại app vẫn giữ | |
| 7.6 | Bấm giờ từ lúc chạm biểu tượng tới lúc thấy dữ liệu | Dưới 1,5 giây | |

## Khoảng trống đã biết

- **Test widget cấp ứng dụng** chưa có: drift chạy I/O thật nên treo trong vùng
  thời gian giả của `testWidgets`. Hành vi tương ứng được test repository phủ,
  nhưng phần dựng hình thì chỉ kiểm tay được.
- **Số liệu hiệu năng** (mục 7.6) chưa đo tự động — Story 4.4.
- **iOS tối thiểu là 14.0**, không phải 13.0 như NFR-6 ban đầu: `file_picker`
  yêu cầu vậy. Xem mục 5 của PRD.
