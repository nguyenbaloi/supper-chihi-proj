---
title: "Phụ lục Brief — Đầu vào cho PRD & Architecture"
status: draft
created: 2026-08-27
updated: 2026-08-27
---

# Phụ lục — App Quản lý Danh mục Đầu tư

Phần chi tiết không thuộc về brief (brief giữ gọn 1-2 trang) nhưng cần cho pha PRD và Architecture.

## 1. Ràng buộc kỹ thuật

| Hạng mục | Giá trị | Ghi chú |
|---|---|---|
| Framework | Flutter 3.29.2 / Dart 3.7.2 | Bản đang cài tại `Development/flutter`. Giữ nguyên trong MVP. |
| Nền tảng | Android + iOS | |
| Application ID | `com.finapp.personal_finance` | Nên đổi thành tên phản ánh đúng sản phẩm (vd `com.finapp.portfolio`) — đổi càng sớm càng rẻ. |
| Lưu trữ | SQLite cục bộ | Ứng viên: `drift` (type-safe, migration tốt, reactive query) hoặc `sqflite`. Quyết định ở pha Architecture. |
| Mạng | Chỉ gọi ra để lấy giá và tỷ giá | Không có backend riêng, không gửi dữ liệu nắm giữ đi đâu. |
| Tiền tệ | VND (gốc) + USD | Quy đổi về VND để tổng hợp. |
| Ngôn ngữ | Tiếng Việt | Bọc chuỗi qua lớp l10n từ đầu để mở đường cho tiếng Anh sau. |

## 2. Quy tắc số học — cực kỳ quan trọng, sai là hỏng toàn bộ

**Tiền tệ.** Lưu dưới dạng **số nguyên đơn vị đồng**, tuyệt đối không dùng `double`. Cộng dồn `double` sinh sai số dấu phẩy động, và với một danh mục 680 triệu thì sai lệch tích lũy sẽ hiện ra ở đúng chỗ người dùng nhìn vào nhiều nhất — con số tổng.

**Số lượng nắm giữ.** Đây là điểm khác biệt so với tiền: BTC cần tới **8 chữ số thập phân** (1 satoshi = 0,00000001 BTC), vàng cần 2–3 chữ số (chỉ/lượng), cổ phiếu là số nguyên. Không dùng `double`. Hai hướng: lưu số nguyên đã nhân hệ số (scaled integer, mỗi loại tài sản khai báo số chữ số thập phân riêng), hoặc dùng thư viện `decimal`. **Đây là quyết định kiến trúc phải chốt sớm — đổi sau sẽ phải migrate toàn bộ dữ liệu.**

**Thứ tự phép tính.** Luôn tính `số lượng × giá` ở độ chính xác cao nhất rồi mới làm tròn về đồng ở bước hiển thị cuối cùng. Làm tròn sớm ở từng khoản rồi cộng lại sẽ cho tổng lệch so với Excel.

**Tỷ trọng.** `tỷ trọng = giá trị khoản / tổng danh mục`. Hiển thị một chữ số thập phân, khớp Excel (2,2% · 13,5% · 57,4% · 26,9%). Lưu ý tổng các tỷ trọng sau làm tròn có thể ra 99,9% hoặc 100,1% — cần quy tắc xử lý nhất quán để không gây hoang mang.

## 3. Công thức lãi lỗ — chốt cứng, đã kiểm chứng trên 10 dòng dữ liệu thật

```
vốn_góp_lũy_kế(n) = vốn_góp_lũy_kế(n−1) + nạp_rút(n)
lãi_lỗ(n)         = giá_trị_hiện_tại(n) − vốn_góp_lũy_kế(n)
```

- `nạp_rút` dương là nạp thêm tiền vào, âm là rút tiền ra.
- Sổ nạp/rút là **một dòng tiền chung** cho cả nhóm đầu tư, không tách theo lớp tài sản — giữ đúng cách Excel đang làm.
- Phạm vi áp dụng ở MVP: **chỉ Chứng khoán + Crypto**. Vàng và tiền mặt bị loại trừ — đúng theo ghi chú gốc trên Excel: *"Chỉ tính đầu tư ck và crypto, bỏ tiền mặt và vàng riêng"*.
- Cần thiết kế để phạm vi này **cấu hình được** (chọn lớp nào tham gia tính lãi lỗ), vì đây là ứng viên thay đổi rõ ràng ở v1.1.

### Ràng buộc bắt buộc: vốn góp lũy kế là giá trị TÍNH TOÁN, không lưu cứng

Người dùng yêu cầu **sửa và xóa được lịch sử vốn**. Điều này loại bỏ hoàn toàn phương án lưu sẵn cột `vốn_góp_lũy_kế` cho từng dòng như Excel đang làm.

