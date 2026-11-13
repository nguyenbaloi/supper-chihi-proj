import 'package:flutter/material.dart';

import '../../app/symbol_view.dart';
import '../strings.dart';
import '../theme.dart';

/// Phần Vùng DCA trong thẻ Mã (FR-14, FR-15).
///
/// Vùng chính thức lấy từ tuần **đã đóng** gần nhất (AD-5). Vùng của tuần đang
/// chạy chỉ hiện thêm một dòng nhỏ, kèm nhãn tạm tính, khi nó khác vùng chính.
class DcaSection extends StatelessWidget {
  const DcaSection({super.key, required this.view, this.onOpenGuide});

  final SymbolView view;
  final VoidCallback? onOpenGuide;

  @override
  Widget build(BuildContext context) {
    final week = view.latestDca;
    if (week == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final color = DcaColors.of(week.zone, brightness);
    final hint = theme.textTheme.bodySmall?.copyWith(color: theme.hintColor);
    final provisional = view.provisionalZone;
    final today = view.latestFearGreed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.4)),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              S.dcaSection,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (onOpenGuide != null)
              TextButton(
                onPressed: onOpenGuide,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(S.dcaGuideOpen),
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ZoneChip(label: S.dcaZoneName(week.zone), color: color),
            Text(S.dcaWeeksInZone(week.weeksInZone), style: hint),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          S.dcaQuotePrefix + S.dcaRule(week.symbol, week.zone),
          style: theme.textTheme.bodySmall,
        ),
        if (week.bearishDivergence) ...[
          const SizedBox(height: 6),
          Text(
            '${S.dcaDivergenceName}. ${S.dcaQuotePrefix}${S.dcaDivergenceRule}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: DcaColors.divergence(brightness),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (provisional != null && provisional != week.zone) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.hourglass_empty, size: 13, color: theme.hintColor),
              const SizedBox(width: 4),
              Expanded(child: Text(S.dcaProvisional(provisional), style: hint)),
            ],
          ),
        ],
        if (today != null) ...[
          const SizedBox(height: 4),
          Text(S.fearGreedToday(today.value), style: hint),
        ],
      ],
    );
  }
}

class _ZoneChip extends StatelessWidget {
  const _ZoneChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}
