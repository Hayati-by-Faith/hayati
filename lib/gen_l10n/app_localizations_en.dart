// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Hayati';

  @override
  String get welcome_title => 'Welcome to Hayati';

  @override
  String get welcome_subtitle =>
      'A community platform for village enrollment and services.';

  @override
  String get welcome_cta => 'Start enrollment';

  @override
  String get phone_otp_title => 'Verify phone number';

  @override
  String get phone_number_label => 'Phone number';

  @override
  String get send_code_button => 'Send verification code';

  @override
  String get verification_code_label => 'Verification code';

  @override
  String get verify_code_button => 'Verify code';

  @override
  String get validation_required => 'This field is required.';

  @override
  String get validation_invalid => 'Please enter a valid value.';

  @override
  String get consent_title => 'Consent and terms';

  @override
  String get consent_body =>
      'We collect only the information needed to deliver a clear benefit to your household.';

  @override
  String get consent_accept_button => 'Accept and continue';

  @override
  String get enrollment_title => 'Enrollment form';

  @override
  String get name_label => 'Name in Arabic';

  @override
  String get address_label => 'Address';

  @override
  String get household_size_label => 'Household size';

  @override
  String get comment_label => 'Comment';

  @override
  String get save_and_continue_button => 'Save and continue';

  @override
  String get success_title => 'Enrollment complete';

  @override
  String get success_subtitle => 'Your QR identity is ready.';

  @override
  String get open_qr_button => 'Open my QR';

  @override
  String get qr_title => 'My QR code';

  @override
  String get qr_share_button => 'Share';

  @override
  String get qr_save_button => 'Save to gallery';

  @override
  String get scanner_title => 'Scan QR code';

  @override
  String get scanner_hint => 'Point the camera at a household QR code.';

  @override
  String get resident_home_title => 'Resident home';

  @override
  String get blog_title => 'Blog feed';

  @override
  String get blog_placeholder =>
      'Blog content will appear here once village posts are available.';

  @override
  String get village_picker_title => 'Choose village';

  @override
  String get select_village_hint =>
      'Select the active village context for super admin work.';

  @override
  String get staff_home_title => 'Staff home';

  @override
  String get super_admin_home_title => 'Super admin home';

  @override
  String get phase_locked_title => 'This phase is locked';

  @override
  String get phase_locked_body =>
      'The current village has not enabled this feature yet.';

  @override
  String get loading_text => 'Loading';
}
