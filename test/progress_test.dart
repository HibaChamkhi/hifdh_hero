import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/data/auth/data_sources/local/auth_prefutils.dart';
import 'package:hifdh_hero/data/progress/repositories/progress_repository_imp.dart';
import 'package:hifdh_hero/data/revision/data_sources/local/revision_local_data_source.dart';
import 'package:hifdh_hero/domain/onboarding/models/memorization_level.dart';
import 'package:hifdh_hero/domain/memorization/models/ayah_range.dart';
import 'package:hifdh_hero/domain/memorization/models/memorized_ayahs.dart';
import 'package:hifdh_hero/domain/onboarding/models/onboarding_profile.dart';
import 'package:hifdh_hero/domain/onboarding/repositories/onboarding_repository.dart';
import 'package:hifdh_hero/domain/progress/models/user_progress.dart';
import 'package:hifdh_hero/domain/quran/models/ayah.dart';
import 'package:hifdh_hero/domain/quran/models/ayah_search_result.dart';
import 'package:hifdh_hero/domain/quran/models/juz.dart';
import 'package:hifdh_hero/domain/quran/models/revelation_type.dart';
import 'package:hifdh_hero/domain/quran/models/surah.dart';
import 'package:hifdh_hero/domain/quran/repositories/quran_repository.dart';
import 'package:hifdh_hero/domain/revision/models/ayah_review_state.dart';
import 'package:hifdh_hero/domain/revision/models/revision_history.dart';
import 'package:hifdh_hero/domain/revision/models/revision_item.dart';
import 'package:hifdh_hero/domain/revision/models/revision_plan.dart';
import 'package:hifdh_hero/domain/revision/repositories/revision_repository.dart';

/// Two tiny surahs and one juz spanning both, so the ayah arithmetic is
/// checkable by hand: juz 30 covers surah 1 ayahs 3-5 and all 4 of surah 2.
const _surahs = [
  Surah(
    number: 1,
    name: 'الأولى',
    englishName: 'First',
    revelationType: RevelationType.meccan,
    ayahCount: 5,
  ),
  Surah(
    number: 2,
    name: 'الثانية',
    englishName: 'Second',
    revelationType: RevelationType.meccan,
    ayahCount: 4,
  ),
];

const _juz30 = Juz(
  number: 30,
  name: 'عمّ',
  startSurah: 1,
  startAyah: 3,
  endSurah: 2,
  endAyah: 4,
);

class _FakeQuranRepository implements QuranRepository {
  @override
  Future<List<Ayah>> getAyahs(int surahNumber) async => [];
  @override
  Future<List<Juz>> getJuzList() async => [_juz30];
  @override
  Future<Surah> getSurah(int surahNumber) async =>
      _surahs.firstWhere((s) => s.number == surahNumber);
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
  final OnboardingProfile profile;
  _FakeOnboardingRepository(this.profile);

  @override
  Future<void> completeOnboarding() async {}
  @override
  OnboardingProfile getProfile() => profile;
  @override
  bool isOnboardingComplete() => profile.completed;
  @override
  Future<void> saveProfile(OnboardingProfile profile) async {}
}

class _FakeRevisionRepository implements RevisionRepository {
  final RevisionHistory history;
  _FakeRevisionRepository(this.history);

  @override
  Future<void> ensureSeeded() async {}
  @override
  Future<RevisionHistory> getHistory() async => history;
  @override
  Future<RevisionPlan> getTodayPlan({int limit = 10}) async =>
      const RevisionPlan();
  @override
  Future<List<RevisionItem>> getWeakAyahs({int limit = 20}) async => [];
  @override
  Future<void> recordReview(int s, int a, bool correct) async {}
}

class _FakeRevisionLocalDataSource implements RevisionLocalDataSource {
  final List<AyahReviewState> states;
  _FakeRevisionLocalDataSource(this.states);

  @override
  Future<void> addReviewDay(int dayNumber) async {}
  @override
  Set<int> getReviewDays() => {};
  @override
  List<AyahReviewState> getStates() => states;
  @override
  Future<void> saveStates(List<AyahReviewState> states) async {}
}

class _FakeAuthPrefUtils implements AuthPrefUtils {
  String? name;
  String? avatarPath;
  _FakeAuthPrefUtils(this.name);

  @override
  void clear() {}
  @override
  String? getAvatarPath() => avatarPath;
  @override
  void setAvatarPath(String? path) => avatarPath = path;
  @override
  String? getToken() => 'token';
  @override
  String? getUserName() => name;
  @override
  void setRefreshToken(String token) {}
  @override
  void setToken(String token) {}
  @override
  void setUserName(String value) => name = value;
}

