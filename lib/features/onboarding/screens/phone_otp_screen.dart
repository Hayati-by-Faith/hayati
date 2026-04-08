import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/localization.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/big_button.dart';
import '../../../core/widgets/loading_overlay.dart';

class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+20');
  final _codeController = TextEditingController();
  String? _verificationId;
  String? _errorMessage;
  bool _isBusy = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).sendOtp(
            phoneNumber: _phoneController.text.trim(),
            codeSent: (verificationId) {
              setState(() {
                _verificationId = verificationId;
              });
            },
            verificationFailed: (error) {
              setState(() {
                _errorMessage = error.message;
              });
            },
          );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    final verificationId = _verificationId;
    if (verificationId == null || _codeController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).confirmOtp(
            verificationId: verificationId,
            smsCode: _codeController.text.trim(),
            );
      if (!mounted) {
        return;
      }
      context.go('/consent');
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
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
        appBar: AppBar(title: Text(context.l('phone_otp_title'))),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: context.l('phone_number_label'),
                    ),
                    validator: (value) {
                      if (Validators.isRequired(value)) {
                        return context.l('validation_required');
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  BigButton(
                    label: context.l('send_code_button'),
                    icon: Icons.sms_outlined,
                    onPressed: _sendCode,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: context.l('verification_code_label'),
                    ),
                    validator: (value) {
                      if (Validators.isRequired(value)) {
                        return context.l('validation_required');
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  BigButton(
                    label: context.l('verify_code_button'),
                    icon: Icons.verified_outlined,
                    onPressed: _verifyCode,
                  ),
                  if (_verificationId != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _verificationId!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
