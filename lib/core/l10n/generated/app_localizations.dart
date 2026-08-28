import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'ChichiMonney'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get navDashboard;

  /// No description provided for @navTargets.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get navTargets;

  /// No description provided for @navHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get navHistory;

  /// No description provided for @navDebts.
  ///
  /// In vi, this message translates to:
  /// **'Sổ nợ'**
  String get navDebts;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get navSettings;

  /// No description provided for @totalAssets.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tài sản'**
  String get totalAssets;

  /// No description provided for @profitLoss.
  ///
  /// In vi, this message translates to:
  /// **'Lãi lỗ'**
  String get profitLoss;

  /// No description provided for @investmentGroup.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm đầu tư'**
  String get investmentGroup;

  /// No description provided for @cumulativeContribution.
  ///
  /// In vi, this message translates to:
  /// **'Vốn góp lũy kế'**
  String get cumulativeContribution;

  /// No description provided for @initialContribution.
  ///
  /// In vi, this message translates to:
  /// **'Vốn góp khởi điểm'**
  String get initialContribution;

  /// No description provided for @assetClasses.
  ///
  /// In vi, this message translates to:
  /// **'Lớp tài sản'**
  String get assetClasses;

  /// No description provided for @holdings.
  ///
  /// In vi, this message translates to:
  /// **'Khoản nắm giữ'**
  String get holdings;

  /// No description provided for @actionAdd.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get actionConfirm;

  /// No description provided for @actionClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get actionClose;

  /// No description provided for @actionRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get actionRetry;

  /// No description provided for @actionApply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get actionApply;

  /// No description provided for @unpricedHoldings.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{{count} khoản chưa có giá}}'**
  String unpricedHoldings(int count);

  /// No description provided for @noPriceYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giá'**
  String get noPriceYet;

  /// No description provided for @noFxRateYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tỷ giá'**
  String get noFxRateYet;

  /// No description provided for @manualPriceBadge.
  ///
  /// In vi, this message translates to:
  /// **'Giá tự nhập'**
  String get manualPriceBadge;

  /// No description provided for @needsManualPrice.
  ///
  /// In vi, this message translates to:
  /// **'Loại tài sản này chưa có nguồn giá tự động — cần nhập giá thủ công'**
  String get needsManualPrice;

  /// No description provided for @fallbackFxRateNotice.
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng tỷ giá dự phòng'**
  String get fallbackFxRateNotice;

  /// No description provided for @priceUpdatedJustNow.
  ///
  /// In vi, this message translates to:
  /// **'cập nhật vừa xong'**
  String get priceUpdatedJustNow;

  /// No description provided for @priceUpdatedMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{cập nhật {count} phút trước}}'**
  String priceUpdatedMinutes(int count);

  /// No description provided for @priceUpdatedHours.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{cập nhật {count} giờ trước}}'**
  String priceUpdatedHours(int count);

  /// No description provided for @priceUpdatedDays.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{cập nhật {count} ngày trước}}'**
  String priceUpdatedDays(int count);

  /// No description provided for @priceStale.
  ///
  /// In vi, this message translates to:
  /// **'Giá đã cũ hơn 24 giờ'**
  String get priceStale;

  /// No description provided for @priceNeverFetched.
  ///
  /// In vi, this message translates to:
  /// **'chưa từng lấy được giá'**
  String get priceNeverFetched;

  /// No description provided for @offlineUsingCachedPrices.
  ///
  /// In vi, this message translates to:
  /// **'Không có mạng — đang dùng giá lưu lần cuối'**
  String get offlineUsingCachedPrices;

  /// No description provided for @emptyPortfolioTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục còn trống'**
  String get emptyPortfolioTitle;

  /// No description provided for @emptyPortfolioBody.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khoản nắm giữ đầu tiên để thấy tổng tài sản và cơ cấu.'**
  String get emptyPortfolioBody;

  /// No description provided for @assetClassRename.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên lớp tài sản'**
  String get assetClassRename;

  /// No description provided for @assetClassHide.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn lớp này'**
  String get assetClassHide;

  /// No description provided for @assetClassUnhide.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ ẩn'**
  String get assetClassUnhide;

  /// No description provided for @assetClassHidden.
  ///
  /// In vi, this message translates to:
  /// **'Đang ẩn'**
  String get assetClassHidden;

  /// No description provided for @assetClassCannotHide.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{Không ẩn được: lớp đang chứa {count} khoản nắm giữ}}'**
  String assetClassCannotHide(int count);

  /// No description provided for @assetClassNameEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Tên lớp tài sản không được để trống'**
  String get assetClassNameEmpty;

  /// No description provided for @holdingSymbol.
  ///
  /// In vi, this message translates to:
  /// **'Ký hiệu'**
  String get holdingSymbol;

  /// No description provided for @holdingDisplayName.
  ///
  /// In vi, this message translates to:
  /// **'Tên gợi nhớ'**
  String get holdingDisplayName;

  /// No description provided for @holdingQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng'**
  String get holdingQuantity;

  /// No description provided for @holdingValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị'**
  String get holdingValue;

  /// No description provided for @holdingCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ'**
  String get holdingCurrency;

  /// No description provided for @holdingNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get holdingNote;

  /// No description provided for @holdingPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá một đơn vị'**
  String get holdingPrice;

  /// No description provided for @holdingEffectivePrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá hiệu lực'**
  String get holdingEffectivePrice;

  /// No description provided for @holdingConvertedValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị quy đổi'**
  String get holdingConvertedValue;

  /// No description provided for @holdingPriceOnlyManual.
  ///
  /// In vi, this message translates to:
  /// **'Loại tài sản này chưa có nguồn giá tự động — giá bạn nhập ở đây là giá duy nhất được dùng'**
  String get holdingPriceOnlyManual;

  /// No description provided for @holdingPriceOverridesMarket.
  ///
  /// In vi, this message translates to:
  /// **'Để trống thì dùng giá thị trường tự lấy'**
  String get holdingPriceOverridesMarket;

  /// No description provided for @holdingPriceMissingForValue.
  ///
  /// In vi, this message translates to:
  /// **'Nhập giá để thấy giá trị quy đổi'**
  String get holdingPriceMissingForValue;

  /// No description provided for @holdingWeightInClass.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ trọng trong lớp'**
  String get holdingWeightInClass;

  /// No description provided for @holdingDuplicateSymbol.
  ///
  /// In vi, this message translates to:
  /// **'Lớp này đã có khoản mang ký hiệu {symbol}'**
  String holdingDuplicateSymbol(String symbol);

  /// No description provided for @holdingQuantityTooPrecise.
  ///
  /// In vi, this message translates to:
  /// **'{decimals, plural, =0{Loại tài sản này chỉ nhận số nguyên} other{Loại tài sản này nhận tối đa {decimals} chữ số thập phân}}'**
  String holdingQuantityTooPrecise(int decimals);

  /// No description provided for @holdingInvalidQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng không hợp lệ'**
  String get holdingInvalidQuantity;

  /// No description provided for @holdingMissingQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Chưa nhập số lượng'**
  String get holdingMissingQuantity;

  /// No description provided for @holdingMissingValue.
  ///
  /// In vi, this message translates to:
  /// **'Chưa nhập số tiền'**
  String get holdingMissingValue;

  /// No description provided for @holdingDeleteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xóa khoản {symbol}?'**
  String holdingDeleteConfirm(String symbol);

  /// No description provided for @holdingDeleteExplain.
  ///
  /// In vi, this message translates to:
  /// **'Mọi số liệu tổng hợp sẽ được tính lại. Bản chốt lịch sử giữ nguyên.'**
  String get holdingDeleteExplain;

  /// No description provided for @addHolding.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khoản nắm giữ'**
  String get addHolding;

  /// No description provided for @editHolding.
  ///
  /// In vi, this message translates to:
  /// **'Sửa khoản nắm giữ'**
  String get editHolding;

  /// No description provided for @setManualPrice.
  ///
  /// In vi, this message translates to:
  /// **'Nhập giá thủ công'**
  String get setManualPrice;

  /// No description provided for @clearManualPrice.
  ///
  /// In vi, this message translates to:
  /// **'Xóa giá tự nhập'**
  String get clearManualPrice;

  /// No description provided for @capitalLedger.
  ///
  /// In vi, this message translates to:
  /// **'Sổ vốn'**
  String get capitalLedger;

  /// No description provided for @cashFlowDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Nạp vào'**
  String get cashFlowDeposit;

  /// No description provided for @cashFlowWithdraw.
  ///
  /// In vi, this message translates to:
  /// **'Rút ra'**
  String get cashFlowWithdraw;

  /// No description provided for @cashFlowAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get cashFlowAmount;

  /// No description provided for @cashFlowDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get cashFlowDate;

  /// No description provided for @cashFlowNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get cashFlowNote;

  /// No description provided for @addCashFlow.
  ///
  /// In vi, this message translates to:
  /// **'Thêm dòng vốn'**
  String get addCashFlow;

  /// No description provided for @editCashFlow.
  ///
  /// In vi, this message translates to:
  /// **'Sửa dòng vốn'**
  String get editCashFlow;

  /// No description provided for @cashFlowDeleteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xóa dòng vốn này?'**
  String get cashFlowDeleteConfirm;

  /// No description provided for @cashFlowDeleteExplain.
  ///
  /// In vi, this message translates to:
  /// **'Vốn góp lũy kế và lãi lỗ của mọi mốc phía sau sẽ được tính lại.'**
  String get cashFlowDeleteExplain;

  /// No description provided for @cashFlowEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dòng vốn nào. Vốn góp lũy kế đang bằng vốn góp khởi điểm.'**
  String get cashFlowEmpty;

  /// No description provided for @profitLossExplain.
  ///
  /// In vi, this message translates to:
  /// **'Lãi lỗ = giá trị nhóm đầu tư − vốn góp lũy kế'**
  String get profitLossExplain;

  /// No description provided for @debtLedger.
  ///
  /// In vi, this message translates to:
  /// **'Sổ nợ'**
  String get debtLedger;

  /// No description provided for @debtLent.
  ///
  /// In vi, this message translates to:
  /// **'Cho vay'**
  String get debtLent;

  /// No description provided for @debtBorrowed.
  ///
  /// In vi, this message translates to:
  /// **'Đi vay'**
  String get debtBorrowed;

  /// No description provided for @debtNet.
  ///
  /// In vi, this message translates to:
  /// **'Tổng ròng'**
  String get debtNet;

  /// No description provided for @debtPersonName.
  ///
  /// In vi, this message translates to:
  /// **'Tên người'**
  String get debtPersonName;

  /// No description provided for @debtAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get debtAmount;

  /// No description provided for @debtDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get debtDate;

  /// No description provided for @debtNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get debtNote;

  /// No description provided for @addDebt.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khoản nợ'**
  String get addDebt;

  /// No description provided for @editDebt.
  ///
  /// In vi, this message translates to:
  /// **'Sửa khoản nợ'**
  String get editDebt;

  /// No description provided for @debtSettle.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu đã tất toán'**
  String get debtSettle;

  /// No description provided for @debtUnsettle.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ đánh dấu tất toán'**
  String get debtUnsettle;

  /// No description provided for @debtSettledOn.
  ///
  /// In vi, this message translates to:
  /// **'Tất toán ngày {date}'**
  String debtSettledOn(String date);

  /// No description provided for @debtSettledHistory.
  ///
  /// In vi, this message translates to:
  /// **'Khoản đã tất toán'**
  String get debtSettledHistory;

  /// No description provided for @debtDeleteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xóa khoản nợ của {name}?'**
  String debtDeleteConfirm(String name);

  /// No description provided for @debtEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có khoản nợ nào.'**
  String get debtEmpty;

  /// No description provided for @debtNameEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Tên người không được để trống'**
  String get debtNameEmpty;

  /// No description provided for @targets.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get targets;

  /// No description provided for @targetWeight.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ trọng mục tiêu'**
  String get targetWeight;

  /// No description provided for @targetWeightShort.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get targetWeightShort;

  /// No description provided for @actualWeight.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ trọng thực tế'**
  String get actualWeight;

  /// No description provided for @targetDrift.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng lệch'**
  String get targetDrift;

  /// No description provided for @targetGroup.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm mục tiêu'**
  String get targetGroup;

  /// No description provided for @addTargetGroup.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhóm mục tiêu'**
  String get addTargetGroup;

  /// No description provided for @targetSumWarning.
  ///
  /// In vi, this message translates to:
  /// **'Tổng các tỷ trọng mục tiêu đang là {percent}, không phải 100%'**
  String targetSumWarning(String percent);

  /// No description provided for @targetOver.
  ///
  /// In vi, this message translates to:
  /// **'Đang thừa'**
  String get targetOver;

  /// No description provided for @targetUnder.
  ///
  /// In vi, this message translates to:
  /// **'Đang thiếu'**
  String get targetUnder;

  /// No description provided for @targetNoneSet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đặt mục tiêu nào.'**
  String get targetNoneSet;

  /// No description provided for @allocationPlan.
  ///
  /// In vi, this message translates to:
  /// **'Phân bổ chuẩn'**
  String get allocationPlan;

  /// No description provided for @allocationBuy.
  ///
  /// In vi, this message translates to:
  /// **'Mua thêm'**
  String get allocationBuy;

  /// No description provided for @allocationSell.
  ///
  /// In vi, this message translates to:
  /// **'Bán bớt'**
  String get allocationSell;

  /// No description provided for @allocationHold.
  ///
  /// In vi, this message translates to:
  /// **'Đang cân'**
  String get allocationHold;

  /// No description provided for @allocationCurrentToTarget.
  ///
  /// In vi, this message translates to:
  /// **'Hiện {current} · chuẩn {target}'**
  String allocationCurrentToTarget(String current, String target);

  /// No description provided for @allocationTotalBuy.
  ///
  /// In vi, this message translates to:
  /// **'Tổng mua'**
  String get allocationTotalBuy;

  /// No description provided for @allocationTotalSell.
  ///
  /// In vi, this message translates to:
  /// **'Tổng bán'**
  String get allocationTotalSell;

  /// No description provided for @allocationNetNeeded.
  ///
  /// In vi, this message translates to:
  /// **'Cần nạp thêm'**
  String get allocationNetNeeded;

  /// No description provided for @allocationNetSpare.
  ///
  /// In vi, this message translates to:
  /// **'Bán ra còn dư'**
  String get allocationNetSpare;

  /// No description provided for @allocationBalanced.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch tự cân'**
  String get allocationBalanced;

  /// No description provided for @allocationUntargeted.
  ///
  /// In vi, this message translates to:
  /// **'Đang ở lớp chưa đặt mục tiêu'**
  String get allocationUntargeted;

  /// No description provided for @allocationNoBasis.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài sản để phân bổ.'**
  String get allocationNoBasis;

  /// No description provided for @targetBarTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thực tế so với chuẩn'**
  String get targetBarTitle;

  /// No description provided for @targetBarActual.
  ///
  /// In vi, this message translates to:
  /// **'thực tế {percent}'**
  String targetBarActual(String percent);

  /// No description provided for @targetBarStandard.
  ///
  /// In vi, this message translates to:
  /// **'chuẩn {percent} · {amount}'**
  String targetBarStandard(String percent, String amount);

  /// No description provided for @targetProgress.
  ///
  /// In vi, this message translates to:
  /// **'Mức đạt'**
  String get targetProgress;

  /// No description provided for @targetActualVsTarget.
  ///
  /// In vi, this message translates to:
  /// **'Thực tế {actual} / mục tiêu {target}'**
  String targetActualVsTarget(String actual, String target);

  /// No description provided for @targetProgressNoBase.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài sản để so'**
  String get targetProgressNoBase;

  /// No description provided for @driftThreshold.
  ///
  /// In vi, this message translates to:
  /// **'Ngưỡng cảnh báo lệch'**
  String get driftThreshold;

  /// No description provided for @driftExceeded.
  ///
  /// In vi, this message translates to:
  /// **'Lệch quá ngưỡng'**
  String get driftExceeded;

  /// No description provided for @actionNotes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú kế hoạch'**
  String get actionNotes;

  /// No description provided for @addActionNote.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ghi chú'**
  String get addActionNote;

  /// No description provided for @actionNoteCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành'**
  String get actionNoteCompleted;

  /// No description provided for @actionNotePending.
  ///
  /// In vi, this message translates to:
  /// **'Chưa hoàn thành'**
  String get actionNotePending;

  /// No description provided for @actionNoteEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ghi chú nào.'**
  String get actionNoteEmpty;

  /// No description provided for @actionNoteDeleteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ghi chú này?'**
  String get actionNoteDeleteConfirm;

  /// No description provided for @history.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get history;

  /// No description provided for @snapshotManual.
  ///
  /// In vi, this message translates to:
  /// **'Chốt thủ công'**
  String get snapshotManual;

  /// No description provided for @snapshotAuto.
  ///
  /// In vi, this message translates to:
  /// **'Tự động'**
  String get snapshotAuto;

  /// No description provided for @captureSnapshot.
  ///
  /// In vi, this message translates to:
  /// **'Chốt sổ'**
  String get captureSnapshot;

  /// No description provided for @snapshotNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú cho mốc này'**
  String get snapshotNote;

  /// No description provided for @snapshotDeleteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bản chốt này?'**
  String get snapshotDeleteConfirm;

  /// No description provided for @snapshotAutoCannotDelete.
  ///
  /// In vi, this message translates to:
  /// **'Bản chốt tự động không xóa được'**
  String get snapshotAutoCannotDelete;

  /// No description provided for @snapshotNotEnoughData.
  ///
  /// In vi, this message translates to:
  /// **'Cần ít nhất hai bản chốt để vẽ biểu đồ. Mở ứng dụng vào những ngày khác nhau để tích lũy dữ liệu.'**
  String get snapshotNotEnoughData;

  /// No description provided for @snapshotDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bản chốt ngày {date}'**
  String snapshotDetailTitle(String date);

  /// No description provided for @rangeOneMonth.
  ///
  /// In vi, this message translates to:
  /// **'1 tháng'**
  String get rangeOneMonth;

  /// No description provided for @rangeThreeMonths.
  ///
  /// In vi, this message translates to:
  /// **'3 tháng'**
  String get rangeThreeMonths;

  /// No description provided for @rangeSixMonths.
  ///
  /// In vi, this message translates to:
  /// **'6 tháng'**
  String get rangeSixMonths;

  /// No description provided for @rangeOneYear.
  ///
  /// In vi, this message translates to:
  /// **'1 năm'**
  String get rangeOneYear;

  /// No description provided for @rangeAll.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ'**
  String get rangeAll;

  /// No description provided for @chartTotalAssets.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tài sản'**
  String get chartTotalAssets;

  /// No description provided for @chartProfitLoss.
  ///
  /// In vi, this message translates to:
  /// **'Lãi lỗ'**
  String get chartProfitLoss;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @settingsStartDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu'**
  String get settingsStartDate;

  /// No description provided for @settingsFxRate.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ giá USD sang VND'**
  String get settingsFxRate;

  /// No description provided for @settingsFxRateAuto.
  ///
  /// In vi, this message translates to:
  /// **'Tự lấy'**
  String get settingsFxRateAuto;

  /// No description provided for @settingsFxRateManual.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tay'**
  String get settingsFxRateManual;

  /// No description provided for @settingsInvestmentGroup.
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình nhóm đầu tư'**
  String get settingsInvestmentGroup;

  /// No description provided for @settingsThemeMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ hiển thị'**
  String get settingsThemeMode;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get themeSystem;

  /// No description provided for @settingsExport.
  ///
  /// In vi, this message translates to:
  /// **'Xuất dữ liệu'**
  String get settingsExport;

  /// No description provided for @settingsExportShare.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ tệp'**
  String get settingsExportShare;

  /// No description provided for @settingsLastExported.
  ///
  /// In vi, this message translates to:
  /// **'Lần xuất gần nhất: {date}'**
  String settingsLastExported(String date);

  /// No description provided for @settingsNeverExported.
  ///
  /// In vi, this message translates to:
  /// **'Chưa từng xuất dữ liệu'**
  String get settingsNeverExported;

  /// No description provided for @backupReminder.
  ///
  /// In vi, this message translates to:
  /// **'Đã {days} ngày chưa sao lưu. Xuất dữ liệu để giữ một bản ở nơi bạn chọn.'**
  String backupReminder(int days);

  /// No description provided for @recalcWarningTitle.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ lịch sử lãi lỗ sẽ được tính lại'**
  String get recalcWarningTitle;

  /// No description provided for @recalcWarningBody.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi này ảnh hưởng tới mọi con số lãi lỗ trong quá khứ, kể cả trên các bản chốt đã lưu.'**
  String get recalcWarningBody;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Dựng lại danh mục từ Excel'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In vi, this message translates to:
  /// **'Ba bước: chọn lớp tài sản, nhập những gì bạn đang có, rồi khai báo vốn góp khởi điểm.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingStepClasses.
  ///
  /// In vi, this message translates to:
  /// **'Lớp tài sản'**
  String get onboardingStepClasses;

  /// No description provided for @onboardingStepHoldings.
  ///
  /// In vi, this message translates to:
  /// **'Khoản nắm giữ'**
  String get onboardingStepHoldings;

  /// No description provided for @onboardingStepCapital.
  ///
  /// In vi, this message translates to:
  /// **'Vốn góp khởi điểm'**
  String get onboardingStepCapital;

  /// No description provided for @onboardingSkip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua bước này'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get onboardingNext;

  /// No description provided for @onboardingFinish.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get onboardingFinish;

  /// No description provided for @onboardingCapitalExplain.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số tiền ròng bạn đã bỏ vào chứng khoán và crypto tính đến hôm nay. Ví dụ: đã nạp 400 triệu và rút ra 59 triệu thì nhập 341 triệu.'**
  String get onboardingCapitalExplain;

  /// No description provided for @onboardingCapitalRequired.
  ///
  /// In vi, this message translates to:
  /// **'Cần khai báo vốn góp khởi điểm để hoàn tất'**
  String get onboardingCapitalRequired;

  /// No description provided for @onboardingCapitalZeroWarning.
  ///
  /// In vi, this message translates to:
  /// **'Nhập 0 nghĩa là toàn bộ giá trị nhóm đầu tư sẽ được coi là lãi. Bạn chắc chứ?'**
  String get onboardingCapitalZeroWarning;

  /// No description provided for @errorGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra'**
  String get errorGeneric;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải'**
  String get loading;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppL10nVi();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
