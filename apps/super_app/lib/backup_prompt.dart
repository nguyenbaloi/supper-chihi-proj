import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mini_app_core/mini_app_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'strings.dart';
import 'weekly_backup.dart';

/// Hỏi người dùng mỗi khi đến hạn sao lưu hằng tuần, rồi xuất dữ liệu của
/// mọi mini app có [MiniApp.backupSources] vào app Tệp.
///
/// Kiểm tra mỗi lần màn hình chính hiện ra và mỗi lần ứng dụng quay lại tiền
/// cảnh — không chạy nền: iOS không bảo đảm giờ chạy nền, còn người dùng muốn
/// được hỏi trước mỗi lần xuất.
class WeeklyBackupPrompt extends StatefulWidget {
  WeeklyBackupPrompt({
    super.key,
    required this.apps,
    required this.builder,
    Future<WeeklyBackup> Function()? openSchedule,
    Future<Directory> Function()? backupDirectory,
  })  : openSchedule = openSchedule ??
            (() async => WeeklyBackup(await SharedPreferences.getInstance())),
        backupDirectory = backupDirectory ?? getApplicationDocumentsDirectory;

  final List<MiniApp> apps;

  /// Dựng màn hình chính. `backupNow` là `null` khi không mini app nào có dữ
  /// liệu để xuất.
  final Widget Function(BuildContext context, VoidCallback? backupNow) builder;

  final Future<WeeklyBackup> Function() openSchedule;
  final Future<Directory> Function() backupDirectory;

  @override
  State<WeeklyBackupPrompt> createState() => _WeeklyBackupPromptState();
}

class _WeeklyBackupPromptState extends State<WeeklyBackupPrompt>
    with WidgetsBindingObserver {
  late final _apps = [
    for (final app in widget.apps)
      if (app.backupSources.isNotEmpty) app,
  ];
  Future<WeeklyBackup>? _schedule;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (_apps.isEmpty) return;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _askIfDue());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _askIfDue();
  }

  Future<void> _askIfDue() async {
    if (_busy) return;
    _busy = true;
    try {
      final schedule = await (_schedule ??= widget.openSchedule());
      if (!mounted || !schedule.isDue) return;

      final confirmed = await _confirm();
      // Chạm ra ngoài hộp thoại cũng tính là "Để sau", không phải "không bao
      // giờ": không hoãn thì nó hiện lại ngay ở lần quay về màn hình chính.
      if (confirmed == true) {
        await _run(schedule);
      } else {
        await schedule.snooze();
      }
    } on Object {
      // Không đọc được lịch thì thôi hỏi lần này; sao lưu không được phép
      // chặn người dùng vào mini app.
    } finally {
      _busy = false;
    }
  }

  Future<void> _backupNow() async {
    if (_busy) return;
    _busy = true;
    try {
      final schedule = await (_schedule ??= widget.openSchedule());
      if (await _confirm() == true) await _run(schedule);
    } on Object {
      _toast(S.backupFailed(_apps.map((a) => a.title)));
    } finally {
      _busy = false;
    }
  }

  Future<bool?> _confirm() async {
    if (!mounted) return null;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.backupDueTitle),
        content: Text(S.backupDueBody(_apps.map((a) => a.title))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(S.backupLater),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(S.backupConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _run(WeeklyBackup schedule) async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    Map<BackupSource, BackupOutcome> outcomes;
    try {
      outcomes = await schedule.run(
        await widget.backupDirectory(),
        [for (final app in _apps) ...app.backupSources],
      );
    } finally {
      if (mounted) Navigator.of(context).pop();
    }

    final failed = [
      for (final app in _apps)
        if (app.backupSources
            .any((s) => outcomes[s] == BackupOutcome.failed))
          app.title,
    ];
    if (failed.isNotEmpty) {
      _toast(S.backupFailed(failed));
    } else if (outcomes.containsValue(BackupOutcome.written)) {
      _toast(S.backupDone);
    } else {
      _toast(S.backupNothing);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _apps.isEmpty ? null : _backupNow);
}
