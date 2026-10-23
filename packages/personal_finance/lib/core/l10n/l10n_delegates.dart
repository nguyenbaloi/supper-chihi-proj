import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

/// Gom các delegate l10n lại một chỗ để test dựng được màn hình mà không phải
/// nhắc lại danh sách ở từng tệp.
class AppL10nDelegates {
  const AppL10nDelegates._();

  static List<LocalizationsDelegate<Object?>> get delegates =>
      AppL10n.localizationsDelegates;

  static List<Locale> get locales => AppL10n.supportedLocales;
}
