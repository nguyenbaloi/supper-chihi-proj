import 'package:meta/meta.dart';

import '../../core/money/money.dart';

/// Việc cần làm với một danh mục để về đúng Tỷ trọng mục tiêu.
enum AllocationAction { buy, sell, hold }

/// Một đơn vị có Tỷ trọng mục tiêu: một Lớp tài sản đặt mục tiêu riêng, hoặc
/// một Nhóm mục tiêu gộp nhiều lớp.
///
/// Lớp tài sản đã xếp vào Nhóm mục tiêu **không** xuất hiện riêng — mục tiêu
/// của nó đặt ở cấp nhóm, tính riêng ra nữa là cộng trùng.
@immutable
class AllocationTarget {
  final String label;
  final Money currentValue;
  final int targetWeightBp;

  const AllocationTarget({
    required this.label,
    required this.currentValue,
    required this.targetWeightBp,
  });
}

/// Một dòng trong Kế hoạch phân bổ.
@immutable
class AllocationLine {
  final String label;

  /// Giá trị đang có.
  final Money currentValue;

  final int targetWeightBp;

  /// Phân bổ chuẩn — số tiền lẽ ra phải nằm ở danh mục này.
  ///
  /// Đã chia xong phần dư nên tổng các [targetAmount] khớp đúng phần Tổng tài
  /// sản được phân bổ, không lệch một đồng nào.
  final Money targetAmount;

  const AllocationLine({
    required this.label,
    required this.currentValue,
    required this.targetWeightBp,
    required this.targetAmount,
  });

  /// Chênh lệch so với Phân bổ chuẩn: dương là **mua thêm**, âm là **bán bớt**.
  ///
  /// Dấu ngược với `TargetDrift.amountDrift` một cách có chủ đích: bên kia trả
  /// lời "đang thừa hay thiếu bao nhiêu", bên này trả lời "phải làm gì".
  Money get actionAmount => targetAmount - currentValue;

  AllocationAction get action {
    if (actionAmount.isPositive) return AllocationAction.buy;
    if (actionAmount.isNegative) return AllocationAction.sell;
    return AllocationAction.hold;
  }

  @override
  String toString() => 'AllocationLine($label, $currentValue → $targetAmount)';
}

/// Kế hoạch phân bổ: mỗi danh mục nên có bao nhiêu, và phải mua bán bao nhiêu
/// để tới đó.
@immutable
class AllocationPlan {
  final List<AllocationLine> lines;
  final Money totalAssets;

  /// Tổng các Tỷ trọng mục tiêu, đơn vị phần vạn.
  final int totalTargetBp;

  const AllocationPlan({
    required this.lines,
    required this.totalAssets,
    required this.totalTargetBp,
  });

  static const AllocationPlan empty = AllocationPlan(
    lines: [],
    totalAssets: Money.zero,
    totalTargetBp: 0,
  );

  /// Có cơ sở để phân bổ không. Tổng tài sản bằng 0 thì mọi con số phân bổ
  /// đều bằng 0 và chẳng nói lên điều gì — giao diện phải nói rõ thay vì hiện
  /// một bảng toàn số không.
  bool get hasBasis => totalAssets.isPositive && totalTargetBp > 0;

  /// Tổng các Tỷ trọng mục tiêu đã đủ 100% chưa. Xem FR-19.
  bool get isFullyAllocated => totalTargetBp == 10000;

  /// Tổng Phân bổ chuẩn của mọi dòng.
  Money get allocatedAmount => Money.sum(lines.map((l) => l.targetAmount));

  /// Giá trị đang nằm ở các danh mục **có** mục tiêu.
  Money get targetedValue => Money.sum(lines.map((l) => l.currentValue));

  /// Giá trị đang nằm ở các Lớp tài sản chưa đặt mục tiêu nào.
  ///
  /// Khác 0 nghĩa là bảng phân bổ chưa nói hết về Tổng tài sản, và giao diện
  /// phải nói ra — im lặng ở đây là để người dùng cộng nhẩm phần còn lại, tức
  /// là đúng cái việc ứng dụng sinh ra để xoá bỏ.
  Money get untargetedValue => totalAssets - targetedValue;

  Money get totalBuy => Money.sum(
        lines.where((l) => l.action == AllocationAction.buy).map(
              (l) => l.actionAmount,
            ),
      );

  Money get totalSell => Money.sum(
        lines.where((l) => l.action == AllocationAction.sell).map(
              (l) => -l.actionAmount,
            ),
      );

  /// Tiền phải bỏ thêm vào để chạy xong kế hoạch: dương là cần nạp thêm, âm là
  /// bán ra còn dư.
  ///
  /// Bằng 0 khi mọi Lớp tài sản đều có mục tiêu và tổng tỷ trọng đủ 100% —
  /// lúc đó kế hoạch tự cân, bán bao nhiêu mua bấy nhiêu.
  Money get netCashNeeded => totalBuy - totalSell;

  List<AllocationLine> get buys =>
      lines.where((l) => l.action == AllocationAction.buy).toList(
            growable: false,
          );

