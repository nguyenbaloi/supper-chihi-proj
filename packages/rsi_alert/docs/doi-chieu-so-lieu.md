# Đối chiếu số liệu — Story 6.2

**Ngày kiểm:** 2026-09-04
**Công cụ:** `fvm dart run tool/doi_chieu.dart` — gọi nguồn dữ liệu thật, tính RSI bằng đúng mã nguồn app dùng (`lib/domain/rsi.dart`).

## Phạm vi đã kiểm tự động

| Kiểm | Kết quả | Nơi kiểm |
| --- | --- | --- |
| RSI khớp cài đặt Wilder độc lập trong ±0.5 điểm, trên 894 nến VNINDEX và 458 nến BTC | Đạt | `test/domain/rsi_test.dart` |
| Nến gộp từ VNDirect khớp nến tuần trực tiếp của SSI trong ±0.5 điểm | Đạt, so được hơn 30 tuần | `test/data/sources_test.dart` |
| Tín hiệu chỉ sinh tại tuần cắt ngưỡng, không lặp trong đợt kéo dài | Đạt | `test/domain/signal_test.dart` |
| Nến đang chạy không bao giờ sinh tín hiệu | Đạt | `test/domain/signal_test.dart`, `test/ui/overview_test.dart` |

Giá trị tham chiếu ở `test/fixtures/rsi_reference.json` được sinh bằng một cài đặt Wilder viết riêng bằng Python, độc lập với mã Dart. Nó bắt được lỗi cài đặt, nhưng **không** thay thế được việc đối chiếu với TradingView — hai cài đặt sai giống nhau vẫn khớp nhau.

## Việc còn lại phải làm bằng tay

Bước dưới đây **chưa làm được từ môi trường này** vì không truy cập được TradingView. Đây là việc của người dùng, và nó là điều kiện để coi SM-1 và SM-2 đạt:

1. Mở TradingView, chọn `BINANCE:BTCUSDT` khung **1W**, bật chỉ báo **RSI** chu kỳ **14**, nguồn giá **close**.
2. So 20 giá trị RSI ở bảng dưới với cột RSI trên TradingView. Sai lệch phải ≤ 0.5 điểm.
3. Lặp lại với `HOSE:VNINDEX` khung 1W.
4. Cuộn lại ba năm gần nhất trên TradingView, đếm số lần đường RSI cắt qua 30 hoặc 70, đối chiếu với danh sách Tín hiệu ở dưới. Không được sót và không được thừa.

## Số liệu chụp lúc 2026-09-04

### BTC — nguồn Binance (`data-api.binance.vision`)

473 nến tuần, từ 2017-08-14 đến 2026-08-31. Nến cuối là **nến đang chạy**.

| Tuần mở (UTC) | Giá đóng | RSI |
| --- | ---: | ---: |
| 2026-04-20 | 78 657.55 | 47.29 |
| 2026-04-27 | 78 568.57 | 47.21 |
| 2026-05-04 | 82 210.07 | 51.23 |
| 2026-05-11 | 77 457.67 | 46.27 |
| 2026-05-18 | 77 064.96 | 45.88 |
| 2026-05-25 | 73 674.39 | 42.51 |
| 2026-06-01 | 63 332.01 | 34.24 |
| 2026-06-08 | 65 746.45 | 37.31 |
| 2026-06-15 | 63 311.99 | 35.51 |
| 2026-06-22 | 59 577.01 | 32.89 |
| 2026-06-29 | 63 650.00 | 38.24 |
| 2026-07-06 | 63 780.00 | 38.41 |
| 2026-07-13 | 64 722.54 | 39.69 |
| 2026-07-20 | 65 399.99 | 40.65 |
| 2026-07-27 | 63 570.00 | 38.86 |
| 2026-08-03 | 64 901.59 | 40.90 |
| 2026-08-10 | 62 900.00 | 38.80 |
| 2026-08-17 | 77 734.00 | 56.61 |
| 2026-08-24 | 77 682.00 | 56.55 |
| 2026-08-31 | 80 684.72 | 59.32 · **tạm tính** |

