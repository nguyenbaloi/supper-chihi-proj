import 'package:meta/meta.dart';

import '../../core/money/money.dart';
import 'enums.dart';

/// Thiết lập nền của ứng dụng. Luôn đúng một bản ghi.
///
/// [initialContributionAmount] là điểm neo của mọi phép tính Lãi lỗ: người
/// dùng bỏ toàn bộ lịch sử quá khứ và bắt đầu từ hiện tại, nên không có con số
/// này thì ứng dụng sẽ hiểu là chưa bỏ đồng nào vào và báo lãi bằng đúng toàn
/// bộ giá trị danh mục. Xem AD-4 và FR-3.
@immutable
class AppSettings {
  final Money initialContributionAmount;
  final DateTime startDate;

  /// Tỷ giá USD sang VND do người dùng nhập, `null` nếu chưa nhập.
  final Money? fxRateManualAmount;

  /// Ngưỡng cảnh báo lệch so với Tỷ trọng mục tiêu, đơn vị phần vạn.
  final int driftThresholdBp;

  final DateTime? lastExportedAt;
  final bool onboardingCompleted;

  /// Chế độ hiển thị sáng tối. Xem FR-39.
  final ThemeModeSetting themeModeSetting;

  const AppSettings({
    required this.initialContributionAmount,
    required this.startDate,
    this.fxRateManualAmount,
    this.driftThresholdBp = 500,
    this.lastExportedAt,
    this.onboardingCompleted = false,
    this.themeModeSetting = ThemeModeSetting.system,
  });

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.initialContributionAmount == initialContributionAmount &&
      other.startDate == startDate &&
      other.fxRateManualAmount == fxRateManualAmount &&
      other.driftThresholdBp == driftThresholdBp &&
      other.lastExportedAt == lastExportedAt &&
      other.onboardingCompleted == onboardingCompleted &&
      other.themeModeSetting == themeModeSetting;

  @override
  int get hashCode => Object.hash(
        initialContributionAmount,
        startDate,
        fxRateManualAmount,
        driftThresholdBp,
        lastExportedAt,
        onboardingCompleted,
        themeModeSetting,
      );
}
