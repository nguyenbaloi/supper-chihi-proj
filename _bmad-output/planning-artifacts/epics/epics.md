---
stepsCompleted: [step-01, step-02, step-03, step-04]
inputDocuments:
  - '_bmad-output/planning-artifacts/prds/prd-rsi-alert-2026-09-04/prd.md'
  - '_bmad-output/planning-artifacts/architecture/architecture-rsi-alert-2026-09-04/ARCHITECTURE-SPINE.md'
---

# RSI Alert - Epic Breakdown

## Overview

Tài liệu này phân rã PRD và Architecture Spine thành các Epic và Story triển khai được. Thứ tự Epic là thứ tự thi công: mỗi Epic chỉ phụ thuộc vào các Epic trước nó.

## Requirements Inventory

### Functional Requirements

- **FR-1** Xem RSI tuần hiện tại của cả hai Mã
- **FR-2** Làm mới dữ liệu khi mở app và khi kéo xuống
- **FR-3** Hiển thị được khi không có mạng
- **FR-4** Phát hiện Tín hiệu cắt ngưỡng
- **FR-5** Hiện dải cảnh báo cho Tín hiệu mới
- **FR-6** Xem biểu đồ nến tuần
- **FR-7** Xem khung RSI kèm vạch ngưỡng
- **FR-8** Xem chi tiết một nến
- **FR-9** Xem danh sách Tín hiệu lịch sử
- **FR-10** Lấy Nến tuần BTC
- **FR-11** Lấy Nến tuần VNINDEX
- **FR-12** Lưu Nến tuần cục bộ
- **FR-13** Tính RSI(14) theo Wilder

### NonFunctional Requirements

- **NFR-1** Mở app tới lúc thấy số cũ từ Kho cục bộ < 1 giây
- **NFR-2** Biểu đồ cuộn mượt 60fps với 500 nến
- **NFR-3** Một Nguồn dữ liệu chết không làm crash hay chặn màn hình
- **NFR-4** Không gửi dữ liệu nào ra ngoài trừ lời gọi đọc dữ liệu thị trường
- **NFR-5** Toàn bộ giao diện tiếng Việt
- **NFR-6** Số phụ thuộc tối thiểu

### Additional Requirements

Ràng buộc kiến trúc bắt buộc: **AD-1** (`domain/` Dart thuần) · **AD-2** (RSI và Tín hiệu không bao giờ lưu) · **AD-3** (mốc thời gian giữ nguyên từ nguồn) · **AD-4** (adapter quyết định `isClosed`) · **AD-5** (Tín hiệu chỉ từ nến đã đóng) · **AD-6** (lỗi không vượt biên repository) · **AD-7** (biểu đồ tự vẽ, chung viewport) · **AD-8** (Riverpod không codegen) · **AD-9** (kho JSON phẳng) · **AD-10** (chuỗi tập trung) · **AD-11** (hằng số một nguồn).

### UX Design Requirements

Chưa có tài liệu UX riêng. Bố cục lấy từ PRD §4.1, §4.3, §4.4 và các User Journey UJ-1…UJ-4.

### FR Coverage Map

| FR | Story |
| --- | --- |
| FR-13 | 1.2 |
| FR-4 | 1.3 |
| FR-10 | 2.2 |
| FR-11 | 2.3, 2.4 |
| FR-12 | 2.5 |
| FR-3 | 2.6, 3.3 |
| FR-1 | 3.2 |
| FR-2 | 3.2, 3.3 |
| FR-5 | 3.4 |
| FR-6 | 4.2 |
| FR-7 | 4.3 |
| FR-8 | 4.4 |
| FR-9 | 5.1, 5.2 |

Mọi FR đều có ít nhất một Story. Không Story nào không truy về được một FR hoặc một AD.

## Epic List

1. **Nền móng và hạt nhân miền** — dựng khung project, hằng số, model, RSI Wilder, phát hiện tín hiệu. Không có UI. Kết thúc Epic là toàn bộ nghiệp vụ đã đúng và đã được test.
2. **Tầng dữ liệu** — ba adapter nguồn, kho cục bộ, repository có dự phòng và rơi về cache.
3. **Màn hình Tổng quan và cảnh báo** — màn hình đầu, hai thẻ, làm mới, dải Tín hiệu mới.
4. **Màn hình Chi tiết: biểu đồ nến và khung RSI** — hai painter chung viewport, cuộn/phóng đồng bộ, xem chi tiết nến.
5. **Lịch sử tín hiệu** — tab thứ ba, lọc theo Mã, điều hướng tới đúng tuần trên biểu đồ.
6. **Hoàn thiện và đối chiếu** — điều hướng ba tab, trạng thái rỗng, kiểm chứng số với TradingView, dọn dẹp.

---

## Epic 1: Nền móng và hạt nhân miền

Dựng bộ khung project và toàn bộ logic nghiệp vụ dưới dạng Dart thuần, có test, trước khi chạm tới mạng hay giao diện. Đây là phần duy nhất trong app mà một con số sai sẽ đi thẳng ra quyết định đầu tư của người dùng, nên nó được làm trước và làm kỹ nhất.

