/// Loại của một Lớp tài sản.
///
/// Đúng năm loại, cố định. Người dùng đã xác nhận không cần thêm lớp mới.
enum AssetKind {
  stock,
  gold,
  crypto,
  cashSavings,
  lending,
}

/// Cách người dùng khai báo giá trị một Khoản nắm giữ.
enum InputMode {
  /// Nhập số lượng, ứng dụng tự nhân với Giá hiệu lực.
  /// Dùng cho crypto, chứng khoán, vàng.
  quantity,

  /// Nhập thẳng giá trị quy đổi.
  /// Dùng cho tiền mặt và tiền gửi tiết kiệm.
  value,
}

/// Tiền tệ được hỗ trợ. Chỉ hai loại, xem mục Không làm gì của PRD.
enum Currency { vnd, usd }

extension AssetKindX on AssetKind {
  /// Số chữ số thập phân của số lượng thuộc loại tài sản này.
  ///
  /// Crypto cần 8 chữ số (1 satoshi), vàng 2 (đơn vị chỉ), cổ phiếu là số
  /// nguyên. Xem AD-3.
  int get quantityDecimals => switch (this) {
        AssetKind.crypto => 8,
        AssetKind.gold => 2,
        AssetKind.stock => 0,
        AssetKind.cashSavings => 0,
        AssetKind.lending => 0,
      };

  /// Đơn vị hiển thị cạnh ô nhập số lượng.
  String? get quantityUnit => switch (this) {
        AssetKind.crypto => null, // dùng ký hiệu coin: BTC, ETH
        AssetKind.gold => 'chỉ',
        AssetKind.stock => 'cổ',
        AssetKind.cashSavings => null,
        AssetKind.lending => null,
      };

  /// Chế độ nhập mặc định của loại tài sản này.
  InputMode get defaultInputMode => switch (this) {
        AssetKind.crypto || AssetKind.gold || AssetKind.stock =>
          InputMode.quantity,
        AssetKind.cashSavings || AssetKind.lending => InputMode.value,
      };
}
