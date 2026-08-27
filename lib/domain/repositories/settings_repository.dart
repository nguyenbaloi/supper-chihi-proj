import '../../core/money/money.dart';
import '../models/app_settings.dart';

/// Đọc ghi thiết lập nền.
///
/// Trả về `null` khi người dùng chưa đi qua luồng khởi tạo — đó là trạng thái
/// hợp lệ, không phải lỗi. Xem FR-2 và FR-3.
abstract interface class SettingsRepository {
  Future<AppSettings?> current();

  Stream<AppSettings?> watch();

  /// Ghi Vốn góp khởi điểm và ngày bắt đầu, hoàn tất luồng khởi tạo.
  Future<AppSettings> initialize({
    required Money initialContributionAmount,
    required DateTime startDate,
  });

  Future<void> setInitialContribution(Money amount);

  Future<void> setStartDate(DateTime date);

  /// Ghi Tỷ giá nhập tay. `null` để xoá và quay lại tỷ giá tự lấy.
  Future<void> setFxRate(Money? rate);

  Future<void> setDriftThreshold(int bp);

  Future<void> markExported(DateTime at);
}
