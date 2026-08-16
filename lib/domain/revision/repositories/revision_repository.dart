import '../models/revision_history.dart';
import '../models/revision_item.dart';
import '../models/revision_plan.dart';

/// Spaced-repetition review tracking (T084–T092).
abstract class RevisionRepository {
  /// Creates initial review states from the user's memorized surahs if none
  /// exist yet (idempotent). Call on first entry to the revision area.
  Future<void> ensureSeeded();

  /// Ayahs due today, ranked most-overdue / weakest first.
  Future<RevisionPlan> getTodayPlan({int limit = 10});

  /// Weakest ayahs overall (screen 31), ranked ascending by strength.
  Future<List<RevisionItem>> getWeakAyahs({int limit = 20});

  /// Record a review outcome; updates the ayah's box/schedule and the day log.
  Future<void> recordReview(int surahNumber, int ayahNumber, bool correct);

  /// Review calendar + streaks (screen 32).
  Future<RevisionHistory> getHistory();
}
