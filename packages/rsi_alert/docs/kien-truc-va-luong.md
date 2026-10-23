# Kiến trúc và luồng

Tóm tắt vận hành. Hợp đồng đầy đủ nằm ở `_bmad-output/planning-artifacts/architecture/architecture-rsi-alert-2026-09-04/ARCHITECTURE-SPINE.md`.

## Cây thư mục

```
lib/
  main.dart                     ProviderScope + MaterialApp
  domain/                       Dart thuần — không import package nào
    constants.dart              rsiPeriod 14, ngưỡng 30 / 70
    market_symbol.dart          enum MarketSymbol { btc, vnindex }
    candle.dart                 Candle: openTime UTC, ohlcv, isClosed
    rsi.dart                    computeRsi() — Wilder, hàm thuần
    signal.dart                 Signal + detectSignals()
    rsi_status.dart             RsiStatus.from(rsi)
  data/
    market_data_source.dart     interface + MarketDataException
    udf_parser.dart             bộ đọc chung định dạng TradingView UDF
    binance_source.dart         BTC
    ssi_source.dart             VNINDEX nguồn chính
    vndirect_source.dart        VNINDEX dự phòng + gộp nến ngày → tuần
    candle_store.dart           shared_preferences, JSON phẳng
    market_repository.dart      điều phối nguồn + kho, không bao giờ ném
  app/
    symbol_view.dart            suy ra RSI + Tín hiệu từ chuỗi nến
    overview_controller.dart    Notifier điều phối màn hình Tổng quan
    providers.dart              dựng repository thật, provider điều hướng
  ui/
    strings.dart  theme.dart  format.dart  home_shell.dart
    overview/   symbol_card, signal_banner, overview_screen
    detail/     chart_viewport, chart_geometry, candle_painter,
                rsi_painter, detail_screen
    history/    history_screen
tool/
  doi_chieu.dart                đối chiếu số với nguồn thật
```

## Một lần mở app

1. `main()` mở `CandleStore`, dựng repository, chạy `ProviderScope`.
2. `OverviewController.build()` đọc **ngay** nến đã lưu và trả về trạng thái từ đó — màn hình có số trước khi mạng xong.
3. Cùng lúc, `Future.microtask(refresh)` tải cả hai Mã **song song**. Việc hoãn sang microtask là bắt buộc: gán `state` trong lúc `build()` còn chạy sẽ đọc phải provider chưa khởi tạo.
4. Với mỗi Mã, repository thử từng nguồn theo thứ tự ưu tiên. Thành công thì ghi đè kho và trả `staleness: fresh`. Mọi nguồn hỏng thì rơi về kho (`stale`) hoặc trả rỗng (`empty`).
5. `SymbolView.from()` tính `computeRsi` và `detectSignals` **tại chỗ** từ chuỗi nến. Không giá trị nào ở đây được đọc lên từ kho.
6. So Tín hiệu cuối với mốc đã xem của Mã đó → quyết định có hiện dải cảnh báo không. Lần chạy đầu sau khi cài app thì đặt mốc bằng Tín hiệu cuối tìm thấy, để không dội cảnh báo lịch sử.

## Hai khung biểu đồ chia chung viewport

`DetailScreen` sở hữu một `ChartViewport` duy nhất trong `State`. Cả `CandlePainter` lẫn `RsiPainter` đọc chính nó và tính toạ độ ngang qua cùng một `ChartGeometry`, nên một cột thời gian luôn rơi vào cùng vị trí ở cả hai khung.

Cử chỉ nằm ở `_GestureLayer`, đặt trên **cả hai** khung, và cả hai cùng cập nhật viewport đó — kéo ở khung nào thì khung kia cũng đi theo.

Khác biệt cố ý giữa hai khung: trục dọc khung giá **co giãn** theo khoảng giá của các nến đang trong cửa sổ; trục dọc khung RSI **cố định 0–100**, vì hai vạch ngưỡng chỉ có nghĩa khi chúng luôn ở cùng một chỗ.

## Kiểm thử

| Tệp | Canh điều gì |
| --- | --- |
| `test/architecture_test.dart` | AD-1, AD-7, AD-8, AD-10, AD-11, NFR-4 — quét mã nguồn, fail khi ranh giới bị phá |
| `test/domain/rsi_test.dart` | Wilder đúng, biên 0/100, đối chiếu 1352 giá trị tham chiếu |
| `test/domain/signal_test.dart` | Quy tắc cắt ngưỡng, nến đang chạy không sinh tín hiệu |
| `test/domain/candle_test.dart` | Bất biến UTC, vòng JSON, AD-2 |
| `test/data/sources_test.dart` | Ba adapter trên **dữ liệu mẫu thật**, mọi nhánh lỗi, gộp nến tuần |
| `test/data/store_and_repository_test.dart` | Thay toàn bộ khi lưu, dự phòng, rơi về cache, không ném qua biên |
| `test/ui/chart_viewport_test.dart` | Kẹp biên, phóng quanh điểm neo |
| `test/ui/overview_test.dart` | Thứ tự thẻ, nhãn Từ điển, ngoại tuyến, dải cảnh báo, lịch sử |

Dữ liệu mẫu ở `test/fixtures/` là **phản hồi thật** tải về ngày 2026-09-04, không phải dữ liệu bịa. Tải lại khi cần: xem `tool/doi_chieu.dart` để biết tham số gọi.
