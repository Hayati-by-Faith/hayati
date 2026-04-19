import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/village_constants.dart';
import '../../../core/providers/qr_token_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/localization.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/big_button.dart';
import '../../../core/widgets/loading_overlay.dart';

class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _householdSizeController = TextEditingController(text: '4');
  final _commentController = TextEditingController();

  final LocationService _locationService = const LocationService();

  LocationCapture? _location;
  bool _gpsSkipped = false;
  bool _locationAttempted = false;
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptLocationCapture();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _householdSizeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _attemptLocationCapture() async {
    setState(() {
      _locationAttempted = true;
    });
    final result = await _locationService.capture();
    if (!mounted) {
      return;
    }
    if (result.isCaptured && result.capture != null) {
      setState(() {
        _location = result.capture;
        _gpsSkipped = false;
      });
      const AppLogger().log('enrollment_gps_captured');
      return;
    }

    const AppLogger().log(
      'enrollment_gps_unavailable',
      level: AppLogLevel.info,
      error: result.status.name,
    );

    await _showGpsSkipDialog();
  }

  Future<void> _showGpsSkipDialog() async {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final proceedWithoutGps = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            dialogContext.l('enrollment_gps_denied_title'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: Text(
            dialogContext.l('enrollment_gps_denied_body'),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                dialogContext.l('enrollment_gps_retry_button'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                dialogContext.l('enrollment_gps_skip_button'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }
    if (proceedWithoutGps == true) {
      setState(() {
        _gpsSkipped = true;
        _location = null;
      });
      const AppLogger().log('enrollment_gps_skipped');
    } else {
      await _attemptLocationCapture();
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_location == null && !_gpsSkipped) {
      await _showGpsSkipDialog();
      if (!mounted) {
        return;
      }
      if (_location == null && !_gpsSkipped) {
        return;
      }
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    final householdSize = int.tryParse(_householdSizeController.text.trim());
    final payload = <String, dynamic>{
      'villageId': VillageConstants.defaultVillageId,
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'householdSize': householdSize,
      'comment': _commentController.text.trim(),
      if (_location != null) ...{
        'gps': {
          'latitude': _location!.latitude,
          'longitude': _location!.longitude,
        },
        'geohash': _location!.geohash,
      } else ...{
        'gps': null,
        'geohash': null,
      },
    };

    try {
      const AppLogger().log(
        'enrollment_started',
        level: AppLogLevel.info,
      );

      final functions = FirebaseFunctions.instanceFor(
        region: VillageConstants.functionsRegion,
      );
      final callable = functions.httpsCallable('createHousehold');
      final response = await callable.call<Map<String, dynamic>>(payload);
      final result = Map<String, dynamic>.from(response.data);

      final qrToken = result['qrToken'] as String?;
      if (qrToken == null || qrToken.isEmpty) {
        throw StateError('createHousehold returned no qrToken');
      }
      ref.read(lastQrTokenProvider.notifier).state = qrToken;

      const AppLogger().log('enrollment_completed');

      if (!mounted) {
        return;
      }
      context.go('/enrollment/success');
    } on FirebaseFunctionsException catch (error, stack) {
      const AppLogger().log(
        'enrollment_failed',
        level: AppLogLevel.error,
        error: error,
        stackTrace: stack,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = context.l('enrollment_error');
      });
    } catch (error, stack) {
      const AppLogger().log(
        'enrollment_failed',
        level: AppLogLevel.error,
        error: error,
        stackTrace: stack,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = context.l('enrollment_error');
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
            context.l('enrollment_title'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.l('name_label'),
                    ),
                    validator: (value) {
                      if (Validators.isRequired(value)) {
                        return context.l('validation_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: context.l('address_label'),
                    ),
                    validator: (value) {
                      if (Validators.isRequired(value)) {
                        return context.l('validation_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _householdSizeController,
                    decoration: InputDecoration(
                      labelText: context.l('household_size_label'),
                    ),
                    validator: (value) {
                      if (!Validators.isValidHouseholdSize(value)) {
                        return context.l('validation_invalid');
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: context.l('comment_label'),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  if (_location != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _location!.geohash,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else if (_gpsSkipped && _locationAttempted)
                    Text(
                      context.l('enrollment_gps_skip_button'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 16),
                  BigButton(
                    label: context.l('save_and_continue_button'),
                    icon: Icons.save_outlined,
                    onPressed: _submit,
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
      ),
    );
  }
}
