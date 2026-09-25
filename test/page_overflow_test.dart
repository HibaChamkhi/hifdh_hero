import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/di/injection.dart';
import 'package:hifdh_hero/domain/challenges/models/challenge_result.dart';
import 'package:hifdh_hero/domain/quran/models/revelation_type.dart';
import 'package:hifdh_hero/domain/quran/models/surah.dart';
import 'package:hifdh_hero/domain/revision/models/ayah_review_state.dart';
import 'package:hifdh_hero/domain/revision/models/revision_history.dart';
import 'package:hifdh_hero/domain/revision/models/revision_item.dart';
import 'package:hifdh_hero/domain/revision/models/revision_plan.dart';
import 'package:hifdh_hero/domain/revision/repositories/revision_repository.dart';
import 'package:hifdh_hero/presentation/challenges/pages/challenge_result_page.dart';
import 'package:hifdh_hero/presentation/challenges/pages/surah_challenges_page.dart';
import 'package:hifdh_hero/presentation/revision/bloc/revision_bloc.dart';
import 'package:hifdh_hero/presentation/revision/pages/revision_plan_page.dart';

/// A full plan — five due rows plus both stat tiles is the worst case, and
/// what overflowed the التقدم tab on a real device.
RevisionPlan _fullPlan() => RevisionPlan(
  items: [
    for (var i = 1; i <= 5; i++)
      RevisionItem(
        state: AyahReviewState(surahNumber: 2, ayahNumber: i),
        surahName: 'البقرة',
      ),
  ],
);

class _FakeRevisionRepository implements RevisionRepository {
  @override
  Future<void> ensureSeeded() async {}
  @override
  Future<RevisionHistory> getHistory() async => const RevisionHistory();
  @override
  Future<RevisionPlan> getTodayPlan({int limit = 10}) async => _fullPlan();
  @override
  Future<List<RevisionItem>> getWeakAyahs({int limit = 20}) async => [];
  @override
  Future<void> recordReview(int s, int a, bool correct) async {}
}

const _surah = Surah(
  number: 67,
  name: 'الملك',
  englishName: 'Al-Mulk',
  revelationType: RevelationType.meccan,
  ayahCount: 30,
);

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

/// Renders [child] at the default 800x600 test viewport — short and wide
/// relative to the 390x844 design canvas, so every fixed-height column is
/// under real pressure. A RenderFlex overflow throws during layout in tests,
/// so reaching the assertions below is itself the assertion.
///
/// Deliberately no `setSurfaceSize`: resizing after `ScreenUtilInit` has
/// captured its scale mixes two scales and produces overflows no device sees.
Future<void> _pumpTight(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_host(child));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    final repository = _FakeRevisionRepository();
    getIt
      ..registerSingleton<RevisionRepository>(repository)
      ..registerFactory<RevisionBloc>(() => RevisionBloc(repository));
  });

  tearDown(getIt.reset);

  testWidgets('revision plan scrolls instead of overflowing', (tester) async {
    await _pumpTight(tester, const RevisionPlanPage());

    expect(find.text('توصية اليوم'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('challenge result scrolls instead of overflowing', (
    tester,
  ) async {
    await _pumpTight(
      tester,
      const ChallengeResultPage(
        result: ChallengeResult(
          total: 10,
          correct: 9,
          xp: 120,
          duration: Duration(minutes: 2),
        ),
      ),
    );

    expect(find.text('أحسنت!'), findsOneWidget);
  });

  testWidgets('surah challenges scrolls instead of overflowing', (
    tester,
  ) async {
    await _pumpTight(tester, const SurahChallengesPage(surah: _surah));

    expect(find.text('سورة الملك'), findsOneWidget);
  });
}
