import '../models/ayah_review_state.dart';

/// A small Leitner-style spaced-repetition scheduler. Pure and deterministic
/// (all "now" values are passed in as day numbers) so it is fully unit-testable.
class SpacedRepetition {
  const SpacedRepetition();

  /// Interval in days for each box level. box 0 → due same/next day.
  static const List<int> intervals = [0, 1, 3, 7, 16, 35];

  /// A fresh state for a newly-tracked ayah (due immediately).
  AyahReviewState initial({
    required int surahNumber,
    required int ayahNumber,
    required int today,
    int box = 0,
    int lastReviewedDay = -1,
  }) {
    final safeBox = box.clamp(0, AyahReviewState.maxBox);
    return AyahReviewState(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      box: safeBox,
      lastReviewedDay: lastReviewedDay,
      dueDay:
          (lastReviewedDay < 0 ? today : lastReviewedDay) + intervals[safeBox],
    );
  }

  /// Apply a review outcome. Correct → promote a box; incorrect → demote and
  /// count a lapse. Returns the updated state.
  AyahReviewState review(AyahReviewState s, bool correct, int today) {
    final newBox = correct
        ? (s.box + 1).clamp(0, AyahReviewState.maxBox)
        : (s.box - 1).clamp(0, AyahReviewState.maxBox);
    return s.copyWith(
      box: newBox,
      lastReviewedDay: today,
      dueDay: today + intervals[newBox],
      reviewCount: s.reviewCount + 1,
      lapses: s.lapses + (correct ? 0 : 1),
    );
  }
}
