import 'package:flutter/material.dart';

import '../../core/format/vn_date.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/snapshot.dart';
import '../../presentation/widgets/money_text.dart';

/// Xem lại một mốc trong quá khứ.
///
/// Giá trị từng lớp là con số **đã ghi lúc chốt** — thêm hay xoá Khoản nắm
/// giữ sau ngày đó không làm nó đổi. Riêng Vốn góp lũy kế và Lãi lỗ được tính
/// lại, vì sửa một Dòng vốn chính là sửa lịch sử. Xem AD-12 và FR-31.
class SnapshotDetailScreen extends StatelessWidget {
  final SnapshotPoint point;

  const SnapshotDetailScreen({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final snapshot = point.snapshot;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.snapshotDetailTitle(VnDate.full(snapshot.date))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (snapshot.note != null) ...[
            Text(snapshot.note!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
          ],
          _Row(label: l10n.totalAssets, amount: snapshot.totalAssetsAmount),
          _Row(
            label: l10n.investmentGroup,
            amount: snapshot.investmentGroupAmount,
          ),
          _Row(
            label: l10n.cumulativeContribution,
            amount: point.cumulativeContribution,
          ),
          const Divider(height: 24),
          _Row(label: l10n.profitLoss, amount: point.profitLoss, signed: true),
          const SizedBox(height: 24),
          Text(l10n.assetClasses, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final detail in snapshot.details)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(detail.assetClassName),
              trailing: MoneyText(detail.valueAmount, compact: true),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final Money amount;
  final bool signed;

  const _Row({required this.label, required this.amount, this.signed = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          MoneyText(
            amount,
            style: theme.textTheme.titleMedium,
            colorBySign: signed,
            showPlusSign: signed,
          ),
        ],
      ),
    );
  }
}
