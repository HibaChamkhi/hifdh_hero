part of 'progress_bloc.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class ProgressRequested extends ProgressEvent {
  const ProgressRequested();
}
