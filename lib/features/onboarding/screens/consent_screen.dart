import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/localization.dart';
import '../../../core/widgets/big_button.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l('consent_title'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l('consent_body'),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            BigButton(
              label: context.l('consent_accept_button'),
              icon: Icons.check_circle_outline,
              onPressed: () => context.go('/enrollment'),
            ),
          ],
        ),
      ),
    );
  }
}

