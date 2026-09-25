import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/constants/app_strings.dart';
import 'package:hifdh_hero/core/di/injection.dart';
import 'package:hifdh_hero/domain/onboarding/models/memorization_level.dart';
import 'package:hifdh_hero/domain/progress/models/juz_progress.dart';
import 'package:hifdh_hero/domain/progress/models/user_progress.dart';
import 'package:hifdh_hero/domain/progress/repositories/progress_repository.dart';
import 'package:hifdh_hero/domain/quran/models/juz.dart';
import 'package:hifdh_hero/domain/revision/models/revision_history.dart';
import 'package:hifdh_hero/domain/revision/models/revision_item.dart';
import 'package:hifdh_hero/domain/revision/models/revision_plan.dart';
import 'package:hifdh_hero/domain/revision/repositories/revision_repository.dart';
import 'package:hifdh_hero/presentation/home/pages/home_page.dart';
import 'package:hifdh_hero/presentation/map/pages/hifz_map_page.dart';
import 'package:hifdh_hero/presentation/profile/pages/profile_page.dart';
import 'package:hifdh_hero/presentation/progress/bloc/progress_bloc.dart';

JuzProgress _juz(int number, String name, int done, int total) => JuzProgress(
  juz: Juz(
    number: number,
    name: name,
    startSurah: 1,
    startAyah: 1,
    endSurah: 1,
    endAyah: total,
  ),
  memorizedAyahs: done,
  totalAyahs: total,
);

final _progress = UserProgress(
  name: 'سارة يوسف',
  level: MemorizationLevel.intermediate,
  currentStreak: 25,
  exploredAyahs: 120,
  trackedAyahs: 240,
  memorizedSurahs: 14,
  xp: 1240,
  juz: [
    _juz(30, 'جزء عمّ', 10, 10),
    _juz(29, 'جزء تبارك', 6, 10),
    _juz(28, 'جزء قد سمع', 0, 10),
  ],
);

class _FakeProgressRepository implements ProgressRepository {
  @override
  Future<UserProgress> getUserProgress() async => _progress;
}

class _FakeRevisionRepository implements RevisionRepository {
  @override
  Future<void> ensureSeeded() async {}
  @override
  Future<RevisionHistory> getHistory() async => const RevisionHistory();
  @override
  Future<RevisionPlan> getTodayPlan({int limit = 10}) async =>
      const RevisionPlan();
  @override
  Future<List<RevisionItem>> getWeakAyahs({int limit = 20}) async => [];
  @override
  Future<void> recordReview(int s, int a, bool correct) async {}
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
    home: Scaffold(body: child),
  ),
);

void main() {
  setUp(() {
    final revision = _FakeRevisionRepository();
    getIt
      ..registerSingleton<ProgressRepository>(_FakeProgressRepository())
      ..registerSingleton<RevisionRepository>(revision)
      ..registerFactory<ProgressBloc>(
        () => ProgressBloc(getIt<ProgressRepository>(), revision),
      );
  });

  tearDown(getIt.reset);

  testWidgets('home shows the greeting, stats and journey', (tester) async {
    await tester.pumpWidget(_host(HomePage(onContinueTraining: () {})));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.greeting), findsOneWidget);
    expect(find.text('سارة يوسف'), findsOneWidget);
    expect(find.text('120'), findsOneWidget); // ayahs explored
    expect(find.text('25'), findsWidgets); // streak, ring + card
    expect(find.text(AppStrings.yourJourney), findsOneWidget);
    // Only the started juz belong on the home card.
    expect(find.text('جزء عمّ'), findsOneWidget);
    expect(find.text('جزء تبارك'), findsOneWidget);
    expect(find.text('جزء قد سمع'), findsNothing);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text(AppStrings.continueTraining), findsOneWidget);
  });

  testWidgets('home hands off to the practice tab', (tester) async {
    var continued = false;
    await tester.pumpWidget(
      _host(HomePage(onContinueTraining: () => continued = true)),
    );
    await tester.pumpAndSettle();

    final button = find.text(AppStrings.continueTraining);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();

    expect(continued, isTrue);
  });

  testWidgets('map lists every juz and locks the ones not yet reachable', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const HifzMapPage()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.hifzMap), findsOneWidget);
    expect(find.text('جزء عمّ'), findsOneWidget);
    expect(find.text('جزء قد سمع'), findsOneWidget);
    // Completed juz show the chevron, unfinished ones their percentage.
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('profile shows the account identity and headline numbers', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const ProfilePage()));
    await tester.pumpAndSettle();

    expect(find.text('س ي'), findsOneWidget); // avatar initials
    expect(find.text('سارة يوسف'), findsOneWidget);
    expect(find.text(AppStrings.levelIntermediate), findsOneWidget);
    expect(find.text('1240'), findsOneWidget); // xp
    expect(find.text('14'), findsOneWidget); // surahs
    expect(find.text('25'), findsOneWidget); // streak
    expect(find.text(AppStrings.logout), findsOneWidget);
  });
}
