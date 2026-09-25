import 'package:injectable/injectable.dart';
import '../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../domain/progress/models/juz_progress.dart';
import '../../../domain/progress/models/user_progress.dart';
import '../../../domain/progress/repositories/progress_repository.dart';
import '../../../domain/quran/models/juz.dart';
import '../../../domain/quran/models/surah.dart';
import '../../../domain/quran/repositories/quran_repository.dart';
import '../../../domain/onboarding/repositories/onboarding_repository.dart';
import '../../../domain/revision/repositories/revision_repository.dart';
import '../../auth/data_sources/local/auth_prefutils.dart';
import '../../revision/data_sources/local/revision_local_data_source.dart';

/// Composes the existing stores rather than owning any of its own: the profile
/// comes from onboarding, juz boundaries from the bundled corpus, and the
/// streak/XP figures from the spaced-repetition log.
@Injectable(as: ProgressRepository)
class ProgressRepositoryImpl implements ProgressRepository {
  final QuranRepository quranRepository;
  final OnboardingRepository onboardingRepository;
  final RevisionRepository revisionRepository;
  final RevisionLocalDataSource revisionLocalDataSource;
  final AuthPrefUtils authPrefUtils;

  ProgressRepositoryImpl({
    required this.quranRepository,
    required this.onboardingRepository,
    required this.revisionRepository,
    required this.revisionLocalDataSource,
    required this.authPrefUtils,
  });

  /// 10 points per completed review — the same unit the challenge screens award.
  static const int xpPerReview = 10;

  @override
  Future<UserProgress> getUserProgress() async {
    final profile = onboardingRepository.getProfile();
    final memorized = profile.memorized;

    final juzList = await quranRepository.getJuzList();
    final surahs = await quranRepository.getSurahs();
    final byNumber = {for (final s in surahs) s.number: s};

    final juz = [for (final j in juzList) _progressFor(j, byNumber, memorized)]
      ..sort((a, b) => b.juz.number.compareTo(a.juz.number));

    final states = revisionLocalDataSource.getStates();
    final history = await revisionRepository.getHistory();

    return UserProgress(
      name: authPrefUtils.getUserName() ?? '',
      avatarPath: authPrefUtils.getAvatarPath(),
      level: profile.level,
      currentStreak: history.currentStreak,
      exploredAyahs: states.where((s) => s.reviewCount > 0).length,
      trackedAyahs: states.length,
      memorizedSurahs: _fullyMemorizedCount(byNumber, memorized),
      memorizedAyahs: memorized.totalAyahs,
      xp: states.fold<int>(0, (sum, s) => sum + s.reviewCount) * xpPerReview,
      juz: juz,
    );
  }

  /// Counts the ayahs a juz spans, and how many of them sit in a memorized
  /// surah. A juz can start and end mid-surah, so the first and last surahs
  /// are clipped to the juz boundaries.
  JuzProgress _progressFor(
    Juz juz,
    Map<int, Surah> byNumber,
    MemorizedAyahs memorized,
  ) {
    var total = 0;
    var done = 0;
    for (var n = juz.startSurah; n <= juz.endSurah; n++) {
      final surah = byNumber[n];
      if (surah == null) continue;
      final first = n == juz.startSurah ? juz.startAyah : 1;
      final last = n == juz.endSurah ? juz.endAyah : surah.ayahCount;
      final count = last - first + 1;
      if (count <= 0) continue;
      total += count;
      // Only the memorized ayahs inside this juz's slice of the surah.
      done += memorized.countInRange(n, first, last);
    }
    return JuzProgress(juz: juz, memorizedAyahs: done, totalAyahs: total);
  }

  /// Surahs memorized end to end — a part-done surah doesn't count towards the
  /// "N سورة" figure on the profile.
  int _fullyMemorizedCount(Map<int, Surah> byNumber, MemorizedAyahs memorized) {
    return memorized.startedSurahs
        .where((n) => memorized.isWholeSurah(n, byNumber[n]?.ayahCount ?? 0))
        .length;
  }
}
