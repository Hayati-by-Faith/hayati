import 'package:flutter/material.dart';

import '../utils/localization.dart';

/// Placeholder screen shown for phase-gated routes whose phase has not been
/// enabled for the current village. Uses existing `phase_locked_*` ARB keys.
///
/// See `hayati-architecture.md` §3 (phase rollout) and §8 (village phase
/// configuration). Phase 2–6 routes render this screen unconditionally until
/// the feature is implemented.
class PhasePlaceholderScreen extends StatelessWidget {
  const PhasePlaceholderScreen({super.key, this.titleKey});

  /// Optional ARB key for the AppBar title. Falls back to
  /// `phase_locked_title` when null.
  final String? titleKey;

  @override
  Widget build(BuildContext context) {
    final appBarTitle = context.l(titleKey ?? 'phase_locked_title');
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l('phase_locked_title'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l('phase_locked_body'),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
