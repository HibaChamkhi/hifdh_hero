/// Whole-day helpers used by the spaced-repetition scheduler.
/// A "day number" is the count of days since the Unix epoch (UTC), so
/// arithmetic on it is timezone-stable and easy to persist as an int.
class Day {
  Day._();

  static const int _msPerDay = 86400000;

  static int fromDateTime(DateTime dt) =>
      (dt.toUtc().millisecondsSinceEpoch / _msPerDay).floor();

  static int today() => fromDateTime(DateTime.now());

  static DateTime toDateTime(int dayNumber) =>
      DateTime.fromMillisecondsSinceEpoch(dayNumber * _msPerDay, isUtc: true);

  /// "اليوم" / "أمس" / "قبل N يومًا"
  static String agoLabel(int dayNumber, int today) {
    final diff = today - dayNumber;
    if (diff <= 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    if (diff == 2) return 'قبل يومين';
    if (diff <= 10) return 'قبل $diff أيام';
    return 'قبل $diff يومًا';
  }
}