Lý do: giả sử chuỗi nạp/rút là `+341 → −60 → −36 → +9`, cho lũy kế `341 → 281 → 245 → 254`. Nếu người dùng sửa dòng thứ hai từ `−60` thành `−50`, thì **cả ba dòng sau đều sai** nếu lũy kế được lưu cứng. Excel không gặp vấn đề này vì công thức tự chạy lại; một database thì không.

**Quy tắc chốt:**
- Chỉ lưu `nạp_rút` của từng dòng và `vốn_góp_lũy_kế_khởi_điểm` một lần duy nhất.
- `vốn_góp_lũy_kế` tại bất kỳ thời điểm nào = `khởi_điểm + tổng các nạp_rút có ngày ≤ thời điểm đó`, luôn tính tại chỗ.
- Mọi thao tác thêm / sửa / xóa / **đổi ngày** một dòng nạp/rút đều kéo theo tính lại lũy kế và lãi lỗ của mọi dòng từ đó về sau, bao gồm cả các bản snapshot đã lưu.
- Đổi ngày là trường hợp dễ bỏ sót nhất: nó không đổi giá trị nào nhưng làm đảo thứ tự chuỗi tính toán.

### Phạm vi chỉnh sửa yêu cầu ở MVP

| Đối tượng | Thêm | Sửa | Xóa | Ghi chú |
|---|---|---|---|---|
| Khoản nắm giữ crypto | ✓ | ✓ | ✓ | Sửa số lượng, đè giá, đổi ký hiệu |
| Khoản nắm giữ chứng khoán | ✓ | ✓ | ✓ | Sửa số lượng, đè giá, đổi mã |
| Dòng lịch sử nạp/rút vốn | ✓ | ✓ | ✓ | Kéo theo tính lại toàn chuỗi |
| Khoản vàng, tiền mặt, tiết kiệm | ✓ | ✓ | ✓ | Sửa giá trị trực tiếp |
| Khoản nợ / cho vay | ✓ | ✓ | ✓ | Thêm trạng thái đã tất toán |
| Tỷ trọng mục tiêu | — | ✓ | — | Sửa được bất cứ lúc nào |
| Vốn góp lũy kế khởi điểm | — | ✓ | — | Sửa được, nhưng cảnh báo rõ vì ảnh hưởng toàn bộ lịch sử lãi lỗ |
| Snapshot tự động hằng ngày | — | — | — | Không cho sửa, giữ tính toàn vẹn của biểu đồ lịch sử |

**Bộ dữ liệu kiểm thử bắt buộc** — lấy nguyên từ Excel, dùng làm test case đối chiếu:

| Ngày | Nạp/Rút | Vốn góp lũy kế kỳ vọng | Tài sản | Lãi/Lỗ kỳ vọng |
|---|---|---|---|---|
| 12/1/2025 | 0 | 341 | 341 | 0 |
| 21/2/2025 | 0 | 341 | 302 | −39 |
| 3/3/2025 | 0 | 341 | 310 | −31 |
| 30/3/2025 | 0 | 341 | 173 | −168 |
| 21/7/2025 | 0 | 341 | 320 | −21 |
| 9/8/2025 | −60 | 281 | 311 | +30 |
| 18/8/2025 | −36 | 245 | 283 | +38 |
| 7/10/2025 | +9 | 254 | 321 | +67 |
| 28/11/2025 | +47 | 301 | 267 | −34 |
| 3/2/2026 | +32 | 333 | 233 | −100 |

## 4. Mô hình dữ liệu đề xuất

