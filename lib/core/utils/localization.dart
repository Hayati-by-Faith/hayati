import 'package:flutter/widgets.dart';

class _L10nValues {
  const _L10nValues({
    required this.ar,
    required this.en,
  });

  final Map<String, String> ar;
  final Map<String, String> en;

  String valueFor(Locale? locale, String key) {
    final languageCode = locale?.languageCode ?? 'ar';
    final values = switch (languageCode) {
      'en' => en,
      _ => ar,
    };
    return values[key] ?? en[key] ?? key;
  }
}

const _phase1L10n = _L10nValues(
  ar: {
    'app_title': 'حياتي',
    'welcome_title': 'أهلاً بك في حياتي',
    'welcome_subtitle': 'منصة مجتمعية لتسجيل القرى وتقديم الخدمات.',
    'welcome_cta': 'بدء التسجيل',
    'phone_otp_title': 'تأكيد رقم الهاتف',
    'phone_number_label': 'رقم الهاتف',
    'send_code_button': 'إرسال رمز التحقق',
    'verification_code_label': 'رمز التحقق',
    'verify_code_button': 'تأكيد الرمز',
    'validation_required': 'هذه الخانة مطلوبة.',
    'validation_invalid': 'يرجى إدخال قيمة صحيحة.',
    'consent_title': 'الموافقة والشروط',
    'consent_body': 'نجمع فقط البيانات اللازمة لتقديم منفعة واضحة للأسرة.',
    'consent_accept_button': 'موافقة ومتابعة',
    'consent_saving': 'جارٍ حفظ الموافقة...',
    'consent_error': 'تعذر حفظ الموافقة. حاول مرة أخرى.',
    'enrollment_title': 'استمارة التسجيل',
    'name_label': 'الاسم بالعربية',
    'address_label': 'العنوان',
    'household_size_label': 'حجم الأسرة',
    'comment_label': 'ملاحظات',
    'save_and_continue_button': 'حفظ ومتابعة',
    'enrollment_saving': 'جارٍ حفظ بياناتك...',
    'enrollment_error': 'حدث خطأ أثناء التسجيل. حاول مرة أخرى.',
    'enrollment_gps_denied_title': 'تحديد الموقع غير متاح',
    'enrollment_gps_denied_body':
        'الموقع الجغرافي يساعدنا في تقديم خدمات أفضل لقريتك. يمكنك المتابعة بدون تحديد الموقع.',
    'enrollment_gps_skip_button': 'متابعة بدون موقع',
    'enrollment_gps_retry_button': 'المحاولة مرة أخرى',
    'success_title': 'اكتمل التسجيل',
    'success_subtitle': 'بطاقة QR الخاصة بك جاهزة.',
    'open_qr_button': 'فتح QR الخاص بي',
    'qr_title': 'رمز QR الخاص بي',
    'qr_share_button': 'مشاركة',
    'qr_save_button': 'حفظ في المعرض',
    'scanner_title': 'مسح رمز QR',
    'scanner_hint': 'وجّه الكاميرا نحو رمز QR الخاص بالأسرة.',
    'resident_home_title': 'الصفحة الرئيسية للمقيم',
    'blog_title': 'تغذية المدونة',
    'blog_placeholder': 'ستظهر منشورات القرية هنا عندما تصبح متاحة.',
    'village_picker_title': 'اختيار القرية',
    'select_village_hint': 'اختر سياق القرية النشط لأعمال السوبر أدمن.',
    'staff_home_title': 'الصفحة الرئيسية للموظفين',
    'super_admin_home_title': 'الصفحة الرئيسية للسوبر أدمن',
    'not_found_title': 'الصفحة غير موجودة',
    'not_found_body': 'الرابط الذي فتحته غير متاح داخل التطبيق.',
    'phase_locked_title': 'هذه المرحلة مغلقة',
    'phase_locked_body': 'القرية الحالية لم تفعل هذه الميزة بعد.',
    'loading_text': 'جار التحميل',
  },
  en: {
    'app_title': 'Hayati',
    'welcome_title': 'Welcome to Hayati',
    'welcome_subtitle': 'A community platform for village enrollment and services.',
    'welcome_cta': 'Start enrollment',
    'phone_otp_title': 'Verify phone number',
    'phone_number_label': 'Phone number',
    'send_code_button': 'Send verification code',
    'verification_code_label': 'Verification code',
    'verify_code_button': 'Verify code',
    'validation_required': 'This field is required.',
    'validation_invalid': 'Please enter a valid value.',
    'consent_title': 'Consent and terms',
    'consent_body':
        'We collect only the information needed to deliver a clear benefit to your household.',
    'consent_accept_button': 'Accept and continue',
    'consent_saving': 'Saving consent...',
    'consent_error': 'Could not save consent. Please try again.',
    'enrollment_title': 'Enrollment form',
    'name_label': 'Name in Arabic',
    'address_label': 'Address',
    'household_size_label': 'Household size',
    'comment_label': 'Comment',
    'save_and_continue_button': 'Save and continue',
    'enrollment_saving': 'Saving your information...',
    'enrollment_error':
        'An error occurred during enrollment. Please try again.',
    'enrollment_gps_denied_title': 'Location unavailable',
    'enrollment_gps_denied_body':
        'Location helps us deliver better services to your village. You can continue without it.',
    'enrollment_gps_skip_button': 'Continue without location',
    'enrollment_gps_retry_button': 'Try again',
    'success_title': 'Enrollment complete',
    'success_subtitle': 'Your QR identity is ready.',
    'open_qr_button': 'Open my QR',
    'qr_title': 'My QR code',
    'qr_share_button': 'Share',
    'qr_save_button': 'Save to gallery',
    'scanner_title': 'Scan QR code',
    'scanner_hint': 'Point the camera at a household QR code.',
    'resident_home_title': 'Resident home',
    'blog_title': 'Blog feed',
    'blog_placeholder':
        'Blog content will appear here once village posts are available.',
    'village_picker_title': 'Choose village',
    'select_village_hint':
        'Select the active village context for super admin work.',
    'staff_home_title': 'Staff home',
    'super_admin_home_title': 'Super admin home',
    'not_found_title': 'Page not found',
    'not_found_body': 'The link you opened is not available in the app.',
    'phase_locked_title': 'This phase is locked',
    'phase_locked_body': 'The current village has not enabled this feature yet.',
    'loading_text': 'Loading',
  },
);

extension LocalizationX on BuildContext {
  String l(String key) {
    return _phase1L10n.valueFor(Localizations.maybeLocaleOf(this), key);
  }
}

