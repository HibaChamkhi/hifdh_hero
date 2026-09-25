import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/model/ui_state.dart';
import 'package:hifdh_hero/domain/challenges/models/challenge_question.dart';
import 'package:hifdh_hero/domain/challenges/models/challenge_type.dart';
import 'package:hifdh_hero/domain/challenges/repositories/challenge_repository.dart';
import 'package:hifdh_hero/domain/revision/models/revision_history.dart';
import 'package:hifdh_hero/domain/revision/models/revision_item.dart';
import 'package:hifdh_hero/domain/revision/models/revision_plan.dart';
import 'package:hifdh_hero/domain/revision/repositories/revision_repository.dart';
import 'package:hifdh_hero/presentation/challenges/bloc/challenge_bloc.dart';

ChallengeQuestion _question(int ayah) => ChallengeQuestion(
  type: ChallengeType.findSurah,
  prompt: 'نص الآية $ayah',
  options: const ['الملك', 'البقرة', 'النساء'],
  correctIndex: 0,
  reference: 'الملك · آية $ayah',
  surahNumber: 67,
  ayahNumber: ayah,
);

class _FakeChallengeRepository implements ChallengeRepository {
  @override
  Future<List<ChallengeQuestion>> generateChallenge({
    required ChallengeType type,
    required int surahNumber,
    int? count,
  }) async => [_question(1), _question(2)];
}

class _RecordingRevisionRepository implements RevisionRepository {
  final recorded = <(int, int, bool)>[];
  bool throwOnRecord = false;

  @override
  Future<void> recordReview(int surah, int ayah, bool correct) async {
    if (throwOnRecord) throw Exception('disk full');
    recorded.add((surah, ayah, correct));
  }

  @override
  Future<void> ensureSeeded() async {}
  @override
  Future<RevisionHistory> getHistory() async => const RevisionHistory();
  @override
  Future<RevisionPlan> getTodayPlan({int limit = 10}) async =>
      const RevisionPlan();
  @override
  Future<List<RevisionItem>> getWeakAyahs({int limit = 20}) async => [];
}

void main() {
  late _RecordingRevisionRepository revision;

  ChallengeBloc build() => ChallengeBloc(_FakeChallengeRepository(), revision);

  setUp(() => revision = _RecordingRevisionRepository());

  Future<ChallengeBloc> started() async {
    final bloc = build()
      ..add(
        const ChallengeStarted(type: ChallengeType.findSurah, surahNumber: 67),
      );
    await bloc.stream.firstWhere((s) => s.status == UIStatus.success);
    return bloc;
  }

  test('each answer is recorded as a review of that ayah', () async {
    final bloc = await started();

    bloc
      ..add(const OptionSelected(0)) // correct
      ..add(const AnswerSubmitted());
    await bloc.stream.firstWhere((s) => s.index == 1);

    bloc
      ..add(const OptionSelected(1)) // wrong
      ..add(const AnswerSubmitted());
    await bloc.stream.firstWhere((s) => s.finished);

    expect(revision.recorded, [(67, 1, true), (67, 2, false)]);
    await bloc.close();
  });

  test('nothing is recorded until an option is chosen', () async {
    final bloc = await started();

    bloc.add(const AnswerSubmitted());
    await Future<void>.delayed(Duration.zero);

    expect(revision.recorded, isEmpty);
    expect(bloc.state.index, 0); // still on the first question
    await bloc.close();
  });

  test('a failed write costs the review, not the run', () async {
    revision.throwOnRecord = true;
    final bloc = await started();

    bloc
      ..add(const OptionSelected(0))
      ..add(const AnswerSubmitted());
    await bloc.stream.firstWhere((s) => s.index == 1);

    // The user advanced despite the write failing.
    expect(bloc.state.index, 1);
    expect(revision.recorded, isEmpty);
    await bloc.close();
  });
}
