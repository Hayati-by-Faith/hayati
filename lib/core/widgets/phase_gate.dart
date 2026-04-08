import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/phase_provider.dart';
import '../utils/localization.dart';

class PhaseGate extends ConsumerWidget {
  const PhaseGate({
    super.key,
    required this.phaseKey,
    required this.child,
    this.fallback,
  });

  final String phaseKey;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(phaseEnabledProvider(phaseKey));
    if (enabled) {
      return child;
    }

    return fallback ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l('phase_locked_title'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l('phase_locked_body'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
  }
}

