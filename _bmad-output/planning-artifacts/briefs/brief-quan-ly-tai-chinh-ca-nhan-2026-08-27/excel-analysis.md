---
title: "Phân tích Excel hiện trạng — Nguồn yêu cầu gốc"
status: draft
created: 2026-08-27
updated: 2026-08-27
---

# Phân tích hệ thống Excel hiện trạng

Nguồn: 2 sheet người dùng đang dùng — "DANH MỤC VÀ CƠ CẤU TỶ TRỌNG TÀI SẢN" và "NỢ VÀ CHO VAY".

> **Kết luận quan trọng:** đây KHÔNG phải sổ thu chi hằng ngày. Đây là **hệ thống theo dõi danh mục đầu tư (portfolio tracker)** đa lớp tài sản, kèm quản lý nợ/cho vay và đo lãi lỗ theo dòng tiền nạp/rút.

---

## Sheet 1 — Danh mục và cơ cấu tỷ trọng tài sản

### 1.1 Bảng tổng tài sản (đơn vị: triệu VND)

| STT | Tài sản | Giá trị | Tỷ trọng thực tế |
|---|---|---|---|
| 1 | STOCK | 15 | 2,2% |
| 2 | GOLD | 92 | 13,5% |
| 3 | BITCOIN | 390 | 57,4% |
| 4 | C VAY + CASH | 183 | 26,9% |
| | **TỔNG** | **680** | 100% |

Đã kiểm chứng: mọi tỷ trọng khớp với `giá trị / 680`. Biểu đồ tròn "TÀI SẢN" là hệ quả tự động của bảng này.

### 1.2 Bảng chi tiết chứng khoán (bóc tách lớp STOCK)

| STT | Mã | Giá trị | Tỷ trọng trong lớp |
|---|---|---|---|
| 1 | FPT | 15 | 100% |
| 2 | HCM | 0 | 0% |
| 3 | KHÁC | 0 | 0% |
| 4 | CASH | 0 | 0% |
| | **TỔNG** | **15** | |

Tổng lớp này (15) khớp đúng dòng STOCK ở bảng tổng → **hai bảng liên kết nhau, không nhập trùng**.

### 1.3 Bảng chi tiết crypto (bóc tách lớp BITCOIN, đơn vị: USD)

| STT | Coin | Giá trị (USD) | Tỷ trọng trong lớp |
|---|---|---|---|
| 1 | BTC | 12.500 | 83,3% |
| 2 | ETH | 2.500 | 16,7% |
| 3 | USDT | 0 | 0% |
| 4 | KHÁC | 0 | 0% |
| | **TỔNG** | **15.000** | |

**Phát hiện:** lớp này ghi bằng USD nhưng bảng tổng ghi 390 triệu VND. Suy ra có một bước **quy đổi ngoại tệ**: 390.000.000 / 15.000 ≈ **26.000 VND/USD**. Tỷ giá này hiện đang nằm ẩn trong công thức Excel — app phải xử lý tường minh.

### 1.4 Bảng theo dõi lãi lỗ theo dòng tiền (TỔNG KẾT CK+BTC)

Ghi chú gốc trên sheet: *"Chỉ tính đầu tư ck và crypto, bỏ tiền mặt và vàng riêng"* và *"Lời lỗ = Hiện tại − tổng nạp rút"*.

| Tổng nạp rút lũy kế | Nạp/Rút kỳ này | Tài sản hiện tại | Kết quả | Ngày |
|---|---|---|---|---|
| 341 | 0 | 341 | 0 | 12/1/2025 |
| 341 | 0 | 302 | −39 | 21/2/2025 |
| 341 | 0 | 310 | −31 | 3/3/2025 |
| 341 | 0 | 173 | −168 | 30/3/2025 |
| 341 | 0 | 320 | −21 | 21/7/2025 |
| 281 | −60 | 311 | +30 | 9/8/2025 |
| 245 | −36 | 283 | +38 | 18/8/2025 |
| 254 | +9 | 321 | +67 | 7/10/2025 |
| 301 | +47 | 267 | −34 | 28/11/2025 |
| 333 | +32 | 233 | −100 | 3/2/2026 |

**Hai công thức cốt lõi đã kiểm chứng trên toàn bộ 10 dòng:**

```
Tổng nạp rút lũy kế (n) = Tổng nạp rút lũy kế (n−1) + Nạp/Rút kỳ n
Kết quả (lãi/lỗ)        = Tài sản hiện tại − Tổng nạp rút lũy kế
```

Đây là phương pháp **vốn góp ròng (net contribution)** — chuẩn mực đúng để đo hiệu quả đầu tư khi có nạp/rút giữa chừng, vì nó tách bạch "tiền tăng do mình bỏ thêm vào" với "tiền tăng do đầu tư sinh lời". Rút tiền ra làm giảm vốn góp lũy kế, nên lãi lỗ vẫn phản ánh đúng.

**Đặc điểm quan trọng:** các mốc ngày **không đều nhau** (12/1 → 21/2 → 3/3 → 30/3 → 21/7...). Đây là hành vi "chốt sổ khi nào nhớ thì chốt", không phải snapshot định kỳ tự động.

