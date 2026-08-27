# CLAUDE.md

Hướng dẫn cho Claude Code khi làm việc trong project này.

## Sản phẩm

App Flutter theo dõi **danh mục đầu tư cá nhân** — thay thế hệ thống Excel hai sheet người dùng đã duy trì hơn một năm. Năm lớp tài sản: Chứng khoán, Vàng, Crypto, Tiền mặt & Tiết kiệm, Cho vay.

**Đây KHÔNG phải app sổ thu chi hằng ngày.** Không ghi nhận việc mua ly cà phê. Nếu một yêu cầu nghe giống chi tiêu hằng ngày, hãy hỏi lại trước khi làm.

## Lệnh — luôn dùng tiền tố `fvm`

SDK được ghim riêng cho project này qua FVM (`.fvmrc` → Flutter 3.38.10 / Dart 3.10.9). Máy còn có bản 3.29.2 dùng chung cho các project eGOV khác.

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run
fvm dart run build_runner build --delete-conflicting-outputs
```

Chạy `flutter` trần sẽ dùng bản 3.29.2 và **giải phụ thuộc thất bại** vì pubspec yêu cầu Dart `^3.10.9`.

## Quy tắc tuyệt đối

Bốn quy tắc dưới đây sinh ra từ lỗi có thật trong hệ thống Excel gốc. Vi phạm chúng làm hỏng tính đúng đắn của toàn bộ sản phẩm, và hỏng theo kiểu **không báo lỗi** — chỉ lặng lẽ cho ra con số sai.

### 1. Cấm `double` trong mọi phép tính tài chính

- **Lưu trữ:** tiền là `int` đơn vị đồng. Số lượng là `int` đã nhân hệ số, kèm cột `decimals`.
- **Tính toán:** chuyển sang `Decimal` (gói `decimal`) trước khi nhân chia.
- **Hiển thị:** làm tròn duy nhất một lần, ở lớp định dạng.

Từ khóa `double` không được xuất hiện trong `lib/domain/` và trong bất kỳ cột bảng Drift nào. Ngoại lệ duy nhất: toạ độ vẽ biểu đồ trong `lib/presentation/`.

BTC cần 8 chữ số thập phân, vàng 2 (đơn vị **chỉ**), cổ phiếu là số nguyên.

### 2. Vốn góp lũy kế không bao giờ lưu cứng

Cơ sở dữ liệu chỉ lưu số tiền từng `CashFlow` và một `initialContributionAmount` duy nhất trong bảng thiết lập.

```
vốn_góp_lũy_kế(t) = vốn_góp_khởi_điểm + tổng(CashFlow có ngày ≤ t)
lãi_lỗ(t)         = giá_trị_nhóm_đầu_tư(t) − vốn_góp_lũy_kế(t)
```

**Không được tạo cột `cumulativeContribution` ở bất kỳ bảng nào.** Người dùng sửa và xóa được dòng vốn quá khứ, kể cả đổi ngày — mọi giá trị phía sau phải tự đúng theo.

Nhóm đầu tư mặc định gồm đúng hai lớp: Chứng khoán và Crypto. Vàng và tiền mặt bị loại trừ.

### 3. Giá trị tổng hợp luôn suy ra, không nhập tay

- Giá trị `AssetClass` = tổng các `Holding` thuộc nó
- Riêng lớp `lending` = tổng ròng các `Debt` đang hiệu lực
- Tổng tài sản = tổng các `AssetClass` không bị ẩn

Không tạo cột lưu tổng, không tạo màn hình cho phép sửa trực tiếp các con số này. Đây là lỗi `133 + 50 = 183` cộng thủ công trong Excel gốc — mục đích của app là triệt tiêu nó.

### 4. Mạng chỉ được dùng để hỏi giá

Mọi lời gọi mạng nằm trong `lib/data/remote/`. Nội dung gửi đi chỉ chứa ký hiệu tài sản và mã tiền tệ.

**Cấm gửi số lượng nắm giữ, giá trị, hay bất kỳ định danh người dùng nào.** Không thêm công cụ phân tích hành vi, không thu thập số liệu sử dụng, không quảng cáo. Không có backend, không tài khoản, không đồng bộ.

Lỗi mạng không bao giờ được chặn thao tác — luôn dùng giá lưu gần nhất kèm nhãn thời gian.

## Cấu trúc mã nguồn

```
lib/
  core/        money · result · format · l10n
  domain/      models · rules · repositories (chỉ hợp đồng trừu tượng)
  data/        db (drift) · remote · repositories (cài đặt)
  features/    onboarding · dashboard · asset_class · targets
               capital · history · debts · notes · settings
  presentation/ providers · widgets