ProgressRepositoryImpl _repository({
  MemorizedAyahs memorized = MemorizedAyahs.empty,
  List<AyahReviewState> states = const [],
  int streak = 0,
  String? name,
}) {
  return ProgressRepositoryImpl(
    quranRepository: _FakeQuranRepository(),
    onboardingRepository: _FakeOnboardingRepository(
      OnboardingProfile(
        level: MemorizationLevel.intermediate,
        memorized: memorized,
        completed: true,
      ),
    ),
    revisionRepository: _FakeRevisionRepository(
      RevisionHistory(currentStreak: streak),
    ),
    revisionLocalDataSource: _FakeRevisionLocalDataSource(states),
    authPrefUtils: _FakeAuthPrefUtils(name),
  );
}

/// Whole-surah selections, the shape a migrated profile has.
MemorizedAyahs _whole(List<int> surahs) =>
    MemorizedAyahs.wholeSurahs(surahs, const {1: 5, 2: 4});

void main() {
  group('juz progress', () {
    test('counts only the ayahs the juz actually spans', () async {
      // Nothing memorized: the denominator is still surah 1 ayahs 3-5 (3) plus
      // surah 2 ayahs 1-4 (4) = 7.
      final progress = await _repository().getUserProgress();

      expect(progress.juz, hasLength(1));
      expect(progress.juz.single.totalAyahs, 7);
      expect(progress.juz.single.memorizedAyahs, 0);
      expect(progress.juz.single.percent, 0);
      expect(progress.juz.single.isStarted, isFalse);
    });

    test('clips a memorized surah to the juz boundary', () async {
      // Surah 1 is memorized but the juz only contains 3 of its 5 ayahs.
      final progress = await _repository(
        memorized: _whole(const [1]),
      ).getUserProgress();

      expect(progress.juz.single.memorizedAyahs, 3);
      expect(progress.juz.single.percent, 43); // 3/7
      expect(progress.juz.single.isComplete, isFalse);
    });

    test('counts only the memorized ayahs of a part-done surah', () async {
      // Surah 1 ayahs 1-4 memorized, but the juz only starts at ayah 3 —
      // so just ayahs 3 and 4 land inside it.
      final progress = await _repository(
        memorized: MemorizedAyahs.of(const [
          AyahRange(surah: 1, start: 1, end: 4),
        ]),
      ).getUserProgress();

      expect(progress.juz.single.memorizedAyahs, 2);
      expect(progress.memorizedSurahs, 0); // surah 1 has 5 ayahs, not 4
      expect(progress.memorizedAyahs, 4);
    });

    test('is complete once every surah it spans is memorized', () async {
      final progress = await _repository(
        memorized: _whole(const [1, 2]),
      ).getUserProgress();

      expect(progress.juz.single.memorizedAyahs, 7);
      expect(progress.juz.single.percent, 100);
      expect(progress.juz.single.isComplete, isTrue);
      expect(progress.currentJuz, isNull); // nothing left unfinished
    });
  });

  group('headline figures', () {
    test('explored counts reviewed ayahs, xp is 10 per review', () async {
      final progress = await _repository(
        states: const [
          AyahReviewState(surahNumber: 1, ayahNumber: 1, reviewCount: 3),
          AyahReviewState(surahNumber: 1, ayahNumber: 2, reviewCount: 1),
          AyahReviewState(surahNumber: 1, ayahNumber: 3), // never reviewed
        ],
        streak: 5,
        memorized: _whole(const [1]),
      ).getUserProgress();

      expect(progress.trackedAyahs, 3);
      expect(progress.exploredAyahs, 2);
      expect(progress.exploredRatio, closeTo(2 / 3, 0.001));
      expect(progress.xp, 40);
      expect(progress.currentStreak, 5);
      expect(progress.memorizedSurahs, 1);
      expect(progress.level, MemorizationLevel.intermediate);
    });

    test('ratios stay at zero rather than dividing by zero', () async {
      final progress = await _repository().getUserProgress();

      expect(progress.trackedAyahs, 0);
      expect(progress.exploredRatio, 0);
      expect(progress.xp, 0);
    });

    test('carries the registered name through, empty when unknown', () async {
      expect(
        (await _repository(name: 'سارة يوسف').getUserProgress()).name,
        'سارة يوسف',
      );
      expect((await _repository().getUserProgress()).name, '');
    });
  });

  group('avatar initials', () {
    test('takes the first letter of the first two words', () {
      expect(const UserProgress(name: 'سارة يوسف').initials, 'س ي');
      expect(const UserProgress(name: 'سارة').initials, 'س');
      expect(const UserProgress(name: '  أحمد   بن  علي ').initials, 'أ ب');
    });

    test('is empty when no name was captured', () {
      expect(const UserProgress().initials, '');
      expect(const UserProgress(name: '   ').initials, '');
    });
  });
}