  List<AllocationLine> get sells =>
      lines.where((l) => l.action == AllocationAction.sell).toList(
            growable: false,
          );

  List<AllocationLine> get holds =>
      lines.where((l) => l.action == AllocationAction.hold).toList(
            growable: false,
          );
}

/// Công thức phân bổ theo Tỷ trọng mục tiêu.
class Allocation {
  const Allocation._();

  /// Dựng Kế hoạch phân bổ từ các đơn vị có mục tiêu và Tổng tài sản.
  ///
  /// Phân bổ chuẩn của một danh mục là `Tỷ trọng mục tiêu × Tổng tài sản`, làm
  /// tròn về đồng sao cho **tổng các phần khớp đúng số bị chia**. Xem
  /// [_apportion] để biết vì sao không làm tròn từng phần độc lập.
  static AllocationPlan plan({
    required List<AllocationTarget> targets,
    required Money totalAssets,
  }) {
    final totalTargetBp = targets.fold(0, (sum, t) => sum + t.targetWeightBp);

    if (targets.isEmpty) {
      return AllocationPlan(
        lines: const [],
        totalAssets: totalAssets,
        totalTargetBp: totalTargetBp,
      );
    }

    // Không có cơ sở để chia thì mọi Phân bổ chuẩn bằng 0. Vẫn dựng đủ dòng để
    // giao diện còn liệt kê được danh mục, chỉ là chưa có con số.
    final hasBasis = totalAssets.isPositive && totalTargetBp > 0;
    final amounts = hasBasis
        ? _apportion(
            total: _allocatableAmount(totalAssets, totalTargetBp),
            weights: targets.map((t) => t.targetWeightBp).toList(),
            weightSum: totalTargetBp,
          )
        : List<int>.filled(targets.length, 0);

    return AllocationPlan(
      lines: [
        for (var i = 0; i < targets.length; i++)
          AllocationLine(
            label: targets[i].label,
            currentValue: targets[i].currentValue,
            targetWeightBp: targets[i].targetWeightBp,
            targetAmount: Money(amounts[i]),
          ),
      ],
      totalAssets: totalAssets,
      totalTargetBp: totalTargetBp,
    );
  }

  /// Phần Tổng tài sản thực sự được đem chia.
  ///
  /// Đủ 100% thì lấy nguyên Tổng tài sản, **không** đi qua phép nhân chia nào
  /// — có làm tròn ở bước này thì tổng phân bổ đã lệch trước cả khi chia.
  static int _allocatableAmount(Money totalAssets, int totalTargetBp) {
    if (totalTargetBp == 10000) return totalAssets.amount;
    return _divRoundHalfUp(totalAssets.amount * totalTargetBp, 10000);
  }

  /// Chia [total] theo [weights] sao cho tổng các phần **bằng đúng** [total].
  ///
  /// Dùng phương pháp phần dư lớn nhất: lấy phần nguyên trước, rồi phát nốt số
  /// đồng còn thừa cho những phần có dư lớn nhất, mỗi phần một đồng.
  ///
  /// Làm tròn từng phần một cách độc lập là chỗ sai âm thầm kinh điển: ba danh
  /// mục 33,33% của 100 đồng cho ra 33+33+33 = 99, hụt một đồng không biết đi
  /// đâu. Với danh mục hàng trăm triệu thì con số hụt đó đủ lớn để người dùng
  /// nhìn thấy tổng mua khác tổng bán rồi tự hỏi mình nhầm ở đâu.
  ///
  /// Toàn bộ phép tính chạy trên số nguyên, không có bước nào làm tròn ngoài
  /// bước phát phần dư — nên kết quả tái lập được y hệt mỗi lần chạy. Xem AD-3.
  static List<int> _apportion({
    required int total,
    required List<int> weights,
    required int weightSum,
  }) {
    if (weightSum <= 0) return List<int>.filled(weights.length, 0);

    final shares = <int>[];
    final remainders = <int>[];
    var distributed = 0;

    for (final weight in weights) {
      final numerator = total * weight;
      final share = numerator ~/ weightSum;
      shares.add(share);
      remainders.add(numerator - share * weightSum);
      distributed += share;
    }

    // Xếp theo phần dư giảm dần; dư bằng nhau thì danh mục đứng trước được
    // trả lời trước, để cùng một dữ liệu luôn ra cùng một kết quả.
    final order = List<int>.generate(weights.length, (i) => i)
      ..sort((a, b) {
        final byRemainder = remainders[b].compareTo(remainders[a]);
        return byRemainder != 0 ? byRemainder : a.compareTo(b);
      });

    var leftover = total - distributed;
    for (var i = 0; i < order.length && leftover > 0; i++) {
      shares[order[i]] += 1;
      leftover--;
    }

    return shares;
  }

  /// Chia làm tròn nửa lên, chỉ dùng cho số không âm.
  static int _divRoundHalfUp(int numerator, int denominator) {
    if (numerator < 0) return -((-numerator + denominator ~/ 2) ~/ denominator);
    return (numerator + denominator ~/ 2) ~/ denominator;
  }
}
