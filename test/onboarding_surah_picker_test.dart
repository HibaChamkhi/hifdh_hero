import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/constants/app_strings.dart';
import 'package:hifdh_hero/core/di/injection.dart';
import 'package:hifdh_hero/domain/onboarding/models/onboarding_profile.dart';
import 'package:hifdh_hero/domain/onboarding/repositories/onboarding_repository.dart';
import 'package:hifdh_hero/domain/quran/models/ayah.dart';
import 'package:hifdh_hero/domain/quran/models/ayah_search_result.dart';
import 'package:hifdh_hero/domain/quran/models/juz.dart';
import 'package:hifdh_hero/domain/quran/models/revelation_type.dart';
import 'package:hifdh_hero/domain/quran/models/surah.dart';
import 'package:hifdh_hero/domain/quran/repositories/quran_repository.dart';
import 'package:hifdh_hero/presentation/onboarding/bloc/onboarding_bloc.dart';
import 'package:hifdh_hero/presentation/onboarding/pages/start_journey_page.dart';

/// Includes a surah the onboarding chips do NOT offer, which is the whole
/// point of the "+ المزيد" control.
const _surahs = [
  Surah(
    number: 1,
    name: 'الفاتحة',
    englishName: 'Al-Fatihah',
    revelationType: RevelationType.meccan,
    ayahCount: 7,
  ),
  Surah(
    number: 67,
    name: 'الملك',
    englishName: 'Al-Mulk',
    revelationType: RevelationType.meccan,
    ayahCount: 30,
  ),
];

class _FakeQuranRepository implements QuranRepository {
  @override
  Future<List<Ayah>> getAyahs(int surahNumber) async => [];
  @override
  Future<List<Juz>> getJuzList() async => [];
  @override
  Future<Surah> getSurah(int surahNumber) async => _surahs.first;
  @override
  Future<List<Surah>> getSurahs() async => _surahs;
  @override
  Future<List<Surah>> getSurahsInJuz(int juzNumber) async => _surahs;
  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 30,
  }) async => [];
  @override
  Future<List<Surah>> searchSurahs(String query) async => [];
}

class _FakeOnboardingRepository implements OnboardingRepository {
  OnboardingProfile profile = const OnboardingProfile();

  @override
  Future<void> completeOnboarding() async {}
  @override
  OnboardingProfile getProfile() => profile;
  @override
  bool isOnboardingComplete() => profile.completed;
  @override
  Future<void> saveProfile(OnboardingProfile p) async => profile = p;
}

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (_, __) => MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
    // Submitting onboarding routes onward; land it somewhere harmless.
    onGenerateRoute: (_) =>
        MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink()),
  ),
);

void main() {
  late _FakeOnboardingRepository onboarding;

  setUp(() {
    onboarding = _FakeOnboardingRepository();
    getIt
      ..registerSingleton<QuranRepository>(_FakeQuranRepository())
      ..registerSingleton<OnboardingRepository>(onboarding)
      ..registerFactory<OnboardingBloc>(
        () => OnboardingBloc(onboarding, _FakeQuranRepository()),
      );
  });

  tearDown(getIt.reset);

  testWidgets('"+ المزيد" opens the full surah list and keeps the choice', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const StartJourneyPage()));
    await tester.pumpAndSettle();

    // Al-Mulk isn't one of the three starter chips.
    expect(find.text('الملك'), findsNothing);

    await tester.tap(find.text(AppStrings.more));
    await tester.pumpAndSettle();

    await tester.tap(find.text('الملك'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    // Back on onboarding, and the pick survives all the way through save.
    expect(find.text(AppStrings.startJourney), findsOneWidget);

    final submit = find.text(AppStrings.startMyJourney);
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(onboarding.profile.memorized.startedSurahs, contains(67));
    // Picking a surah in the list means the whole surah.
    expect(onboarding.profile.memorized.countIn(67), 30);
  });
}