```
AssetClass (lớp tài sản)
  id · tên · loại (stock|gold|crypto|cash_savings|lending)
  tỷ_trọng_mục_tiêu (%) · tính_vào_lãi_lỗ (bool) · icon · màu · thứ tự

Holding (khoản nắm giữ)
  id · asset_class_id · ký hiệu (FPT, BTC, ETH...) · tên hiển thị
  chế_độ_nhập (quantity | value)
    → quantity: crypto (8 chữ số thập phân), cổ phiếu (số nguyên), vàng (đơn vị CHỈ, 2 chữ số)
    → value:    tiền mặt, tiền gửi tiết kiệm, cho vay
  số_lượng · đơn_vị (BTC|cổ|chỉ) · số_chữ_số_thập_phân
  giá_trị_nhập_tay · tiền_tệ (VND|USD)
  ghi chú · ngày cập nhật

PriceQuote (giá thị trường, có cache)
  ký hiệu · giá · tiền tệ · nguồn (api|manual) · thời điểm lấy
  → giá manual luôn thắng giá api cho tới khi bị xóa

FxRate (tỷ giá)
  cặp tiền (USD/VND) · tỷ giá · nguồn · thời điểm
  → Excel đang ẩn ở mức ~26.000

PortfolioSetting (thiết lập khởi tạo — BẮT BUỘC)
  vốn_góp_lũy_kế_khởi_điểm · ngày_bắt_đầu
  → Vì người dùng bỏ toàn bộ lịch sử quá khứ và bắt đầu từ hiện tại,
    con số này là điểm neo cho mọi phép tính lãi lỗ về sau.
    Excel dòng cuối (3/2/2026) cho giá trị 333 triệu, nhưng người dùng
    đã nạp thêm vốn sau mốc đó — số thực tế phải hỏi lại lúc cài đặt.
    Bỏ trống hoặc để 0 → lãi lỗ sai hoàn toàn, app phải chặn ở luồng khởi tạo.

CashFlow (sổ nạp/rút)
  id · ngày · số tiền (+nạp/−rút) · phạm vi áp dụng · ghi chú
  → vốn góp lũy kế = vốn_góp_lũy_kế_khởi_điểm + tổng các CashFlow phát sinh sau ngày_bắt_đầu

Snapshot (bản chốt)
  id · ngày · tổng tài sản · vốn góp lũy kế · lãi lỗ
  loại (auto_daily | manual) · ghi chú
  → bản auto sinh mỗi ngày; bản manual do người dùng bấm

SnapshotDetail (chi tiết từng lớp tại thời điểm chốt)
  snapshot_id · asset_class_id · giá trị · tỷ trọng
  → cần thiết để tái dựng lại cơ cấu quá khứ, Excel hiện không có

Debt (nợ và cho vay)
  id · tên người · loại (cho_vay | đi_vay) · số tiền
  ngày · ghi chú
  trạng_thái (đang_hiệu_lực | đã_tất_toán) · ngày_tất_toán
  → khoản đã tất toán bị loại khỏi tổng tài sản nhưng vẫn giữ trong lịch sử
  → quy ước dấu: dương = cho vay, âm = đi vay
  → tổng ròng tự chảy vào AssetClass loại lending

ActionNote (kế hoạch hành động)
  id · nội dung · ngày tạo · đã hoàn thành
  → thay cho các dòng ghi chú tự do ở cuối sheet Excel
```

**Quy tắc liên kết bắt buộc:** giá trị của một `AssetClass` = tổng giá trị các `Holding` thuộc nó. Riêng lớp `lending` thì giá trị = tổng ròng của sổ `Debt`. Không cho phép nhập giá trị lớp một cách độc lập — đây chính là lỗi cộng thủ công đang có trong Excel.

## 5. Nguồn dữ liệu giá

| Loại | Nguồn đề xuất | Ghi chú |
|---|---|---|
| Crypto (BTC, ETH, USDT) | CoinGecko API công khai | Miễn phí, không cần API key ở mức dùng cơ bản, hỗ trợ trả thẳng giá theo VND. |
| Tỷ giá USD/VND | Lấy kèm từ CoinGecko, hoặc nguồn tỷ giá riêng | Cần giá trị mặc định dự phòng khi không có mạng. |
| Cổ phiếu VN (FPT, HCM) | **Nhập tay ở MVP** | API chứng khoán VN không ổn định và điều khoản sử dụng không rõ ràng. Khảo sát lại ở v1.1. |
| Vàng | **Nhập tay ở MVP** — giá theo **chỉ** | Giá vàng SJC không có API công khai đáng tin. Người dùng vốn đã tự nhẩm theo chỉ nên đơn vị này là tự nhiên với họ. |

**Nguyên tắc xử lý lỗi mạng:** không bao giờ để trống và không bao giờ hiển thị giá cũ như thể là giá mới. Luôn hiện giá lưu lần cuối kèm nhãn thời gian rõ ràng ("cập nhật 2 giờ trước"), và đánh dấu trực quan khi giá đã cũ quá ngưỡng.

## 6. Các lựa chọn đã cân nhắc và lý do loại

**App sổ thu chi hằng ngày.** Đây là hướng của bản brief đầu tiên, dựng trước khi có Excel thực tế. Loại bỏ hoàn toàn sau khi thấy dữ liệu thật: nhu cầu nằm ở theo dõi danh mục đầu tư, không phải ghi chi tiêu. Bản cũ giữ tại `brief-v1-expense-tracker.md.bak`.

**Nhập thẳng giá trị cho mọi tài sản (y hệt Excel).** Loại. Giữ nguyên cách này thì app chỉ là Excel có màu — người dùng vẫn phải tự tra giá và tự tính. Nhập theo số lượng mới là thứ tạo ra giá trị tự động hóa.

