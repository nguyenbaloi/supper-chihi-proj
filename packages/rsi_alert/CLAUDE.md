# CLAUDE.md

Hướng dẫn cho Claude Code khi làm việc trong project này.

## Sản phẩm

App Flutter theo dõi **RSI(14) khung tuần** của **Bitcoin** và **VNINDEX**, và cảnh báo khi chỉ số cắt xuống dưới 30 hoặc lên trên 70.

Ba màn hình, và chỉ ba: Tổng quan (hai thẻ Mã) · Biểu đồ (nến tuần + khung RSI) · Lịch sử tín hiệu.

**Từ 2026-11-13:** thêm *Vùng DCA theo Cẩm nang* (PRD §4.6, FR-14 → FR-19). Mỗi thẻ xếp tuần đã đóng vào 5 vùng (BTC 35/45/70/82, VNINDEX 32/40/68/76), gắn F&G crypto cho BTC, phát hiện phân kỳ giảm tuần, có dải cảnh báo riêng, bảng Cẩm nang (bottom sheet, không phải màn hình thứ tư), và lời nhắc cục bộ 09:30 sáng thứ Hai. Lý do và số liệu kiểm chứng nằm ở PRD §11.

Sản phẩm sinh ra từ quy trình **BMAD v6**. Tài liệu quy hoạch nằm ở `_bmad-output/planning-artifacts/` — brief, PRD, architecture spine, epics. **Đọc PRD và ARCHITECTURE-SPINE trước khi sửa bất cứ gì**; chúng là hợp đồng, không phải ghi chú.

**Đây KHÔNG phải app theo dõi danh mục đầu tư.** Không lãi lỗ, không số dư, không kết nối môi giới. Việc đó thuộc project `personal_finance` bên cạnh. Ở đây chỉ có *tín hiệu*, không có *tài sản*.

**App không tự đưa ra khuyến nghị.** Không chấm điểm, không xếp hạng, không tự nói "nên mua". Ngoại lệ duy nhất (người dùng chọn 2026-11-13): luật hành động **trích từ Cẩm nang của người dùng**, nằm ở `S.dcaRule()` và luôn hiện kèm `S.dcaQuotePrefix` ("Theo cẩm nang của bạn: "). Câu hành động ở bất kỳ chỗ nào khác vẫn là lỗi.

## Lệnh — luôn dùng tiền tố `fvm`

