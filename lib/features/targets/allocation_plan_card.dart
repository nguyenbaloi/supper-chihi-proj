import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/rules/allocation.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/money_text.dart';

/// Kế hoạch phân bổ — mỗi danh mục nên có bao nhiêu tiền theo Tỷ trọng mục
/// tiêu, và phải mua bán bao nhiêu để tới đó.
///
/// Đây là bước cuối của UJ-4: thay vì để người dùng đọc khoảng lệch phần trăm
/// rồi tự nhân với Tổng tài sản, ứng dụng đưa thẳng con số phải mua và phải
/// bán. Nhân với tổng tài sản trong đầu là đúng cái phép tính mà bảng Excel cũ
/// hay làm sai.
class AllocationPlanCard extends ConsumerWidget {
  const AllocationPlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final plan = ref.watch(allocationPlanProvider);

    if (plan.lines.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.allocationPlan,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                MoneyText(
                  plan.totalAssets,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (!plan.hasBasis)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.allocationNoBasis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            else ...[
              _Section(
                title: l10n.allocationBuy,
                icon: Icons.arrow_upward,
                color: context.profitColor,
                // Việc lớn xếp trước: mua nhiều nhất là quyết định đáng cân
                // nhắc nhất.
                lines: _sortedByMagnitude(plan.buys),
              ),
              _Section(
                title: l10n.allocationSell,
                icon: Icons.arrow_downward,
                color: context.lossColor,
                lines: _sortedByMagnitude(plan.sells),
              ),
              _Section(
                title: l10n.allocationHold,
                icon: Icons.check,
                color: theme.colorScheme.onSurfaceVariant,
                lines: plan.holds,
              ),
              const Divider(height: 24),
              _Total(label: l10n.allocationTotalBuy, amount: plan.totalBuy),
              _Total(label: l10n.allocationTotalSell, amount: plan.totalSell),
              _NetLine(net: plan.netCashNeeded),
              if (!plan.untargetedValue.isZero)
                // Nói ra phần Tổng tài sản mà bảng này chưa nói tới. Im lặng ở
                // đây là để người dùng tự cộng nhẩm phần còn lại.
                _Total(
                  label: l10n.allocationUntargeted,
                  amount: plan.untargetedValue,
                  muted: true,
                ),
            ],
          ],
        ),
      ),
    );
  }

  static List<AllocationLine> _sortedByMagnitude(List<AllocationLine> lines) {
    final sorted = lines.toList()
      ..sort((a, b) => b.actionAmount.abs().compareTo(a.actionAmount.abs()));
    return sorted;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<AllocationLine> lines;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
        for (final line in lines) _PlanLine(line: line),
      ],
    );
  }
}

class _PlanLine extends StatelessWidget {
  final AllocationLine line;

  const _PlanLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final isHold = line.action == AllocationAction.hold;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(line.label, style: theme.textTheme.bodyMedium),
              ),
              if (!isHold)
                MoneyText(
                  line.actionAmount,
                  colorBySign: true,
                  showPlusSign: true,
                  style: theme.textTheme.titleSmall,
                ),
            ],
          ),
          Text(
            // Hiện tại → Phân bổ chuẩn. Đặt cạnh nhau để thấy ngay khoảng cách
            // phải đi, không phải trừ nhẩm.
            l10n.allocationCurrentToTarget(
              VnFormat.amount(line.currentValue),
              VnFormat.money(line.targetAmount),
            ),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  final String label;
  final Money amount;
  final bool muted;

  const _Total({
    required this.label,
    required this.amount,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        muted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
          MoneyText(
            amount,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Chênh lệch ròng giữa tổng mua và tổng bán.
///
/// Bằng 0 nghĩa là kế hoạch tự cân — bán bao nhiêu mua bấy nhiêu, không phải
/// bỏ thêm đồng nào. Đây là con số cho biết bảng phân bổ có đáng tin không,
/// nên nói thẳng ra chứ không để người dùng tự trừ hai dòng trên.
class _NetLine extends StatelessWidget {
  final Money net;

  const _NetLine({required this.net});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    if (net.isZero) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                size: 14, color: context.profitColor),
            const SizedBox(width: 4),
            Text(
              l10n.allocationBalanced,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: context.profitColor),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              net.isPositive ? l10n.allocationNetNeeded : l10n.allocationNetSpare,
              style: theme.textTheme.bodySmall,
            ),
          ),
          MoneyText(
            net.abs(),
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
