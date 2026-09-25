import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/constants/app_strings.dart';
import 'package:hifdh_hero/core/di/injection.dart';
import 'package:hifdh_hero/core/ui/styles/text_styles.dart';
import 'package:hifdh_hero/core/utils/arabic_text.dart';
import 'package:hifdh_hero/domain/memorization/models/memorized_ayahs.dart';
import 'package:hifdh_hero/domain/memorization/repositories/memorization_repository.dart';
import 'package:hifdh_hero/domain/quran/models/ayah.dart';
import 'package:hifdh_hero/domain/quran/models/ayah_search_result.dart';
import 'package:hifdh_hero/domain/quran/models/juz.dart';
import 'package:hifdh_hero/domain/quran/models/revelation_type.dart';
import 'package:hifdh_hero/domain/quran/models/surah.dart';
import 'package:hifdh_hero/domain/quran/repositories/quran_repository.dart';
import 'package:hifdh_hero/presentation/quran/pages/surah_reader_page.dart';

const _basmalah = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

/// Al-Fatihah carries the basmalah as ayah 1; At-Tawbah has none; everything
/// else gets it as a heading.
const _fatihah = Surah(
  number: 1,
  name: 'الفاتحة',
  englishName: 'Al-Fatihah',
  revelationType: RevelationType.meccan,
  ayahCount: 2,
);
const _tawbah = Surah(
  number: 9,
  name: 'التوبة',
  englishName: 'At-Tawbah',
  revelationType: RevelationType.medinan,
  ayahCount: 1,
);
const _ikhlas = Surah(
  number: 112,
  name: 'الإخلاص',
  englishName: 'Al-Ikhlas',
  revelationType: RevelationType.meccan,
  ayahCount: 2,
);

class _FakeQuranRepository implements QuranRepository {
  @override
  Future<List<Ayah>> getAyahs(int surahNumber) async => switch (surahNumber) {
    1 => const [
      Ayah(number: 1, text: _basmalah),
      Ayah(number: 2, text: 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ'),
    ],
    9 => const [Ayah(number: 1, text: 'بَرَآءَةٞ مِّنَ ٱللَّهِ')],
    _ => const [
      Ayah(number: 1, text: 'قُلۡ هُوَ ٱللَّهُ أَحَدٌ'),
      Ayah(number: 2, text: 'ٱللَّهُ ٱلصَّمَدُ'),
    ],
  };
  @override
  Future<List<Juz>> getJuzList() async => [];
  @override
  Future<Surah> getSurah(int surahNumber) async => _ikhlas;
  @override
  Future<List<Surah>> getSurahs() async => const [_fatihah, _tawbah, _ikhlas];
  @override
  Future<List<Surah>> getSurahsInJuz(int juzNumber) async => const [];
  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 30,
  }) async => [];
  @override
  Future<List<Surah>> searchSurahs(String query) async => [];
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
  ),
);

/// Counts how many times [text] appears as its own Text widget.
int _countText(WidgetTester tester, String text) =>
    tester.widgetList(find.text(text)).length;

class _FakeMemorizationRepository implements MemorizationRepository {
  MemorizedAyahs current = MemorizedAyahs.empty;

  @override
  MemorizedAyahs get() => current;

  @override
  Future<void> save(MemorizedAyahs memorized) async => current = memorized;

  @override
  Future<MemorizedAyahs> toggleAyah(int surah, int ayah) async =>
      current = current.toggleAyah(surah, ayah);

  @override
  Future<MemorizedAyahs> setWholeSurah(
    int surah,
    int ayahCount, {
    required bool memorized,
  }) async => current = current.setWholeSurah(surah, ayahCount, memorized);
}

