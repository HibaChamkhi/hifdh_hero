import 'package:injectable/injectable.dart';
import '../../../domain/challenges/models/challenge_question.dart';
import '../../../domain/challenges/models/challenge_type.dart';
import '../../../domain/challenges/repositories/challenge_repository.dart';
import '../../../domain/challenges/services/question_generator.dart';
import '../../../domain/quran/repositories/quran_repository.dart';

@Injectable(as: ChallengeRepository)
class ChallengeRepositoryImpl implements ChallengeRepository {
  final QuranRepository quranRepository;
  final QuestionGenerator _generator;

  ChallengeRepositoryImpl({required this.quranRepository})
      : _generator = QuestionGenerator();

  @override
  Future<List<ChallengeQuestion>> generateChallenge({
    required ChallengeType type,
    required int surahNumber,
    int? count,
  }) async {
    final surah = await quranRepository.getSurah(surahNumber);
    final allSurahs = await quranRepository.getSurahs();
    final juzList = await quranRepository.getJuzList();
    return _generator.generate(
      type: type,
      surah: surah,
      allSurahs: allSurahs,
      juzList: juzList,
      count: count,
    );
  }
}
