import 'package:equatable/equatable.dart';

/// Review calendar + streaks (screen 32 — "سجل المراجعة").
class RevisionHistory extends Equatable {
  /// Day numbers (days since epoch) on which the user reviewed.
  final Set<int> reviewedDays;
  final int currentStreak;
  final int longestStreak;
  final int daysThisMonth;

  const RevisionHistory({
    this.reviewedDays = const {},
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.daysThisMonth = 0,
  });

  bool reviewedOn(int dayNumber) => reviewedDays.contains(dayNumber);

  @override
  List<Object?> get props =>
      [reviewedDays, currentStreak, longestStreak, daysThisMonth];
}
