import 'package:flutter/material.dart';

import '../../app/symbol_view.dart';
import '../../domain/dca.dart';
import '../../domain/market_symbol.dart';
import '../strings.dart';
import '../theme.dart';

/// Bảng Cẩm nang của một Mã: năm vùng, luật trích lại, và thống kê lịch sử
/// tính trên chính dữ liệu đang có (FR-18) — để người dùng tự đánh giá luật
/// của mình thay vì phải tin app.
Future<void> showDcaGuide(BuildContext context, SymbolView view) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controller) =>
            _GuideBody(view: view, controller: controller),
      ),
    );

class _GuideBody extends StatelessWidget {
  const _GuideBody({required this.view, required this.controller});

  final SymbolView view;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hint = theme.textTheme.bodySmall?.copyWith(color: theme.hintColor);
    final symbol = view.symbol;
    final current = view.latestDca?.zone;
    final stats = {for (final s in view.zoneStats) s.zone: s};

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Text(
          '${S.dcaGuideTitle} — ${symbol.label}',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(S.dcaDisclaimer, style: hint),
        const SizedBox(height: 4),
        Text(S.dcaClosedWeekNote, style: hint),
        const SizedBox(height: 12),
        for (final zone in DcaZone.values)
          _ZoneTile(
            symbol: symbol,
            zone: zone,
            isCurrent: zone == current,
            stats: stats[zone],
          ),
        const SizedBox(height: 4),
        _RuleCard(
          color: DcaColors.divergence(theme.brightness),
          title: S.dcaDivergenceName,
          lines: [
            S.dcaDivergenceCondition,
            S.dcaQuotePrefix + S.dcaDivergenceRule,
          ],
          highlighted: view.latestDca?.bearishDivergence ?? false,
        ),
        const SizedBox(height: 12),
        Text(
          symbol == MarketSymbol.btc
              ? S.dcaFearGreedNoteBtc
              : S.dcaFearGreedNoteVn,
          style: hint,
        ),
      ],
    );
  }
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({
    required this.symbol,
    required this.zone,
    required this.isCurrent,
    required this.stats,
  });

  final MarketSymbol symbol;
  final DcaZone zone;
  final bool isCurrent;
  final ZoneStats? stats;

  @override
  Widget build(BuildContext context) {
    final color = DcaColors.of(zone, Theme.of(context).brightness);
    final s = stats;
    final median = s?.medianReturnPct;
    final positive = s?.positiveSharePct;

    return _RuleCard(
      color: color,
      title: '${S.dcaZoneName(zone)}  ·  ${_range(symbol, zone)}',
      lines: [
        S.dcaQuotePrefix + S.dcaRule(symbol, zone),
        if (s != null)
          '${S.dcaStatsTitle}: '
              '${median != null && positive != null ? S.dcaStats(s.weeks, median, positive) : S.dcaStatsFew(s.weeks)}',
      ],
      highlighted: isCurrent,
    );
  }

  static String _range(MarketSymbol symbol, DcaZone zone) {
    final t = dcaThresholdsOf(symbol);
    String f(double v) => v.toStringAsFixed(0);
    return switch (zone) {
      DcaZone.strongBuy => S.rangeAtMost(f(t.strongBuyMax)),
      DcaZone.probeBuy => S.rangeBetween(f(t.strongBuyMax), f(t.probeBuyMax)),
      DcaZone.hold => S.rangeBetween(f(t.probeBuyMax), f(t.holdMax)),
      DcaZone.probeSell => S.rangeBetween(f(t.holdMax), f(t.probeSellMax)),
      DcaZone.strongSell => S.rangeAbove(f(t.probeSellMax)),
    };
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.color,
    required this.title,
    required this.lines,
    required this.highlighted,
  });

  final Color color;
  final String title;
  final List<String> lines;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlighted ? 0.16 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          for (final line in lines) ...[
            const SizedBox(height: 4),
            Text(line, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
