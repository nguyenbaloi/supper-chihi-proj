import 'package:flutter/material.dart';

/// Có mặt trong cây widget khi mini app đang được super app chứa.
///
/// Chạy độc lập thì không có scope này, mọi thứ dựa vào nó tự biến mất.
class MiniAppScope extends InheritedWidget {
  const MiniAppScope({super.key, required this.onExit, required super.child});

  /// Đóng mini app, quay về màn hình chính của super app.
  final VoidCallback onExit;

  static MiniAppScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MiniAppScope>();

  /// Nút quay về super app, dành cho `AppBar.leading` của các màn hình tab gốc.
  ///
  /// Trả về `null` — tức để AppBar tự quyết như cũ — khi chạy độc lập, hoặc
  /// khi màn hình không nằm ở route đầu tiên (nút back thường phải được giữ).
  static Widget? exitButtonOf(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null) return null;
    if (!(ModalRoute.of(context)?.isFirst ?? true)) return null;
    return IconButton(
      tooltip: MiniAppStrings.backToHome,
      icon: const Icon(Icons.apps),
      onPressed: scope.onExit,
    );
  }

  @override
  bool updateShouldNotify(MiniAppScope oldWidget) => onExit != oldWidget.onExit;
}

/// Chuỗi hiển thị của lớp vỏ mini app.
abstract final class MiniAppStrings {
  static const backToHome = 'Về màn hình chính';
}
