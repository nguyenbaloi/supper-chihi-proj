import 'dart:io';

import 'package:flutter/foundation.dart';

/// Một tệp dữ liệu mini app giao cho super app xuất ra định kỳ.
///
/// Super app không biết bên trong tệp là gì — chỉ biết tên và cách ghi. Bản
/// ghi ra phải là thứ mà chính mini app **nhập lại được** khi cài lại ứng
/// dụng, nếu không thì sao lưu chỉ là cảm giác an toàn giả.
@immutable
class BackupSource {
  const BackupSource({required this.fileName, required this.write});

  /// Tên tệp đích, cố định qua mọi lần xuất để lần sau ghi đè lần trước.
  final String fileName;

  /// Ghi toàn bộ dữ liệu vào [target] — một tệp chưa tồn tại.
  ///
  /// Trả về `false` khi chưa có gì để xuất (mini app chưa từng mở). Được gọi
  /// cả khi mini app chưa mở, nên không được dựa vào container của nó.
  final Future<bool> Function(File target) write;
}
