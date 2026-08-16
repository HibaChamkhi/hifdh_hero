import '../models/challenge_question.dart';
import '../models/challenge_type.dart';

/// Produces a set of questions for a challenge on a given surah.
abstract class ChallengeRepository {
  Future<List<ChallengeQuestion>> generateChallenge({
    required ChallengeType type,
    required int surahNumber,
    int? count,
  });
}
