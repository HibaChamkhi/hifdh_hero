import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/constants/app_strings.dart';
import 'package:hifdh_hero/core/di/injection.dart';
import 'package:hifdh_hero/core/ui/widgets/selection_row.dart';
import 'package:hifdh_hero/domain/onboarding/models/memorization_level.dart';
import 'package:hifdh_hero/domain/memorization/models/ayah_range.dart';
import 'package:hifdh_hero/domain/memorization/models/memorized_ayahs.dart';
import 'package:hifdh_hero/domain/profile/models/editable_profile.dart';
import 'package:hifdh_hero/domain/profile/repositories/profile_repository.dart';
import 'package:hifdh_hero/domain/quran/models/ayah.dart';
import 'package:hifdh_hero/domain/quran/models/ayah_search_result.dart';
import 'package:hifdh_hero/domain/quran/models/juz.dart';
import 'package:hifdh_hero/domain/quran/models/revelation_type.dart';
import 'package:hifdh_hero/domain/quran/models/surah.dart';
import 'package:hifdh_hero/domain/quran/repositories/quran_repository.dart';
import 'package:hifdh_hero/presentation/profile/bloc/profile_edit_bloc.dart';
import 'package:hifdh_hero/presentation/profile/pages/edit_profile_page.dart';
import 'package:hifdh_hero/presentation/quran/pages/select_surahs_page.dart';
import 'package:hifdh_hero/presentation/profile/widgets/profile_avatar.dart';

const _surahs = [
  Surah(
    number: 1,
    name: 'الفاتحة',
    englishName: 'Al-Fatihah',
    revelationType: RevelationType.meccan,
    ayahCount: 7,
  ),
  Surah(
    number: 112,
    name: 'الإخلاص',
    englishName: 'Al-Ikhlas',
    revelationType: RevelationType.meccan,
    ayahCount: 4,
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

class _FakeProfileRepository implements ProfileRepository {
  EditableProfile stored = EditableProfile(
    name: 'سارة يوسف',
    level: MemorizationLevel.beginner,
    memorized: MemorizedAyahs.of(const [AyahRange(surah: 1, start: 1, end: 7)]),
  );
  EditableProfile? saved;

  @override
  EditableProfile getProfile() => stored;
  @override
  Future<void> save(EditableProfile profile) async => saved = profile;
  @override
  Future<String> persistAvatar(String pickedPath) async => '/documents/a.jpg';
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

void main() {
  late _FakeProfileRepository repository;

  setUp(() {
    repository = _FakeProfileRepository();
    getIt
      ..registerSingleton<ProfileRepository>(repository)
      ..registerSingleton<QuranRepository>(_FakeQuranRepository())
      ..registerFactory<ProfileEditBloc>(() => ProfileEditBloc(repository));
  });

  tearDown(getIt.reset);

  testWidgets('edit screen shows the current name, level and surah count', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const EditProfilePage()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.editProfile), findsOneWidget);
    expect(find.byType(ProfileAvatar), findsOneWidget);
    expect(find.text(AppStrings.changePhoto), findsOneWidget);
    // Name is seeded into the field.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'سارة يوسف',
    );
    // All three levels offered, and the memorized count reflects the profile.
    expect(find.text(AppStrings.levelBeginner), findsOneWidget);
    expect(find.text(AppStrings.levelHafiz), findsOneWidget);
    expect(
      find.text('7 ${AppStrings.ayahCount} · 1 ${AppStrings.surahUnit}'),
      findsOneWidget,
    );
  });

  testWidgets('editing the name and saving writes it through', (tester) async {
    await tester.pumpWidget(_host(const EditProfilePage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'هبة شمخي');
    await tester.pump();

    final save = find.text(AppStrings.saveChanges);
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(repository.saved?.name, 'هبة شمخي');
  });

  testWidgets('clearing the name disables saving', (tester) async {
    await tester.pumpWidget(_host(const EditProfilePage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.nameRequired), findsOneWidget);

    final save = find.text(AppStrings.saveChanges);
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(repository.saved, isNull);
  });

  testWidgets('surah picker toggles selection and filters by search', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SelectSurahsPage(
          initial: MemorizedAyahs.of(const [
            AyahRange(surah: 1, start: 1, end: 7),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SelectionRow), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'الفاتحة');
    await tester.pumpAndSettle();
    expect(find.byType(SelectionRow), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ikhlas');
    await tester.pumpAndSettle();
    expect(find.text('الإخلاص'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noSurahFound), findsOneWidget);
  });

  testWidgets('surah picker returns the edited set, and null on back', (
    tester,
  ) async {
    MemorizedAyahs? result;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async => result = await showSelectSurahs(
                  context,
                  MemorizedAyahs.of(const [
                    AyahRange(surah: 1, start: 1, end: 7),
                  ]),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الإخلاص'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    expect(result!.startedSurahs, {1, 112});

    // Backing out of a second visit discards the change.
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الفاتحة'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  group('a partly-memorized surah is protected in the picker', () {
    // Al-Fatihah with 3 of 7 ayahs marked — the kind of record only the reader
    // can produce, and the kind a stray tap would flatten.
    final partial = MemorizedAyahs.of(const [
      AyahRange(surah: 1, start: 1, end: 3),
    ]);

    testWidgets('the row shows how much of it is done', (tester) async {
      await tester.pumpWidget(_host(SelectSurahsPage(initial: partial)));
      await tester.pumpAndSettle();

      expect(find.textContaining('٣/٧'), findsOneWidget);
    });

    testWidgets('cancelling the overwrite leaves it alone', (tester) async {
      await tester.pumpWidget(_host(SelectSurahsPage(initial: partial)));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('الفاتحة'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.overwritePartialTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      // Still 3 of 7, not the whole surah.
      expect(find.textContaining('٣/٧'), findsOneWidget);
    });

    testWidgets('confirming marks the whole surah', (tester) async {
      await tester.pumpWidget(_host(SelectSurahsPage(initial: partial)));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('الفاتحة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.confirm));
      await tester.pumpAndSettle();

      expect(find.textContaining('٣/٧'), findsNothing);
    });

    testWidgets('an untouched surah toggles without asking', (tester) async {
      await tester.pumpWidget(
        _host(const SelectSurahsPage(initial: MemorizedAyahs.empty)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('الإخلاص'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.overwritePartialTitle), findsNothing);
    });
  });

  testWidgets('avatar falls back to initials when the file is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Scaffold(
          body: Center(
            child: ProfileAvatar(
              name: 'سارة يوسف',
              imagePath: '/nope/missing.jpg',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('س ي'), findsOneWidget);
  });
}
