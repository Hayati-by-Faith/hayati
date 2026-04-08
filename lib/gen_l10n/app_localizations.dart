import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Hayati'**
  String get app_title;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hayati'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A community platform for village enrollment and services.'**
  String get welcome_subtitle;

  /// No description provided for @welcome_cta.
  ///
  /// In en, this message translates to:
  /// **'Start enrollment'**
  String get welcome_cta;

  /// No description provided for @phone_otp_title.
  ///
  /// In en, this message translates to:
  /// **'Verify phone number'**
  String get phone_otp_title;

  /// No description provided for @phone_number_label.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone_number_label;

  /// No description provided for @send_code_button.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get send_code_button;

  /// No description provided for @verification_code_label.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verification_code_label;

  /// No description provided for @verify_code_button.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verify_code_button;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validation_required;

  /// No description provided for @validation_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid value.'**
  String get validation_invalid;

  /// No description provided for @consent_title.
  ///
  /// In en, this message translates to:
  /// **'Consent and terms'**
  String get consent_title;

  /// No description provided for @consent_body.
  ///
  /// In en, this message translates to:
  /// **'We collect only the information needed to deliver a clear benefit to your household.'**
  String get consent_body;

  /// No description provided for @consent_accept_button.
  ///
  /// In en, this message translates to:
  /// **'Accept and continue'**
  String get consent_accept_button;

  /// No description provided for @enrollment_title.
  ///
  /// In en, this message translates to:
  /// **'Enrollment form'**
  String get enrollment_title;

  /// No description provided for @name_label.
  ///
  /// In en, this message translates to:
  /// **'Name in Arabic'**
  String get name_label;

  /// No description provided for @address_label.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address_label;

  /// No description provided for @household_size_label.
  ///
  /// In en, this message translates to:
  /// **'Household size'**
  String get household_size_label;

  /// No description provided for @comment_label.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment_label;

  /// No description provided for @save_and_continue_button.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get save_and_continue_button;

  /// No description provided for @success_title.
  ///
  /// In en, this message translates to:
  /// **'Enrollment complete'**
  String get success_title;

  /// No description provided for @success_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your QR identity is ready.'**
  String get success_subtitle;

  /// No description provided for @open_qr_button.
  ///
  /// In en, this message translates to:
  /// **'Open my QR'**
  String get open_qr_button;

  /// No description provided for @qr_title.
  ///
  /// In en, this message translates to:
  /// **'My QR code'**
  String get qr_title;

  /// No description provided for @qr_share_button.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get qr_share_button;

  /// No description provided for @qr_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get qr_save_button;

  /// No description provided for @scanner_title.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanner_title;

  /// No description provided for @scanner_hint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a household QR code.'**
  String get scanner_hint;

  /// No description provided for @resident_home_title.
  ///
  /// In en, this message translates to:
  /// **'Resident home'**
  String get resident_home_title;

  /// No description provided for @blog_title.
  ///
  /// In en, this message translates to:
  /// **'Blog feed'**
  String get blog_title;

  /// No description provided for @blog_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Blog content will appear here once village posts are available.'**
  String get blog_placeholder;

  /// No description provided for @village_picker_title.
  ///
  /// In en, this message translates to:
  /// **'Choose village'**
  String get village_picker_title;

  /// No description provided for @select_village_hint.
  ///
  /// In en, this message translates to:
  /// **'Select the active village context for super admin work.'**
  String get select_village_hint;

  /// No description provided for @staff_home_title.
  ///
  /// In en, this message translates to:
  /// **'Staff home'**
  String get staff_home_title;

  /// No description provided for @super_admin_home_title.
  ///
  /// In en, this message translates to:
  /// **'Super admin home'**
  String get super_admin_home_title;

  /// No description provided for @phase_locked_title.
  ///
  /// In en, this message translates to:
  /// **'This phase is locked'**
  String get phase_locked_title;

  /// No description provided for @phase_locked_body.
  ///
  /// In en, this message translates to:
  /// **'The current village has not enabled this feature yet.'**
  String get phase_locked_body;

  /// No description provided for @loading_text.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading_text;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
