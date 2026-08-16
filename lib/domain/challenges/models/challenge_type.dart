/// The challenge games available on a surah (screen 14).
///
/// All four current types are multiple-choice so grading is uniform. Drag-order
/// (رتّب الآية) and free-text / voice types can be added later.
enum ChallengeType {
  completeAyah,
  findSurah,
  missingWord,
  guessJuz;

  /// Title shown on the challenge card / play header.
  String get arabicLabel {
    switch (this) {
      case ChallengeType.completeAyah:
        return 'أكمل الآية';
      case ChallengeType.findSurah:
        return 'أي سورة هذه؟';
      case ChallengeType.missingWord:
        return 'الكلمة الناقصة';
      case ChallengeType.guessJuz:
        return 'خمّن الجزء';
    }
  }

  /// Instruction shown above the prompt during play.
  String get instruction {
    switch (this) {
      case ChallengeType.completeAyah:
        return 'اختر الآية التالية';
      case ChallengeType.findSurah:
        return 'أي سورة هذه؟';
      case ChallengeType.missingWord:
        return 'اختر الكلمة الناقصة';
      case ChallengeType.guessJuz:
        return 'إلى أي جزء تنتمي هذه الآية؟';
    }
  }

  int get defaultCount {
    switch (this) {
      case ChallengeType.completeAyah:
        return 10;
      case ChallengeType.missingWord:
        return 8;
      case ChallengeType.findSurah:
        return 7;
      case ChallengeType.guessJuz:
        return 5;
    }
  }
}