### Story 1.1: Bộ khung project và hàng rào kiến trúc

As a lập trình viên,
I want một project Flutter đã ghim SDK, đã khai báo đủ phụ thuộc, và có test canh gác ranh giới tầng,
So that mọi Story sau đó không thể vô tình phá vỡ AD-1.

**Acceptance Criteria:**

**Given** project `rsi_alert` vừa tạo
**When** chạy `fvm flutter pub get`
**Then** phụ thuộc giải xong với đúng danh sách ở §Stack của Architecture Spine
**And** `.fvmrc` ghim Flutter 3.38.10
**And** không có package biểu đồ nào trong `pubspec.yaml` (AD-7)
**And** không có `build_runner`, `freezed`, `riverpod_generator` (AD-8)

**Given** cây thư mục `lib/domain`, `lib/data`, `lib/app`, `lib/ui` đã tồn tại
**When** chạy `fvm flutter test test/architecture_test.dart`
**Then** test quét mọi file dưới `lib/domain/` và fail nếu thấy `import` của `package:flutter`, `package:http`, `package:shared_preferences`, hay bất kỳ `package:` nào ngoài `dart:` lõi
**And** test này pass trên cây thư mục hiện tại

**Given** `lib/domain/constants.dart`
**When** đọc file
**Then** nó khai báo `rsiPeriod = 14`, `oversoldThreshold = 30`, `overboughtThreshold = 70` (AD-11)

### Story 1.2: Tính RSI(14) theo Wilder

As a người dùng,
I want giá trị RSI app tính ra khớp với TradingView,
So that tôi tin được con số mình nhìn thấy và không ra quyết định trên dữ liệu sai.

Hiện thực **FR-13**. Ràng buộc: **AD-1**, **AD-11**.

**Acceptance Criteria:**

**Given** một chuỗi 200 nến tuần có giá đóng cửa xác định trong `test/fixtures/`
**When** gọi `computeRsi(closes)`
**Then** trả về danh sách `RsiPoint` có độ dài `closes.length - 14`
**And** giá trị đầu tiên ứng với nến thứ 15 và dùng trung bình cộng đơn giản của 14 mức tăng và 14 mức giảm đầu tiên
**And** mỗi giá trị sau dùng làm mượt Wilder `avg = (avg_trước * 13 + giá_trị_hiện_tại) / 14`

**Given** một chuỗi mọi nến đều tăng, không có nến giảm nào
**When** gọi `computeRsi(closes)`
**Then** mọi giá trị RSI bằng 100.0, không có `NaN`, không có `Infinity`

**Given** một chuỗi có đúng 14 nến hoặc ít hơn
**When** gọi `computeRsi(closes)`
**Then** trả về danh sách rỗng
**And** không ném lỗi

**Given** cùng một chuỗi đầu vào
**When** gọi `computeRsi` hai lần
**Then** kết quả giống hệt nhau
**And** hàm không đọc `DateTime.now()` và không gọi mạng (AD-1)

**Given** bộ dữ liệu đối chiếu thật trong `test/fixtures/` kèm giá trị RSI tham chiếu
**When** so sánh từng giá trị
**Then** sai lệch tuyệt đối ≤ 0.5 điểm cho mọi nến (SM-1)

### Story 1.3: Phát hiện Tín hiệu cắt ngưỡng

As a người dùng,
I want app chỉ báo tín hiệu tại đúng nến RSI *cắt qua* ngưỡng, và chỉ trên nến đã đóng,
So that tôi không bị dội cảnh báo lặp lại suốt một đợt giảm dài, và không bị cảnh báo giả rồi bị rút lại.

Hiện thực **FR-4**. Ràng buộc: **AD-2**, **AD-5**, **AD-11**.

**Acceptance Criteria:**

**Given** chuỗi nến đã đóng có RSI lần lượt 35, 28, 26, 31
**When** gọi `detectSignals(candles)`
**Then** trả về đúng **một** Tín hiệu loại `oversold` tại nến có RSI 28
**And** nến RSI 26 không sinh Tín hiệu

**Given** chuỗi nến đã đóng có RSI lần lượt 65, 72, 75, 68, 73
**When** gọi `detectSignals(candles)`
**Then** trả về **hai** Tín hiệu loại `overbought`, tại nến RSI 72 và tại nến RSI 73

**Given** một chuỗi trong đó nến cuối cùng có `isClosed == false` và RSI của nó là 24
**When** gọi `detectSignals(candles)`
**Then** không có Tín hiệu nào ứng với nến đó (AD-5)

**Given** một chuỗi mà nến đầu tiên có RSI đã dưới 30
**When** gọi `detectSignals(candles)`
**Then** nến đó không sinh Tín hiệu vì không có nến liền trước để so

