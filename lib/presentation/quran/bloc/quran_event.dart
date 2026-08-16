part of 'quran_bloc.dart';

abstract class QuranEvent extends Equatable {
  const QuranEvent();

  @override
  List<Object?> get props => [];
}

class SurahsRequested extends QuranEvent {
  const SurahsRequested();
}

class SurahSearchChanged extends QuranEvent {
  final String query;
  const SurahSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
