import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/money/money.dart';
import '../../domain/models/asset_class.dart';
import '../../presentation/providers/portfolio_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/widgets/asset_class_icon.dart';
import '../../presentation/widgets/money_field.dart';
import '../asset_class/holding_editor.dart';

/// Luồng khởi tạo ba bước. Xem FR-2, FR-3 và Story 1.9.
///
/// Bước nhập Khoản nắm giữ bỏ qua được, bước Vốn góp khởi điểm thì không —
/// thiếu con số đó ứng dụng sẽ hiểu là chưa bỏ đồng nào vào và báo lãi bằng
/// đúng toàn bộ giá trị danh mục.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  Money _initialContribution = Money.zero;
  DateTime _startDate = DateTime.now().toUtc();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final classes = ref.watch(assetClassesProvider).value ?? const <AssetClass>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _onContinue,
        onStepCancel: _step == 0 ? null : () => setState(() => _step -= 1),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              FilledButton(
                onPressed: details.onStepContinue,
                child: Text(
                  _step == 2 ? l10n.onboardingFinish : l10n.onboardingNext,
                ),
              ),
              const SizedBox(width: 8),
              // Bỏ qua được ở bước nhập khoản nắm giữ, không chặn. Xem FR-2.
              if (_step == 1)
                TextButton(
                  onPressed: () => setState(() => _step = 2),
                  child: Text(l10n.onboardingSkip),
                ),
              if (details.onStepCancel != null)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(l10n.actionCancel),
                ),
            ],
          ),
        ),
        steps: [
          Step(
            title: Text(l10n.onboardingStepClasses),
            isActive: _step >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.onboardingWelcomeBody,
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                for (final assetClass in classes)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(assetClass.colorValue),
                      child: AssetClassIcon(
                        codePoint: assetClass.iconCodePoint,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    title: Text(assetClass.name),
                  ),
              ],
            ),
          ),
          Step(
            title: Text(l10n.onboardingStepHoldings),
            isActive: _step >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final assetClass in classes)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(assetClass.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => showHoldingEditor(
                        context,
                        ref,
                        assetClass: assetClass,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Step(
            title: Text(l10n.onboardingStepCapital),
            isActive: _step >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoneyField(
                  label: l10n.initialContribution,
                  initial: _initialContribution,
                  onChanged: (value) => _initialContribution = value,
                  helperText: l10n.onboardingCapitalExplain,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsStartDate),
                  subtitle: Text('${_startDate.toLocal()}'.split(' ').first),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate.toLocal(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    if (_step < 2) {
      setState(() => _step += 1);
      return;
    }

    final l10n = AppL10n.of(context);

    // Nhập 0 được, nhưng cảnh báo hệ quả trước khi cho qua. Xem FR-3.
    if (_initialContribution.isZero) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.onboardingCapitalZeroWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionConfirm),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    await ref.read(settingsRepositoryProvider).initialize(
          initialContributionAmount: _initialContribution,
          startDate: _startDate,
        );
  }
}
