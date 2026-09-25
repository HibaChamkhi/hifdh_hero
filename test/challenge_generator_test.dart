import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/domain/challenges/models/challenge_type.dart';
import 'package:hifdh_hero/domain/challenges/services/question_generator.dart';
import 'package:hifdh_hero/domain/quran/models/ayah.dart';
import 'package:hifdh_hero/domain/quran/models/juz.dart';
import 'package:hifdh_hero/domain/quran/models/revelation_type.dart';
import 'package:hifdh_hero/domain/quran/models/surah.dart';

Surah _surah() => const Surah(
  number: 112,
  name: 'الإخلاص',
  englishName: 'Al-Ikhlas',
  revelationType: RevelationType.meccan,
  ayahCount: 4,
  startJuz: 30,
  ayahs: [
    Ayah(number: 1, text: 'قل هو الله احد'),
    Ayah(number: 2, text: 'الله الصمد'),
    Ayah(number: 3, text: 'لم يلد ولم يولد'),
    Ayah(number: 4, text: 'ولم يكن له كفوا احد'),
  ],
);

List<Surah> _metas() => const [
  Surah(
    number: 112,
    name: 'الإخلاص',
    englishName: 'Al-Ikhlas',
    revelationType: RevelationType.meccan,
    ayahCount: 4,
  ),
  Surah(
    number: 113,
    name: 'الفلق',
    englishName: 'Al-Falaq',
    revelationType: RevelationType.meccan,
    ayahCount: 5,
  ),
  Surah(
    number: 114,
    name: 'الناس',
    englishName: 'An-Nas',
    revelationType: RevelationType.meccan,
    ayahCount: 6,
  ),
  Surah(
    number: 67,
    name: 'الملك',
    englishName: 'Al-Mulk',
    revelationType: RevelationType.meccan,
    ayahCount: 30,
  ),
];

List<Juz> _juz() => const [
  Juz(
    number: 29,
    name: 'تبارك',
    startSurah: 67,
    startAyah: 1,
    endSurah: 77,
    endAyah: 50,
  ),
  Juz(
    number: 30,
    name: 'عمّ',
    startSurah: 78,
    startAyah: 1,
    endSurah: 114,
    endAyah: 6,
  ),
];

void main() {
  final gen = QuestionGenerator(Random(42)); // seeded → deterministic

  for (final type in ChallengeType.values) {
    group('generate ${type.name}', () {
      final questions = gen.generate(
        type: type,
        surah: _surah(),
        allSurahs: _metas(),
        juzList: _juz(),
        count: 5,
      );

      test('produces the requested number of questions', () {
        expect(questions.length, 5);
      });

      test('every question is internally valid', () {
        for (final q in questions) {
          expect(q.options, isNotEmpty);
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
          expect(q.options.contains(q.correctAnswer), isTrue);
          expect(q.prompt.trim(), isNotEmpty);
        }
      });

      test('every question names the ayah it tests', () {
        // Answering records a review against these, so they have to be real.
        for (final q in questions) {
          expect(q.surahNumber, 112);
          expect(q.ayahNumber, inInclusiveRange(1, 4));
          expect(q.reference, contains('آية ${q.ayahNumber}'));
        }
      });
    });
  }

  test('guess-juz picks the juz that actually contains the ayah', () {
    final qs = gen.generate(
      type: ChallengeType.guessJuz,
      surah: _surah(), // surah 112 → all ayahs are in juz 30
      allSurahs: _metas(),
      juzList: _juz(),
      count: 3,
    );
    for (final q in qs) {
      expect(q.correctAnswer, 'الجزء 30');
    }
  });

  test('complete-ayah is reviewed against the answer ayah, not the prompt', () {
    // The prompt shows ayah N and asks for N+1, so the ayah being tested — and
    // therefore reviewed — is N+1.
    final qs = gen.generate(
      type: ChallengeType.completeAyah,
      surah: _surah(),
      allSurahs: _metas(),
      juzList: _juz(),
      count: 3,
    );
    for (final q in qs) {
      expect(q.promptSubtitle, contains('آية ${q.ayahNumber - 1}'));
      expect(q.reference, contains('آية ${q.ayahNumber}'));
    }
  });

  test('complete-ayah answer is the true next ayah', () {
    final qs = gen.generate(
      type: ChallengeType.completeAyah,
      surah: _surah(),
      allSurahs: _metas(),
      juzList: _juz(),
      count: 3,
    );
    const ayahTexts = [
      'قل هو الله احد',
      'الله الصمد',
      'لم يلد ولم يولد',
      'ولم يكن له كفوا احد',
    ];
    for (final q in qs) {
      final promptIdx = ayahTexts.indexOf(q.prompt);
      expect(promptIdx, isNonNegative);
      expect(q.correctAnswer, ayahTexts[promptIdx + 1]);
    }
  });
}
