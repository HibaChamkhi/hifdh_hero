import 'package:equatable/equatable.dart';

/// An inclusive run of ayahs inside one surah, e.g. Al-Baqarah 1–20.
class AyahRange extends Equatable implements Comparable<AyahRange> {
  final int surah;
  final int start;
  final int end;

  const AyahRange({
    required this.surah,
    required this.start,
    required this.end,
  });

  /// A single ayah.
  const AyahRange.single(this.surah, int ayah) : start = ayah, end = ayah;

  int get length => end - start + 1;

  bool contains(int ayah) => ayah >= start && ayah <= end;

  /// True when the two runs overlap or sit back-to-back (1–5 and 6–9), which
  /// is when they should be stored as one range.
  bool touches(AyahRange other) =>
      other.surah == surah && other.start <= end + 1 && start <= other.end + 1;

  AyahRange merge(AyahRange other) => AyahRange(
    surah: surah,
    start: start < other.start ? start : other.start,
    end: end > other.end ? end : other.end,
  );

  /// How many ayahs of this range fall inside [from]–[to] (inclusive).
  int overlapWith(int from, int to) {
    final lo = start > from ? start : from;
    final hi = end < to ? end : to;
    return hi >= lo ? hi - lo + 1 : 0;
  }

  /// Sorted by surah, then by position — the order ranges are stored in.
  @override
  int compareTo(AyahRange other) => surah != other.surah
      ? surah.compareTo(other.surah)
      : start.compareTo(other.start);

  Map<String, dynamic> toJson() => {'s': surah, 'a': start, 'b': end};

  factory AyahRange.fromJson(Map<String, dynamic> j) =>
      AyahRange(surah: j['s'] as int, start: j['a'] as int, end: j['b'] as int);

  @override
  List<Object?> get props => [surah, start, end];
}
