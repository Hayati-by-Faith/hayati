import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/services/qr_service.dart';
import '../../../core/utils/localization.dart';
import '../../../core/widgets/big_button.dart';

class EnrollmentSuccessScreen extends StatelessWidget {
  const EnrollmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payload = const QrService().buildResidentPayload(
      villageId: 'abusir',
      householdId: 'household-demo',
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l('success_title'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l('success_subtitle'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Center(
              child: QrImageView(
                data: payload,
                size: 220,
                semanticsLabel: context.l('qr_title'),
              ),
            ),
            const SizedBox(height: 24),
            BigButton(
              label: context.l('open_qr_button'),
              icon: Icons.qr_code_2_outlined,
              onPressed: () => context.go('/qr'),
            ),
          ],
        ),
      ),
    );
  }
}

