import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/format/vn_format.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/models/asset_class.dart';
import 'package:personal_finance/domain/models/enums.dart';
import 'package:personal_finance/domain/models/portfolio_valuation.dart';
import 'package:personal_finance/domain/rules/portfolio_math.dart';

/// Bốn lớp tài sản với đúng con số của Excel gốc, đơn vị triệu đồng:
/// Chứng khoán 15, Tiền mặt 92, Crypto 390, Cho vay 183 — tổng 680.
AssetClass _class(
  int id,
  String name,
  AssetKind kind, {
  bool hidden = false,
  bool inInvestmentGroup = false,
  int? targetWeightBp,
}) =>
    AssetClass(
      id: id,
      name: name,
      kind: kind,
      colorValue: 0xFF000000,
      iconCodePoint: 0xe000,
      hidden: hidden,
      inInvestmentGroup: inInvestmentGroup,
      targetWeightBp: targetWeightBp,
      sortOrder: id,
    );

void main() {
  final stock = _class(1, 'Chứng khoán', AssetKind.stock,
      inInvestmentGroup: true);
  final cash = _class(2, 'Tiền mặt & Tiết kiệm', AssetKind.cashSavings);
  final crypto = _class(3, 'Crypto', AssetKind.crypto,
      inInvestmentGroup: true);
  final lending = _class(4, 'Cho vay', AssetKind.lending);

  const values = {
    1: Money(15000000),
    2: Money(92000000),
    3: Money(390000000),
    4: Money(183000000),
  };

  group('Giá trị lớp tài sản', () {
    test('lớp chỉ có FPT 15 triệu thì giá trị lớp là 15 triệu', () {
      expect(
        PortfolioMath.assetClassValue(const [Money(15000000)]),
        const Money(15000000),
      );
    });

    test('lớp rỗng có giá trị 0 đồng', () {
      expect(PortfolioMath.assetClassValue(const []), Money.zero);
    });

    test('tổng các khoản nắm giữ bằng đúng giá trị lớp, không lệch một đồng',
        () {
      // Ba khoản lẻ cố tình không tròn triệu.
      const holdings = [
        Money(12345678),
        Money(2654321),
        Money(1),
      ];
      expect(
        PortfolioMath.assetClassValue(holdings),
        const Money(15000000),
      );
    });

    test('lớp chưa có khoản nắm giữ vẫn là lớp hợp lệ với giá trị 0', () {
      final valuation = PortfolioMath.valuation([stock, cash], const {
        1: Money(15000000),
      });
      expect(valuation.entries.last.value, Money.zero);
    });
  });

  group('Tổng tài sản', () {
    test('15 + 92 + 390 + 183 triệu cho đúng 680 triệu', () {
      final valuation =
          PortfolioMath.valuation([stock, cash, crypto, lending], values);
      expect(valuation.totalAssets, const Money(680000000));
    });

    test('khớp con số Excel gốc khi hiển thị', () {
      final valuation =
          PortfolioMath.valuation([stock, cash, crypto, lending], values);
      expect(VnFormat.money(valuation.totalAssets), '680.000.000 đ');
      expect(VnFormat.moneyCompact(valuation.totalAssets), '680 tr');
    });

    test('lớp bị ẩn không được cộng vào tổng', () {
      final hiddenLending = _class(4, 'Cho vay', AssetKind.lending,
          hidden: true);
      final valuation = PortfolioMath.valuation(
        [stock, cash, crypto, hiddenLending],
        values,
      );

      expect(valuation.totalAssets, const Money(497000000));
      expect(valuation.visible, hasLength(3));
      // Lớp ẩn vẫn còn trong danh sách đầy đủ — ẩn không phải là xoá.
      expect(valuation.entries, hasLength(4));
    });

    test('ẩn hết thì tổng bằng 0 chứ không phải lỗi', () {
      final valuation = PortfolioMath.valuation(
        [_class(1, 'Chứng khoán', AssetKind.stock, hidden: true)],
        const {1: Money(15000000)},
      );
      expect(valuation.totalAssets, Money.zero);
    });

    test('danh mục rỗng cho tổng 0 đồng', () {
      expect(PortfolioValuation.empty.totalAssets, Money.zero);
    });
  });

  group('Tỷ trọng thực tế', () {
    late PortfolioValuation valuation;

    setUp(() {
      valuation =
          PortfolioMath.valuation([stock, cash, crypto, lending], values);
    });

    test('bốn lớp cho đúng nhãn biểu đồ tròn của Excel', () {
      final labels = [1, 2, 3, 4]
          .map((id) => VnFormat.percent(valuation.weightOf(id)!))
          .toList();
      expect(labels, ['2,2%', '13,5%', '57,4%', '26,9%']);
    });

    test('tổng tài sản bằng 0 thì tỷ trọng là null, không phải 0', () {
      // Trả về 0 sẽ vẽ ra một biểu đồ tròn trông như thật.
      final empty = PortfolioMath.valuation([stock], const {1: Money.zero});
      expect(empty.weightOf(1), isNull);
    });

    test('lớp bị ẩn không có tỷ trọng', () {
      final hidden = PortfolioMath.valuation(
        [stock, _class(2, 'Tiền mặt', AssetKind.cashSavings, hidden: true)],
        values,
      );
      expect(hidden.weightOf(2), isNull);
    });

    test('lớp không tồn tại trả về null', () {
      expect(valuation.weightOf(999), isNull);
    });

    test('weight tính trực tiếp khớp với weightOf', () {
      expect(
        PortfolioMath.weight(const Money(390000000), const Money(680000000)),
        valuation.weightOf(3),
      );
    });
  });

  group('Sắp xếp danh sách hiển thị', () {
    test('theo giá trị giảm dần', () {
      final valuation =
          PortfolioMath.valuation([stock, cash, crypto, lending], values);
      expect(
        valuation.byValueDescending.map((e) => e.assetClass.name),
        ['Crypto', 'Cho vay', 'Tiền mặt & Tiết kiệm', 'Chứng khoán'],
      );
    });

    test('lớp bị ẩn không xuất hiện trong danh sách', () {
      final valuation = PortfolioMath.valuation(
        [stock, _class(3, 'Crypto', AssetKind.crypto, hidden: true)],
        values,
      );
      expect(
        valuation.byValueDescending.map((e) => e.assetClass.name),
        ['Chứng khoán'],
      );
    });
  });

  group('Giá trị nhóm đầu tư', () {
    test('chỉ gồm Chứng khoán và Crypto', () {
      final valuation =
          PortfolioMath.valuation([stock, cash, crypto, lending], values);
      // 15 + 390, không có tiền mặt và cho vay.
      expect(valuation.investmentGroupValue, const Money(405000000));
    });

    test('lớp trong nhóm đầu tư mà bị ẩn thì không tính', () {
      final valuation = PortfolioMath.valuation(
        [
          stock,
          _class(3, 'Crypto', AssetKind.crypto,
              inInvestmentGroup: true, hidden: true),
        ],
        values,
      );
      expect(valuation.investmentGroupValue, const Money(15000000));
    });
  });

  group('Khoảng lệch so với tỷ trọng mục tiêu', () {
    test('thực tế 57,4% so với mục tiêu 50% cho lệch dương', () {
      final actual = PortfolioMath.weight(
        const Money(390000000),
        const Money(680000000),
      );
      expect(PortfolioMath.driftBp(actual, 5000), 735);
    });

    test('chưa đặt mục tiêu thì không có khoảng lệch', () {
      expect(PortfolioMath.driftBp(Decimal.parse('0.5'), null), isNull);
    });

    test('chưa tính được tỷ trọng thì không có khoảng lệch', () {
      expect(PortfolioMath.driftBp(null, 5000), isNull);
    });

    test('đúng mục tiêu thì lệch bằng 0', () {
      expect(PortfolioMath.driftBp(Decimal.parse('0.5'), 5000), 0);
    });
  });
}