```

**Hướng phụ thuộc một chiều:** `presentation → domain ← data`.

File trong `domain/` không được `import` bất cứ thứ gì từ `package:flutter`, `package:drift`, `package:http`, hay từ `data/` và `presentation/`. Đây là điều kiện để test toàn bộ công thức tài chính mà không cần dựng giả lập.

## Ngăn xếp

Riverpod 3.3.2 · drift 2.31.0 · drift_flutter 0.2.8 · decimal 3.2.6 · fl_chart 1.2.0 · intl 0.20.2

**Không dùng code generation của Riverpod.** `riverpod_generator` cần `analyzer ^9/^12` còn `drift_dev` cần `^10/^13` — loại trừ nhau dưới Dart 3.10.9. Provider khai báo thủ công dưới dạng biến `final` cấp cao nhất trong `presentation/providers/`. Không thêm `riverpod_annotation`, `riverpod_lint`, `custom_lint`.

### Cấm build hooks trong cây phụ thuộc

`build_runner` biên dịch builder bằng `dart compile`, mà `dart compile` chưa hỗ trợ build hooks của Dart. Một gói dùng hooks lọt vào cây phụ thuộc là **mất luôn khả năng sinh mã drift**, tức là mất tầng dữ liệu. Lỗi hiện ra dưới dạng:

```
'dart compile' does not support build hooks, use 'dart build' instead.
```

Hai ràng buộc đang giữ điều đó:
- `drift_flutter` phải ở nhánh **0.2.x** — nhánh 0.3.x kéo theo `sqlite3` 3.x vốn dùng hooks
- `path_provider_foundation` ghim đè **2.5.1** — bản 2.6.0 kéo theo `objective_c` vốn dùng hooks

**Trước khi thêm bất kỳ gói mới nào**, kiểm tra gói đó và các phụ thuộc của nó có thư mục `hook/` không:

```bash
ls ~/.pub-cache/hosted/pub.dev/<tên>-<phiên bản>/hook 2>/dev/null
```

### Bộ công cụ Android

AGP **8.11.1** · Kotlin **2.2.20** · Gradle **8.14** — khớp đúng phiên bản Flutter SDK dùng trong template. Thư mục `android/` ban đầu do Flutter 3.29.2 sinh ra với Kotlin 1.8.22, quá cũ để biên dịch `share_plus 13.x`.

Khi nâng Flutter SDK, đối chiếu lại ba con số này trong `.fvm/flutter_sdk/packages/flutter_tools/lib/src/android/gradle_utils.dart`.

## Thuật ngữ — dùng đúng, không đặt từ đồng nghĩa

`AssetClass` · `Holding` · `CashFlow` · `Snapshot` · `SnapshotDetail` · `Debt` · `ActionNote` · `PriceQuote` · `FxRate`

Từ điển đầy đủ ở mục 3 của PRD. Giới thiệu một từ đồng nghĩa ở bất kỳ đâu là vi phạm.

## Quy ước

| Việc | Cách làm |
|---|---|
| Ngày tháng | Lưu UTC trong DB, đổi giờ địa phương ở tầng hiển thị. Ngày của `Snapshot` và `CashFlow` cắt về đầu ngày. |
| Tên biến tiền | Kết thúc bằng `Amount` hoặc `Value` |
| Tên biến số lượng | Kết thúc bằng `Quantity`, luôn đi kèm `decimals` |
| Tên provider | `camelCase` kết thúc bằng `Provider` |
| Lỗi | Kiểu kết quả tường minh ở ranh giới tầng `data`, không `throw` để truyền lỗi nghiệp vụ |
| Chuỗi hiển thị | Qua lớp l10n, không viết thẳng tiếng Việt trong widget |
| Đổi schema DB | Tăng `schemaVersion`, viết migration, kèm test dựng DB bản cũ rồi nâng lên |

## Đổi cấu trúc cơ sở dữ liệu

Mỗi lần tăng `schemaVersion`, làm đủ bốn bước — thiếu bước nào cũng có thể làm mất dữ liệu người dùng mà không có đường khôi phục:

```bash
# 1. Chụp lại schema mới
fvm dart run drift_dev schema dump lib/data/db/database.dart drift_schemas/

