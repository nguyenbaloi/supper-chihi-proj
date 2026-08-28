import 'dart:io';
import 'package:image/image.dart';

void main(List<String> args) {
  final img = decodeImage(File(args[0]).readAsBytesSync())!;
  double lum(int x, int y) {
    final p = img.getPixel(x, y);
    return p.r.toDouble() * 0.299 + p.g.toDouble() * 0.587 + p.b.toDouble() * 0.114;
  }
  String hex(int x, int y) {
    final p = img.getPixel(x, y);
    return '#${p.r.toInt().toRadixString(16).padLeft(2, '0')}'
        '${p.g.toInt().toRadixString(16).padLeft(2, '0')}'
        '${p.b.toInt().toRadixString(16).padLeft(2, '0')}';
  }

  const tileX = 78, tileY = 61, tileW = 638, tileH = 555;
  // Vùng chắc chắn nằm sâu trong ô icon, tránh cả góc bo lẫn viền.
  final ix = tileX + 40, iy = tileY + 40, iw = tileW - 80, ih = tileH - 80;

  stdout.writeln('nền sâu trong ô: ${hex(396, tileY + 40)} ${hex(ix, 330)} '
      '${hex(tileX + tileW - 40, 330)} ${hex(396, tileY + tileH - 40)}');
  final bgLum = lum(396, tileY + 40);
  stdout.writeln('lum nền trong = ${bgLum.round()}');

  for (final over in [3.0, 6.0, 12.0]) {
    final thr = bgLum + over;
    int? minX, maxX, minY, maxY;
    for (var y = iy; y < iy + ih; y++) {
      for (var x = ix; x < ix + iw; x++) {
        if (lum(x, y) < thr) continue;
        minX = (minX == null || x < minX) ? x : minX;
        maxX = (maxX == null || x > maxX) ? x : maxX;
        minY = (minY == null || y < minY) ? y : minY;
        maxY = (maxY == null || y > maxY) ? y : maxY;
      }
    }
    stdout.writeln('nền+$over → glyph x=$minX..$maxX (rộng ${maxX! - minX! + 1}) '
        'y=$minY..$maxY (cao ${maxY! - minY! + 1}) tâm=(${(minX + maxX) ~/ 2},${(minY + maxY) ~/ 2})');
  }
}
