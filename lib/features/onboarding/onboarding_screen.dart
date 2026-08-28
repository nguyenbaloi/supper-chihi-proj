import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../presentation/providers/providers.dart';

/// FR-2, FR-4: người dùng không bao giờ nhìn thấy một app trống.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _busy = false;

  Future<void> _finish({required bool withSeed}) async {
    setState(() => _busy = true);
    if (withSeed) {
      await ref.read(seederProvider).applyProjectSeed();
    }
    final repo = ref.read(settingsRepositoryProvider);
    await repo.save((await repo.get()).copyWith(seedApplied: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.auto_awesome_motion,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(S.onboardingTitle,
                  style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(S.onboardingBody,
                  style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _busy ? null : () => _finish(withSeed: true),
                child: Text(S.onboardingSeed),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : () => _finish(withSeed: false),
                child: Text(S.onboardingSkip),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
