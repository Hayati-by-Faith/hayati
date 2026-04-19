import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/utils/localization.dart';
import '../../../core/widgets/icon_label_card.dart';
import '../../../core/widgets/phase_gate.dart';

class ResidentHomeScreen extends StatelessWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qrCard = IconLabelCard(
      icon: Icons.qr_code_2,
      label: context.l('qr_title'),
      subtitle: context.l('open_qr_button'),
      onTap: () => context.go('/qr'),
    );
    final blogCard = PhaseGate(
      phaseKey: FeatureFlags.phase4Blog,
      child: IconLabelCard(
        icon: Icons.article_outlined,
        label: context.l('blog_title'),
        subtitle: context.l('blog_placeholder'),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l('resident_home_title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final breakpoint = breakpointForWidth(constraints.maxWidth);
            if (breakpoint == Breakpoint.phone) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  qrCard,
                  const SizedBox(height: 16),
                  blogCard,
                ],
              );
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: qrCard),
                  const SizedBox(width: 24),
                  Expanded(child: blogCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
