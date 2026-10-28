import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app_core/mini_app_core.dart';

import 'backup_prompt.dart';
import 'launcher_screen.dart';
import 'strings.dart';

/// Gốc super app: hiển thị **hoặc** màn hình chính **hoặc** đúng một mini app.
///
/// Mini app thay chỗ màn hình chính chứ không được push lên trên nó — xem
/// [MiniAppHost] để biết vì sao.
///
/// Container của mỗi mini app được tạo ở lần mở đầu tiên rồi giữ tới khi vỏ
/// đóng: mở lại thì vào ngay, trạng thái còn nguyên. Không có ProviderScope ở
/// tầng vỏ — vỏ không chia sẻ trạng thái nào với mini app.
class SuperApp extends StatefulWidget {
  const SuperApp({super.key, required this.apps});

  final List<MiniApp> apps;

  @override
  State<SuperApp> createState() => _SuperAppState();
}

class _SuperAppState extends State<SuperApp> {
  // Lưu Future chứ không lưu container, để hai lần chạm liên tiếp không mở
  // kho dữ liệu hai lần.
  final _containers = <String, Future<ProviderContainer>>{};
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  String? _openingId;
  ({MiniApp app, ProviderContainer container})? _active;

  Future<void> _open(MiniApp app) async {
    if (_openingId != null) return;
    setState(() => _openingId = app.id);
    try {
      final container =
          await _containers.putIfAbsent(app.id, app.createContainer);
      if (mounted) setState(() => _active = (app: app, container: container));
    } catch (_) {
      _containers.remove(app.id);
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('${S.openFailed}: ${app.title}')),
      );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  void _close() => setState(() => _active = null);

  @override
  void dispose() {
    for (final future in _containers.values) {
      future.then((container) => container.dispose(), onError: (_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: active == null
          ? _LauncherApp(
              key: const ValueKey('launcher'),
              messengerKey: _messengerKey,
              apps: widget.apps,
              openingId: _openingId,
              onOpen: _open,
            )
          : MiniAppHost(
              key: ValueKey(active.app.id),
              app: active.app,
              container: active.container,
              onExit: _close,
            ),
    );
  }
}

class _LauncherApp extends StatelessWidget {
  const _LauncherApp({
    super.key,
    required this.messengerKey,
    required this.apps,
    required this.openingId,
    required this.onOpen,
  });

  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final List<MiniApp> apps;
  final String? openingId;
  final ValueChanged<MiniApp> onOpen;

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) => ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: brightness,
          ),
        );

    return MaterialApp(
      title: S.appTitle,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: WeeklyBackupPrompt(
        apps: apps,
        builder: (context, backupNow) => LauncherScreen(
          apps: apps,
          openingId: openingId,
          onOpen: onOpen,
          onBackupNow: backupNow,
        ),
      ),
    );
  }
}
