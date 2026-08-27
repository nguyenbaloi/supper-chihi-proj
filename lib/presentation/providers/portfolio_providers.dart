import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../domain/models/action_note.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/asset_class.dart';
import '../../domain/models/cash_flow.dart';
import '../../domain/models/debt.dart';
import '../../domain/models/fx_rate.dart';
import '../../domain/models/portfolio_valuation.dart';
import '../../domain/models/snapshot.dart';
import '../../domain/models/target_group.dart';
import '../../domain/models/valued_holding.dart';
import '../../domain/rules/allocation.dart';
import '../../domain/rules/contribution.dart';
import '../../domain/rules/debt_math.dart';
import '../../domain/rules/profit_loss.dart';
import '../../data/repositories/snapshot_repository_impl.dart';
import 'repository_providers.dart';

final settingsProvider = StreamProvider<AppSettings?>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

final assetClassesProvider = StreamProvider<List<AssetClass>>(
  (ref) => ref.watch(assetClassRepositoryProvider).watchAll(),
);

final portfolioValuationProvider = StreamProvider<PortfolioValuation>(
  (ref) => ref.watch(portfolioRepositoryProvider).watchValuation(),
);

final cashFlowsProvider = StreamProvider<List<CashFlow>>(
  (ref) => ref.watch(cashFlowRepositoryProvider).watchAll(),
);

final debtsProvider = StreamProvider<List<Debt>>(
  (ref) => ref.watch(debtRepositoryProvider).watchAll(),
);

final actionNotesProvider = StreamProvider<List<ActionNote>>(
  (ref) => ref.watch(actionNoteRepositoryProvider).watchAll(),
);

final targetGroupsProvider = StreamProvider<List<TargetGroup>>(
  (ref) => ref.watch(targetRepositoryProvider).watchGroups(),
);

final snapshotsProvider = StreamProvider<List<Snapshot>>(
  (ref) => ref.watch(snapshotRepositoryProvider).watchAll(),
);

/// Khoản nắm giữ của một Lớp tài sản, kèm giá và giá trị quy đổi.
final valuedHoldingsProvider =
    FutureProvider.family<List<ValuedHolding>, int>((ref, assetClassId) {
  // Phụ thuộc vào định giá để tự chạy lại khi giá hay tỷ giá đổi.
  ref.watch(portfolioValuationProvider);
  return ref.watch(portfolioRepositoryProvider).valuedHoldings(assetClassId);
});

/// Tỷ giá đang thực sự dùng, kèm cờ cho biết có phải giá trị dự phòng không.
final effectiveFxRateProvider = FutureProvider<FxRate>((ref) {
  ref.watch(portfolioValuationProvider);
  return ref.watch(fxRateRepositoryProvider).effectiveRate();
});

/// Tổng hợp Sổ nợ: tổng cho vay, tổng đi vay, tổng ròng.
final debtTotalsProvider = Provider<DebtTotals>((ref) {
  final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
  return DebtMath.totals(debts);
});

/// Lãi lỗ hiện tại của Nhóm đầu tư.
///
/// Vốn góp lũy kế được tính tại chỗ từ chuỗi Dòng vốn, không đọc từ cột nào.
/// Xem AD-4.
final currentProfitLossProvider = Provider<ProfitLoss?>((ref) {
  final valuation = ref.watch(portfolioValuationProvider).value;
  final settings = ref.watch(settingsProvider).value;
  final flows = ref.watch(cashFlowsProvider).value;
  if (valuation == null || settings == null || flows == null) return null;

  return ProfitLossRule.current(
    investmentGroupValue: valuation.investmentGroupValue,
    initialContribution: settings.initialContributionAmount,
    cashFlows: flows,
  );
});

/// Chuỗi Dòng vốn kèm Vốn góp lũy kế tại từng dòng. Xem FR-26.
final contributionSeriesProvider = Provider<List<ContributionPoint>>((ref) {
  final settings = ref.watch(settingsProvider).value;
  final flows = ref.watch(cashFlowsProvider).value;
  if (settings == null || flows == null) return const [];

  return Contribution.series(
    initialContribution: settings.initialContributionAmount,
    cashFlows: flows,
  );
});

/// Vốn góp lũy kế hiện tại.
final cumulativeContributionProvider = Provider<Money>((ref) {
  final settings = ref.watch(settingsProvider).value;
  final flows = ref.watch(cashFlowsProvider).value;
  if (settings == null) return Money.zero;

  return Contribution.total(
    initialContribution: settings.initialContributionAmount,
    cashFlows: flows ?? const [],
  );
});

/// Bản chốt kèm Vốn góp lũy kế và Lãi lỗ, tính lại lúc đọc. Xem AD-12.
final snapshotSeriesProvider = FutureProvider<List<SnapshotPoint>>((ref) {
  ref.watch(snapshotsProvider);
  ref.watch(cashFlowsProvider);
  ref.watch(settingsProvider);
  final repo = ref.watch(snapshotRepositoryProvider);
  return (repo as SnapshotRepositoryImpl).series();
});

/// Các đơn vị đang có Tỷ trọng mục tiêu: Lớp tài sản đặt mục tiêu riêng, cộng
/// các Nhóm mục tiêu.
///
/// Lớp đã xếp vào Nhóm mục tiêu không xuất hiện riêng — mục tiêu của nó đặt ở
/// cấp nhóm, liệt kê thêm lần nữa là cộng trùng. Giá trị của nhóm suy ra từ
/// các lớp thành viên, không lưu ở đâu cả. Xem AD-5 và FR-19.
final targetUnitsProvider = Provider<List<AllocationTarget>>((ref) {
  final valuation = ref.watch(portfolioValuationProvider).value;
  if (valuation == null) return const [];
  final groups = ref.watch(targetGroupsProvider).value ?? const <TargetGroup>[];

  return [
    for (final entry in valuation.visible)
      if (entry.assetClass.targetGroupId == null &&
          entry.assetClass.targetWeightBp != null)
        AllocationTarget(
          label: entry.assetClass.name,
          currentValue: entry.value,
          targetWeightBp: entry.assetClass.targetWeightBp!,
        ),
    for (final group in groups)
      AllocationTarget(
        label: group.name,
        currentValue: Money.sum(
          valuation.visible
              .where((e) => e.assetClass.targetGroupId == group.id)
              .map((e) => e.value),
        ),
        targetWeightBp: group.targetWeightBp,
      ),
  ];
});

/// Kế hoạch phân bổ: mỗi danh mục nên có bao nhiêu, và phải mua bán bao nhiêu
/// để tới đó. Suy ra từ Tổng tài sản hiện tại, không lưu ở đâu. Xem AD-5.
final allocationPlanProvider = Provider<AllocationPlan>((ref) {
  final valuation = ref.watch(portfolioValuationProvider).value;
  if (valuation == null) return AllocationPlan.empty;

  return Allocation.plan(
    targets: ref.watch(targetUnitsProvider),
    totalAssets: valuation.totalAssets,
  );
});
