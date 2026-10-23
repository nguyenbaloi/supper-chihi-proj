import 'package:flutter/material.dart';

import '../../core/format/price_freshness.dart';
import '../../core/l10n/generated/app_localizations.dart';

/// Nhãn "cập nhật 5 phút trước", kèm cảnh báo khi giá đã cũ.
///
/// Không có màn hình nào hiện số liệu tài chính mà thiếu nhãn này. Xem FR-13.
class PriceFreshnessLabel extends StatelessWidget {
  final DateTime? fetchedAt;
  final DateTime? now;
  final TextStyle? style;

  const PriceFreshnessLabel({
    super.key,
    required this.fetchedAt,
    this.now,
    this.style,
  });

  static String describe(AppL10n l10n, PriceFreshness freshness) =>
      switch (freshness.unit) {
        FreshnessUnit.never => l10n.priceNeverFetched,
        FreshnessUnit.justNow => l10n.priceUpdatedJustNow,
        FreshnessUnit.minutes => l10n.priceUpdatedMinutes(freshness.count),
        FreshnessUnit.hours => l10n.priceUpdatedHours(freshness.count),
        FreshnessUnit.days => l10n.priceUpdatedDays(freshness.count),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final freshness = PriceFreshness.since(
      fetchedAt,
      now: now ?? DateTime.now().toUtc(),
    );

    final baseStyle = (style ?? theme.textTheme.bodySmall)?.copyWith(
      color: freshness.isStale
          ? theme.colorScheme.error
          : theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (freshness.isStale) ...[
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            describe(l10n, freshness),
            style: baseStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
