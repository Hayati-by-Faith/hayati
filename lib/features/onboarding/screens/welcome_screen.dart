import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/localization.dart';
import '../../../core/widgets/big_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l('app_title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l('welcome_title'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              context.l('welcome_subtitle'),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            BigButton(
              label: context.l('welcome_cta'),
              icon: Icons.arrow_forward,
              onPressed: () => context.go('/phone-otp'),
            ),
          ],
        ),
      ),
    );
  }
}

