part of 'revision_bloc.dart';

abstract class RevisionEvent extends Equatable {
  const RevisionEvent();

  @override
  List<Object?> get props => [];
}

class RevisionRequested extends RevisionEvent {
  const RevisionRequested();
}

class ReviewGraded extends RevisionEvent {
  final int surahNumber;
  final int ayahNumber;
  final bool correct;

  const ReviewGraded({
    required this.surahNumber,
    required this.ayahNumber,
    required this.correct,
  });

  @override
  List<Object?> get props => [surahNumber, ayahNumber, correct];
}
