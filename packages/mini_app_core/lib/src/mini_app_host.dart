import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mini_app.dart';
import 'mini_app_scope.dart';

/// Gốc ứng dụng trong lúc một mini app đang mở.
///
/// Phải đặt **thay cho** màn hình chính của super app, không được push lên
/// navigator của nó: `showDialog` mặc định tìm navigator xa nhất trong cây
/// (`rootNavigator: true`), vượt qua cả `MaterialApp` lồng bên trong. Lồng vào
/// thì mọi dialog của mini app rơi ra ngoài container Riverpod và
/// localizations của chính nó.
///
/// Nút Back: `WidgetsBinding.handlePopRoute` hỏi các observer theo thứ tự đăng
/// ký. Host đăng ký sau khung hình đầu, tức là sau `MaterialApp` của mini app,
/// nên chỉ nhận Back khi mini app không còn gì để pop — lúc đó mới thoát.
class MiniAppHost extends StatefulWidget {
  const MiniAppHost({
    super.key,
    required this.app,
    required this.container,
    required this.onExit,
  });

  final MiniApp app;
  final ProviderContainer container;
  final VoidCallback onExit;

  @override
  State<MiniAppHost> createState() => _MiniAppHostState();
}

class _MiniAppHostState extends State<MiniAppHost> with WidgetsBindingObserver {
  late final Widget _app = widget.app.buildApp();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) WidgetsBinding.instance.addObserver(this);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    widget.onExit();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: widget.container,
      child: MiniAppScope(onExit: widget.onExit, child: _app),
    );
  }
}
