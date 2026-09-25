import 'package:equatable/equatable.dart';
import '../../../core/utils/initials.dart';
import '../../onboarding/models/memorization_level.dart';
import 'juz_progress.dart';

/// The aggregate the home (07), map (08) and profile (11) screens read from.
///
/// Every field is derived from data the app already holds — the onboarding
/// profile, the bundled Quran corpus and the spaced-repetition log — so none of
/// it is placeholder content.
class UserProgress extends Equatable {
  /// Empty when the account was created before names were stored, or when the
  /// user signed in rather than registered on this device.
  final String name;

  /// Absolute path to the user's chosen photo; null means the initials mark.
  final String? avatarPath;

  final MemorizationLevel level;

  /// Consecutive days with at least one review (screen 32's streak).
  final int currentStreak;

  /// Ayahs reviewed at least once.
  final int exploredAyahs;

  /// Ayahs currently tracked by the review schedule — the denominator behind
  /// the home screen's progress bar.
  final int trackedAyahs;

  /// Surahs memorized end to end.
  final int memorizedSurahs;

  /// Ayahs memorized in total, including partly-done surahs.
  final int memorizedAyahs;

  /// 10 points per completed review.
  final int xp;

  /// One entry per juz, ordered from جزء عمّ (30) down to الجزء الأول.
  final List<JuzProgress> juz;

  const UserProgress({
    this.name = '',
    this.avatarPath,
    this.level = MemorizationLevel.beginner,
    this.currentStreak = 0,
    this.exploredAyahs = 0,
    this.trackedAyahs = 0,
    this.memorizedSurahs = 0,
    this.memorizedAyahs = 0,
    this.xp = 0,
    this.juz = const [],
  });

  /// 0.0 – 1.0 share of tracked ayahs that have been reviewed.
  double get exploredRatio =>
      trackedAyahs <= 0 ? 0 : (exploredAyahs / trackedAyahs).clamp(0.0, 1.0);

  /// The juz the user is partway through, else the first unfinished one —
  /// what the map highlights as "current".
  JuzProgress? get currentJuz {
    for (final j in juz) {
      if (!j.isComplete) return j;
    }
    return null;
  }

  /// Up to two initials for the profile avatar, e.g. "سارة يوسف" -> "س ي".
  String get initials => initialsOf(name);

  @override
  List<Object?> get props => [
    name,
    avatarPath,
    level,
    currentStreak,
    exploredAyahs,
    trackedAyahs,
    memorizedSurahs,
    memorizedAyahs,
    xp,
    juz,
  ];
}
