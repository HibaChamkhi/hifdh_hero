part of 'challenge_bloc.dart';

abstract class ChallengeEvent extends Equatable {
  const ChallengeEvent();

  @override
  List<Object?> get props => [];
}

class ChallengeStarted extends ChallengeEvent {
  final ChallengeType type;
  final int surahNumber;
  final int? count;

  const ChallengeStarted({
    required this.type,
    required this.surahNumber,
    this.count,
  });

  @override
  List<Object?> get props => [type, surahNumber, count];
}

class OptionSelected extends ChallengeEvent {
  final int optionIndex;
  const OptionSelected(this.optionIndex);

  @override
  List<Object?> get props => [optionIndex];
}

class AnswerSubmitted extends ChallengeEvent {
  const AnswerSubmitted();
}
