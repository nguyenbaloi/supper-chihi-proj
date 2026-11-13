import 'package:flutter/material.dart';

import '../../domain/dca.dart';
import '../format.dart';
import '../strings.dart';
import '../theme.dart';

/// Dải cảnh báo Vùng DCA ở đầu màn hình Tổng quan (FR-17).
///
/// Hiện cho tuần đã đóng gần nhất khi nó nằm ngoài Vùng Nắm giữ hoặc có phân
/// kỳ giảm, và người dùng chưa xem. Cẩm nang giải ngân **mỗi tuần** trong vùng,
/// nên mỗi tuần mới trong vùng là một dải mới.
class DcaBanner extends StatelessWidget {
  const DcaBanner({super.key, required this.week, required this.onTap});

  final DcaWeek week;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final divergence = week.bearishDivergence;
    final color = divergence
        ? DcaColors.divergence(brightness)
        : DcaColors.of(week.zone, brightness);
    final fearGreed = week.fearGreed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      divergence
                          ? Icons.call_split
                          : week.zone.isBuy
                              ? Icons.south_east
                              : Icons.north_east,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${week.symbol.label} — '
                        '${divergence ? S.dcaDivergenceName : S.dcaZoneName(week.zone)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: theme.hintColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    '${S.rsiWeekly} ${formatRsi(week.rsi)}',
                    if (fearGreed != null) S.fearGreed(fearGreed),
                    S.weekOf(formatWeekRange(week.weekOpenTime)),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  S.dcaQuotePrefix +
                      (divergence
                          ? S.dcaDivergenceRule
                          : S.dcaRule(week.symbol, week.zone)),
                  style: theme.textTheme.bodySmall,
                ),
                if (week.fearGreedConfirms) ...[
                  const SizedBox(height: 6),
                  _Tag(label: S.dcaFearGreedConfirms, color: color),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}
