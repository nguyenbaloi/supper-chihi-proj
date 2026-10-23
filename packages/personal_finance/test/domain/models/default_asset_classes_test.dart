import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/domain/models/default_asset_classes.dart';
import 'package:personal_finance/domain/models/enums.dart';

void main() {
  group('Năm lớp tài sản dựng sẵn', () {
    test('đúng năm lớp, đúng tên, đúng thứ tự', () {
      expect(
        defaultAssetClasses.map((s) => s.name),
        ['Chứng khoán', 'Vàng', 'Crypto', 'Tiền mặt & Tiết kiệm', 'Cho vay'],
      );
    });

    test('phủ hết năm loại, mỗi loại đúng một lần', () {
      expect(
        defaultAssetClasses.map((s) => s.kind).toSet(),
        AssetKind.values.toSet(),
      );
      expect(defaultAssetClasses.length, AssetKind.values.length);
    });

    test('màu phân biệt được với nhau trên biểu đồ tròn', () {
      final colors = defaultAssetClasses.map((s) => s.colorValue).toSet();
      expect(colors.length, defaultAssetClasses.length);
    });

    test('mỗi lớp một biểu tượng riêng', () {
      final icons = defaultAssetClasses.map((s) => s.iconCodePoint).toSet();
      expect(icons.length, defaultAssetClasses.length);
    });

    test('màu đều đục hoàn toàn để vẽ biểu đồ không bị lẫn nền', () {
      for (final seed in defaultAssetClasses) {
        final alpha = (seed.colorValue >> 24) & 0xFF;
        expect(alpha, 0xFF, reason: '${seed.name} có màu không đục');
      }
    });

    test('sortOrder liên tục từ 0, không trùng', () {
      expect(
        defaultAssetClasses.map((s) => s.sortOrder),
        List.generate(defaultAssetClasses.length, (i) => i),
      );
    });

    test('nhóm đầu tư gồm đúng hai lớp: Chứng khoán và Crypto', () {
      // Vàng và tiền mặt bị loại trừ có chủ đích — chúng không tham gia công
      // thức Lãi lỗ. Xem FR-25 và quy tắc 2 của CLAUDE.md.
      final inGroup = defaultAssetClasses
          .where((s) => s.inInvestmentGroup)
          .map((s) => s.kind)
          .toSet();
      expect(inGroup, {AssetKind.stock, AssetKind.crypto});
    });
  });
}
