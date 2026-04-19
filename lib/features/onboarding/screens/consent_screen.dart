import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/logger_service.dart';
import '../../../core/utils/localization.dart';
import '../../../core/widgets/big_button.dart';
import '../../../core/widgets/loading_overlay.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _isBusy = false;
  String? _errorMessage;

  Future<void> _acceptConsent() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _errorMessage = context.l('consent_error');
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final consentRef = FirebaseFirestore.instance
          .collection('households')
          .doc(uid)
          .collection('consents')
          .doc();

      await consentRef.set({
        'scope': 'privacy_v1',
        'version': 1,
        'grantedByUid': uid,
        'onBehalfOfUid': uid,
        'grantedAt': FieldValue.serverTimestamp(),
        'revokedAt': null,
        'evidence': {'method': 'otp'},
        'schemaVersion': 1,
      });

      const AppLogger().log('consent_accepted');

      if (!mounted) {
        return;
      }
      context.go('/enrollment');
    } catch (error, stack) {
      const AppLogger().log(
        'consent_failed',
        level: AppLogLevel.error,
        error: error,
        stackTrace: stack,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = context.l('consent_error');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isBusy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.l('consent_title'),
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
                  context.l('consent_body'),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                BigButton(
                  label: context.l('consent_accept_button'),
                  icon: Icons.check_circle_outline,
                  onPressed: _acceptConsent,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