Tín hiệu: 13 trong toàn bộ dữ liệu, 6 trong ba năm gần nhất.

| Tuần | Loại | RSI | Giá đóng |
| --- | --- | ---: | ---: |
| 2023-10-23 | Quá mua | 70.69 | 34 525.89 |
| 2024-02-05 | Quá mua | 76.55 | 48 299.99 |
| 2024-06-03 | Quá mua | 70.14 | 69 648.14 |
| 2024-11-11 | Quá mua | 73.32 | 89 855.99 |
| 2025-07-07 | Quá mua | 70.22 | 119 086.64 |
| 2026-02-02 | Quá bán | 29.01 | 70 330.38 |

### VNINDEX — nguồn SSI iBoard

909 nến tuần, từ 2007-07-23 đến 2026-08-31. Nến cuối là **nến đang chạy**.

| Tuần mở (UTC) | Giá đóng | RSI |
| --- | ---: | ---: |
| 2026-04-20 | 1 853.29 | 60.39 |
| 2026-04-27 | 1 854.10 | 60.44 |
| 2026-05-04 | 1 915.37 | 64.26 |
| 2026-05-11 | 1 921.60 | 64.63 |
| 2026-05-18 | 1 877.13 | 59.82 |
| 2026-05-25 | 1 863.49 | 58.39 |
| 2026-06-01 | 1 838.90 | 55.79 |
| 2026-06-08 | 1 791.65 | 51.09 |
| 2026-06-15 | 1 824.53 | 54.00 |
| 2026-06-22 | 1 871.91 | 57.88 |
| 2026-06-29 | 1 862.08 | 56.81 |
| 2026-07-06 | 1 828.34 | 53.17 |
| 2026-07-13 | 1 787.45 | 49.07 |
| 2026-07-20 | 1 686.11 | 40.69 |
| 2026-07-27 | 1 735.78 | 45.59 |
| 2026-08-03 | 1 768.06 | 48.57 |
| 2026-08-10 | 1 729.08 | 45.34 |
| 2026-08-17 | 1 768.12 | 49.00 |
| 2026-08-24 | 1 832.12 | 54.38 |
| 2026-08-31 | 1 858.65 | 56.43 · **tạm tính** |

Tín hiệu: 28 trong toàn bộ dữ liệu, 4 trong ba năm gần nhất.

| Tuần | Loại | RSI | Giá đóng |
| --- | --- | ---: | ---: |
| 2024-02-26 | Quá mua | 70.28 | 1 258.28 |
| 2024-03-18 | Quá mua | 71.58 | 1 281.80 |
| 2025-07-07 | Quá mua | 75.54 | 1 457.76 |
| 2026-01-05 | Quá mua | 71.13 | 1 867.90 |

## Điểm cần biết khi đối chiếu

**Chuỗi VNINDEX thiếu hẳn tuần nghỉ Tết mỗi năm.** Thị trường không giao dịch tuần đó nên không có nến, và TradingView cũng vậy. Đừng coi đó là dữ liệu thủng. Dữ liệu cũ 2007–2009 cũng có khoảng trống lớn; chúng ở quá xa để ảnh hưởng tới RSI hiện tại vì phép làm mượt Wilder hội tụ sau vài chục nến.

**Nến cuối luôn là nến đang chạy** ở cả hai nguồn. RSI của nó là *tạm tính* và sẽ đổi cho tới khi tuần kết thúc. Khi so với TradingView, hãy so nến **đã đóng** — nến cuối trên TradingView cũng đang chạy và sẽ khớp chỉ khi hai bên chụp cùng một thời điểm.

**TCBS không dùng được.** `apipubaws.tcbs.com.vn` trả HTTP 403 kèm trang thử thách Cloudflare, kể cả với đầy đủ header trình duyệt. **`api.binance.com` không kết nối được** từ mạng này (kết nối bị ngắt, không phải lỗi HTTP); `data-api.binance.vision` là máy chủ dữ liệu thị trường công khai của chính Binance và hoạt động bình thường.
