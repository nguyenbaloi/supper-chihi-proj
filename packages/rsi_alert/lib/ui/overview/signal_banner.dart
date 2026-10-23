import 'package:flutter/material.dart';

import '../../domain/signal.dart';
import '../format.dart';
import '../strings.dart';
import '../theme.dart';
import '../../domain/rsi_status.dart';

/// Dải cảnh báo Tín hiệu mới ở đầu màn hình Tổng quan (FR-5).
///
/// Đây là thứ duy nhất trong app chủ động nói với người dùng, nên nó phải nói
/// đủ để hiểu ngay mà không cần chạm vào: Mã nào, chuyện gì, RSI bao nhiêu,
/// tuần nào.
class SignalBanner extends StatelessWidget {
  const SignalBanner({super.key, required this.signal, required this.onTap});

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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOversold ? Icons.trending_down : Icons.trending_up,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${signal.symbol.label} — '
                        '${isOversold ? S.signalOversoldTitle : S.signalOverboughtTitle}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${S.rsiWeekly} ${formatRsi(signal.rsiValue)} · '
                        '${S.weekOf(formatWeekRange(signal.weekOpenTime))}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  S.tapToView,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right, size: 18, color: theme.hintColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
