// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppL10nVi extends AppL10n {
  AppL10nVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'ChichiMonney';

  @override
  String get navDashboard => 'Tổng quan';

  @override
  String get navTargets => 'Mục tiêu';

  @override
  String get navHistory => 'Lịch sử';

  @override
  String get navDebts => 'Sổ nợ';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get totalAssets => 'Tổng tài sản';

  @override
  String get profitLoss => 'Lãi lỗ';

  @override
  String get investmentGroup => 'Nhóm đầu tư';

  @override
  String get cumulativeContribution => 'Vốn góp lũy kế';

  @override
  String get initialContribution => 'Vốn góp khởi điểm';

  @override
  String get assetClasses => 'Lớp tài sản';

  @override
  String get holdings => 'Khoản nắm giữ';

  @override
  String get actionAdd => 'Thêm';

  @override
  String get actionEdit => 'Sửa';

  @override
  String get actionDelete => 'Xóa';

  @override
  String get actionSave => 'Lưu';

  @override
  String get actionCancel => 'Hủy';

  @override
  String get actionConfirm => 'Xác nhận';

  @override
  String get actionClose => 'Đóng';

  @override
  String get actionRetry => 'Thử lại';

  @override
  String get actionApply => 'Áp dụng';

  @override
  String unpricedHoldings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count khoản chưa có giá',
    );
    return '$_temp0';
  }

  @override
  String get noPriceYet => 'Chưa có giá';

  @override
  String get noFxRateYet => 'Chưa có tỷ giá';

  @override
  String get manualPriceBadge => 'Giá tự nhập';

  @override
  String get needsManualPrice =>
      'Loại tài sản này chưa có nguồn giá tự động — cần nhập giá thủ công';

  @override
  String get fallbackFxRateNotice => 'Đang dùng tỷ giá dự phòng';

  @override
  String get priceUpdatedJustNow => 'cập nhật vừa xong';

  @override
  String priceUpdatedMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cập nhật $count phút trước',
    );
    return '$_temp0';
  }

  @override
  String priceUpdatedHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cập nhật $count giờ trước',
    );
    return '$_temp0';
  }

  @override
  String priceUpdatedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cập nhật $count ngày trước',
    );
    return '$_temp0';
  }

  @override
  String get priceStale => 'Giá đã cũ hơn 24 giờ';

  @override
  String get priceNeverFetched => 'chưa từng lấy được giá';

  @override
  String get offlineUsingCachedPrices =>
      'Không có mạng — đang dùng giá lưu lần cuối';

  @override
  String get emptyPortfolioTitle => 'Danh mục còn trống';

  @override
  String get emptyPortfolioBody =>
      'Thêm khoản nắm giữ đầu tiên để thấy tổng tài sản và cơ cấu.';

  @override
  String get assetClassRename => 'Đổi tên lớp tài sản';

  @override
  String get assetClassHide => 'Ẩn lớp này';

  @override
  String get assetClassUnhide => 'Bỏ ẩn';

  @override
  String get assetClassHidden => 'Đang ẩn';

  @override
  String assetClassCannotHide(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Không ẩn được: lớp đang chứa $count khoản nắm giữ',
    );
    return '$_temp0';
  }

  @override
  String get assetClassNameEmpty => 'Tên lớp tài sản không được để trống';

  @override
  String get holdingSymbol => 'Ký hiệu';

  @override
  String get holdingDisplayName => 'Tên gợi nhớ';

  @override
  String get holdingQuantity => 'Số lượng';

  @override
  String get holdingValue => 'Giá trị';

  @override
  String get holdingCurrency => 'Tiền tệ';

  @override
  String get holdingNote => 'Ghi chú';

  @override
  String get holdingPrice => 'Giá một đơn vị';

  @override
  String get holdingEffectivePrice => 'Giá hiệu lực';

  @override
  String get holdingConvertedValue => 'Giá trị quy đổi';

  @override
  String get holdingPriceOnlyManual =>
      'Loại tài sản này chưa có nguồn giá tự động — giá bạn nhập ở đây là giá duy nhất được dùng';

  @override
  String get holdingPriceOverridesMarket =>
      'Để trống thì dùng giá thị trường tự lấy';

  @override
  String get holdingPriceMissingForValue => 'Nhập giá để thấy giá trị quy đổi';

  @override
  String get holdingWeightInClass => 'Tỷ trọng trong lớp';

  @override
  String holdingDuplicateSymbol(String symbol) {
    return 'Lớp này đã có khoản mang ký hiệu $symbol';
  }

  @override
  String holdingQuantityTooPrecise(int decimals) {
    String _temp0 = intl.Intl.pluralLogic(
      decimals,
      locale: localeName,
      other: 'Loại tài sản này nhận tối đa $decimals chữ số thập phân',
      zero: 'Loại tài sản này chỉ nhận số nguyên',
    );
    return '$_temp0';
  }

  @override
  String get holdingInvalidQuantity => 'Số lượng không hợp lệ';

  @override
  String get holdingMissingQuantity => 'Chưa nhập số lượng';

  @override
  String get holdingMissingValue => 'Chưa nhập số tiền';

  @override
  String holdingDeleteConfirm(String symbol) {
    return 'Xóa khoản $symbol?';
  }

  @override
  String get holdingDeleteExplain =>
      'Mọi số liệu tổng hợp sẽ được tính lại. Bản chốt lịch sử giữ nguyên.';

  @override
  String get addHolding => 'Thêm khoản nắm giữ';

  @override
  String get editHolding => 'Sửa khoản nắm giữ';

  @override
  String get setManualPrice => 'Nhập giá thủ công';

  @override
  String get clearManualPrice => 'Xóa giá tự nhập';

  @override
  String get capitalLedger => 'Sổ vốn';

  @override
  String get cashFlowDeposit => 'Nạp vào';

  @override
  String get cashFlowWithdraw => 'Rút ra';

  @override
  String get cashFlowAmount => 'Số tiền';

  @override
  String get cashFlowDate => 'Ngày';

  @override
  String get cashFlowNote => 'Ghi chú';

  @override
  String get addCashFlow => 'Thêm dòng vốn';

  @override
  String get editCashFlow => 'Sửa dòng vốn';

  @override
  String get cashFlowDeleteConfirm => 'Xóa dòng vốn này?';

  @override
  String get cashFlowDeleteExplain =>
      'Vốn góp lũy kế và lãi lỗ của mọi mốc phía sau sẽ được tính lại.';

  @override
  String get cashFlowEmpty =>
      'Chưa có dòng vốn nào. Vốn góp lũy kế đang bằng vốn góp khởi điểm.';

  @override
  String get profitLossExplain =>
      'Lãi lỗ = giá trị nhóm đầu tư − vốn góp lũy kế';

  @override
  String get debtLedger => 'Sổ nợ';

  @override
  String get debtLent => 'Cho vay';

  @override
  String get debtBorrowed => 'Đi vay';

  @override
  String get debtNet => 'Tổng ròng';

  @override
  String get debtPersonName => 'Tên người';

  @override
  String get debtAmount => 'Số tiền';

  @override
  String get debtDate => 'Ngày';

  @override
  String get debtNote => 'Ghi chú';

  @override
  String get addDebt => 'Thêm khoản nợ';

  @override
  String get editDebt => 'Sửa khoản nợ';

  @override
  String get debtSettle => 'Đánh dấu đã tất toán';

  @override
  String get debtUnsettle => 'Bỏ đánh dấu tất toán';

  @override
  String debtSettledOn(String date) {
    return 'Tất toán ngày $date';
  }

  @override
  String get debtSettledHistory => 'Khoản đã tất toán';

  @override
  String debtDeleteConfirm(String name) {
    return 'Xóa khoản nợ của $name?';
  }

  @override
  String get debtEmpty => 'Chưa có khoản nợ nào.';

  @override
  String get debtNameEmpty => 'Tên người không được để trống';

  @override
  String get targets => 'Mục tiêu';

  @override
  String get targetWeight => 'Tỷ trọng mục tiêu';

  @override
  String get targetWeightShort => 'Mục tiêu';

  @override
  String get actualWeight => 'Tỷ trọng thực tế';

  @override
  String get targetDrift => 'Khoảng lệch';

  @override
  String get targetGroup => 'Nhóm mục tiêu';

  @override
  String get addTargetGroup => 'Thêm nhóm mục tiêu';

  @override
  String targetSumWarning(String percent) {
    return 'Tổng các tỷ trọng mục tiêu đang là $percent, không phải 100%';
  }

  @override
  String get targetOver => 'Đang thừa';

  @override
  String get targetUnder => 'Đang thiếu';

  @override
  String get targetNoneSet => 'Chưa đặt mục tiêu nào.';

  @override
  String get allocationPlan => 'Phân bổ chuẩn';

  @override
  String get allocationBuy => 'Mua thêm';

  @override
  String get allocationSell => 'Bán bớt';

  @override
  String get allocationHold => 'Đang cân';

  @override
  String allocationCurrentToTarget(String current, String target) {
    return 'Hiện $current · chuẩn $target';
  }

  @override
  String get allocationTotalBuy => 'Tổng mua';

  @override
  String get allocationTotalSell => 'Tổng bán';

  @override
  String get allocationNetNeeded => 'Cần nạp thêm';

  @override
  String get allocationNetSpare => 'Bán ra còn dư';

  @override
  String get allocationBalanced => 'Kế hoạch tự cân';

  @override
  String get allocationUntargeted => 'Đang ở lớp chưa đặt mục tiêu';

  @override
  String get allocationNoBasis => 'Chưa có tài sản để phân bổ.';

  @override
  String get targetBarTitle => 'Thực tế so với chuẩn';

  @override
  String targetBarActual(String percent) {
    return 'thực tế $percent';
  }

  @override
  String targetBarStandard(String percent, String amount) {
    return 'chuẩn $percent · $amount';
  }

  @override
  String get targetProgress => 'Mức đạt';

  @override
  String targetActualVsTarget(String actual, String target) {
    return 'Thực tế $actual / mục tiêu $target';
  }

  @override
  String get targetProgressNoBase => 'Chưa có tài sản để so';

  @override
  String get driftThreshold => 'Ngưỡng cảnh báo lệch';

  @override
  String get driftExceeded => 'Lệch quá ngưỡng';

  @override
  String get actionNotes => 'Ghi chú kế hoạch';

  @override
  String get addActionNote => 'Thêm ghi chú';

  @override
  String get actionNoteCompleted => 'Đã hoàn thành';

  @override
  String get actionNotePending => 'Chưa hoàn thành';

  @override
  String get actionNoteEmpty => 'Chưa có ghi chú nào.';

  @override
  String get actionNoteDeleteConfirm => 'Xóa ghi chú này?';

  @override
  String get history => 'Lịch sử';

  @override
  String get snapshotManual => 'Chốt thủ công';

  @override
  String get snapshotAuto => 'Tự động';

  @override
  String get captureSnapshot => 'Chốt sổ';

  @override
  String get snapshotNote => 'Ghi chú cho mốc này';

  @override
  String get snapshotDeleteConfirm => 'Xóa bản chốt này?';

  @override
  String get snapshotAutoCannotDelete => 'Bản chốt tự động không xóa được';

  @override
  String get snapshotNotEnoughData =>
      'Cần ít nhất hai bản chốt để vẽ biểu đồ. Mở ứng dụng vào những ngày khác nhau để tích lũy dữ liệu.';

  @override
  String snapshotDetailTitle(String date) {
    return 'Bản chốt ngày $date';
  }

  @override
  String get rangeOneMonth => '1 tháng';

  @override
  String get rangeThreeMonths => '3 tháng';

  @override
  String get rangeSixMonths => '6 tháng';

  @override
  String get rangeOneYear => '1 năm';

  @override
  String get rangeAll => 'Toàn bộ';

  @override
  String get chartTotalAssets => 'Tổng tài sản';

  @override
  String get chartProfitLoss => 'Lãi lỗ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get settingsStartDate => 'Ngày bắt đầu';

  @override
  String get settingsFxRate => 'Tỷ giá USD sang VND';

  @override
  String get settingsFxRateAuto => 'Tự lấy';

  @override
  String get settingsFxRateManual => 'Nhập tay';

  @override
  String get settingsInvestmentGroup => 'Cấu hình nhóm đầu tư';

  @override
  String get settingsThemeMode => 'Chế độ hiển thị';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get settingsExport => 'Xuất dữ liệu';

  @override
  String get settingsExportShare => 'Chia sẻ tệp';

  @override
  String settingsLastExported(String date) {
    return 'Lần xuất gần nhất: $date';
  }

  @override
  String get settingsNeverExported => 'Chưa từng xuất dữ liệu';

  @override
  String backupReminder(int days) {
    return 'Đã $days ngày chưa sao lưu. Xuất dữ liệu để giữ một bản ở nơi bạn chọn.';
  }

  @override
  String get recalcWarningTitle => 'Toàn bộ lịch sử lãi lỗ sẽ được tính lại';

  @override
  String get recalcWarningBody =>
      'Thay đổi này ảnh hưởng tới mọi con số lãi lỗ trong quá khứ, kể cả trên các bản chốt đã lưu.';

  @override
  String get onboardingWelcomeTitle => 'Dựng lại danh mục từ Excel';

  @override
  String get onboardingWelcomeBody =>
      'Ba bước: chọn lớp tài sản, nhập những gì bạn đang có, rồi khai báo vốn góp khởi điểm.';

  @override
  String get onboardingStepClasses => 'Lớp tài sản';

  @override
  String get onboardingStepHoldings => 'Khoản nắm giữ';

  @override
  String get onboardingStepCapital => 'Vốn góp khởi điểm';

  @override
  String get onboardingSkip => 'Bỏ qua bước này';

  @override
  String get onboardingNext => 'Tiếp tục';

  @override
  String get onboardingFinish => 'Xong';

  @override
  String get onboardingCapitalExplain =>
      'Tổng số tiền ròng bạn đã bỏ vào chứng khoán và crypto tính đến hôm nay. Ví dụ: đã nạp 400 triệu và rút ra 59 triệu thì nhập 341 triệu.';

  @override
  String get onboardingCapitalRequired =>
      'Cần khai báo vốn góp khởi điểm để hoàn tất';

  @override
  String get onboardingCapitalZeroWarning =>
      'Nhập 0 nghĩa là toàn bộ giá trị nhóm đầu tư sẽ được coi là lãi. Bạn chắc chứ?';

  @override
  String get errorGeneric => 'Có lỗi xảy ra';

  @override
  String get loading => 'Đang tải';
}
