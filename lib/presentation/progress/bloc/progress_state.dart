part of 'progress_bloc.dart';

class ProgressState extends Equatable {
  final UIStatus status;
  final String message;
  final UserProgress progress;

  const ProgressState({
    this.status = UIStatus.initial,
    this.message = '',
    this.progress = const UserProgress(),
  });

  ProgressState copyWith({
    UIStatus? status,
    String? message,
    UserProgress? progress,
  }) {
    return ProgressState(
      status: status ?? this.status,
      message: message ?? this.message,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [status, message, progress];
}
