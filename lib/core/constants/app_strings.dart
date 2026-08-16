/// Central Arabic string table.
///
/// This is an interim solution so no Arabic text is hard-coded in widgets.
/// For multi-language support (T115/T116 in the backlog) migrate these keys to
/// Flutter's ARB / gen-l10n or easy_localization.
class AppStrings {
  AppStrings._();

  // App
  static const appName = 'Hifz Hero';
  static const tagline = 'رحلتك في حفظ القرآن';

  // Onboarding
  static const startJourney = 'ابدأ رحلة حفظك';
  static const startJourneySubtitle = 'بضعة أسئلة سريعة لتخصيص خطتك';
  static const memorizationLevel = 'مستوى الحفظ';
  static const levelBeginner = 'مبتدئ';
  static const levelIntermediate = 'متوسط';
  static const levelHafiz = 'مراجعة حافظ';
  static const memorizedSurahs = 'السور التي حفظتها';
  static const more = '+ المزيد';
  static const startMyJourney = 'ابدأ رحلتي';
  static const next = 'التالي';

  // Common actions
  static const next2 = 'التالي';
  static const continueLabel = 'متابعة';
  static const save = 'حفظ';
  static const apply = 'تطبيق';

  // Auth
  static const welcomeBack = 'مرحبًا بعودتك';
  static const welcomeBackSubtitle = 'تابع رحلة حفظك من حيث توقفت';
  static const email = 'البريد الإلكتروني';
  static const password = 'كلمة المرور';
  static const forgotPassword = 'نسيت كلمة المرور؟';
  static const login = 'تسجيل الدخول';
  static const createAccount = 'إنشاء حساب';
  static const noAccount = 'ليس لديك حساب؟';
  static const haveAccount = 'لديك حساب بالفعل؟';
  static const fullName = 'الاسم الكامل';
  static const registerTitle = 'أنشئ حسابك';
  static const registerSubtitle = 'انضم إلى آلاف الحفّاظ اليوم';
  static const agreeTerms = 'أوافق على الشروط وسياسة الخصوصية';
  static const forgotTitle = 'نسيت كلمة المرور؟';
  static const forgotSubtitle =
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور';
  static const sendResetLink = 'إرسال رابط إعادة التعيين';
  static const backToLogin = 'العودة لتسجيل الدخول';
  static const resetLinkSent = 'تم إرسال رابط إعادة التعيين إلى بريدك';
  static const emailHint = 'example@email.com';

  // Errors / states
  static const genericError = 'حدث خطأ غير متوقع';
  static const noConnection = 'لا يوجد اتصال بالإنترنت';
}
