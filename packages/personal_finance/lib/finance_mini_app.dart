import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app_core/mini_app_core.dart';

import 'app.dart';
import 'data/db/backup_file.dart';
import 'core/l10n/generated/app_localizations.dart';

/// Điểm vào duy nhất của ứng dụng — dùng chung cho `main()` độc lập và super app.
class FinanceMiniApp implements MiniApp {
  const FinanceMiniApp();

  @override
  String get id => 'personal_finance';

  @override
  String get title => lookupAppL10n(const Locale('vi')).appTitle;

  @override
  IconData get icon => Icons.pie_chart;

  @override
  Color get color => const Color(0xFF1565C0);

  // Không mở cơ sở dữ liệu ở đây: `databaseHostProvider` tự mở khi cần, để
  // khôi phục dữ liệu đóng và mở lại được tệp mà không dựng lại cây widget.
  @override
  Future<ProviderContainer> createContainer() async => ProviderContainer();

  @override
  Widget buildApp() => const PersonalFinanceApp();

  // Tệp `.sqlite` khôi phục được bằng nút Khôi phục trong Cài đặt.
  @override
  List<BackupSource> get backupSources => const [
        BackupSource(
          fileName: kWeeklyBackupFileName,
          write: writeWeeklyBackup,
        ),
      ];
}
