# CLAUDE.md

Hướng dẫn cho Claude Code khi làm việc trong project này.

## Sản phẩm

App Flutter **quản lý dự án và mục tiêu cá nhân** — thay thế hai file `HÀNH ĐỘNG.pdf` và `Ý TƯỞNG.pdf` mà người dùng đang dùng làm nơi chứa bảy hướng đi cá nhân, danh sách hành động và mục tiêu dài hạn.

Trật tự tổ chức: **Mục tiêu là gốc, Dự án là nhánh, Hành động là lá.**

**Đây KHÔNG phải app theo dõi tài sản đầu tư.** Việc đó thuộc về project `personal_finance` bên cạnh. Ở đây chỉ có *ý chí* — mục tiêu, nguyên tắc, hành động — không có *số liệu tài sản*, không có giá thị trường, không có lãi lỗ. Nếu một yêu cầu nghe giống theo dõi danh mục đầu tư, hãy hỏi lại trước khi làm.

## Lệnh — luôn dùng tiền tố `fvm`

SDK ghim riêng cho project này qua FVM (`.fvmrc` → Flutter 3.38.10 / Dart 3.10.9). Máy còn bản 3.29.2 dùng chung cho các project eGOV khác.

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run
fvm dart run build_runner build --delete-conflicting-outputs
```

Chạy `flutter` trần sẽ dùng bản 3.29.2 và **giải phụ thuộc thất bại** vì pubspec yêu cầu Dart `^3.10.9`.

## Quy tắc tuyệt đối

Bốn quy tắc dưới đây sinh ra từ khuyết tật có thật của hai file PDF gốc và từ lỗi có thật ở project `personal_finance`. Vi phạm chúng làm hỏng sản phẩm theo kiểu **không báo lỗi** — chỉ lặng lẽ cho ra con số sai.

### 1. Giá trị suy ra không bao giờ lưu cứng

Cấm tuyệt đối các cột sau ở mọi bảng:

```
Project.completionRatio   Project.completionPercent   Project.actionCount
Goal.currentValue         Goal.progress               Goal.progressPercent
```

```
tỷ_lệ_hoàn_thành(dự án) = |hành động Xong| ÷ |hành động không Bỏ|
tiến_độ(mục tiêu, t)    = giá_trị_mốc_gần_nhất(≤ t) ÷ giá_trị_đích
```

Người dùng sửa và xoá được Mốc quá khứ, kể cả đổi ngày — mọi giá trị phía sau phải tự đúng theo.

Ngoại lệ duy nhất có chủ đích: cột `searchText` là chỉ mục tìm kiếm, không phải giá trị nghiệp vụ.

### 2. Cấm `double` trong mọi phép tính giá trị Mục tiêu

- **Lưu trữ:** tiền là `int` đơn vị đồng. Đơn vị khác là `int` đã nhân hệ số, kèm cột `decimals`.
- **Tính toán:** chuyển sang `Decimal` (gói `decimal`) trước khi nhân chia.
- **Hiển thị:** làm tròn duy nhất một lần, ở lớp định dạng.

Từ khoá `double` không được xuất hiện trong `lib/domain/` và trong bất kỳ cột Drift nào. Ngoại lệ duy nhất: toạ độ vẽ biểu đồ trong `lib/presentation/`.

### 3. Dấu thời gian do hệ thống ghi, không do người dùng nhập

`createdAt`, `updatedAt`, `startedAt`, `completedAt` do repository ghi — **không có ô nhập nào trong giao diện**. Chỉ `dueDate` và `GoalUpdate.date` là do người dùng chọn.

`startedAt` ghi **một lần duy nhất** ở lần đầu chuyển sang `Đang làm`, không bao giờ bị xoá sau đó. `completedAt` ghi khi vào `Xong`, xoá khi rời `Xong`.

Chính việc thiếu dấu thời gian là khuyết tật lớn nhất của hai file PDF gốc — app tồn tại một phần để chữa đúng chỗ đó.

### 4. Không có mạng, điểm

Không có `lib/data/remote/`. Không có `package:http` trong `pubspec.yaml`. Không `HttpClient`, không phân tích hành vi, không thu thập số liệu sử dụng, không quảng cáo, không backend, không tài khoản, không đồng bộ.

Ngoại lệ duy nhất: `url_launcher` mở URL của `Link` ra **trình duyệt của hệ điều hành**. Ứng dụng không tải nội dung nào về.

## Cấu trúc mã nguồn

```
lib/
  core/        format · l10n · result · money
  domain/      models · rules · repositories (chỉ hợp đồng trừu tượng)
  data/        db (drift) · backup · seed · repositories (cài đặt)
  features/    today · projects · actions · goals · notes
               search · settings · onboarding
  presentation/ providers · widgets
