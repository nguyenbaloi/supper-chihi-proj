import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';

/// Hỏi xác nhận trước một thao tác không hoàn tác được.
///
/// Trả về `true` khi người dùng đồng ý. Mọi lệnh xoá trong ứng dụng đều đi
/// qua đây — xoá nhầm một Dòng vốn làm lệch toàn bộ lịch sử lãi lỗ.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  String? body,
  String? confirmLabel,
  bool destructive = true,
}) async {
  final l10n = AppL10n.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          child: Text(confirmLabel ?? l10n.actionConfirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