**Given** một Tín hiệu trả về
**When** kiểm tra các trường của nó
**Then** nó có `symbol`, `type`, `weekOpenTime`, `closePrice`, `rsiValue`
**And** không có nơi nào trong `domain/` ghi Tín hiệu xuống bộ nhớ lâu dài (AD-2)

### Story 1.4: Model Candle, MarketSymbol và RsiStatus

As a lập trình viên,
I want các model miền cố định hình dạng dữ liệu và cách suy ra Trạng thái,
So that bốn tầng không tự định nghĩa lại cùng một khái niệm theo cách lệch nhau.

Ràng buộc: **AD-1**, **AD-2**, **AD-3**, **AD-4**, **AD-11**.

**Acceptance Criteria:**

**Given** `lib/domain/candle.dart`
**When** dựng một `Candle`
**Then** nó có `openTime` kiểu `DateTime` luôn `isUtc == true`, cùng `open`, `high`, `low`, `close`, `volume`, `isClosed`
**And** dựng `Candle` với `DateTime` không phải UTC thì ném `AssertionError` (AD-3)

**Given** `lib/domain/market_symbol.dart`
**When** đọc file
**Then** có `enum MarketSymbol { btc, vnindex }` kèm nhãn hiển thị tiếng Việt và mã kho lưu trữ
**And** không có chuỗi `"BTC"` hay `"VNINDEX"` thô nào ở `domain/` ngoài file này

**Given** một giá trị RSI
**When** gọi `RsiStatus.from(value)`
**Then** `value < 30` cho `oversold`, `30 <= value <= 70` cho `neutral`, `value > 70` cho `overbought`, `null` cho `insufficientData`
**And** hàm dùng hằng số từ `constants.dart`, không dùng literal (AD-11)

---

## Epic 2: Tầng dữ liệu

Lấy nến tuần thật từ ba nguồn HTTP, lưu cục bộ, và gói tất cả sau một repository không bao giờ ném lỗi ra ngoài. Cả ba nguồn đều là API không chính thức, nên Epic này thiết kế cho việc **một nguồn chết là chuyện bình thường**, không phải trường hợp ngoại lệ.

### Story 2.1: Interface nguồn dữ liệu và phân loại lỗi

As a lập trình viên,
I want mọi nguồn dữ liệu nằm sau một interface chung và ném cùng một kiểu lỗi có phân loại,
So that đổi nguồn hoặc thêm nguồn dự phòng không lan ra ngoài tầng `data/`.

Ràng buộc: **AD-6**.

**Acceptance Criteria:**

**Given** `lib/data/market_data_source.dart`
**When** đọc file
**Then** có `abstract class MarketDataSource` với `Future<List<Candle>> fetchWeekly()` và một `String get name`
**And** có `MarketDataException` mang `kind ∈ {network, http, parse, empty}` cùng thông điệp

**Given** bất kỳ adapter nào
**When** nó gặp lỗi
**Then** nó ném `MarketDataException` với `kind` đúng loại
**And** không adapter nào trả về danh sách rỗng để biểu đạt lỗi (AD-6)

### Story 2.2: Adapter Binance cho BTC

As a người dùng,
I want app lấy được nến tuần Bitcoin,
So that tôi thấy RSI tuần của BTC.

Hiện thực **FR-10**. Ràng buộc: **AD-3**, **AD-4**.

**Acceptance Criteria:**

**Given** adapter Binance
**When** nó gọi mạng
**Then** nó gọi `GET https://data-api.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1w&limit=1000`
**And** **không** gọi `api.binance.com` — host đó không kết nối được từ mạng người dùng

**Given** phản hồi mẫu thật từ Binance trong `test/fixtures/binance_klines_1w.json`
**When** adapter phân tích nó
**Then** mỗi phần tử mảng ánh xạ `[0]→openTime`, `[1]→open`, `[2]→high`, `[3]→low`, `[4]→close`, `[5]→volume`, `[6]→closeTime`
**And** `openTime` là `DateTime` UTC dựng từ mili-giây
**And** `isClosed` bằng `closeTime < thời điểm hiện tại` (AD-4)
**And** nến cuối cùng có `isClosed == false` khi tuần chưa kết thúc

**Given** HTTP trả mã khác 200
**When** adapter xử lý
**Then** nó ném `MarketDataException(kind: http)`

**Given** thân phản hồi không phải JSON hợp lệ hoặc sai hình dạng
**When** adapter xử lý
**Then** nó ném `MarketDataException(kind: parse)`

### Story 2.3: Adapter SSI cho VNINDEX

As a người dùng,
I want app lấy được nến tuần VNINDEX,
So that tôi thấy RSI tuần của chỉ số chứng khoán Việt Nam.

Hiện thực **FR-11** (nguồn chính). Ràng buộc: **AD-3**, **AD-4**.

**Acceptance Criteria:**

**Given** adapter SSI
**When** nó gọi mạng
**Then** nó gọi `GET https://iboard-api.ssi.com.vn/statistics/charts/history` với `symbol=VNINDEX`, `resolution=W`, `from`, `to`
**And** khoảng `from` lùi đủ để lấy ít nhất 300 nến tuần

