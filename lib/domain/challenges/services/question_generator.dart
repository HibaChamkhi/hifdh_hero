import 'dart:math';
import '../../quran/models/juz.dart';
import '../../quran/models/surah.dart';
import '../models/challenge_question.dart';
import '../models/challenge_type.dart';

/// Pure domain service that turns Quran data into multiple-choice questions.
/// Deterministic when constructed with a seeded [Random] (used in tests).
class QuestionGenerator {
  final Random _random;

  QuestionGenerator([Random? random]) : _random = random ?? Random();

  List<ChallengeQuestion> generate({
    required ChallengeType type,
    required Surah surah,
    required List<Surah> allSurahs,
    required List<Juz> juzList,
    int? count,
  }) {
    final n = count ?? type.defaultCount;
    switch (type) {
      case ChallengeType.findSurah:
        return _findSurah(surah, allSurahs, n);
      case ChallengeType.missingWord:
        return _missingWord(surah, n);
      case ChallengeType.guessJuz:
        return _guessJuz(surah, juzList, n);
      case ChallengeType.completeAyah:
        return _completeAyah(surah, n);
    }
  }

  // ---- helpers ----

  /// Builds a shuffled option list from [correct] + [distractors] and returns
  /// the options and the index of the correct answer.
  (List<String>, int) _mcq(String correct, List<String> distractors) {
    final opts = <String>{correct, ...distractors}.toList();
    opts.shuffle(_random);
    return (opts, opts.indexOf(correct));
  }

  List<T> _pick<T>(List<T> pool, int k, bool Function(T) allow) {
    final candidates = pool.where(allow).toList()..shuffle(_random);
    return candidates.take(k).toList();
  }

  List<String> _words(String ayah) =>
      ayah.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).toList();

  // ---- generators ----

  List<ChallengeQuestion> _findSurah(
      Surah surah, List<Surah> allSurahs, int count) {
    if (surah.ayahs.isEmpty) return const [];
    final questions = <ChallengeQuestion>[];
    final otherNames =
        allSurahs.where((s) => s.number != surah.number).map((s) => s.name).toList();
    for (var i = 0; i < count; i++) {
      final ayah = surah.ayahs[_random.nextInt(surah.ayahs.length)];
      final distractors = (otherNames.toList()..shuffle(_random)).take(2).toList();
      final (options, correctIndex) = _mcq(surah.name, distractors);
      questions.add(ChallengeQuestion(
        type: ChallengeType.findSurah,
        prompt: ayah.text,
        options: options,
        correctIndex: correctIndex,
        reference: '${surah.name} · آية ${ayah.number}',
      ));
    }
    return questions;
  }

  List<ChallengeQuestion> _missingWord(Surah surah, int count) {
    final usable =
        surah.ayahs.where((a) => _words(a.text).length >= 3).toList();
    if (usable.isEmpty) return const [];
    final allWords = surah.ayahs.expand((a) => _words(a.text)).toSet().toList();
    final questions = <ChallengeQuestion>[];
    for (var i = 0; i < count; i++) {
      final ayah = usable[_random.nextInt(usable.length)];
      final words = _words(ayah.text);
      final blankIndex = 1 + _random.nextInt(words.length - 1); // never the first
      final answer = words[blankIndex];
      final shown = List<String>.from(words)..[blankIndex] = '____';
      final distractors =
          _pick(allWords, 2, (w) => w != answer);
      final (options, correctIndex) = _mcq(answer, distractors);
      questions.add(ChallengeQuestion(
        type: ChallengeType.missingWord,
        prompt: shown.join(' '),
        options: options,
        correctIndex: correctIndex,
        reference: '${surah.name} · آية ${ayah.number}',
      ));
    }
    return questions;
  }

  List<ChallengeQuestion> _guessJuz(
      Surah surah, List<Juz> juzList, int count) {
    if (surah.ayahs.isEmpty || juzList.isEmpty) return const [];
    final questions = <ChallengeQuestion>[];
    for (var i = 0; i < count; i++) {
      final ayah = surah.ayahs[_random.nextInt(surah.ayahs.length)];
      final juz = juzList.firstWhere(
        (j) => j.contains(surah.number, ayah.number),
        orElse: () => juzList.last,
      );
      final correct = 'الجزء ${juz.number}';
      final distractors = <String>{};
      var delta = 1;
      while (distractors.length < 2 && delta < 30) {
        for (final d in [juz.number - delta, juz.number + delta]) {
          if (d >= 1 && d <= 30 && d != juz.number) {
            distractors.add('الجزء $d');
          }
          if (distractors.length >= 2) break;
        }
        delta++;
      }
      final (options, correctIndex) = _mcq(correct, distractors.toList());
      questions.add(ChallengeQuestion(
        type: ChallengeType.guessJuz,
        prompt: ayah.text,
        options: options,
        correctIndex: correctIndex,
        reference: '${surah.name} · آية ${ayah.number}',
      ));
    }
    return questions;
  }

  List<ChallengeQuestion> _completeAyah(Surah surah, int count) {
    if (surah.ayahs.length < 2) return const [];
    final questions = <ChallengeQuestion>[];
    for (var i = 0; i < count; i++) {
      final idx = _random.nextInt(surah.ayahs.length - 1); // not the last
      final current = surah.ayahs[idx];
      final next = surah.ayahs[idx + 1];
      final distractors = _pick(
        surah.ayahs,
        2,
        (a) => a.number != next.number && a.number != current.number,
      ).map((a) => a.text).toList();
      final (options, correctIndex) = _mcq(next.text, distractors);
      questions.add(ChallengeQuestion(
        type: ChallengeType.completeAyah,
        prompt: current.text,
        promptSubtitle: '${surah.name} · آية ${current.number}',
        options: options,
        correctIndex: correctIndex,
        reference: '${surah.name} · آية ${next.number}',
      ));
    }
    return questions;
  }
}
