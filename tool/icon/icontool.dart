import 'dart:io';

import 'package:image/image.dart';

/// Sinh bộ icon iOS và Android từ `design/app_icon_chichi_projects.png`.
///
/// Ảnh gốc là ảnh giới thiệu: ô icon bo góc **638×555** nằm trên nền navy nhạt
/// hơn, kèm dòng chữ "Chichi PROJECTS" phía dưới. Icon thì phải **vuông và tràn
/// viền** vì iOS với Android tự bo góc theo cách riêng của chúng.
///
/// Không cắt thẳng ô icon: nó không vuông, cắt vuông thì mất lề hai bên và lộ
/// vệt nền ngoài ở mép trên dưới. Thay vào đó **ghép lại**:
///
/// 1. Nền trong ô icon là một màu phẳng `#030b1e` — dựng khung vuông bằng màu đó.
/// 2. Cắt riêng vùng glyph kèm quầng sáng, nền của nó cũng đúng màu ấy nên dán
///    vào không để lại đường nối.
/// 3. Căn glyph vào **đúng tâm** khung. Trong ảnh gốc glyph lệch trái 33 điểm
///    so với tâm ô icon; lệch tâm trên một icon vuông trông như lỗi.
void main(List<String> args) {
  final srcPath = args[0];
  final iosDir = args[1];
  final androidResDir = args[2];
  final previewPath = args[3];
  final previewOnly = args.length > 4 && args[4] == 'preview-only';

  final src = decodeImage(File(srcPath).readAsBytesSync())!;

  // Đo bằng bin/probe.dart trên chính ảnh gốc.
  const glyphX = 163, glyphY = 169, glyphW = 401, glyphH = 323;
  const pad = 26; // lề an toàn quanh glyph, vẫn nằm sâu trong ô icon

  /// Glyph chiếm bao nhiêu phần bề ngang của icon. 0,62 cho lề thoáng, đúng
  /// tỷ lệ quen thuộc của icon trên iOS.
  const fillRatio = 0.62;
  const canvas = 1024;

  final cropX = glyphX - pad;
  final cropY = glyphY - pad;
  final cropW = glyphW + pad * 2;
  final cropH = glyphH + pad * 2;

  final glyph = copyCrop(src, x: cropX, y: cropY, width: cropW, height: cropH);

  final scale = (canvas * fillRatio) / glyphW;
  final destW = (cropW * scale).round();
  final destH = (cropH * scale).round();
  final scaled =
      copyResize(glyph, width: destW, height: destH, interpolation: Interpolation.cubic);

  final master = Image(width: canvas, height: canvas, numChannels: 3);
  fill(master, color: ColorUint8.rgb(0x03, 0x0b, 0x1e));
  compositeImage(
    master,
    scaled,
    dstX: (canvas - destW) ~/ 2,
    dstY: (canvas - destH) ~/ 2,
  );

  File(previewPath).writeAsBytesSync(encodePng(master));
  stdout.writeln('xem trước: $previewPath  (glyph ${destW}x$destH trên khung $canvas)');
  if (previewOnly) return;

  const iosSizes = <String, int>{
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };
  const androidSizes = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final e in iosSizes.entries) {
    final out = e.value == canvas
        ? master
        : copyResize(master,
            width: e.value, height: e.value, interpolation: Interpolation.average);
    File('$iosDir/${e.key}').writeAsBytesSync(encodePng(out));
  }
  stdout.writeln('đã ghi ${iosSizes.length} icon iOS');

  for (final e in androidSizes.entries) {
    final out = copyResize(master,
        width: e.value, height: e.value, interpolation: Interpolation.average);
    final dir = Directory('$androidResDir/${e.key}')..createSync(recursive: true);
    File('${dir.path}/ic_launcher.png').writeAsBytesSync(encodePng(out));
  }
  stdout.writeln('đã ghi ${androidSizes.length} icon Android');
}
