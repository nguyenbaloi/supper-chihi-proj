import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Hàng rào cho AD-1: `lib/domain/` là Dart thuần.
///
/// Test này tồn tại vì vi phạm AD-1 không gây lỗi biên dịch — nó chỉ âm thầm
/// làm logic nghiệp vụ dính vào Flutter hoặc vào hình dạng JSON của một nhà
/// cung cấp, và tới lúc phát hiện thì đã muộn.
/// Nội dung pubspec đã bỏ mọi chú thích — để chữ trong comment không bị nhầm
/// thành tên phụ thuộc.
String _pubspecWithoutComments() => File('pubspec.yaml')
    .readAsLinesSync()
    .map((line) {
      final hash = line.indexOf('#');
      return hash == -1 ? line : line.substring(0, hash);
    })
    .join('\n');

void main() {
  test('AD-1: không file nào trong lib/domain import package ngoài', () {
    final domainDir = Directory('lib/domain');
    expect(domainDir.existsSync(), isTrue, reason: 'thiếu thư mục lib/domain');

    final importPattern =
        RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''', multiLine: true);
    final violations = <String>[];

    for (final entity in domainDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final match in importPattern.allMatches(source)) {
        final uri = match.group(1)!;
        if (uri.startsWith('package:')) {
          violations.add('${entity.path} → $uri');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'AD-1: lib/domain chỉ được import file cùng tầng và dart: lõi.\n'
          'Vi phạm:\n${violations.join('\n')}',
    );
  });

  test('AD-7: pubspec không có package biểu đồ', () {
    final pubspec = _pubspecWithoutComments();
    for (final banned in ['fl_chart', 'syncfusion', 'candlesticks', 'k_chart', 'graphic:']) {
      expect(
        pubspec.contains(banned),
        isFalse,
        reason: 'AD-7: biểu đồ tự vẽ bằng CustomPainter, không thêm "$banned"',
      );
    }
  });

  test('AD-8: không dùng codegen', () {
    final pubspec = _pubspecWithoutComments();
    for (final banned in ['build_runner', 'riverpod_generator', 'freezed', 'json_serializable']) {
      expect(
        pubspec.contains(banned),
        isFalse,
        reason: 'AD-8: khai báo provider và model thủ công, không thêm "$banned"',
      );
    }
    final generated = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.g.dart') || f.path.endsWith('.freezed.dart'));
    expect(generated, isEmpty, reason: 'AD-8: không được có file sinh mã');
  });

  test('NFR-4: không có package analytics / crash reporting / quảng cáo', () {
    final pubspec = _pubspecWithoutComments();
    for (final banned in ['firebase', 'sentry', 'analytics', 'admob', 'facebook']) {
      expect(
        pubspec.contains(banned),
        isFalse,
        reason: 'NFR-4: app không gửi dữ liệu nào ra ngoài. Bỏ "$banned"',
      );
    }
  });

  test('AD-11: literal ngưỡng RSI chỉ nằm trong constants.dart', () {
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('domain/constants.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        // Bắt các literal ngưỡng đứng riêng, ví dụ `rsi < 30` hay `period: 14`.
        if (RegExp(r'(?<![\w.])(30|70|14)(?![\w.])').hasMatch(line) &&
            RegExp(r'rsi|Rsi|RSI|threshold|Threshold|period|Period',
                    caseSensitive: true)
                .hasMatch(line)) {
          offenders.add('${entity.path}:${i + 1}  $line');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'AD-11: dùng hằng số từ domain/constants.dart.\n'
          '${offenders.join('\n')}',
    );
  });

  test('AD-10: chuỗi hiển thị trong lib/ui chỉ nằm ở strings.dart', () {
    // Chỉ quét `lib/ui/` — đây là tầng duy nhất vẽ ra màn hình. Thông điệp
    // chẩn đoán ở `lib/data/` và assert ở `lib/domain/` không bao giờ tới mắt
    // người dùng nên nằm ngoài phạm vi quy tắc.
    final vietnamese = RegExp(
      '[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ]',
      caseSensitive: false,
    );
    final literal = RegExp(r"'([^'\\]*)'");
    final offenders = <String>[];

    for (final entity in Directory('lib/ui').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('ui/strings.dart')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final trimmed = lines[i].trimLeft();
        if (trimmed.startsWith('//')) continue;
        for (final match in literal.allMatches(lines[i])) {
          if (vietnamese.hasMatch(match.group(1)!)) {
            offenders.add('${entity.path}:${i + 1}  ${match.group(0)}');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'AD-10: đưa chuỗi này vào lib/ui/strings.dart.\n'
          '${offenders.join('\n')}',
    );
  });
}
