import 'package:flutter/material.dart';

import '../../app/symbol_view.dart';
import '../../data/market_repository.dart';
import '../../domain/rsi_status.dart';
import '../format.dart';
import '../strings.dart';
import '../theme.dart';
import 'dca_section.dart';

/// Một thẻ Mã trên màn hình Tổng quan (FR-1, FR-3).
class SymbolCard extends StatelessWidget {
  const SymbolCard({
    super.key,
    required this.view,
    required this.onTap,
    required this.onRetry,
    this.onOpenGuide,
  });

  final SymbolView view;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  /// Mở bảng Cẩm nang DCA của Mã này (FR-18).
  final VoidCallback? onOpenGuide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final status = view.status;
    final statusColor = StatusColors.of(status, brightness);

    if (view.staleness == Staleness.empty && !view.data.hasCandles) {
      return _EmptyCard(view: view, onRetry: onRetry);
    }

    final rsi = view.latestRsi;
    final candle = view.latestCandle;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          view.symbol.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (candle != null)
                          Text(
                            formatPrice(candle.close, view.symbol),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        S.rsiWeekly,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rsi == null ? '—' : formatRsi(rsi),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatusChip(status: status, color: statusColor),
                  if (view.isProvisional && rsi != null) ...[
                    const SizedBox(width: 10),
                    Tooltip(
                      message: S.provisionalHint,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.hintColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 13,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              S.provisional,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              DcaSection(view: view, onOpenGuide: onOpenGuide),
              if (view.staleness == Staleness.stale) ...[
                const SizedBox(height: 10),
                _StaleNote(view: view),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});

  final RsiStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      RsiStatus.oversold => S.statusOversold,
      RsiStatus.neutral => S.statusNeutral,
      RsiStatus.overbought => S.statusOverbought,
      RsiStatus.insufficientData => S.statusInsufficient,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Chú thích dữ liệu cũ — cố tình ở mức chữ nhỏ, không phải dialog chặn (FR-3).
class _StaleNote extends StatelessWidget {
  const _StaleNote({required this.view});

  final SymbolView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final at = view.fetchedAt;
    final parts = <String>[
      if (at != null) '${S.updatedAt(formatTimestamp(at))} — ${S.offlineNote}',
      if (view.data.errorKind != null) S.errorNote(view.data.errorKind!.name),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.cloud_off, size: 14, color: theme.hintColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            parts.join('  '),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.view, required this.onRetry});

  final SymbolView view;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              view.symbol.label,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(S.noDataTitle, style: theme.textTheme.titleSmall),
            Text(
              S.noDataBody,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: onRetry,
                child: const Text(S.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