**Offline tuyệt đối, không gọi mạng.** Loại. Mâu thuẫn trực tiếp với mục tiêu tự động hóa. Đã xác lập: gọi API giá không kèm dữ liệu nắm giữ nên nguyên tắc riêng tư vẫn được giữ nguyên vẹn.

**Đưa sổ lệnh mua bán chi tiết vào MVP.** Loại, để v1.1. Cho phép tính giá vốn bình quân và tách lãi đã thực hiện với chưa thực hiện — nhưng Excel hiện tại không làm điều này, nên đưa vào MVP là mở rộng phạm vi vượt quá mục tiêu "thay thế được Excel".

**Firebase / backend riêng.** Loại. Mâu thuẫn nguyên tắc riêng tư, thêm chi phí vận hành, không giải quyết nỗi đau nào đang có.

**Nhập dữ liệu hàng loạt từ CSV.** Loại khỏi MVP. Ban đầu dự kiến đưa vào để chuyển dữ liệu từ Excel sang, nhưng người dùng đã quyết định bỏ toàn bộ lịch sử quá khứ và bắt đầu từ hiện tại — phần dữ liệu cần chuyển chỉ còn khoảng 15 dòng, nhập tay mất chưa tới 10 phút. Viết tính năng nhập CSV cho việc đó là lãng phí. Xuất CSV vẫn giữ, vì nó phục vụ sao lưu lâu dài chứ không phải chuyển đổi một lần.

**Đưa lãi suất và kỳ hạn tiền gửi tiết kiệm vào MVP.** Loại, để v1.1. Khoản 50 triệu tiết kiệm ngắn hạn có sinh lãi, nhưng người dùng đã chốt phạm vi tính lãi lỗ chỉ gồm Chứng khoán và Crypto. Lãi tiết kiệm hiện được xử lý đơn giản bằng cách người dùng cập nhật lại giá trị khoản đó khi nhận lãi.

## 7. Rủi ro

| Rủi ro | Mức độ | Hướng giảm thiểu |
|---|---|---|
| Sai số học trong tính toán tiền và số lượng | **Cao** — sai số ngầm phá vỡ toàn bộ niềm tin vào app | Dùng số nguyên/decimal, cấm `double`; viết test đối chiếu với 10 dòng dữ liệu Excel ngay từ story đầu tiên |
| API giá đổi hoặc ngừng phục vụ | Trung bình | Trừu tượng hóa nguồn giá sau một interface; luôn có đường đè tay; cache giá lần cuối |
| Mất máy khi chưa sao lưu → mất toàn bộ lịch sử | **Cao** — hệ quả của kiến trúc offline | Xuất CSV ở MVP; nhắc sao lưu; đẩy sao lưu tự động lên sớm ở v1.1 |
| Quên khai báo vốn góp lũy kế khởi điểm | **Cao** — mọi con số lãi lỗ sẽ sai mà không có dấu hiệu báo lỗi | Bắt buộc ở luồng khởi tạo, không cho bỏ qua; hiển thị lại con số này ở màn hình lãi lỗ để người dùng luôn đối chiếu được |
| Sửa một dòng nạp/rút quá khứ mà không tính lại chuỗi phía sau | **Cao** — lãi lỗ sai âm thầm, đúng loại lỗi khó phát hiện nhất | Không lưu cứng lũy kế; viết test riêng cho kịch bản sửa và đổi ngày dòng giữa chuỗi |
| Phạm vi phình dần (thêm sổ lệnh, thuế, cảnh báo giá) | Trung bình | Danh sách "ngoài phạm vi" trong brief là hợp đồng; thay đổi phải qua `bmad-correct-course` |
| Giá cổ phiếu và vàng nhập tay → lại rơi vào đúng nỗi đau cũ | Trung bình | Hai lớp này chỉ chiếm 15,7% danh mục nên tác động hạn chế; ưu tiên tự động hóa ở v1.1 |

## 8. Đặc thù Việt Nam cần xử lý

- Định dạng số kiểu Việt Nam: `680.000.000 đ`, dấu chấm ngăn nghìn, dấu phẩy thập phân.
- Rút gọn khi hiển thị: `680 tr`, `1,2 tỷ` — Excel hiện đang làm việc theo đơn vị triệu.
- Vàng tính theo **chỉ** (1 lượng = 10 chỉ), không phải ounce hay gram. Người dùng đang tư duy theo đơn vị chỉ — giữ nguyên, không quy đổi sang đơn vị khác khi hiển thị.
- Cổ phiếu sàn HOSE giao dịch theo lô 100.
- Cho vay cá nhân không giấy tờ là một lớp tài sản thật sự — chiếm 133/680 ≈ 19,6% danh mục này.
