import 'package:meta/meta.dart';

import 'enums.dart';

/// Một Lớp tài sản dựng sẵn, chưa có `id` vì cơ sở dữ liệu cấp `id` khi tạo.
@immutable
class AssetClassSeed {
  final String name;
  final AssetKind kind;
  final bool inInvestmentGroup;
  final int sortOrder;
  final int colorValue;
  final int iconCodePoint;

  const AssetClassSeed({
    required this.name,
    required this.kind,
    required this.inInvestmentGroup,
    required this.sortOrder,
    required this.colorValue,
    required this.iconCodePoint,
  });
}

/// Năm Lớp tài sản có sẵn ngay khi cài đặt, đúng cách người dùng vẫn phân
/// loại trong Excel. Xem FR-1.
///
/// `inInvestmentGroup` chỉ bật cho Chứng khoán và Crypto — đây là hai lớp
/// người dùng coi là tài sản đầu tư thật sự, và là hai lớp duy nhất tham gia
/// công thức Lãi lỗ. Vàng và tiền mặt bị loại trừ có chủ đích. Xem FR-25.
///
/// **Lưu ý khi dùng `iconCodePoint` ở tầng hiển thị:** phải tra qua bảng ánh
/// xạ sang `IconData` hằng, không được dựng `IconData(codePoint)` tại chỗ.
/// Flutter từ chối rút gọn phông biểu tượng khi gặp `IconData` không hằng, và
/// lỗi chỉ hiện ra lúc build bản phát hành chứ không phải lúc chạy thử.
const List<AssetClassSeed> defaultAssetClasses = [
  AssetClassSeed(
    name: 'Chứng khoán',
    kind: AssetKind.stock,
    inInvestmentGroup: true,
    sortOrder: 0,
    colorValue: 0xFF1565C0, // xanh dương
    iconCodePoint: 0xe67f, // Icons.trending_up
  ),
  AssetClassSeed(
    name: 'Vàng',
    kind: AssetKind.gold,
    inInvestmentGroup: false,
    sortOrder: 1,
    colorValue: 0xFFF9A825, // vàng hổ phách
    iconCodePoint: 0xe553, // Icons.savings
  ),
  AssetClassSeed(
    name: 'Crypto',
    kind: AssetKind.crypto,
    inInvestmentGroup: true,
    sortOrder: 2,
    colorValue: 0xFF6A1B9A, // tím
    iconCodePoint: 0xf06bc, // Icons.currency_bitcoin
  ),
  AssetClassSeed(
    name: 'Tiền mặt & Tiết kiệm',
    kind: AssetKind.cashSavings,
    inInvestmentGroup: false,
    sortOrder: 3,
    colorValue: 0xFF2E7D32, // xanh lá
    iconCodePoint: 0xe041, // Icons.account_balance_wallet
  ),
  AssetClassSeed(
    name: 'Cho vay',
    kind: AssetKind.lending,
    inInvestmentGroup: false,
    sortOrder: 4,
    colorValue: 0xFF00838F, // xanh ngọc
    iconCodePoint: 0xf06be, // Icons.handshake
  ),
];
