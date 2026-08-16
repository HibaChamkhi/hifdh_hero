import 'package:injectable/injectable.dart';
import '../../../core/utils/day.dart';
import '../../../domain/onboarding/repositories/onboarding_repository.dart';
import '../../../domain/quran/repositories/quran_repository.dart';
import '../../../domain/revision/models/ayah_review_state.dart';
import '../../../domain/revision/models/revision_history.dart';
import '../../../domain/revision/models/revision_item.dart';
import '../../../domain/revision/models/revision_plan.dart';
import '../../../domain/revision/repositories/revision_repository.dart';
import '../../../domain/revision/services/spaced_repetition.dart';
import '../data_sources/local/revision_local_data_source.dart';

@Injectable(as: RevisionRepository)
class RevisionRepositoryImpl implements RevisionRepository {
  final RevisionLocalDataSource localDataSource;
  final QuranRepository quranRepository;
  final OnboardingRepository onboardingRepository;
  final SpacedRepetition scheduler;

  RevisionRepositoryImpl({
    required this.localDataSource,
    required this.quranRepository,
    required this.onboardingRepository,
  }) : scheduler = const SpacedRepetition();

  // If the user selected no surahs in onboarding, seed a small default set so
  // the revision screens are populated for demoing.
  static const _defaultSurahs = [1, 112, 113, 114];
  static const _maxAyahsPerSurah = 8;
  static const _maxSeeded = 40;

  @override
  Future<void> ensureSeeded() async {
    if (localDataSource.getStates().isNotEmpty) return;
    final today = Day.today();
    final memorized = onboardingRepository.getProfile().memorizedSurahs;
    final surahs = memorized.isNotEmpty ? memorized : _defaultSurahs;
    final meta = await quranRepository.getSurahs();
    final ayahCountOf = {for (final s in meta) s.number: s.ayahCount};

    final states = <AyahReviewState>[];
    var i = 0;
    for (final surah in surahs) {
      final count = ayahCountOf[surah] ?? 0;
      final take = count < _maxAyahsPerSurah ? count : _maxAyahsPerSurah;
      for (var ayah = 1; ayah <= take; ayah++) {
        if (states.length >= _maxSeeded) break;
        // Deterministic stagger so strengths/last-reviewed vary (no RNG).
        final box = i % 4; // 0..3
        final lastDay = today - (1 + (i * 7) % 20);
        states.add(scheduler.initial(
          surahNumber: surah,
          ayahNumber: ayah,
          today: today,
          box: box,
          lastReviewedDay: lastDay,
        ));
        i++;
      }
    }
    await localDataSource.saveStates(states);
  }

  Future<Map<int, String>> _surahNames() async {
    final meta = await quranRepository.getSurahs();
    return {for (final s in meta) s.number: s.name};
  }

  RevisionItem _enrich(AyahReviewState s, Map<int, String> names) =>
      RevisionItem(state: s, surahName: names[s.surahNumber] ?? '');

  @override
  Future<RevisionPlan> getTodayPlan({int limit = 10}) async {
    await ensureSeeded();
    final today = Day.today();
    final names = await _surahNames();
    final due = localDataSource.getStates().where((s) => s.isDue(today)).toList()
      ..sort((a, b) {
        final overdue = (today - b.dueDay).compareTo(today - a.dueDay);
        return overdue != 0 ? overdue : a.box.compareTo(b.box);
      });
    return RevisionPlan(
      items: due.take(limit).map((s) => _enrich(s, names)).toList(),
    );
  }

  @override
  Future<List<RevisionItem>> getWeakAyahs({int limit = 20}) async {
    await ensureSeeded();
    final today = Day.today();
    final names = await _surahNames();
    final weak =
        localDataSource.getStates().where((s) => s.isWeak(today)).toList()
          ..sort((a, b) {
            final byBox = a.box.compareTo(b.box);
            return byBox != 0 ? byBox : (today - b.dueDay).compareTo(today - a.dueDay);
          });
    return weak.take(limit).map((s) => _enrich(s, names)).toList();
  }

  @override
  Future<void> recordReview(
      int surahNumber, int ayahNumber, bool correct) async {
    final today = Day.today();
    final states = localDataSource.getStates();
    final idx = states
        .indexWhere((s) => s.surahNumber == surahNumber && s.ayahNumber == ayahNumber);
    final current = idx >= 0
        ? states[idx]
        : scheduler.initial(
            surahNumber: surahNumber, ayahNumber: ayahNumber, today: today);
    final updated = scheduler.review(current, correct, today);
    if (idx >= 0) {
      states[idx] = updated;
    } else {
      states.add(updated);
    }
    await localDataSource.saveStates(states);
    await localDataSource.addReviewDay(today);
  }

  @override
  Future<RevisionHistory> getHistory() async {
    final today = Day.today();
    final days = localDataSource.getReviewDays();

    // current streak: consecutive days ending today or yesterday
    var current = 0;
    var cursor = days.contains(today) ? today : today - 1;
    while (days.contains(cursor)) {
      current++;
      cursor--;
    }

    // longest streak across all recorded days
    var longest = 0;
    final sorted = days.toList()..sort();
    var run = 0;
    int? prev;
    for (final d in sorted) {
      run = (prev != null && d == prev + 1) ? run + 1 : 1;
      if (run > longest) longest = run;
      prev = d;
    }

    // days reviewed within the current calendar month
    final now = DateTime.now();
    final monthStart = Day.fromDateTime(DateTime.utc(now.year, now.month, 1));
    final daysThisMonth = days.where((d) => d >= monthStart && d <= today).length;

    return RevisionHistory(
      reviewedDays: days,
      currentStreak: current,
      longestStreak: longest,
      daysThisMonth: daysThisMonth,
    );
  }
}
