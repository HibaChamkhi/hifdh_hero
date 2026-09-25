import 'package:equatable/equatable.dart';
import 'ayah_range.dart';

/// What the user has memorized, at ayah resolution.
///
/// Replaces the old "list of surah numbers", which forced Al-Baqarah to be
/// either 0% or 100%. Ranges are always kept normalized — sorted, non-empty,
/// and with touching runs merged — so equality and counting are cheap and two
/// equivalent selections are never stored differently.
class MemorizedAyahs extends Equatable {
  final List<AyahRange> ranges;

  const MemorizedAyahs._(this.ranges);

  static const MemorizedAyahs empty = MemorizedAyahs._([]);

  factory MemorizedAyahs.of(Iterable<AyahRange> ranges) =>
      MemorizedAyahs._(_normalize(ranges));

  /// Every ayah of each given surah — how a pre-ayah-tracking profile maps
  /// onto the new model.
  factory MemorizedAyahs.wholeSurahs(
    Iterable<int> surahs,
    Map<int, int> ayahCountBySurah,
  ) {
    return MemorizedAyahs.of([
      for (final s in surahs)
        if ((ayahCountBySurah[s] ?? 0) > 0)
          AyahRange(surah: s, start: 1, end: ayahCountBySurah[s]!),
    ]);
  }

  static List<AyahRange> _normalize(Iterable<AyahRange> input) {
    final valid =
        input
            .where((r) => r.surah > 0 && r.start >= 1 && r.end >= r.start)
            .toList()
          ..sort();
    final merged = <AyahRange>[];
    for (final r in valid) {
      if (merged.isNotEmpty && merged.last.touches(r)) {
        merged[merged.length - 1] = merged.last.merge(r);
      } else {
        merged.add(r);
      }
    }
    return List.unmodifiable(merged);
  }

  bool get isEmpty => ranges.isEmpty;

  bool contains(int surah, int ayah) =>
      ranges.any((r) => r.surah == surah && r.contains(ayah));

  /// Ayahs memorized in [surah].
  int countIn(int surah) =>
      ranges.where((r) => r.surah == surah).fold(0, (sum, r) => sum + r.length);

  /// Ayahs memorized in [surah] between [from] and [to] inclusive — the juz
  /// boundaries need this because a juz can start and end mid-surah.
  int countInRange(int surah, int from, int to) => ranges
      .where((r) => r.surah == surah)
      .fold(0, (sum, r) => sum + r.overlapWith(from, to));

  int get totalAyahs => ranges.fold(0, (sum, r) => sum + r.length);

  /// Surahs with at least one memorized ayah.
  Set<int> get startedSurahs => ranges.map((r) => r.surah).toSet();

  bool isWholeSurah(int surah, int ayahCount) =>
      ayahCount > 0 && countIn(surah) >= ayahCount;

  MemorizedAyahs add(AyahRange range) => MemorizedAyahs.of([...ranges, range]);

  /// Removes [range]'s ayahs, splitting any range it cuts through the middle.
  MemorizedAyahs remove(AyahRange range) {
    final kept = <AyahRange>[];
    for (final r in ranges) {
      if (r.surah != range.surah ||
          r.end < range.start ||
          r.start > range.end) {
        kept.add(r);
        continue;
      }
      if (r.start < range.start) {
        kept.add(
          AyahRange(surah: r.surah, start: r.start, end: range.start - 1),
        );
      }
      if (r.end > range.end) {
        kept.add(AyahRange(surah: r.surah, start: range.end + 1, end: r.end));
      }
    }
    return MemorizedAyahs.of(kept);
  }

  MemorizedAyahs toggleAyah(int surah, int ayah) => contains(surah, ayah)
      ? remove(AyahRange.single(surah, ayah))
      : add(AyahRange.single(surah, ayah));

  MemorizedAyahs setWholeSurah(int surah, int ayahCount, bool memorized) {
    final whole = AyahRange(surah: surah, start: 1, end: ayahCount);
    return memorized ? add(whole) : remove(whole);
  }

  List<Map<String, dynamic>> toJson() => ranges.map((r) => r.toJson()).toList();

  factory MemorizedAyahs.fromJson(List<dynamic> json) => MemorizedAyahs.of(
    json.map((e) => AyahRange.fromJson(e as Map<String, dynamic>)),
  );

  @override
  List<Object?> get props => [ranges];
}