**Given** phản hồi mẫu thật trong `test/fixtures/ssi_vnindex_w.json` dạng `{"code":"SUCCESS","data":{"t":[],"o":[],"h":[],"l":[],"c":[],"v":[]}}`
**When** adapter phân tích nó
**Then** sáu mảng song song được ghép thành danh sách `Candle` theo đúng thứ tự chỉ số
**And** `openTime` dựng từ epoch **giây** nhân 1000, `isUtc: true`
**And** `isClosed` bằng `openTime + 7 ngày < thời điểm hiện tại` (AD-4)

**Given** phản hồi có `code` khác `"SUCCESS"`
**When** adapter xử lý
**Then** nó ném `MarketDataException(kind: http)` để repository chuyển sang dự phòng

**Given** các mảng `t`, `o`, `h`, `l`, `c` có độ dài không bằng nhau
**When** adapter xử lý
**Then** nó ném `MarketDataException(kind: parse)`

**Given** mảng `t` rỗng
**When** adapter xử lý
**Then** nó ném `MarketDataException(kind: empty)`

### Story 2.4: Adapter VNDirect dự phòng, gộp nến ngày thành tuần

As a người dùng,
I want app vẫn có dữ liệu VNINDEX khi SSI hỏng,
So that một nhà cung cấp đổi API không làm chết nửa số tính năng của app.

Hiện thực **FR-11** (dự phòng). Ràng buộc: **AD-3**, **AD-4**.

**Acceptance Criteria:**

**Given** adapter VNDirect
**When** nó gọi mạng
**Then** nó gọi `GET https://dchart-api.vndirect.com.vn/dchart/history` với `symbol=VNINDEX` và `resolution=D`
**And** **không** dùng `resolution=W` — VNDirect trả `"Not support resolution W"`

**Given** một chuỗi nến ngày trải qua nhiều tuần
**When** adapter gộp chúng thành nến tuần
**Then** mỗi tuần bắt đầu từ thứ Hai theo giờ Việt Nam (UTC+7)
**And** giá mở của tuần là giá mở của ngày giao dịch **đầu tiên** trong tuần đó
**And** giá đóng của tuần là giá đóng của ngày giao dịch **cuối cùng** trong tuần đó
**And** giá cao là max mọi giá cao trong tuần, giá thấp là min mọi giá thấp
**And** khối lượng là tổng khối lượng trong tuần

**Given** một tuần chỉ có hai ngày giao dịch vì nghỉ lễ
**When** adapter gộp
**Then** tuần đó vẫn tạo ra đúng một nến từ hai ngày có sẵn, không bị bỏ qua và không chèn ngày rỗng

**Given** cùng một khoảng thời gian
**When** so nến tuần gộp từ VNDirect với nến tuần trực tiếp từ SSI trong `test/fixtures/`
**Then** giá đóng cửa mỗi tuần lệch không quá 0.5 điểm

### Story 2.5: Kho nến cục bộ

As a người dùng,
I want app nhớ dữ liệu lần trước,
So that mở app lúc không mạng vẫn xem được, và mở app lúc có mạng thì thấy số ngay lập tức thay vì chờ.

Hiện thực **FR-12**. Ràng buộc: **AD-2**, **AD-9**.

**Acceptance Criteria:**

**Given** một chuỗi nến vừa tải về cho một Mã
**When** gọi `CandleStore.save(symbol, candles, fetchedAt)`
**Then** `shared_preferences` có khoá `candles.<symbol>` chứa `{"v":1,"fetchedAt":<epoch>,"candles":[...]}`
**And** JSON đó **không** chứa trường `rsi`, `status`, hay `signals` nào (AD-2)

**Given** kho đã có 500 nến của một Mã
**When** gọi `save` với 480 nến mới
**Then** kho chứa đúng 480 nến — thay toàn bộ, không merge (AD-9)

**Given** khoá lưu trữ có `"v"` khác 1
**When** gọi `CandleStore.load(symbol)`
**Then** trả về `null`
**And** không ném lỗi, không cố nâng cấp dữ liệu

**Given** một `Candle` đi qua `save` rồi `load`
**When** so sánh với bản gốc
**Then** mọi trường bằng nhau, `openTime` vẫn `isUtc == true`

**Given** mốc tín hiệu đã xem của một Mã
**When** gọi `saveLastSeenSignal` rồi `loadLastSeenSignal`
**Then** giá trị sống qua lần khởi động lại app

### Story 2.6: Repository điều phối nguồn và kho

As a người dùng,
I want app luôn hiện được cái gì đó dù mạng hay nhà cung cấp có vấn đề,
So that tôi không bao giờ gặp màn hình trắng hay hộp thoại lỗi chặn đường.

Hiện thực **FR-2**, **FR-3**. Ràng buộc: **AD-6**.

**Acceptance Criteria:**

