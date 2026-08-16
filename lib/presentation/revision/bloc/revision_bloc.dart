import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/error_utils.dart';
import '../../../core/model/ui_state.dart';
import '../../../domain/revision/models/revision_history.dart';
import '../../../domain/revision/models/revision_item.dart';
import '../../../domain/revision/models/revision_plan.dart';
import '../../../domain/revision/repositories/revision_repository.dart';

part 'revision_event.dart';
part 'revision_state.dart';

/// Loads today's plan, weak ayahs, and history; records self-graded reviews.
@injectable
class RevisionBloc extends Bloc<RevisionEvent, RevisionState> {
  final RevisionRepository repository;

  RevisionBloc(this.repository) : super(const RevisionState()) {
    on<RevisionRequested>(_onRequested);
    on<ReviewGraded>(_onGraded);
  }

  Future<void> _load(Emitter<RevisionState> emit) async {
    final plan = await repository.getTodayPlan();
    final weak = await repository.getWeakAyahs();
    final history = await repository.getHistory();
    emit(state.copyWith(
      status: UIStatus.success,
      plan: plan,
      weak: weak,
      history: history,
    ));
  }

  Future<void> _onRequested(
    RevisionRequested event,
    Emitter<RevisionState> emit,
  ) async {
    emit(state.copyWith(status: UIStatus.loading));
    try {
      await _load(emit);
    } on Exception catch (e) {
      emit(state.copyWith(
          status: UIStatus.error, message: mapExceptionToMessage(e)));
    }
  }

  Future<void> _onGraded(
    ReviewGraded event,
    Emitter<RevisionState> emit,
  ) async {
    try {
      await repository.recordReview(
          event.surahNumber, event.ayahNumber, event.correct);
      await _load(emit); // refresh plan/weak/history
    } on Exception catch (e) {
      emit(state.copyWith(
          status: UIStatus.error, message: mapExceptionToMessage(e)));
    }
  }
}
