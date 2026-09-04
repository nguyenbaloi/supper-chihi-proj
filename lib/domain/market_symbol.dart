/// Hai Mã được theo dõi. v1 cố định, không thêm không bớt (PRD §6.2).
enum MarketSymbol {
  btc(label: 'BTC', fullName: 'Bitcoin', storageKey: 'BTC', priceDecimals: 0),
  vnindex(
    label: 'VNINDEX',
    fullName: 'Chỉ số VN-Index',
    storageKey: 'VNINDEX',
    priceDecimals: 2,
  );

  const MarketSymbol({
    required this.label,
    required this.fullName,
    required this.storageKey,
    required this.priceDecimals,
  });

  /// Tên ngắn hiển thị trên thẻ và trong danh sách tín hiệu.
  final String label;

  /// Tên đầy đủ, dùng ở tiêu đề màn hình Chi tiết.
  final String fullName;

  /// Khoá dùng trong Kho cục bộ. Tách khỏi [label] để đổi nhãn hiển thị
  /// không làm mất dữ liệu đã lưu.
  final String storageKey;

  /// Số chữ số thập phân khi hiển thị giá. BTC tính bằng USD nên làm tròn
  /// tới đơn vị; VNINDEX là chỉ số nên giữ hai chữ số.
  final int priceDecimals;

  static MarketSymbol? fromStorageKey(String key) {
    for (final symbol in MarketSymbol.values) {
      if (symbol.storageKey == key) return symbol;
    }
    return null;
  }
}
