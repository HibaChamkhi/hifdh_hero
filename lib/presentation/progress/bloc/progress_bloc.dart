import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/error_utils.dart';
import '../../../core/model/ui_state.dart';
import '../../../domain/progress/models/user_progress.dart';
import '../../../domain/progress/repositories/progress_repository.dart';
import '../../../domain/revision/repositories/revision_repository.dart';

part 'progress_event.dart';
part 'progress_state.dart';

/// Feeds the home, hifz-map and profile tabs from one aggregate load.
@injectable
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository repository;
  final RevisionRepository revisionRepository;

  ProgressBloc(this.repository, this.revisionRepository)
    : super(const ProgressState()) {
    on<ProgressRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ProgressRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(status: UIStatus.loading));
    try {
      // Seeding is idempotent; it makes the review schedule exist on the very
      // first visit so the explored/XP figures aren't stuck at zero.
      await revisionRepository.ensureSeeded();
      final progress = await repository.getUserProgress();
      emit(state.copyWith(status: UIStatus.success, progress: progress));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: UIStatus.error,
          message: mapExceptionToMessage(e),
        ),
      );
    }
  }
}
