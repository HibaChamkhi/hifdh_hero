import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/domain/memorization/models/ayah_range.dart';
import 'package:hifdh_hero/domain/memorization/models/memorized_ayahs.dart';

void main() {
  group('normalization', () {
    test('merges overlapping and back-to-back runs', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 5),
        AyahRange(surah: 2, start: 4, end: 8), // overlaps
        AyahRange(surah: 2, start: 9, end: 12), // adjacent
      ]);

      expect(m.ranges, [const AyahRange(surah: 2, start: 1, end: 12)]);
      expect(m.countIn(2), 12);
    });

    test('keeps a real gap as two runs', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 5),
        AyahRange(surah: 2, start: 8, end: 10),
      ]);

      expect(m.ranges, hasLength(2));
      expect(m.countIn(2), 8);
      expect(m.contains(2, 6), isFalse);
    });

    test('does not merge across surahs', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 1, start: 1, end: 7),
        AyahRange(surah: 2, start: 1, end: 3),
      ]);

      expect(m.ranges, hasLength(2));
      expect(m.startedSurahs, {1, 2});
    });

    test('drops nonsense ranges instead of storing them', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 5, end: 1), // end before start
        AyahRange(surah: 0, start: 1, end: 3), // no such surah
        AyahRange(surah: 2, start: 0, end: 3), // ayahs are 1-based
      ]);

      expect(m.isEmpty, isTrue);
    });

    test('equal selections built differently compare equal', () {
      final a = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 4),
      ]);
      final b = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 3, end: 4),
        AyahRange(surah: 2, start: 1, end: 2),
      ]);

      expect(a, b);
    });
  });

  group('removal', () {
    test('splits a range cut through the middle', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 10),
      ]).remove(const AyahRange(surah: 2, start: 4, end: 6));

      expect(m.ranges, const [
        AyahRange(surah: 2, start: 1, end: 3),
        AyahRange(surah: 2, start: 7, end: 10),
      ]);
      expect(m.countIn(2), 7);
    });

    test('trims an edge without splitting', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 10),
      ]).remove(const AyahRange(surah: 2, start: 1, end: 3));

      expect(m.ranges, const [AyahRange(surah: 2, start: 4, end: 10)]);
    });

    test('leaves other surahs untouched', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 1, start: 1, end: 7),
        AyahRange(surah: 2, start: 1, end: 5),
      ]).remove(const AyahRange(surah: 2, start: 1, end: 5));

      expect(m.startedSurahs, {1});
    });
  });

  group('toggling', () {
    test('a single ayah goes in and back out', () {
      var m = MemorizedAyahs.empty.toggleAyah(112, 2);
      expect(m.contains(112, 2), isTrue);
      expect(m.totalAyahs, 1);

      m = m.toggleAyah(112, 2);
      expect(m.isEmpty, isTrue);
    });

    test('un-toggling the middle of a run splits it', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 5),
      ]).toggleAyah(2, 3);

      expect(m.contains(2, 3), isFalse);
      expect(m.countIn(2), 4);
      expect(m.ranges, hasLength(2));
    });

    test('a whole surah goes in and back out', () {
      var m = MemorizedAyahs.empty.setWholeSurah(112, 4, true);
      expect(m.isWholeSurah(112, 4), isTrue);
      expect(m.countIn(112), 4);

      m = m.setWholeSurah(112, 4, false);
      expect(m.isEmpty, isTrue);
    });

    test('a partly-memorized surah is not a whole one', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 20),
      ]);

      expect(m.isWholeSurah(2, 286), isFalse);
      expect(m.startedSurahs, contains(2));
    });
  });

  group('counting within bounds', () {
    // Juz boundaries cut through surahs, so the count has to be clipped.
    final m = MemorizedAyahs.of(const [
      AyahRange(surah: 2, start: 1, end: 10),
      AyahRange(surah: 2, start: 20, end: 30),
    ]);

    test('clips to the window', () {
      expect(m.countInRange(2, 5, 25), 6 + 6); // 5-10 and 20-25
    });

    test('is zero outside the window and for other surahs', () {
      expect(m.countInRange(2, 11, 19), 0);
      expect(m.countInRange(3, 1, 100), 0);
    });
  });

  group('migration and storage', () {
    test('whole surahs build full-length ranges', () {
      final m = MemorizedAyahs.wholeSurahs(
        const [1, 112],
        const {1: 7, 112: 4},
      );

      expect(m.countIn(1), 7);
      expect(m.countIn(112), 4);
      expect(m.isWholeSurah(1, 7), isTrue);
    });

    test(
      'a surah with no known ayah count is skipped, not stored as empty',
      () {
        final m = MemorizedAyahs.wholeSurahs(const [1, 999], const {1: 7});

        expect(m.startedSurahs, {1});
      },
    );

    test('survives a JSON round trip', () {
      final m = MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 10),
        AyahRange(surah: 112, start: 1, end: 4),
      ]);

      expect(MemorizedAyahs.fromJson(m.toJson()), m);
    });
  });
}