**Given** `MarketRepository.load(symbol)`
**When** gọi trong bất kỳ tình huống nào, kể cả mọi nguồn đều chết
**Then** nó **không bao giờ** ném lỗi ra ngoài (AD-6)
**And** trả về `SymbolData` gồm `candles`, `fetchedAt`, `staleness`, `errorKind` tuỳ chọn

**Given** nguồn chính trả dữ liệu thành công
**When** `load` chạy xong
**Then** `staleness == fresh`
**And** kho cục bộ đã được ghi đè bằng dữ liệu mới

**Given** Mã là `vnindex` và nguồn SSI ném lỗi
**When** `load` chạy
**Then** nó thử tiếp VNDirect
**And** VNDirect thành công thì `staleness == fresh`

**Given** mọi nguồn của một Mã đều ném lỗi và kho cục bộ có dữ liệu
**When** `load` chạy
**Then** trả về nến từ kho với `staleness == stale` và `fetchedAt` của lần thành công gần nhất
**And** `errorKind` phản ánh lỗi cuối cùng gặp phải

**Given** mọi nguồn đều lỗi và kho cục bộ rỗng
**When** `load` chạy
**Then** trả về danh sách nến rỗng với `staleness == empty`

**Given** cả hai Mã cùng được yêu cầu
**When** tầng trên gọi `load` cho cả hai
**Then** hai lời gọi chạy song song, và một bên lỗi không chặn bên còn lại (NFR-3)

---

## Epic 3: Màn hình Tổng quan và cảnh báo

Màn hình người dùng gặp nhiều nhất, và trong đa số trường hợp nó phải nói "không có gì xảy ra" thật nhanh rồi để người dùng đi (UJ-1). Epic này cũng làm phần cảnh báo — thứ duy nhất trong app chủ động nói với người dùng.

### Story 3.1: Provider Riverpod và bộ điều phối màn hình Tổng quan

As a lập trình viên,
I want trạng thái màn hình Tổng quan nằm trong một controller Riverpod duy nhất,
So that widget không giữ logic nghiệp vụ và luồng tải dữ liệu chỉ có một chỗ để đọc.

Ràng buộc: **AD-2**, **AD-8**.

**Acceptance Criteria:**

**Given** `lib/app/providers.dart`
**When** đọc file
**Then** provider được khai báo thủ công bằng `NotifierProvider` / `Provider` / `FutureProvider`
**And** không có annotation `@riverpod` và không có file `.g.dart` nào (AD-8)

**Given** `OverviewController`
**When** nó dựng trạng thái cho một Mã
**Then** nó gọi `computeRsi` và `detectSignals` tại thời điểm dựng, từ chuỗi nến (AD-2)
**And** trạng thái của nó không chứa trường RSI nào được đọc từ kho lưu trữ

**Given** controller vừa khởi tạo
**When** app khởi động
**Then** nó phát ra trạng thái từ kho cục bộ trước, rồi cập nhật lại khi mạng xong (NFR-1)

### Story 3.2: Hai thẻ Mã trên màn hình Tổng quan

As a người dùng,
I want mở app là thấy ngay RSI tuần và Trạng thái của cả BTC lẫn VNINDEX,
So that tôi biết tình hình trong vài giây rồi đóng app.

Hiện thực **FR-1**, **FR-2**. Realizes UJ-1. Ràng buộc: **AD-10**.

**Acceptance Criteria:**

**Given** dữ liệu đã tải cho cả hai Mã
**When** màn hình Tổng quan hiển thị
**Then** có đúng hai thẻ, BTC ở trên, VNINDEX ở dưới, thứ tự không đổi theo trạng thái
**And** mỗi thẻ hiện tên Mã, giá đóng cửa nến mới nhất, RSI làm tròn một chữ số thập phân, và nhãn Trạng thái

**Given** nhãn Trạng thái
**When** hiển thị
**Then** dùng đúng từ ở Từ điển PRD: `Quá bán`, `Trung tính`, `Quá mua`, `Chưa đủ dữ liệu` (AD-10)
**And** mỗi trạng thái có màu riêng phân biệt được

**Given** nến mới nhất là nến đang chạy
**When** thẻ hiển thị RSI của nó
**Then** thẻ hiện thêm nhãn phụ `tạm tính`

**Given** chuỗi nến có ít hơn 15 phần tử
**When** thẻ hiển thị
**Then** hiện `Chưa đủ dữ liệu` và không hiện số RSI

**Given** người dùng kéo xuống trên danh sách thẻ
**When** cử chỉ hoàn tất
**Then** app tải lại cả hai Mã
**And** trong lúc tải, dữ liệu cũ vẫn hiển thị bên dưới chỉ báo tải, không bị thay bằng màn hình trống

**Given** app đang mở và người dùng không thao tác gì
**When** thời gian trôi qua
**Then** app **không** tự tải lại theo chu kỳ

### Story 3.3: Hiển thị khi ngoại tuyến và khi dữ liệu cũ

