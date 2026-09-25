import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/error_utils.dart';
import '../../../core/model/ui_state.dart';
import '../../../domain/onboarding/models/memorization_level.dart';
import '../../../domain/onboarding/models/onboarding_profile.dart';
import '../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../domain/onboarding/repositories/onboarding_repository.dart';
import '../../../domain/quran/repositories/quran_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Drives the "ابدأ رحلة حفظك" flow. Follows the exact BLoC pattern used by
/// `NameBloc`/`LoginBloc` in starterflutter-develop (part files + UIState).
@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository repository;
  final QuranRepository quranRepository;

  /// Surah number -> ayah count, needed to turn "I know this surah" into a
  /// full-length range.
  Map<int, int> _ayahCounts = const {};

  OnboardingBloc(this.repository, this.quranRepository)
    : super(OnboardingState.initial()) {
    on<OnboardingStarted>(_onStarted);
    on<LevelSelected>(_onLevelSelected);
    on<SurahToggled>(_onSurahToggled);
    on<MemorizedSurahsChanged>(_onSurahsChanged);
    on<OnboardingSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    final meta = await quranRepository.getSurahs();
    _ayahCounts = {for (final s in meta) s.number: s.ayahCount};
    emit(
      state.copyWith(status: UIStatus.initial, data: repository.getProfile()),
    );
  }

  void _onLevelSelected(LevelSelected event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(data: state.profile.copyWith(level: event.level)));
  }

  void _onSurahsChanged(
    MemorizedSurahsChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(data: state.profile.copyWith(memorized: event.memorized)),
    );
  }

  void _onSurahToggled(SurahToggled event, Emitter<OnboardingState> emit) {
    final count = _ayahCounts[event.surahNumber] ?? 0;
    if (count == 0) return; // unknown surah — nothing sensible to store
    final memorized = state.profile.memorized;
    emit(
      state.copyWith(
        data: state.profile.copyWith(
          memorized: memorized.setWholeSurah(
            event.surahNumber,
            count,
            !memorized.isWholeSurah(event.surahNumber, count),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: UIStatus.loading));
    try {
      final profile = state.profile.copyWith(completed: true);
      await repository.saveProfile(profile);
      await repository.completeOnboarding();
      emit(state.copyWith(status: UIStatus.success, data: profile));
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
