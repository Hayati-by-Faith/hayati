import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/providers/qr_token_provider.dart';
import '../../../core/utils/localization.dart';
import '../../../core/widgets/big_button.dart';

class EnrollmentSuccessScreen extends ConsumerWidget {
  const EnrollmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrToken = ref.watch(lastQrTokenProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l('success_title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l('success_subtitle'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              if (qrToken != null && qrToken.isNotEmpty)
                Center(
                  child: QrImageView(
                    data: qrToken,
                    size: 220,
                    semanticsLabel: context.l('qr_title'),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      context.l('loading_text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
      ),
    );
  }
}