```

**Hướng phụ thuộc một chiều:** `presentation → domain ← data`.

File trong `domain/` không được `import` bất cứ thứ gì từ `package:flutter`, `package:drift`, hay từ `data/` và `presentation/`. Đây là điều kiện để test toàn bộ quy tắc nghiệp vụ mà không cần dựng giả lập.

## Ngăn xếp

Riverpod 3.3.2 · drift 2.31.0 · drift_flutter 0.2.8 · decimal 3.2.6 · fl_chart 1.2.0 · intl 0.20.2 · share_plus 13.3.0 · url_launcher 6.3.1

**Không dùng code generation của Riverpod.** `riverpod_generator` cần `analyzer ^9/^12` còn `drift_dev` cần `^10/^13` — loại trừ nhau dưới Dart 3.10.9. Provider khai báo thủ công dưới dạng biến `final` cấp cao nhất trong `presentation/providers/`. Không thêm `riverpod_annotation`, `riverpod_lint`, `custom_lint`.

### Cấm build hooks trong cây phụ thuộc

`build_runner` biên dịch builder bằng `dart compile`, mà `dart compile` chưa hỗ trợ build hooks. Một gói dùng hooks lọt vào cây phụ thuộc là **mất luôn khả năng sinh mã drift**, tức là mất tầng dữ liệu:

```
'dart compile' does not support build hooks, use 'dart build' instead.
```

Hai ràng buộc đang giữ điều đó:
- `drift_flutter` phải ở nhánh **0.2.x** — nhánh 0.3.x kéo theo `sqlite3` 3.x vốn dùng hooks
- `path_provider_foundation` ghim đè **2.5.1** — bản 2.6.0 kéo theo `objective_c` vốn dùng hooks

**Trước khi thêm bất kỳ gói mới nào:**

```bash
ls ~/.pub-cache/hosted/pub.dev/<tên>-<phiên bản>/hook 2>/dev/null
```

### Bộ công cụ Android

AGP **8.11.1** · Kotlin **2.2.20** · Gradle **8.14** — khớp phiên bản Flutter SDK dùng trong template. Khi nâng SDK, đối chiếu lại ba con số này trong `.fvm/flutter_sdk/packages/flutter_tools/lib/src/android/gradle_utils.dart`.

## Thuật ngữ — dùng đúng, không đặt từ đồng nghĩa

`Project` · `Action` · `Goal` · `GoalUpdate` · `Topic` · `Note` · `Link` · `StatusEvent` · `ProjectGoal`

Trạng thái lưu bằng chuỗi ổn định, không lưu chỉ số enum:

```
ProjectStatus : not_started · active · paused · done · dropped
ActionStatus  :               todo · doing · done · dropped
Priority      : high · medium · low
```

Từ điển đầy đủ ở mục 3 của PRD. Giới thiệu một từ đồng nghĩa ở bất kỳ đâu là vi phạm.

## Quy ước

| Hạng mục | Quy ước |
|---|---|
| Tên bảng Drift | Số nhiều, `PascalCase` |
| Tên biến tiền tệ | Kết thúc bằng `Amount`, luôn `int` đơn vị đồng |
| Tên provider | `camelCase` kết thúc bằng `Provider` |
| Trạng thái trong DB | `snake_case`, đọc gặp chuỗi lạ thì về mặc định, không ném lỗi |
| Lỗi | Kiểu kết quả tường minh ở ranh giới tầng `data`, không `throw` để truyền lỗi nghiệp vụ |
| Chuỗi hiển thị | Qua lớp l10n, không viết thẳng tiếng Việt trong widget |
| Ngày trong DB | Lưu UTC; đổi sang giờ địa phương ở lớp định dạng |
| Đổi schema DB | Tăng `schemaVersion`, viết migration, kèm test dựng DB bản cũ rồi nâng lên |

## Đổi cấu trúc cơ sở dữ liệu

Mỗi lần tăng `schemaVersion`, làm đủ bốn bước:

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

Mọi quy tắc trong `domain/rules/` phải có test. Đặc biệt bốn kịch bản dễ sai nhất:

1. **Sửa một Mốc ở giữa chuỗi** — mọi giá trị dẫn xuất phải đúng lại.
2. **Đổi ngày một Mốc** khiến nó không còn là Mốc mới nhất — giá trị hiện tại phải đổi theo.
3. **`Đang làm → Xong → Đang làm`** — `startedAt` giữ nguyên lần đầu, `completedAt` bị xoá.
4. **Xuất → xoá sạch → nhập** — so khớp toàn bộ, kể cả `createdAt` và `sortOrder`.

Ngoài ra: Mục tiêu **không có hạn chót thì tuyệt đối không hiện nhịp và dự báo**, và màn hình Hôm nay **không bao giờ liệt kê toàn bộ Hành động chưa xong**.

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| `_bmad-output/planning-artifacts/briefs/*/brief.md` | Vấn đề, giải pháp, phạm vi |
| `_bmad-output/planning-artifacts/briefs/*/addendum.md` | Dữ liệu hạt giống thật từ hai file PDF, ràng buộc kỹ thuật kế thừa |
| `_bmad-output/planning-artifacts/prds/*/prd.md` | 34 yêu cầu chức năng FR-1..FR-34, từ điển thuật ngữ |
| `_bmad-output/planning-artifacts/architecture/*/ARCHITECTURE-SPINE.md` | 14 quyết định kiến trúc AD-1..AD-14 |
| `_bmad-output/planning-artifacts/epics/epics.md` | 6 epic, 33 story kèm tiêu chí nghiệm thu |

Khi làm một story, đọc tiêu chí nghiệm thu trong `epics.md` và các AD mà story đó chịu ràng buộc.

## Riêng tư

Repo GitHub riêng tư (`nguyenbaloi/Chichi-project`). Tài liệu trong `_bmad-output/` chứa **mục tiêu tài chính thật, tên người thật và kế hoạch gia đình**. Không đưa nội dung các file đó ra ngoài, không đẩy lên dịch vụ bên thứ ba, không chuyển repo sang công khai mà chưa xử lý lịch sử git.
