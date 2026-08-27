import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/format/vn_format.dart';
import '../../core/money/money.dart';
import '../../domain/models/portfolio_valuation.dart';

/// Biểu đồ tròn cơ cấu Lớp tài sản.
///
/// Lớp có Giá trị quy đổi bằng 0 không chiếm chỗ — một lát bánh dày 0 độ vẫn
/// vẽ ra nhãn và làm rối biểu đồ. Xem FR-16.
class AllocationPieChart extends StatelessWidget {
  final PortfolioValuation valuation;
  final void Function(int assetClassId)? onSliceTap;

  const AllocationPieChart({
    super.key,
    required this.valuation,
    this.onSliceTap,
  });

  @override
  Widget build(BuildContext context) {
    final slices = valuation.visible
        .where((entry) => entry.value.isPositive)
        .toList();
    if (slices.isEmpty) return const SizedBox.shrink();

    final total = valuation.totalAssets;

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 52,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions) return;
              final index = response?.touchedSection?.touchedSectionIndex;
              if (index == null || index < 0 || index >= slices.length) return;
              onSliceTap?.call(slices[index].assetClass.id);
            },
          ),
          sections: [
            for (final entry in slices)
              PieChartSectionData(
                value: _sliceWeight(entry, total),
                color: Color(entry.assetClass.colorValue),
                radius: 56,
                title: entry.value.ratioTo(total) == null
                    ? ''
                    : VnFormat.percent(entry.value.ratioTo(total)!),
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// fl_chart cần `double` để vẽ. Đây là ngoại lệ duy nhất của lệnh cấm số
  /// thực, và nó an toàn vì con số này chỉ quyết định độ rộng một lát bánh —
  /// không có giá trị tiền nào đi qua đây. Xem AD-3.
  static double _sliceWeight(AssetClassValuation entry, Money total) {
    final ratio = entry.value.ratioTo(total);
    if (ratio == null) return 0;
    return double.parse(ratio.toString());
  }
}