As a người dùng,
I want app nói rõ tôi đang nhìn số cũ thay vì báo lỗi hoặc hiện màn hình trắng,
So that tôi vẫn dùng được app khi không có mạng và biết mình đang nhìn cái gì.

Hiện thực **FR-3**. Realizes UJ-3. Ràng buộc: **AD-6**.

**Acceptance Criteria:**

**Given** `staleness == stale`
**When** màn hình hiển thị
**Then** thẻ vẫn hiện dữ liệu cũ đầy đủ
**And** có dòng chú thích ghi dấu thời gian lần cập nhật gần nhất kèm ghi chú chưa cập nhật được
**And** **không** có `AlertDialog` hay `SnackBar` chặn thao tác nào xuất hiện

**Given** `staleness == empty`
**When** màn hình hiển thị
**Then** thẻ hiện trạng thái rỗng kèm nút thử lại
**And** nút thử lại gọi lại `load` cho đúng Mã đó

**Given** một Mã lỗi và Mã kia thành công
**When** màn hình hiển thị
**Then** Mã thành công hiện bình thường, không bị ảnh hưởng (NFR-3)

**Given** thiết bị bật chế độ máy bay
**When** người dùng mở màn hình Chi tiết và tab Lịch sử
**Then** cả hai mở được và cuộn được đầy đủ trên dữ liệu cục bộ

### Story 3.4: Dải cảnh báo Tín hiệu mới

As a người dùng,
I want app nói thẳng vào mặt tôi khi RSI tuần vừa cắt ngưỡng,
So that tôi không bỏ lỡ tín hiệu chỉ vì không nghĩ ra việc phải đi tìm nó.

Hiện thực **FR-5**. Realizes UJ-2, UJ-4. Ràng buộc: **AD-5**, **AD-9**, **AD-10**.

**Acceptance Criteria:**

**Given** Tín hiệu cuối cùng của một Mã có mốc tuần muộn hơn mốc đã xem đã lưu
**When** màn hình Tổng quan hiển thị
**Then** một dải cảnh báo hiện ở trên cùng, ghi tên Mã, loại Tín hiệu, giá trị RSI, và mốc tuần

**Given** cả hai Mã đều có Tín hiệu mới
**When** màn hình hiển thị
**Then** hiện hai dải, dải của BTC nằm trên

**Given** người dùng chạm vào dải
**When** thao tác hoàn tất
**Then** mở màn hình Chi tiết của Mã đó
**And** mốc đã xem của Mã đó được ghi bằng mốc tuần của Tín hiệu
**And** dải không hiện lại ở các lần mở app sau, kể cả sau khi tải lại dữ liệu

**Given** đây là lần chạy đầu tiên sau khi cài app và dữ liệu có 40 Tín hiệu lịch sử
**When** dữ liệu tải xong lần đầu
**Then** **không** dải cảnh báo nào hiện ra
**And** mốc đã xem được khởi tạo bằng mốc tuần của Tín hiệu cuối cùng tìm thấy

**Given** RSI tạm tính của nến đang chạy đã xuống dưới 30 nhưng nến chưa đóng
**When** màn hình Tổng quan hiển thị
**Then** **không** có dải cảnh báo nào cho tình huống đó (AD-5)

---

## Epic 4: Màn hình Chi tiết — biểu đồ nến và khung RSI

Nơi người dùng tự nhìn bối cảnh thay vì tin app. Ràng buộc khó nhất của Epic này là hai khung phải cuộn và phóng đồng bộ tuyệt đối — lệch một cột là biểu đồ nói dối.

### Story 4.1: ChartViewport dùng chung

As a lập trình viên,
I want một đối tượng viewport duy nhất mô tả cửa sổ thời gian đang xem,
So that khung giá và khung RSI không thể lệch trục thời gian.

Ràng buộc: **AD-7**.

**Acceptance Criteria:**

**Given** `ChartViewport`
**When** đọc định nghĩa
**Then** nó bất biến và mang `startIndex` cùng `visibleCount`
**And** nó có `copyWith` và `==` tự cài (AD-8)

**Given** một thao tác cuộn hoặc phóng
**When** viewport cập nhật
**Then** `startIndex` bị kẹp trong `[0, totalCandles - visibleCount]`
**And** `visibleCount` bị kẹp trong `[20, totalCandles]`
**And** không thể cuộn ra ngoài hai biên dữ liệu

**Given** màn hình Chi tiết vừa mở
**When** viewport khởi tạo
**Then** `visibleCount == 60` hoặc bằng tổng số nến nếu ít hơn
**And** `startIndex` đặt sao cho nến mới nhất nằm sát mép phải

### Story 4.2: Painter biểu đồ nến tuần

As a người dùng,
I want nhìn thấy biểu đồ nến tuần và cuộn về quá khứ,
So that tôi tự đánh giá được bối cảnh giá quanh mỗi tín hiệu.

Hiện thực **FR-6**. Realizes UJ-2, UJ-4. Ràng buộc: **AD-3**, **AD-7**.

**Acceptance Criteria:**

