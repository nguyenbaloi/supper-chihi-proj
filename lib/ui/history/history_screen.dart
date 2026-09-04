import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/market_symbol.dart';
import '../../domain/rsi_status.dart';
import '../../domain/signal.dart';
import '../format.dart';
import '../strings.dart';
import '../theme.dart';

/// Tab Lịch sử tín hiệu (FR-9).
///
/// Danh sách sinh ra từ chuỗi nến đang có, không đọc từ bảng lưu trữ nào
/// (AD-2) — xoá dữ liệu rồi tải lại phải cho ra đúng danh sách này.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, required this.onOpenChart});

  final void Function(MarketSymbol symbol, int candleIndex) onOpenChart;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  MarketSymbol? _filter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(overviewControllerProvider);

    final signals = <Signal>[
      for (final view in state.views.values)
        if (_filter == null || view.symbol == _filter) ...view.signals,
    ]..sort((a, b) => b.weekOpenTime.compareTo(a.weekOpenTime));

    return Scaffold(
      appBar: AppBar(title: const Text(S.historyTitle)),
      body: Column(
        children: [
          _FilterBar(
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          Expanded(
            child: signals.isEmpty
                ? const _EmptyHistory()
                : ListView.separated(
                    itemCount: signals.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) => _SignalTile(
                      signal: signals[index],
                      onTap: () => widget.onOpenChart(
                        signals[index].symbol,
                        signals[index].candleIndex,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final MarketSymbol? selected;
  final ValueChanged<MarketSymbol?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ChoiceChip(
              label: const Text(S.filterAll),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
            for (final symbol in MarketSymbol.values) ...[
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(symbol.label),
                selected: selected == symbol,
                onSelected: (_) => onChanged(symbol),
              ),
            ],
          ],
        ),
      );
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({required this.signal, required this.onTap});

  final Signal signal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOversold = signal.type == SignalType.oversold;
    final color = StatusColors.of(
      isOversold ? RsiStatus.oversold : RsiStatus.overbought,
      theme.brightness,
    );

    return ListTile(
      onTap: onTap,
      leading: Icon(
        isOversold ? Icons.trending_down : Icons.trending_up,
        color: color,
      ),
      title: Row(
        children: [
          Text(
            signal.symbol.label,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Text(
            isOversold ? S.signalOversoldTitle : S.signalOverboughtTitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
      subtitle: Text(S.weekOf(formatWeekRange(signal.weekOpenTime))),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatRsi(signal.rsiValue),
            style: theme.textTheme.titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
          Text(
            formatPrice(signal.closePrice, signal.symbol),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

/// Trạng thái rỗng phải giải thích rằng đây là đặc tính của phương pháp, không
/// phải app hỏng — RSI tuần có thể vài tháng liền không sinh tín hiệu nào.
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 40),
              const SizedBox(height: 12),
              Text(
                S.emptyHistoryTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(S.emptyHistoryBody, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
