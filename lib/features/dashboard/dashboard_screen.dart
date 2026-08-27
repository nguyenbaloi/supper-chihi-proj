import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/vn_format.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/portfolio_valuation.dart';
import '../../domain/rules/rebalancing.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/theme/app_theme.dart';
import '../../presentation/widgets/allocation_pie_chart.dart';
import '../../presentation/widgets/asset_class_icon.dart';
import '../../presentation/widgets/empty_state.dart';
import '../../presentation/widgets/money_text.dart';
import '../asset_class/asset_class_screen.dart';
import '../capital/profit_loss_screen.dart';
import '../settings/export_service.dart';

/// Màn hình tổng quan — thứ người dùng thấy đầu tiên khi mở ứng dụng.
///
/// Thứ tự có chủ đích: Tổng tài sản là con số nổi bật nhất, rồi Lãi lỗ, rồi
/// biểu đồ tròn, rồi danh sách. Xem FR-15 tới FR-18.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final valuationAsync = ref.watch(portfolioValuationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDashboard)),
      body: valuationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.errorGeneric,
          body: '$error',
        ),
        data: (valuation) => RefreshIndicator(
          // Kéo xuống để lấy lại giá. Thất bại không chặn gì cả — màn hình
          // vẫn hiện số liệu từ giá lưu lần cuối. Xem FR-14.
          onRefresh: () async {
            final outcome =
                await ref.read(priceRefreshServiceProvider).refresh();
            if (outcome.hasFailures && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.offlineUsingCachedPrices)),
              );
            }
          },
          child: _DashboardBody(valuation: valuation),
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final PortfolioValuation valuation;

  const _DashboardBody({required this.valuation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    if (valuation.visible.isEmpty ||
        (valuation.totalAssets.isZero && !valuation.hasUnpricedHoldings)) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          EmptyState(
            icon: Icons.pie_chart_outline,
            title: l10n.emptyPortfolioTitle,
            body: l10n.emptyPortfolioBody,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const _BackupReminder(),
        const _TotalAssetsHeader(),
        const SizedBox(height: 16),
        const _ProfitLossCard(),
        const SizedBox(height: 24),
        AllocationPieChart(
          valuation: valuation,
          onSliceTap: (id) => _openAssetClass(context, id),
        ),
        const SizedBox(height: 24),
        Text(l10n.assetClasses, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final entry in valuation.byValueDescending)
          _AssetClassTile(
            entry: entry,
            total: valuation.totalAssets,
            onTap: () => _openAssetClass(context, entry.assetClass.id),
          ),
      ],
    );
  }

  static void _openAssetClass(BuildContext context, int assetClassId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssetClassScreen(assetClassId: assetClassId),
      ),
    );
  }
}

/// Nhắc sao lưu khi đã lâu chưa xuất dữ liệu.
///
/// Bỏ qua được và **không chặn thao tác nào** — đây là lời nhắc, không phải
/// hàng rào. Xem FR-38.
class _BackupReminder extends ConsumerWidget {
  const _BackupReminder();

  /// Ngưỡng nhắc, tính bằng ngày.
  static const int thresholdDays = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const SizedBox.shrink();

    final lastExported = settings.lastExportedAt;
    // Chưa từng xuất thì chưa nhắc: người dùng vừa cài xong, chưa có gì để
    // mất. Mốc đếm bắt đầu từ lần xuất đầu tiên.
    if (lastExported == null) return const SizedBox.shrink();

    final days = DateTime.now().toUtc().difference(lastExported).inDays;
    if (days < thresholdDays) return const SizedBox.shrink();

    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: ListTile(
        leading: Icon(
          Icons.backup_outlined,
          color: theme.colorScheme.onSecondaryContainer,
        ),
        title: Text(
          l10n.backupReminder(days),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
        ),
        trailing: TextButton(
          onPressed: () => exportAndShare(context, ref),
          child: Text(l10n.settingsExport),
        ),
      ),
    );
  }
}

class _TotalAssetsHeader extends ConsumerWidget {
  const _TotalAssetsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final valuation = ref.watch(portfolioValuationProvider).value;
    final fxRate = ref.watch(effectiveFxRateProvider).value;
    if (valuation == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.totalAssets,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        MoneyText(
          valuation.totalAssets,
          style: theme.textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (valuation.hasUnpricedHoldings)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _Notice(
              icon: Icons.help_outline,
              text: l10n.unpricedHoldings(valuation.unpricedCount),
            ),
          ),
        if (fxRate?.isFallback ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _Notice(
              icon: Icons.info_outline,
              text: l10n.fallbackFxRateNotice,
            ),
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Chỉ số Lãi lỗ, chạm vào mở màn hình chi tiết. Xem FR-18.
class _ProfitLossCard extends ConsumerWidget {
  const _ProfitLossCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final profitLoss = ref.watch(currentProfitLossProvider);
    if (profitLoss == null) return const SizedBox.shrink();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfitLossScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.profitLoss, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    MoneyText(
                      profitLoss.amount,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      colorBySign: true,
                      showPlusSign: true,
                    ),
                    if (profitLoss.ratio != null)
                      Text(
                        VnFormat.percent(profitLoss.ratio!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colorForAmount(
                            profitLoss.amount.amount,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                profitLoss.isLoss
                    ? Icons.trending_down
                    : Icons.trending_up,
                color: context.colorForAmount(profitLoss.amount.amount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetClassTile extends ConsumerWidget {
  final AssetClassValuation entry;
  final Money total;
  final VoidCallback onTap;

  const _AssetClassTile({
    required this.entry,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final weight = entry.value.ratioTo(total);
    final settings = ref.watch(settingsProvider).value;

    final drift = TargetDrift(
      label: entry.assetClass.name,
      currentValue: entry.value,
      actualWeight: weight,
      targetWeightBp: entry.assetClass.targetWeightBp ?? 0,
      totalAssets: total,
    );
    final needsAttention = entry.assetClass.targetWeightBp != null &&
        drift.exceedsThreshold(settings?.driftThresholdBp ?? 500);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Color(entry.assetClass.colorValue),
        child: AssetClassIcon(
          codePoint: entry.assetClass.iconCodePoint,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Flexible(child: Text(entry.assetClass.name)),
          if (needsAttention) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: l10n.driftExceeded,
              child: Icon(
                Icons.error_outline,
                size: 16,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
      subtitle: entry.isComplete
          ? null
          : Text(
              l10n.unpricedHoldings(entry.unpricedCount),
              style: theme.textTheme.bodySmall,
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MoneyText(
            entry.value,
            compact: true,
            style: theme.textTheme.titleMedium,
          ),
          Text(
            weight == null ? '—' : VnFormat.percent(weight),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