**Given** một chuỗi nến và một `ChartViewport`
**When** painter vẽ
**Then** chỉ các nến trong cửa sổ được vẽ
**And** nến có `close >= open` và nến có `close < open` khác màu nhau
**And** mỗi nến vẽ đủ thân và bóng trên/dưới

**Given** cửa sổ hiện tại
**When** painter tính trục dọc
**Then** khoảng giá lấy từ min/max của **các nến đang trong cửa sổ**, không phải toàn chuỗi

**Given** nến có `isClosed == false`
**When** painter vẽ nó
**Then** nó khác biệt về thị giác so với nến đã đóng
**And** màn hình hiện nhãn nêu rõ đó là tuần đang chạy (AD-5)

**Given** 500 nến trong chuỗi
**When** người dùng cuộn ngang liên tục
**Then** khung hình giữ ở 60fps trên máy tầm trung (NFR-2)
**And** `shouldRepaint` chỉ trả `true` khi viewport hoặc dữ liệu thực sự đổi

### Story 4.3: Painter khung RSI với vạch ngưỡng

As a người dùng,
I want thấy đường RSI ngay dưới biểu đồ giá với hai vạch 30 và 70,
So that tôi thấy được đường đó đã cắt ngưỡng bao nhiêu lần và giá phản ứng ra sao sau đó.

Hiện thực **FR-7**. Realizes UJ-2, UJ-4. Ràng buộc: **AD-7**, **AD-11**.

**Acceptance Criteria:**

**Given** khung RSI
**When** painter vẽ
**Then** trục dọc cố định 0–100, không co giãn theo dữ liệu
**And** hai vạch ngang tại 30 và 70 luôn hiển thị kèm nhãn số
**And** hai giá trị đó lấy từ `constants.dart` (AD-11)

**Given** khung RSI và khung giá cùng trên màn hình
**When** người dùng cuộn hoặc phóng ở bất kỳ khung nào
**Then** cả hai khung cập nhật theo cùng một `ChartViewport`
**And** một cột thời gian nằm ở cùng toạ độ ngang trên cả hai khung

**Given** 14 nến đầu chuỗi chưa có giá trị RSI
**When** painter vẽ đoạn đó
**Then** không vẽ đường ở đó
**And** không vẽ giá trị 0 (AD-2)

**Given** một nến đã đóng có Tín hiệu
**When** painter vẽ
**Then** vị trí đó được đánh dấu nhận biết được trên khung RSI

### Story 4.4: Xem chi tiết một nến

As a người dùng,
I want chạm vào biểu đồ để xem số liệu chính xác của tuần đó,
So that tôi đọc được giá và RSI cụ thể thay vì ước lượng bằng mắt.

Hiện thực **FR-8**. Ràng buộc: **AD-7**.

**Acceptance Criteria:**

**Given** người dùng chạm và giữ tại một vị trí trên khung giá hoặc khung RSI
**When** cử chỉ đang diễn ra
**Then** hiện mốc tuần, giá mở/cao/thấp/đóng, và giá trị RSI của đúng nến tại vị trí đó
**And** một đường chỉ dấu dọc hiện đồng thời trên **cả hai** khung tại cùng mốc thời gian

**Given** người dùng bỏ tay ra
**When** cử chỉ kết thúc
**Then** phần hiển thị chi tiết và đường chỉ dấu biến mất

**Given** mốc tuần hiển thị
**When** định dạng ngày
**Then** dùng `intl` theo giờ `Asia/Ho_Chi_Minh` (AD-3)

---

## Epic 5: Lịch sử tín hiệu

Thứ cho phép người dùng tự chấm điểm phương pháp thay vì tin app. Toàn bộ danh sách sinh ra từ chuỗi nến đang có, không có bảng riêng nào để lệch.

### Story 5.1: Danh sách Tín hiệu lịch sử

As a người dùng,
I want xem lại mọi lần RSI tuần đã chạm ngưỡng trong quá khứ,
So that tôi tự đánh giá được tín hiệu lần này đáng tin đến đâu.

Hiện thực **FR-9**. Realizes UJ-2. Ràng buộc: **AD-2**, **AD-5**.

**Acceptance Criteria:**

**Given** dữ liệu của cả hai Mã đã tải
**When** mở tab Lịch sử
**Then** hiện danh sách Tín hiệu của cả hai Mã trộn chung, xếp theo mốc tuần **giảm dần**
**And** mỗi dòng hiện Mã, loại Tín hiệu, mốc tuần, giá đóng cửa tuần đó, và giá trị RSI tuần đó

**Given** danh sách đang hiển thị
**When** kiểm tra nguồn gốc dữ liệu
**Then** nó sinh ra từ `detectSignals` trên chuỗi nến hiện có, không đọc từ bảng lưu trữ nào (AD-2)

**Given** xoá toàn bộ dữ liệu app rồi tải lại
**When** so sánh danh sách Tín hiệu trước và sau
**Then** hai danh sách giống hệt nhau

