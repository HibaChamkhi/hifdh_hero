part of 'revision_bloc.dart';

class RevisionState extends Equatable {
  final UIStatus status;
  final String message;
  final RevisionPlan plan;
  final List<RevisionItem> weak;
  final RevisionHistory history;

  const RevisionState({
    this.status = UIStatus.initial,
    this.message = '',
    this.plan = const RevisionPlan(),
    this.weak = const [],
    this.history = const RevisionHistory(),
  });

  RevisionState copyWith({
    UIStatus? status,
    String? message,
    RevisionPlan? plan,
    List<RevisionItem>? weak,
    RevisionHistory? history,
  }) {
    return RevisionState(
      status: status ?? this.status,
      message: message ?? this.message,
      plan: plan ?? this.plan,
      weak: weak ?? this.weak,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [status, message, plan, weak, history];
}
