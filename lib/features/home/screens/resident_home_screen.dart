import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/icon_label_card.dart';
import '../../../core/widgets/phase_gate.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/utils/localization.dart';

class ResidentHomeScreen extends StatelessWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l('resident_home_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IconLabelCard(
            icon: Icons.qr_code_2,
            label: context.l('qr_title'),
            subtitle: context.l('open_qr_button'),
            onTap: () => context.go('/qr'),
          ),
          const SizedBox(height: 16),
          PhaseGate(
            phaseKey: FeatureFlags.phase4Blog,
            child: IconLabelCard(
              icon: Icons.article_outlined,
              label: context.l('blog_title'),
              subtitle: context.l('blog_placeholder'),
            ),
          ),
        ],
      ),
    );
  }
}

