import 'package:meta/meta.dart';

import '../models/asset_class.dart';

/// Kết quả của thao tác ẩn một Lớp tài sản.
///
/// Là kiểu tường minh chứ không phải `bool` hay ngoại lệ: tầng hiển thị cần
/// **số Khoản nắm giữ đang chứa** để nói rõ lý do từ chối, và đọc con số đó
/// ra từ một chuỗi thông báo là cách làm sẽ hỏng ngay khi đổi ngôn ngữ.
/// Xem AD-11.
@immutable
sealed class HideAssetClassResult {
  const HideAssetClassResult();
}

/// Đã ẩn thành công.
final class AssetClassHidden extends HideAssetClassResult {
  const AssetClassHidden();
}

/// Từ chối vì lớp đang chứa [holdingCount] Khoản nắm giữ. Xem FR-1.
final class AssetClassNotEmpty extends HideAssetClassResult {
  final int holdingCount;
  const AssetClassNotEmpty(this.holdingCount);
}

/// Không tìm thấy Lớp tài sản.
final class AssetClassNotFound extends HideAssetClassResult {
  const AssetClassNotFound();
}

/// Hợp đồng đọc ghi Lớp tài sản.
///
/// Chỉ khai báo, không cài đặt — nhờ vậy mọi công thức phía trên test được mà
/// không cần dựng cơ sở dữ liệu.
abstract interface class AssetClassRepository {
  /// Toàn bộ Lớp tài sản kể cả lớp bị ẩn, sắp theo `sortOrder`.
  Future<List<AssetClass>> all();

  /// Chỉ các Lớp tài sản chưa bị ẩn. Đây là tập tham gia biểu đồ tròn và
  /// Tổng tài sản. Xem AD-5.
  Future<List<AssetClass>> visible();

  /// Theo dõi thay đổi để màn hình tự vẽ lại.
  Stream<List<AssetClass>> watchAll();

  Future<AssetClass?> byId(int id);

  /// Đổi tên. [name] đã được cắt khoảng trắng hai đầu và phải khác rỗng.
  Future<void> rename(int id, String name);

  /// Ẩn một Lớp tài sản. Từ chối nếu lớp còn chứa Khoản nắm giữ.
  Future<HideAssetClassResult> hide(int id);

  Future<void> unhide(int id);
}
