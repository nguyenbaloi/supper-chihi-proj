import 'package:meta/meta.dart';

import '../../core/money/money.dart';
import '../models/enums.dart';
import '../models/holding.dart';

/// Kết quả thêm hoặc sửa một Khoản nắm giữ.
///
/// Mọi nhánh hỏng đều là kiểu riêng mang sẵn dữ liệu tầng hiển thị cần để
/// giải thích, thay vì một chuỗi thông báo dựng sẵn. Xem AD-11.
@immutable
sealed class SaveHoldingResult {
  const SaveHoldingResult();
}

final class HoldingSaved extends SaveHoldingResult {
  final Holding holding;
  const HoldingSaved(this.holding);
}

/// Lớp tài sản đã có một Khoản nắm giữ mang ký hiệu này. Xem FR-4.
final class DuplicateSymbol extends SaveHoldingResult {
  final String symbol;
  const DuplicateSymbol(this.symbol);
}

/// Số lượng nhập vào mịn hơn mức loại tài sản này cho phép — ví dụ nhập
/// `10,5` cổ phiếu, hay `0,123` chỉ vàng.
///
/// Từ chối chứ không lặng lẽ làm tròn: làm tròn ở đây đổi đúng con số người
/// dùng vừa gõ mà không báo gì.
final class QuantityTooPrecise extends SaveHoldingResult {
  final String input;
  final int allowedDecimals;
  final AssetKind kind;
  const QuantityTooPrecise({
    required this.input,
    required this.allowedDecimals,
    required this.kind,
  });
}

/// Chuỗi số lượng không đọc được thành số.
final class InvalidQuantity extends SaveHoldingResult {
  final String input;
  const InvalidQuantity(this.input);
}

/// Thiếu dữ liệu bắt buộc cho chế độ nhập tương ứng.
final class MissingRequiredInput extends SaveHoldingResult {
  final InputMode inputMode;
  const MissingRequiredInput(this.inputMode);
}

final class HoldingAssetClassNotFound extends SaveHoldingResult {
  const HoldingAssetClassNotFound();
}

final class HoldingNotFound extends SaveHoldingResult {
  const HoldingNotFound();
}

/// Hợp đồng đọc ghi Khoản nắm giữ.
abstract interface class HoldingRepository {
  Future<List<Holding>> byAssetClass(int assetClassId);

  Future<List<Holding>> all();

  Stream<List<Holding>> watchByAssetClass(int assetClassId);

  Future<Holding?> byId(int id);

  /// Thêm một Khoản nắm giữ.
  ///
  /// Chế độ nhập suy ra từ loại của Lớp tài sản: loại tính theo số lượng cần
  /// [quantityText], loại tính theo giá trị cần [manualValueAmount]. Độ chính
  /// xác của số lượng do loại tài sản quyết định, xem FR-9.
  Future<SaveHoldingResult> add({
    required int assetClassId,
    required String symbol,
    String? displayName,
    String? quantityText,
    Money? manualValueAmount,
    Currency currency = Currency.vnd,
    String? note,
  });

  /// Sửa một Khoản nắm giữ. Tham số bỏ trống nghĩa là giữ nguyên. Xem FR-5.
  Future<SaveHoldingResult> update(
    int id, {
    String? symbol,
    String? displayName,
    String? quantityText,
    Money? manualValueAmount,
    Currency? currency,
    String? note,
  });

  /// Xóa một Khoản nắm giữ. Xem FR-6.
  ///
  /// Không đụng tới Bản chốt đã lưu — Bản chốt giữ giá trị đã tính của thời
  /// điểm đó, không tham chiếu tới Khoản nắm giữ. Xem AD-12.
  Future<bool> remove(int id);
}
