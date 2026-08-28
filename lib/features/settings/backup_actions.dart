import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/strings.dart';
import '../../presentation/providers/providers.dart';

/// FR-31: xuất một file JSON rồi trao cho chức năng chia sẻ của hệ điều hành.
Future<void> runExport(BuildContext context, WidgetRef ref) async {
  final service = ref.read(backupServiceProvider);
  final messenger = ScaffoldMessenger.of(context);
  // Lấy điểm neo **trước** mọi lần await: sau await thì context có thể đã chết.
  final anchor = _anchorOf(context);

  final json = await service.exportJson();
  final name = service.fileNameFor(DateTime.now());
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$name');
  await file.writeAsString(json);

  // Trên iPad, bảng chia sẻ là popover và **bắt buộc** phải có điểm neo —
  // thiếu nó là crash, không phải hiện sai chỗ.
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      sharePositionOrigin: anchor,
    ),
  );
  messenger.showSnackBar(SnackBar(content: Text(S.backupExported(name))));
}

/// FR-32: thay thế toàn bộ, có xác nhận, và không đụng dữ liệu cũ nếu file hỏng.
Future<void> runImport(BuildContext context, WidgetRef ref) async {
  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (picked == null || !context.mounted) return;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(S.backupImportTitle),
      content: const Text(S.backupImportConfirm),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(S.cancel)),
        FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(S.backupImportReplace)),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  // Đọc bằng UTF-8: nội dung có dấu tiếng Việt, `String.fromCharCodes` sẽ hỏng.
  final raw = utf8.decode(await picked.readAsBytes());

  final result = await ref.read(backupServiceProvider).import(raw);
  result.fold(
    (count) => messenger
        .showSnackBar(SnackBar(content: Text(S.backupImported(count)))),
    (failure) => messenger.showSnackBar(
      SnackBar(content: Text(S.backupFailed(S.backupFailureReason(failure.code)))),
    ),
  );
}

/// FR-34: xoá sạch có xác nhận **hai bước** và gợi ý xuất sao lưu trước.
Future<void> runWipe(BuildContext context, WidgetRef ref) async {
  final first = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(S.backupWipe),
      content: const Text(S.backupWipeStep1),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(S.cancel)),
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(S.backupWipeConfirm)),
      ],
    ),
  );
  if (first != true || !context.mounted) return;

  final second = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(S.backupWipe),
      content: const Text(S.backupWipeStep2),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(S.cancel)),
        FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(S.backupWipeConfirm)),
      ],
    ),
  );
  if (second != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  await ref.read(backupServiceProvider).wipeAll();
  messenger.showSnackBar(const SnackBar(content: Text(S.backupWipeDone)));
}

/// Ô chữ nhật của widget vừa được chạm, dùng làm điểm neo popover trên iPad.
/// Trả về một ô ở giữa màn hình nếu không lấy được — vẫn hơn là để `null`.
Rect _anchorOf(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box != null && box.hasSize) {
    return box.localToGlobal(Offset.zero) & box.size;
  }
  final size = MediaQuery.of(context).size;
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: 1,
    height: 1,
  );
}
