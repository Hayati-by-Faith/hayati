// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_title => 'حياتي';

  @override
  String get welcome_title => 'أهلاً بك في حياتي';

  @override
  String get welcome_subtitle => 'منصة مجتمعية لتسجيل القرى وتقديم الخدمات.';

  @override
  String get welcome_cta => 'بدء التسجيل';

  @override
  String get phone_otp_title => 'تأكيد رقم الهاتف';

  @override
  String get phone_number_label => 'رقم الهاتف';

  @override
  String get send_code_button => 'إرسال رمز التحقق';

  @override
  String get verification_code_label => 'رمز التحقق';

  @override
  String get verify_code_button => 'تأكيد الرمز';

  @override
  String get validation_required => 'هذه الخانة مطلوبة.';

  @override
  String get validation_invalid => 'يرجى إدخال قيمة صحيحة.';

  @override
  String get consent_title => 'الموافقة والشروط';

  @override
  String get consent_body =>
      'نجمع فقط البيانات اللازمة لتقديم منفعة واضحة للأسرة.';

  @override
  String get consent_accept_button => 'موافقة ومتابعة';

  @override
  String get enrollment_title => 'استمارة التسجيل';

  @override
  String get name_label => 'الاسم بالعربية';

  @override
  String get address_label => 'العنوان';

  @override
  String get household_size_label => 'حجم الأسرة';

  @override
  String get comment_label => 'ملاحظات';

  @override
  String get save_and_continue_button => 'حفظ ومتابعة';

  @override
  String get success_title => 'اكتمل التسجيل';

  @override
  String get success_subtitle => 'بطاقة QR الخاصة بك جاهزة.';

  @override
  String get open_qr_button => 'فتح QR الخاص بي';

  @override
  String get qr_title => 'رمز QR الخاص بي';

  @override
  String get qr_share_button => 'مشاركة';

  @override
  String get qr_save_button => 'حفظ في المعرض';

  @override
  String get scanner_title => 'مسح رمز QR';

  @override
  String get scanner_hint => 'وجّه الكاميرا نحو رمز QR الخاص بالأسرة.';

  @override
  String get resident_home_title => 'الصفحة الرئيسية للمقيم';

  @override
  String get blog_title => 'تغذية المدونة';

  @override
  String get blog_placeholder => 'ستظهر منشورات القرية هنا عندما تصبح متاحة.';

  @override
  String get village_picker_title => 'اختيار القرية';

  @override
  String get select_village_hint =>
      'اختر سياق القرية النشط لأعمال السوبر أدمن.';

  @override
  String get staff_home_title => 'الصفحة الرئيسية للموظفين';

  @override
  String get super_admin_home_title => 'الصفحة الرئيسية للسوبر أدمن';

  @override
  String get phase_locked_title => 'هذه المرحلة مغلقة';

  @override
  String get phase_locked_body => 'القرية الحالية لم تفعل هذه الميزة بعد.';

  @override
  String get loading_text => 'جار التحميل';
}
