import 'package:equatable/equatable.dart';
import 'challenge_type.dart';

/// A single multiple-choice question.
class ChallengeQuestion extends Equatable {
  final ChallengeType type;

  /// Main text shown to the user (an ayah, an ayah-with-blank, a word...).
  final String prompt;

  /// Optional secondary line (e.g. the preceding ayah).
  final String? promptSubtitle;

  /// Answer choices.
  final List<String> options;

  /// Index into [options] of the correct answer.
  final int correctIndex;

  /// Human-readable source, e.g. "الملك · آية 2".
  final String reference;

  /// The ayah this question actually tests — for complete-the-ayah that is the
  /// answer, not the prompt. Answering it counts as a review of this ayah, so
  /// practice feeds the spaced-repetition schedule.
  final int surahNumber;
  final int ayahNumber;

  const ChallengeQuestion({
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.reference,
    required this.surahNumber,
    required this.ayahNumber,
    this.promptSubtitle,
  });

  String get correctAnswer => options[correctIndex];

  bool isCorrect(int? selectedIndex) => selectedIndex == correctIndex;

  @override
  List<Object?> get props => [
    type,
    prompt,
    promptSubtitle,
    options,
    correctIndex,
    reference,
    surahNumber,
    ayahNumber,
  ];
}
