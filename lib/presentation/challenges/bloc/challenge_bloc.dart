import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/error_utils.dart';
import '../../../core/model/ui_state.dart';
import '../../../domain/challenges/models/challenge_question.dart';
import '../../../domain/challenges/models/challenge_result.dart';
import '../../../domain/challenges/models/challenge_type.dart';
import '../../../domain/challenges/repositories/challenge_repository.dart';
import '../../../domain/revision/repositories/revision_repository.dart';

part 'challenge_event.dart';
part 'challenge_state.dart';

/// Drives a challenge run: load questions → answer each → score → result.
///
/// Every answer is also recorded as a review, so playing a challenge advances
/// the same spaced-repetition schedule the التقدم tab reads. An ayah the user
/// has never reviewed is picked up by the schedule the first time a challenge
/// asks about it.
@injectable
class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  final ChallengeRepository repository;
  final RevisionRepository revisionRepository;
  DateTime? _startedAt;

  ChallengeBloc(this.repository, this.revisionRepository)
    : super(const ChallengeState()) {
    on<ChallengeStarted>(_onStarted);
    on<OptionSelected>(_onSelected);
    on<AnswerSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
    ChallengeStarted event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeState(status: UIStatus.loading));
    try {
      final questions = await repository.generateChallenge(
        type: event.type,
        surahNumber: event.surahNumber,
        count: event.count,
      );
      if (questions.isEmpty) {
        emit(
          const ChallengeState(
            status: UIStatus.error,
            message: 'تعذّر توليد أسئلة لهذه السورة',
          ),
        );
        return;
      }
      _startedAt = DateTime.now();
      emit(
        ChallengeState(
          status: UIStatus.success,
          questions: questions,
          answers: List<int?>.filled(questions.length, null),
        ),
      );
    } on Exception catch (e) {
      emit(
        ChallengeState(
          status: UIStatus.error,
          message: mapExceptionToMessage(e),
        ),
      );
    }
  }

  void _onSelected(OptionSelected event, Emitter<ChallengeState> emit) {
    if (state.index >= state.answers.length) return;
    final answers = List<int?>.from(state.answers);
    answers[state.index] = event.optionIndex;
    emit(state.copyWith(answers: answers));
  }

  Future<void> _onSubmitted(
    AnswerSubmitted event,
    Emitter<ChallengeState> emit,
  ) async {
    final selected = state.selectedIndex;
    if (selected == null) return; // an option must be chosen

    await _recordReview(state.current, selected);

    if (state.isLast) {
      emit(state.copyWith(finished: true, result: _score()));
    } else {
      emit(state.copyWith(index: state.index + 1));
    }
  }

  /// A failed write must not cost the user their answer, so this never throws
  /// — the run continues and the schedule simply misses one review.
  Future<void> _recordReview(ChallengeQuestion? question, int selected) async {
    if (question == null) return;
    try {
      await revisionRepository.recordReview(
        question.surahNumber,
        question.ayahNumber,
        question.isCorrect(selected),
      );
    } on Exception {
      // Intentionally ignored — see above.
    }
  }

  ChallengeResult _score() {
    var correct = 0;
    for (var i = 0; i < state.questions.length; i++) {
      if (state.questions[i].isCorrect(state.answers[i])) correct++;
    }
    final duration = _startedAt == null
        ? Duration.zero
        : DateTime.now().difference(_startedAt!);
    return ChallengeResult(
      total: state.questions.length,
      correct: correct,
      xp: correct * 15,
      duration: duration,
    );
  }
}