# 2. Sinh lại helper kiểm thử
fvm dart run drift_dev schema generate drift_schemas/ test/data/db/generated/
```

3. Thêm bước nâng cấp vào `MigrationStrategy.onUpgrade` trong `lib/data/db/database.dart`
4. Thêm test `migrateAndValidate` cho cặp phiên bản mới vào `test/data/db/migration_test.dart`

Cấm xoá cột đang chứa dữ liệu người dùng mà không có bước chuyển sang nơi khác.

## Kiểm thử bắt buộc

Mọi công thức tài chính trong `domain/rules/` phải có test. Đặc biệt:

**Bộ đối chiếu 10 dòng** lấy từ Excel gốc — điều kiện nghiệm thu của công thức lãi lỗ:

| Nạp/Rút | Vốn góp lũy kế | Tài sản | Lãi/Lỗ |
|---|---|---|---|
| — | 341 | 341 | 0 |
| 0 | 341 | 302 | −39 |
| 0 | 341 | 310 | −31 |
| 0 | 341 | 173 | −168 |
| 0 | 341 | 320 | −21 |
| −60 | 281 | 311 | +30 |
| −36 | 245 | 283 | +38 |
| +9 | 254 | 321 | +67 |
| +47 | 301 | 267 | −34 |
| +32 | 333 | 233 | −100 |

Phải có thêm test cho kịch bản **sửa một dòng vốn ở giữa chuỗi** và **đổi ngày một dòng vốn** — hai trường hợp dễ bỏ sót nhất.

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| `_bmad-output/planning-artifacts/briefs/*/excel-analysis.md` | Bóc tách Excel gốc, công thức đã kiểm chứng |
| `_bmad-output/planning-artifacts/briefs/*/brief.md` | Vấn đề, giải pháp, phạm vi |
| `_bmad-output/planning-artifacts/briefs/*/addendum.md` | Ràng buộc kỹ thuật, bộ dữ liệu kiểm thử |
| `_bmad-output/planning-artifacts/prds/*/prd.md` | 41 yêu cầu chức năng FR-1..FR-41, từ điển thuật ngữ |
| `_bmad-output/planning-artifacts/architecture/*/ARCHITECTURE-SPINE.md` | 12 quyết định kiến trúc AD-1..AD-12 |
| `_bmad-output/planning-artifacts/epics/epics.md` | 7 epic, 40 story kèm tiêu chí nghiệm thu |

Khi làm một story, đọc tiêu chí nghiệm thu trong `epics.md` và các AD mà story đó ghi là chịu ràng buộc.

## Riêng tư

Repo GitHub riêng tư. Tài liệu trong `_bmad-output/` chứa **số liệu tài chính thật và tên người thật**. Không đưa nội dung các file đó ra ngoài, không đẩy lên dịch vụ bên thứ ba, không chuyển repo sang công khai mà chưa xử lý lịch sử git.