void main() {
  late _FakeMemorizationRepository memorization;

  setUp(() {
    memorization = _FakeMemorizationRepository();
    getIt
      ..registerSingleton<QuranRepository>(_FakeQuranRepository())
      ..registerSingleton<MemorizationRepository>(memorization);
  });

  tearDown(getIt.reset);

  testWidgets('renders the surah heading and every ayah', (tester) async {
    await tester.pumpWidget(_host(const SurahReaderPage(surah: _ikhlas)));
    await tester.pumpAndSettle();

    expect(find.text('سورة الإخلاص'), findsWidgets);
    expect(find.textContaining('قُلۡ هُوَ ٱللَّهُ أَحَدٌ'), findsOneWidget);
    expect(find.textContaining('ٱللَّهُ ٱلصَّمَدُ'), findsOneWidget);
    // Meta line uses Arabic-Indic digits, as a mushaf does.
    expect(find.textContaining('٢ آية'), findsOneWidget);
  });

  testWidgets('ayah text is set in the Uthmani face, not the UI face', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const SurahReaderPage(surah: _ikhlas)));
    await tester.pumpAndSettle();

    final ayah = tester.widget<Text>(
      find.textContaining('قُلۡ هُوَ ٱللَّهُ أَحَدٌ'),
    );
    expect(ayah.style?.fontFamily, AppTextStyles.quranFont);
    expect(ayah.style?.fontFamily, isNot(AppTextStyles.uiFont));
  });

  group('basmalah', () {
    testWidgets('is shown as a heading for an ordinary surah', (tester) async {
      await tester.pumpWidget(_host(const SurahReaderPage(surah: _ikhlas)));
      await tester.pumpAndSettle();

      expect(_countText(tester, _basmalah), 1);
    });

    testWidgets('is not repeated for Al-Fatihah, which carries it as ayah 1', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const SurahReaderPage(surah: _fatihah)));
      await tester.pumpAndSettle();

      // Once, inside the ayah block — not again as a heading.
      expect(_countText(tester, _basmalah), 0);
      expect(find.textContaining(_basmalah), findsOneWidget);
    });

    testWidgets('is omitted entirely for At-Tawbah', (tester) async {
      await tester.pumpWidget(_host(const SurahReaderPage(surah: _tawbah)));
      await tester.pumpAndSettle();

      expect(find.textContaining(_basmalah), findsNothing);
    });
  });

  testWidgets('practice stays one tap away', (tester) async {
    await tester.pumpWidget(_host(const SurahReaderPage(surah: _ikhlas)));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.practice), findsOneWidget);
  });

  group('marking while reading', () {
    testWidgets('tapping an ayah marks it, tapping again clears it', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const SurahReaderPage(surah: _ikhlas)));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('قُلۡ هُوَ ٱللَّهُ أَحَدٌ'));
      await tester.pumpAndSettle();
      expect(memorization.current.contains(112, 1), isTrue);
      // The heading counts it straight away — no save step.
      expect(find.textContaining('١ / ٢'), findsOneWidget);

      await tester.tap(find.textContaining('قُلۡ هُوَ ٱللَّهُ أَحَدٌ'));
      await tester.pumpAndSettle();
      expect(memorization.current.isEmpty, isTrue);
    });

    testWidgets('the app-bar action marks and clears the whole surah', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const SurahReaderPage(surah: _ikhlas)));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(AppStrings.markWholeSurah));
      await tester.pumpAndSettle();
      expect(memorization.current.isWholeSurah(112, 2), isTrue);
      expect(find.textContaining('٢ / ٢'), findsOneWidget);

      await tester.tap(find.byTooltip(AppStrings.clearWholeSurah));
      await tester.pumpAndSettle();
      expect(memorization.current.isEmpty, isTrue);
    });

    testWidgets('an already-memorized ayah shows as marked on open', (
      tester,
    ) async {
      memorization.current = MemorizedAyahs.empty.toggleAyah(112, 2);
      await tester.pumpWidget(_host(const SurahReaderPage(surah: _ikhlas)));
      await tester.pumpAndSettle();

      expect(find.textContaining('١ / ٢'), findsOneWidget);
    });
  });

  test('Arabic-Indic numerals', () {
    expect(toArabicNumerals(0), '٠');
    expect(toArabicNumerals(7), '٧');
    expect(toArabicNumerals(286), '٢٨٦');
  });
}
