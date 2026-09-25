import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/data/memorization/repositories/memorization_migration.dart';
import 'package:hifdh_hero/data/onboarding/data_sources/local/onboarding_local_data_source.dart';
import 'package:hifdh_hero/domain/memorization/models/ayah_range.dart';
import 'package:hifdh_hero/domain/memorization/models/memorized_ayahs.dart';
import 'package:hifdh_hero/domain/onboarding/models/memorization_level.dart';
import 'package:hifdh_hero/domain/onboarding/models/onboarding_profile.dart';
import 'package:hifdh_hero/domain/quran/models/ayah.dart';
import 'package:hifdh_hero/domain/quran/models/ayah_search_result.dart';
import 'package:hifdh_hero/domain/quran/models/juz.dart';
import 'package:hifdh_hero/domain/quran/models/revelation_type.dart';
import 'package:hifdh_hero/domain/quran/models/surah.dart';
import 'package:hifdh_hero/domain/quran/repositories/quran_repository.dart';

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

/// Stands in for shared preferences, tracking what the migration writes.
class _FakeLocalDataSource implements OnboardingLocalDataSource {
  OnboardingProfile profile;
  List<int> legacy;
  int saves = 0;
  bool legacyCleared = false;

  _FakeLocalDataSource({required this.profile, required this.legacy});

  @override
  OnboardingProfile getProfile() => profile;
  @override
  Future<void> saveProfile(OnboardingProfile p) async {
    profile = p;
    saves++;
  }

  @override
  bool isComplete() => profile.completed;
  @override
  Future<void> setComplete(bool value) async {}
  @override
  List<int> legacySurahNumbers() => legacy;
  @override
  Future<void> clearLegacySurahNumbers() async {
    legacy = [];
    legacyCleared = true;
  }
}

MemorizationMigration _migration(_FakeLocalDataSource source) =>
    MemorizationMigration(
      localDataSource: source,
      quranRepository: _FakeQuranRepository(),
    );

void main() {
  test('a pre-ayah profile keeps every surah it had, as full ranges', () async {
    final source = _FakeLocalDataSource(
      profile: const OnboardingProfile(
        level: MemorizationLevel.intermediate,
        completed: true,
      ),
      legacy: const [1, 112],
    );

    await _migration(source).run();

    expect(source.profile.memorized.countIn(1), 7);
    expect(source.profile.memorized.countIn(112), 4);
    expect(source.profile.memorized.isWholeSurah(1, 7), isTrue);
    // Level and completion must survive, or the user gets sent back through
    // onboarding on the next launch.
    expect(source.profile.level, MemorizationLevel.intermediate);
    expect(source.profile.completed, isTrue);
    expect(source.legacyCleared, isTrue);
  });

  test('runs once — a second pass writes nothing', () async {
    final source = _FakeLocalDataSource(
      profile: const OnboardingProfile(),
      legacy: const [1],
    );

    await _migration(source).run();
    final savesAfterFirst = source.saves;
    await _migration(source).run();

    expect(source.saves, savesAfterFirst);
  });

  test('a fresh install with no legacy data is untouched', () async {
    final source = _FakeLocalDataSource(
      profile: const OnboardingProfile(),
      legacy: const [],
    );

    await _migration(source).run();

    expect(source.saves, 0);
    expect(source.profile.memorized.isEmpty, isTrue);
  });

  test(
    'ayah-level data already stored wins over the stale legacy key',
    () async {
      // Half-migrated state: ranges written, old key not yet cleared. The
      // partial range must not be overwritten with a whole surah.
      final source = _FakeLocalDataSource(
        profile: OnboardingProfile(
          memorized: MemorizedAyahs.of(const [
            AyahRange(surah: 1, start: 1, end: 3),
          ]),
        ),
        legacy: const [1],
      );

      await _migration(source).run();

      expect(source.profile.memorized.countIn(1), 3);
      expect(source.saves, 0);
      expect(source.legacyCleared, isTrue);
    },
  );
}
