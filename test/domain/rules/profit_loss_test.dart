import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/format/vn_format.dart';
import 'package:personal_finance/core/money/money.dart';
import 'package:personal_finance/domain/models/cash_flow.dart';
import 'package:personal_finance/domain/rules/contribution.dart';
import 'package:personal_finance/domain/rules/profit_loss.dart';

/// Đơn vị triệu đồng cho gọn — công thức không quan tâm bậc độ lớn.
Money _m(int millions) => Money(millions * 1000000);

CashFlow _flow(int id, int day, int millions) => CashFlow(
      id: id,
      date: DateTime.utc(2026, 1, day),
      amount: _m(millions),
    );

void main() {
  group('Bộ đối chiếu 10 dòng lấy từ Excel gốc', () {
    // Vốn góp khởi điểm 341. Năm dòng đầu không có nạp rút.
    // Từ dòng 6: −60, −36, +9, +47, +32.
    final initial = _m(341);
    final flows = [
      _flow(1, 6, -60),
      _flow(2, 7, -36),
      _flow(3, 8, 9),
      _flow(4, 9, 47),
      _flow(5, 10, 32),
    ];

    /// Giá trị Nhóm đầu tư của từng dòng, cột "Tài sản" trong Excel.
    const assets = [341, 302, 310, 173, 320, 311, 283, 321, 267, 233];

    /// Ngày của từng dòng.
    final days = List.generate(10, (i) => DateTime.utc(2026, 1, i + 1));

    test('cột vốn góp lũy kế khớp cả mười dòng', () {
      final actual = days
          .map((day) => Contribution.cumulativeAt(
                initialContribution: initial,
                cashFlows: flows,
                asOf: day,
              ))
          .map((m) => m.amount ~/ 1000000)
          .toList();

      expect(actual, [341, 341, 341, 341, 341, 281, 245, 254, 301, 333]);
    });

    test('cột lãi lỗ khớp cả mười dòng', () {
      final actual = List.generate(10, (i) {
        return ProfitLossRule.at(
          investmentGroupValue: _m(assets[i]),
          initialContribution: initial,
          cashFlows: flows,
          asOf: days[i],
        ).amount.amount ~/ 1000000;
      });

      expect(actual, [0, -39, -31, -168, -21, 30, 38, 67, -34, -100]);
    });

    test('dòng cuối cùng: tài sản 233, vốn góp 333, lỗ 100', () {
      final result = ProfitLossRule.current(
        investmentGroupValue: _m(233),
        initialContribution: initial,
        cashFlows: flows,
      );

      expect(result.cumulativeContribution, _m(333));
      expect(result.amount, _m(-100));
      expect(result.isLoss, isTrue);
      expect(VnFormat.moneyCompact(result.amount), '-100 tr');
    });

    test('dòng đầu tiên hoà vốn tuyệt đối', () {
      final result = ProfitLossRule.at(
        investmentGroupValue: _m(341),
        initialContribution: initial,
        cashFlows: flows,
        asOf: days.first,
      );
      expect(result.amount, Money.zero);
      expect(result.isProfit, isFalse);
      expect(result.isLoss, isFalse);
    });
  });

  group('Sửa một dòng vốn ở giữa chuỗi', () {
    // Chuỗi +341 khởi điểm, rồi −60, −36, +9.
    final initial = _m(341);

    test('sửa −60 thành −50 làm mọi giá trị phía sau đổi theo', () {
      final before = [
        _flow(1, 6, -60),
        _flow(2, 7, -36),
        _flow(3, 8, 9),
      ];
      final after = [
        _flow(1, 6, -50),
        _flow(2, 7, -36),
        _flow(3, 8, 9),
      ];

      List<int> cumulative(List<CashFlow> flows) => Contribution.series(
            initialContribution: initial,
            cashFlows: flows,
          ).map((p) => p.cumulative.amount ~/ 1000000).toList();

      expect(cumulative(before), [281, 245, 254]);
      // Cả ba giá trị đều dịch lên 10, không chỉ riêng dòng vừa sửa.
      expect(cumulative(after), [291, 255, 264]);
    });

    test('lãi lỗ của các mốc sau cũng đổi theo', () {
      final after = [_flow(1, 6, -50), _flow(2, 7, -36), _flow(3, 8, 9)];

      final result = ProfitLossRule.at(
        investmentGroupValue: _m(321),
        initialContribution: initial,
        cashFlows: after,
        asOf: DateTime.utc(2026, 1, 8),
      );
      // Vốn góp 264 thay vì 254, nên lãi 57 thay vì 67.
      expect(result.cumulativeContribution, _m(264));
      expect(result.amount, _m(57));
    });
  });

  group('Đổi ngày một dòng vốn', () {
    final initial = _m(341);

    test('cho kết quả giống hệt xoá dòng đó rồi thêm lại với ngày mới', () {
      // Dòng id 2 (−36) chuyển từ ngày 7 sang ngày 9.
      final moved = [
        _flow(1, 6, -60),
        _flow(2, 9, -36),
        _flow(3, 8, 9),
      ];
      final rebuilt = [
        _flow(1, 6, -60),
        _flow(3, 8, 9),
        _flow(9, 9, -36),
      ];

      List<int> cumulative(List<CashFlow> flows) => Contribution.series(
            initialContribution: initial,
            cashFlows: flows,
          ).map((p) => p.cumulative.amount ~/ 1000000).toList();

      expect(cumulative(moved), cumulative(rebuilt));
      expect(cumulative(moved), [281, 290, 254]);
    });

    test('đổi ngày làm lũy kế tại một mốc cũ thay đổi', () {
      final before = [_flow(1, 6, -60), _flow(2, 7, -36)];
      final after = [_flow(1, 6, -60), _flow(2, 9, -36)];

      Money at(List<CashFlow> flows) => Contribution.cumulativeAt(
            initialContribution: initial,
            cashFlows: flows,
            asOf: DateTime.utc(2026, 1, 8),
          );

      expect(at(before), _m(245));
      // Dòng −36 đã dời sang ngày 9 nên không còn tính vào mốc ngày 8.
      expect(at(after), _m(281));
    });
  });

  group('Xoá một dòng vốn', () {
    test('kết quả giống như dòng đó chưa từng tồn tại', () {
      final initial = _m(341);
      final withRow = [_flow(1, 6, -60), _flow(2, 7, -36), _flow(3, 8, 9)];
      final without = [_flow(1, 6, -60), _flow(3, 8, 9)];

      expect(
        Contribution.total(initialContribution: initial, cashFlows: without),
        _m(290),
      );
      expect(
        Contribution.total(initialContribution: initial, cashFlows: withRow),
        _m(254),
      );
    });
  });

  group('Ranh giới thời gian', () {
    test('dòng vốn đúng ngày mốc được tính vào', () {
      final flows = [_flow(1, 6, -60)];
      expect(
        Contribution.cumulativeAt(
          initialContribution: _m(341),
          cashFlows: flows,
          asOf: DateTime.utc(2026, 1, 6),
        ),
        _m(281),
      );
    });

    test('dòng vốn sau mốc không được tính vào', () {
      final flows = [_flow(1, 6, -60)];
      expect(
        Contribution.cumulativeAt(
          initialContribution: _m(341),
          cashFlows: flows,
          asOf: DateTime.utc(2026, 1, 5),
        ),
        _m(341),
      );
    });

    test('hai dòng cùng ngày có thứ tự xác định theo id', () {
      final flows = [_flow(5, 6, 10), _flow(2, 6, 20), _flow(9, 6, 30)];
      expect(
        Contribution.sortedByDate(flows).map((f) => f.id),
        [2, 5, 9],
      );
    });
  });

  group('Tỷ lệ lãi lỗ', () {
    test('lỗ 100 trên vốn góp 333 cho khoảng −30%', () {
      final result = ProfitLossRule.current(
        investmentGroupValue: _m(233),
        initialContribution: _m(341),
        cashFlows: [
          _flow(1, 6, -60),
          _flow(2, 7, -36),
          _flow(3, 8, 9),
          _flow(4, 9, 47),
          _flow(5, 10, 32),
        ],
      );
      expect(VnFormat.percent(result.ratio!), '-30,0%');
    });

    test('vốn góp bằng 0 thì không có tỷ lệ, không phải 0%', () {
      final result = ProfitLossRule.current(
        investmentGroupValue: _m(50),
        initialContribution: Money.zero,
        cashFlows: const [],
      );
      expect(result.ratio, isNull);
      expect(result.amount, _m(50));
    });
  });
}
