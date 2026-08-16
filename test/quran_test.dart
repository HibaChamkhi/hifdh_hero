import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/utils/arabic_text.dart';
import 'package:hifdh_hero/domain/quran/models/juz.dart';
import 'package:hifdh_hero/domain/quran/models/revelation_type.dart';
import 'package:hifdh_hero/domain/quran/models/surah.dart';

void main() {
  group('ArabicText.normalize / contains', () {
    test('search is diacritic-insensitive', () {
      // "ٱلرَّحۡمَٰن" (Uthmani, with marks) should match plain "الرحمن".
      const uthmani = 'ٱلرَّحۡمَٰن';
      expect(ArabicText.contains(uthmani, 'الرحمن'), isTrue);
    });

    test('normalizes alef/hamza/ta-marbuta variants', () {
      expect(ArabicText.normalize('إِيَّاكَ'), 'اياك');
      expect(ArabicText.contains('سُورَة', 'سوره'), isTrue);
    });

    test('empty query matches anything', () {
      expect(ArabicText.contains('أي نص', ''), isTrue);
    });
  });

  group('Juz.contains', () {
    // Juz 30 (عمّ): 78:1 .. 114:6
    const juz30 = Juz(
      number: 30,
      name: 'عمّ',
      startSurah: 78,
      startAyah: 1,
      endSurah: 114,
      endAyah: 6,
    );

    test('includes ayahs within range', () {
      expect(juz30.contains(78, 1), isTrue);
      expect(juz30.contains(112, 3), isTrue);
      expect(juz30.contains(114, 6), isTrue);
    });

    test('excludes ayahs outside range', () {
      expect(juz30.contains(77, 50), isFalse);
      expect(juz30.contains(67, 1), isFalse);
    });
  });

  group('Surah.meta parsing', () {
    test('parses metadata json', () {
      final s = Surah.meta(const {
        'number': 67,
        'name': 'الملك',
        'englishName': 'Al-Mulk',
        'revelationType': 'meccan',
        'ayahCount': 30,
        'startJuz': 29,
      });
      expect(s.number, 67);
      expect(s.name, 'الملك');
      expect(s.revelationType, RevelationType.meccan);
      expect(s.revelationType.arabicLabel, 'مكية');
      expect(s.ayahCount, 30);
      expect(s.startJuz, 29);
      expect(s.hasAyahs, isFalse);
    });
  });
}
