import 'package:meta/meta.dart';

import 'enums.dart';

/// Lớp tài sản — nhóm phân loại cấp một của Danh mục.
///
/// Cố tình **không có** trường giá trị. Giá trị một Lớp tài sản luôn được suy
/// ra từ các Khoản nắm giữ thuộc nó tại thời điểm đọc, không bao giờ lưu sẵn.
/// Đây là ràng buộc triệt tiêu lỗi cộng thủ công giữa hai sheet trong Excel
/// gốc. Xem AD-5.
@immutable
class AssetClass {
  final int id;

  /// Tên người dùng nhìn thấy. Sửa được, xem FR-1.
  final String name;

  /// Loại cố định, quyết định độ chính xác số lượng và chế độ nhập. Không đổi
  /// được sau khi tạo — đổi loại sẽ làm số lượng đang lưu mất nghĩa.
  final AssetKind kind;

  /// Tỷ trọng mục tiêu, đơn vị phần vạn — 5000 tương đương 50%.
  final int? targetWeightBp;

  /// Lớp này có tham gia tính Lãi lỗ không. Xem FR-25.
  final bool inInvestmentGroup;

  /// Lớp bị ẩn không lên biểu đồ và không cộng vào Tổng tài sản.
  final bool hidden;

  final int sortOrder;

  /// Màu trên biểu đồ tròn, dạng ARGB. Là `int` chứ không phải `Color` vì
  /// `domain` không được phụ thuộc Flutter.
  final int colorValue;

  /// Điểm mã biểu tượng trong bộ Material Icons.
  final int iconCodePoint;

  const AssetClass({
    required this.id,
    required this.name,
    required this.kind,
    required this.colorValue,
    required this.iconCodePoint,
    this.targetWeightBp,
    this.inInvestmentGroup = false,
    this.hidden = false,
    this.sortOrder = 0,
  });

  AssetClass copyWith({
    String? name,
    int? Function()? targetWeightBp,
    bool? inInvestmentGroup,
    bool? hidden,
    int? sortOrder,
    int? colorValue,
    int? iconCodePoint,
  }) =>
      AssetClass(
        id: id,
        name: name ?? this.name,
        kind: kind,
        targetWeightBp:
            targetWeightBp == null ? this.targetWeightBp : targetWeightBp(),
        inInvestmentGroup: inInvestmentGroup ?? this.inInvestmentGroup,
        hidden: hidden ?? this.hidden,
        sortOrder: sortOrder ?? this.sortOrder,
        colorValue: colorValue ?? this.colorValue,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      );

  @override
  bool operator ==(Object other) =>
      other is AssetClass &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.targetWeightBp == targetWeightBp &&
      other.inInvestmentGroup == inInvestmentGroup &&
      other.hidden == hidden &&
      other.sortOrder == sortOrder &&
      other.colorValue == colorValue &&
      other.iconCodePoint == iconCodePoint;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        kind,
        targetWeightBp,
        inInvestmentGroup,
        hidden,
        sortOrder,
        colorValue,
        iconCodePoint,
      );

  @override
  String toString() => 'AssetClass($id, $name, $kind)';
}