### 1.5 Mục tiêu cân bằng danh mục (target allocation)

| Lớp tài sản | Mục tiêu |
|---|---|
| BTC | 50% |
| CASH | 30% |
| Vàng + CK | 20% |

So sánh với thực tế hiện tại → **lệch rất xa**:

| Lớp | Thực tế | Mục tiêu | Chênh lệch |
|---|---|---|---|
| BTC | 57,4% | 50% | **+7,4%** (thừa) |
| Cash + Cho vay | 26,9% | 30% | −3,1% (thiếu) |
| Vàng + CK | 15,7% | 20% | −4,3% (thiếu) |

Đây chính là thứ sinh ra các ghi chú hành động ở cuối sheet — tức là **app cần tự động tính khoảng lệch này và đề xuất hành động**, thay vì người dùng phải nhẩm.

### 1.6 Ghi chú kế hoạch hành động (dạng văn bản tự do)

- Cơ cấu lại danh mục cho vay: giảm lượng tiền cho vay về 10%
- Cơ cấu lại tiền mặt và đầu tư: mua thêm vàng và chứng khoán + BTC
- Khoản vay có kế hoạch thu hồi nợ từ giờ đến cuối năm: thu 50 triệu
- Tăng altcoin, mua thêm ETH
- Mua thêm BTC

---

## Sheet 2 — Nợ và cho vay

| STT | Tên | Nội dung | Số tiền | Ghi chú |
|---|---|---|---|---|
| 1 | Anh Thắng | Cho vay | 63 | 28/12/2024 — vay thêm 2 triệu ngày 1/2025 |
| 2 | Chị Nhâm | Cho vay | 30 | |
| 3 | E Tuấn | Cho vay | 30 | |
| 4 | Hoa (Chị Dậu) | Hoa gửi | 0 | |
| 5 | Bảy | Cho vay | 20 | |
| 6 | (Vay) | Vay | **−10** | Số âm = mình đi vay |
| | **TỔNG** | | **133** | |

**Quy ước phát hiện được:** số dương = mình cho người khác vay (tài sản), số âm = mình đi vay (nợ phải trả). Tổng 133 là **giá trị ròng**.

**Mối liên kết giữa hai sheet:** dòng "C VAY + CASH = 183" ở Sheet 1 = **133 (cho vay ròng) + 50 (tiền mặt)**. Hai sheet đang được cộng thủ công vào nhau — đây là điểm dễ sai và là lý do rõ ràng để đưa lên app.

---

## Mô hình dữ liệu suy ra

```
Danh mục (Portfolio)
├── Lớp tài sản (AssetClass): Chứng khoán · Vàng · Crypto · Tiền mặt · Cho vay
│   ├── có tỷ trọng mục tiêu (%)
│   └── Khoản nắm giữ (Holding): FPT, HCM / BTC, ETH, USDT / ...
│       ├── giá trị (theo đơn vị tiền gốc: VND hoặc USD)
│       └── quy đổi về VND qua tỷ giá
│
├── Sổ nạp/rút (CashFlow): ngày · số tiền (+nạp/−rút) · phạm vi áp dụng (CK+Crypto)
│
├── Bản chốt sổ (Snapshot): ngày · tổng tài sản · nạp rút lũy kế · lãi lỗ
│
├── Sổ nợ & cho vay (Debt): người · số tiền (+cho vay/−đi vay) · ngày · ghi chú
│
└── Kế hoạch hành động (ActionNote): văn bản tự do gắn với kỳ chốt sổ
```

## Những gì Excel đang làm được mà app bắt buộc phải giữ

1. Tỷ trọng % tự tính và biểu đồ tròn cho từng cấp (tổng danh mục → từng lớp).
2. Bóc tách hai cấp: lớp tài sản → khoản nắm giữ chi tiết, không nhập trùng số liệu.
3. Lãi lỗ theo phương pháp vốn góp ròng, có lịch sử theo mốc thời gian.
4. So sánh tỷ trọng thực tế với tỷ trọng mục tiêu.
5. Sổ nợ/cho vay tách riêng nhưng có cộng vào tổng tài sản.

## Những gì Excel KHÔNG làm được — chính là lý do cần app

| Điểm đau trong Excel | Hệ quả |
|---|---|
| Tỷ giá USD/VND nằm ẩn trong công thức, phải sửa tay | Số liệu sai lệch âm thầm khi tỷ giá đổi |
| Giá BTC, ETH, giá cổ phiếu phải tra rồi gõ tay | Lười cập nhật → số liệu cũ → quyết định sai |
| Sheet Nợ và sheet Tài sản cộng thủ công vào nhau | Sai sót khi một bên đổi mà bên kia quên |
| Không có biểu đồ đường tài sản theo thời gian | Không thấy được xu hướng, chỉ thấy từng điểm rời rạc |
| Khoảng lệch so với mục tiêu phải tự nhẩm | Không biết cụ thể cần mua/bán bao nhiêu để về đúng tỷ trọng |
| Thao tác trên điện thoại rất khổ | Chỉ cập nhật được khi ngồi máy tính → chốt sổ thưa thớt, không đều |
| Không có nhắc chốt sổ | Các mốc cách nhau tới 4 tháng (30/3 → 21/7) |
