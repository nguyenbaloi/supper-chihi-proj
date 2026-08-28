import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/db/backup_file.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/confirm_dialog.dart';

/// Sao lưu và khôi phục toàn bộ cơ sở dữ liệu — đường chuyển dữ liệu sang máy
/// mới. Tệp CSV của `export_service.dart` là bản đọc cho người, không khôi
/// phục lại được.

/// Chép cơ sở dữ liệu ra một tệp `.sqlite` rồi mở hộp chia sẻ của hệ điều
/// hành, để người dùng cất vào nơi họ chọn.
Future<void> backupAndShare(BuildContext context, WidgetRef ref) async {
  final l10n = AppL10n.of(context);
  final db = ref.read(databaseProvider);

  final File target;
  try {
    final source = await liveDatabaseFile();
    final dir = await getTemporaryDirectory();
    target = await writeBackupCopy(
      db: db,
      source: source,
      target: File('${dir.path}/${backupFileName(DateTime.now())}'),
    );
  } on Object {
    if (context.mounted) _toast(context, l10n.backupFailed);
    return;
  }

  await ref.read(settingsRepositoryProvider).markExported(
        DateTime.now().toUtc(),
      );

  if (!context.mounted) return;
  await SharePlus.instance.share(
    ShareParams(files: [XFile(target.path)], text: l10n.settingsBackup),
  );
}

/// Chọn một tệp sao lưu và thay toàn bộ dữ liệu hiện tại bằng nó.
///
/// Ba cửa trước khi ghi: tệp phải là bản sao lưu hợp lệ, người dùng phải xác
/// nhận việc mất dữ liệu hiện có, và cơ sở dữ liệu phải đóng trước khi tệp bị
/// thay. Xem `backup_file.dart`.
Future<void> restoreFromBackup(BuildContext context, WidgetRef ref) async {
  final l10n = AppL10n.of(context);

  // FileType.any chứ không lọc theo đuôi tệp: nhiều trình quản lý tệp trên
  // Android không nhận ra đuôi `.sqlite` và sẽ làm mờ đúng tệp cần chọn.
  final picked = await FilePicker.pickFile(dialogTitle: l10n.settingsRestore);
  final path = picked?.path;
  if (path == null) return;

  final check = await inspectBackupFile(
    File(path),
    currentSchemaVersion: ref.read(databaseProvider).schemaVersion,
  );
  if (!context.mounted) return;
  if (check is BackupRejected) {
    _toast(context, _rejectionMessage(l10n, check.reason));
    return;
  }

  final confirmed = await confirmAction(
    context,
    title: l10n.restoreWarningTitle,
    body: l10n.restoreWarningBody,
    confirmLabel: l10n.settingsRestore,
  );
  if (!confirmed || !context.mounted) return;

  // Che màn hình trong lúc cơ sở dữ liệu đóng: các provider đang đọc dữ liệu
  // sẽ thấy nó biến mất trong khoảnh khắc tệp bị thay.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  var restored = true;
  try {
    await ref.read(databaseHostProvider.notifier).reopen(() async {
      await replaceDatabaseFile(
        backup: File(path),
        target: await liveDatabaseFile(),
      );
    });
  } on Object {
    restored = false;
  }

  if (!context.mounted) return;
  Navigator.of(context).pop();
  _toast(context, restored ? l10n.restoreDone : l10n.restoreFailed);
}

String _rejectionMessage(AppL10n l10n, BackupRejection reason) =>
    switch (reason) {
      BackupRejection.unreadable => l10n.restoreRejectedUnreadable,
      BackupRejection.notSqlite => l10n.restoreRejectedNotSqlite,
      BackupRejection.missingTables => l10n.restoreRejectedMissingTables,
      BackupRejection.futureSchema => l10n.restoreRejectedFutureSchema,
    };

void _toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
