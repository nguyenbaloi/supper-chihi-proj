import 'package:flutter/material.dart';
import 'package:mini_app_core/mini_app_core.dart';

import 'strings.dart';

/// Màn hình chính: lưới các mini app.
class LauncherScreen extends StatelessWidget {
  const LauncherScreen({
    super.key,
    required this.apps,
    required this.openingId,
    required this.onOpen,
    this.onBackupNow,
  });

  final List<MiniApp> apps;

  /// Mini app đang khởi tạo, hiện vòng quay trên ô của nó.
  final String? openingId;
  final ValueChanged<MiniApp> onOpen;

  /// `null` khi không mini app nào có dữ liệu để sao lưu.
  final VoidCallback? onBackupNow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.appTitle),
        actions: [
          if (onBackupNow case final onBackupNow?)
            IconButton(
              tooltip: S.backupNow,
              icon: const Icon(Icons.save_alt),
              onPressed: onBackupNow,
            ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          for (final app in apps)
            _MiniAppTile(
              app: app,
              loading: openingId == app.id,
              onTap: () => onOpen(app),
            ),
        ],
      ),
    );
  }
}

class _MiniAppTile extends StatelessWidget {
  const _MiniAppTile({
    required this.app,
    required this.loading,
    required this.onTap,
  });

  final MiniApp app;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: app.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Icon(app.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            app.title,
            style: theme.textTheme.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