**Given** không có Tín hiệu nào trong dữ liệu
**When** tab Lịch sử hiển thị
**Then** hiện trạng thái rỗng giải thích rằng Tín hiệu RSI tuần vốn hiếm
**And** không hiện như một lỗi

### Story 5.2: Lọc theo Mã và điều hướng tới biểu đồ

As a người dùng,
I want lọc lịch sử theo từng Mã và nhảy thẳng từ một tín hiệu sang đúng tuần trên biểu đồ,
So that tôi xem được giá phản ứng thế nào sau tín hiệu đó mà không phải tự đi tìm.

Hiện thực **FR-9**.

**Acceptance Criteria:**

**Given** bộ lọc trên tab Lịch sử
**When** người dùng chọn một Mã
**Then** chỉ Tín hiệu của Mã đó hiển thị
**And** có lựa chọn quay về xem tất cả

**Given** người dùng chạm vào một dòng Tín hiệu
**When** thao tác hoàn tất
**Then** mở màn hình Chi tiết của Mã đó
**And** `ChartViewport` đặt sao cho tuần của Tín hiệu nằm trong cửa sổ hiển thị

---

## Epic 6: Hoàn thiện và đối chiếu

Ghép ba màn hình lại, rồi làm việc quan trọng nhất còn lại: **chứng minh các con số đúng**. Một app RSI cho số sai thì tệ hơn hẳn không có app.

### Story 6.1: Điều hướng ba tab và chủ đề giao diện

As a người dùng,
I want di chuyển giữa ba màn hình bằng thanh tab dưới,
So that mọi thứ app làm đều nằm trong tầm một lần chạm.

Ràng buộc: **AD-10**.

**Acceptance Criteria:**

**Given** app khởi động
**When** màn hình đầu hiện ra
**Then** có thanh điều hướng dưới với ba mục: Tổng quan, Biểu đồ, Lịch sử
**And** nhãn tiếng Việt lấy từ `strings.dart` (AD-10, NFR-5)

**Given** người dùng chuyển tab qua lại
**When** quay lại tab Biểu đồ
**Then** `ChartViewport` giữ nguyên vị trí đang xem

**Given** thiết bị ở chế độ tối
**When** app hiển thị
**Then** màu chữ và nền tương phản đọc được ở cả chế độ sáng lẫn tối
**And** ba màu Trạng thái phân biệt được ở cả hai chế độ

### Story 6.2: Đối chiếu số với TradingView

As a người dùng,
I want có bằng chứng RSI của app khớp với công cụ tôi vẫn tin,
So that tôi dám dùng app này thay cho việc mở TradingView.

Hiện thực **SM-1**, **SM-2**.

**Acceptance Criteria:**

**Given** 20 nến tuần gần nhất của BTC
**When** đối chiếu RSI app với TradingView
**Then** mọi giá trị lệch không quá 0.5 điểm (SM-1)

**Given** 20 nến tuần gần nhất của VNINDEX
**When** đối chiếu tương tự
**Then** mọi giá trị lệch không quá 0.5 điểm (SM-1)

**Given** ba năm dữ liệu gần nhất của mỗi Mã
**When** đối chiếu Lịch sử tín hiệu của app với các lần cắt ngưỡng trên biểu đồ TradingView
**Then** không sót lần nào và không thừa lần nào (SM-2)

**Given** kết quả đối chiếu
**When** hoàn tất
**Then** ghi lại thành `docs/doi-chieu-so-lieu.md` kèm ngày kiểm và dữ liệu đã dùng

### Story 6.3: Dọn dẹp và kiểm tra ràng buộc cuối

As a lập trình viên,
I want mọi ràng buộc kiến trúc và mọi Non-Goal được kiểm lại trước khi coi là xong,
So that app không âm thầm phình ra ngoài thứ đã cam kết ở PRD.

Ràng buộc: **AD-1**, **AD-2**, **AD-7**, **AD-8**, **AD-10**, **NFR-4**, **NFR-6**.

**Acceptance Criteria:**

**Given** toàn bộ mã nguồn
**When** chạy `fvm flutter analyze`
**Then** không có cảnh báo và không có lỗi

**Given** toàn bộ test
**When** chạy `fvm flutter test`
**Then** tất cả pass

**Given** cây phụ thuộc
**When** kiểm tra
**Then** không có package analytics, crash reporting, quảng cáo, hay biểu đồ nào (NFR-4, NFR-6, AD-7)
**And** app không gọi mạng tới host nào ngoài `data-api.binance.vision`, `iboard-api.ssi.com.vn`, `dchart-api.vndirect.com.vn` (NFR-4)

**Given** toàn bộ `lib/`
**When** tìm chuỗi tiếng Việt hiển thị
**Then** mọi chuỗi đều nằm trong `strings.dart` (AD-10)

**Given** toàn bộ `lib/` trong ngữ cảnh RSI
**When** tìm literal `14`, `30`, `70`
**Then** chúng chỉ xuất hiện trong `constants.dart` (AD-11)
