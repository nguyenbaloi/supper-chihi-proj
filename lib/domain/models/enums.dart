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

/// Cách một Bản chốt ra đời.
enum SnapshotKind {
  /// Ứng dụng tự sinh khi mở lần đầu trong ngày. Không sửa, không xoá được.
  auto,

  /// Người dùng tự chốt kèm ghi chú.
  manual,
}

/// Chế độ hiển thị sáng tối.
enum ThemeModeSetting { light, dark, system }

/// Nguồn của một Giá.
enum PriceSource {
  /// Lấy tự động từ nguồn dữ liệu bên ngoài.
  api,

  /// Người dùng tự nhập. Luôn thắng [api] cho tới khi bị xóa. Xem FR-12.
  manual,
}

extension CurrencyX on Currency {
  /// Số chữ số thập phân của đơn vị tiền.
  ///
  /// Mọi số tiền đều lưu bằng **đơn vị nhỏ nhất** của loại tiền đó: đồng với
  /// VND (không có phần thập phân trong thực tế sử dụng), xu với USD. Nhờ vậy
  /// không có số tiền nào phải đi qua kiểu số thực. Xem AD-3.
  int get decimals => switch (this) {
        Currency.vnd => 0,
        Currency.usd => 2,
      };

  String get code => switch (this) {
        Currency.vnd => 'VND',
        Currency.usd => 'USD',
      };
}

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