SDK ghim riêng qua FVM (`.fvmrc` → Flutter 3.38.10 / Dart 3.10.9). Máy còn bản 3.29.2 dùng chung cho các project eGOV khác, và bản đó **giải phụ thuộc thất bại** vì pubspec yêu cầu Dart `^3.10.9`.

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run
fvm dart run tool/doi_chieu.dart   # đối chiếu số liệu với nguồn thật
fvm dart run tool/phan_tich_dca.dart   # kiểm chứng Cẩm nang DCA trên dữ liệu thật (PRD §11)
```

Không có `build_runner`. Không có bước sinh mã nào.

## Quy tắc tuyệt đối

Bốn quy tắc dưới đây khi bị vi phạm sẽ hỏng theo kiểu **không báo lỗi** — app vẫn chạy, chỉ lặng lẽ cho ra con số sai. Đó là kiểu hỏng tệ nhất với một app mà người dùng ra quyết định tài chính dựa trên số của nó.

### 1. RSI và Tín hiệu không bao giờ được lưu

Cấm tuyệt đối các trường sau ở mọi nơi lưu trữ:

```
rsi   rsiValue   status   signals   lastRsi
```

```
rsi(t)     = Wilder(giá đóng cửa nến tuần, chu kỳ 14)
tín_hiệu(t) = rsi(t) cắt qua ngưỡng so với rsi(t-1), CHỈ trên nến đã đóng
```

Kho cục bộ chỉ giữ OHLCV, chuỗi F&G thô, mốc tín hiệu / Vùng DCA đã xem, và dấu thời gian cập nhật. Vùng DCA và cờ phân kỳ cũng thuộc loại "không bao giờ lưu" (AD-12). Nguồn dữ liệu có thể đính chính nến quá khứ; nếu RSI bị lưu cứng thì nó sẽ lệch khỏi chuỗi nến mà không ai biết. Xem AD-2.

Hàng rào: `test/architecture_test.dart`, `test/data/store_and_repository_test.dart`.

### 2. Nến đang chạy không bao giờ sinh tín hiệu

Nến tuần cuối cùng ở **cả hai nguồn** luôn là nến chưa đóng. RSI của nó nhảy liên tục và có thể quay đầu trước khi tuần kết thúc.

App vẫn hiển thị giá trị đó, nhưng phải kèm nhãn *tạm tính*, và `detectSignals` chỉ nhận chuỗi đã lọc `isClosed == true`. Một cảnh báo giả rồi bị rút lại phá hỏng lòng tin vào toàn bộ app. Xem AD-5.

### 3. Mốc thời gian nến giữ nguyên từ nguồn, luôn là UTC

Nến BTC theo tuần UTC từ thứ Hai 00:00. Nến VNINDEX theo tuần giao dịch Việt Nam, mốc thứ Hai 02:00 UTC (09:00 giờ Việt Nam). **Không ép hai bên về chung một mốc.**

`Candle.openTime` có `assert(openTime.isUtc)`. Chỉ tầng `ui/` mới đổi sang giờ Việt Nam để hiển thị, qua `lib/ui/format.dart`. Xem AD-3.

### 4. Biểu đồ đánh chỉ số theo vị trí nến, không theo trục thời gian

Chuỗi VNINDEX **thiếu hẳn tuần nghỉ Tết mỗi năm** — thị trường không giao dịch nên không có nến, và dữ liệu cũ 2007–2009 còn có khoảng trống lớn hơn. Một trục thời gian tuyến tính sẽ vẽ ra khoảng trắng giả ở mỗi dịp Tết.

`ChartViewport` đánh theo `startIndex` / `visibleCount` trên mảng nến. Giữ nguyên như vậy.

## Ranh giới tầng

```
ui/  →  app/  →  domain/  ←  data/
```

`lib/domain/` là **Dart thuần**: không `package:flutter`, không `package:http`, không `package:shared_preferences`. `test/architecture_test.dart` canh việc này và sẽ fail nếu vi phạm.

`ui/` không bao giờ chạm `data/`. `app/` là nơi duy nhất nối hai bên.

`MarketRepository` **không bao giờ ném lỗi ra ngoài**. Nó trả `SymbolData` với `staleness ∈ {fresh, stale, empty}`. Vì vậy `app/` và `ui/` không được dùng `try/catch` cho luồng dữ liệu, và không màn hình nào được trắng vì lỗi mạng. Xem AD-6.

## Nguồn dữ liệu — đã kiểm chứng 2026-09-04

| Mã | Nguồn | Ghi chú |
| --- | --- | --- |
| BTC | `data-api.binance.vision` | `api.binance.com` **không kết nối được** từ mạng này (kết nối bị ngắt). Đừng đổi sang host đó. |
| VNINDEX | `iboard-api.ssi.com.vn` (chính) | Hỗ trợ thẳng `resolution=W`. |
| VNINDEX | `dchart-api.vndirect.com.vn` (dự phòng) | Chỉ có `resolution=D`; adapter tự gộp thành tuần. Gọi với `W` sẽ trả chuỗi `"Not support resolution W"` kèm mã 200. |
| F&G (BTC) | `api.alternative.me/fng/` | Thêm 2026-11-13 (AD-13). Chỉ để tăng cường Vùng, hỏng thì bỏ qua. Không có nguồn F&G cho VNINDEX. |

**TCBS đã bị loại.** `apipubaws.tcbs.com.vn` trả HTTP 403 kèm trang thử thách Cloudflare kể cả với đầy đủ header trình duyệt. Đừng thêm lại.

Cả ba nguồn đều là API **không chính thức**. Một bên đổi đường dẫn là chuyện bình thường, không phải trường hợp ngoại lệ — đó là lý do có `MarketDataSource` và có nguồn dự phòng.

## Ràng buộc còn lại

- **Không thêm package biểu đồ.** Hai khung phải chia chung một `ChartViewport`; painter tự viết. AD-7.
- **Không codegen.** Không `build_runner`, `freezed`, `riverpod_generator` — `flutter_riverpod` 3.4.x cũng không dùng được vì nó đòi Dart ≥ 3.12. AD-8.
- **Không analytics, không crash reporting, không quảng cáo.** App không gửi gì ra ngoài ngoài bốn host ở bảng trên. NFR-4.
- **Hằng số 14 / 30 / 70 và mọi ngưỡng Vùng DCA / F&G chỉ nằm ở `lib/domain/constants.dart`.** AD-11, có test canh.
- **Lời nhắc tuần (AD-14):** port ở `domain/weekly_reminder.dart`, bản cài plugin ở `data/`. Provider mặc định là Noop để test chạy không cần plugin. Host native (super app và bản chạy riêng) đã có desugaring + receiver Android, delegate iOS — giữ nguyên.
- **Chuỗi hiển thị chỉ nằm ở `lib/ui/strings.dart`**, trừ nhãn Mã ở `market_symbol.dart`. Thông điệp chẩn đoán không thuộc phạm vi này. AD-10, có test canh.

## Ngoài phạm vi bản này

Đã cân nhắc và **cố tình bỏ**, đừng thêm lại nếu không có yêu cầu mới rõ ràng:

- Chạy nền, push từ server, backend. Lời nhắc thứ Hai là thông báo cục bộ, không mang Vùng; Vùng chỉ tính khi mở app.
- Ngưỡng tự đặt, thêm Mã, thêm khung thời gian, thêm chỉ báo ngoài RSI + F&G.
- Tài khoản, đồng bộ đám mây, đa ngôn ngữ.
