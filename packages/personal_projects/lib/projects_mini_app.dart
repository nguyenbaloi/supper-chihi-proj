import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mini_app_core/mini_app_core.dart';

import 'app.dart';
import 'data/backup/weekly_backup.dart';
import 'core/l10n/strings.dart';
import 'presentation/theme/app_theme.dart';

/// Điểm vào duy nhất của ứng dụng — dùng chung cho `main()` độc lập và super app.
class ProjectsMiniApp implements MiniApp {
  const ProjectsMiniApp();

  @override
  String get id => 'personal_projects';

  @override
  String get title => S.appTitle;

  @override
  IconData get icon => Icons.folder;

  @override
  Color get color => AppColors.seed;

  @override
  Future<ProviderContainer> createContainer() async {
    // Định dạng ngày kiểu Việt Nam cần dữ liệu locale được nạp trước.
    await initializeDateFormatting('vi_VN');
    return ProviderContainer();
  }

  @override
  Widget buildApp() => const PersonalProjectsApp();

  // Tệp JSON nhập lại được bằng nút Nhập sao lưu trong Cài đặt.
  @override
  List<BackupSource> get backupSources => const [
        BackupSource(
          fileName: kWeeklyBackupFileName,
          write: writeWeeklyBackup,
        ),
      ];
}
