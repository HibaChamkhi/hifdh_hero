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

  // Home (screen 07)
  static const greeting = 'السلام عليكم';
  static const exploredAyahs = 'مستكشفة الآيات';
  static const streakDays = 'أيام متتالية';
  static const dayUnit = 'يوم';
  static const yourJourney = 'رحلة حفظك';
  static const continueTraining = 'متابعة التدريب';

  // Hifz map (screen 08)
  static const hifzMap = 'خريطة الحفظ';
  static const hifzMapSubtitle = 'أكمل كل جزء لفتح التالي';

  // Profile (screen 11)
  static const profileTitle = 'حسابي';
  static const xpPoints = 'نقاط الخبرة';
  static const surahUnit = 'سورة';
  static const logout = 'تسجيل الخروج';

  // Edit profile (screen 35) + memorized surahs (screen 03)
  static const editProfile = 'تعديل الملف الشخصي';
  static const editProfileAction = 'تعديل';
  static const changePhoto = 'تغيير الصورة';
  static const chooseFromGallery = 'اختيار من المعرض';
  static const takePhoto = 'التقاط صورة';
  static const removePhoto = 'إزالة الصورة';
  static const saveChanges = 'حفظ التغييرات';
  static const profileSaved = 'تم حفظ التغييرات';
  static const nameRequired = 'الرجاء إدخال الاسم';
  static const photoFailed = 'تعذّر اختيار الصورة';
  static const searchSurah = 'ابحثي عن سورة...';
  static const done = 'تم';
  static const noSurahFound = 'لا توجد سورة بهذا الاسم';
  static const surahCount = 'سورة محفوظة';
  static const ayahCount = 'آية محفوظة';
  static const memorizedOfTotal = 'محفوظة';
  static const markWholeSurah = 'تحديد السورة كاملة';
  static const clearWholeSurah = 'إلغاء تحديد السورة';
  static const overwritePartialTitle = 'تحديد السورة كاملة؟';
  static const overwritePartialBody =
      'لديك آيات محددة يدويًا في هذه السورة. تحديد السورة كاملة سيستبدل هذا '
      'التحديد.';
  static const cancel = 'إلغاء';
  static const confirm = 'تأكيد';

  // Reading (surah reader)
  static const practice = 'تدرّب';
  static const read = 'اقرأ';

  // Errors / states
  static const genericError = 'حدث خطأ غير متوقع';
  static const noConnection = 'لا يوجد اتصال بالإنترنت';
}
