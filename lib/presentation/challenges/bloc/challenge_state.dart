part of 'challenge_bloc.dart';

class ChallengeState extends Equatable {
  final UIStatus status;
  final String message;
  final List<ChallengeQuestion> questions;
  final List<int?> answers;
  final int index;
  final bool finished;
  final ChallengeResult? result;

  const ChallengeState({
    this.status = UIStatus.initial,
    this.message = '',
    this.questions = const [],
    this.answers = const [],
    this.index = 0,
    this.finished = false,
    this.result,
  });

  ChallengeQuestion? get current =>
      (index >= 0 && index < questions.length) ? questions[index] : null;

  int? get selectedIndex =>
      (index >= 0 && index < answers.length) ? answers[index] : null;

  bool get isLast => questions.isNotEmpty && index == questions.length - 1;

  int get total => questions.length;

  /// 1-based position for display, e.g. "4 / 10".
  int get position => index + 1;

  ChallengeState copyWith({
    UIStatus? status,
    String? message,
    List<ChallengeQuestion>? questions,
    List<int?>? answers,
    int? index,
    bool? finished,
    ChallengeResult? result,
  }) {
    return ChallengeState(
      status: status ?? this.status,
      message: message ?? this.message,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      index: index ?? this.index,
      finished: finished ?? this.finished,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props =>
      [status, message, questions, answers, index, finished, result];
}
