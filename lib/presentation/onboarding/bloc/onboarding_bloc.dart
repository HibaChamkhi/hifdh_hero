import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/error_utils.dart';
import '../../../core/model/ui_state.dart';
import '../../../domain/onboarding/models/memorization_level.dart';
import '../../../domain/onboarding/models/onboarding_profile.dart';
import '../../../domain/onboarding/repositories/onboarding_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Drives the "ابدأ رحلة حفظك" flow. Follows the exact BLoC pattern used by
/// `NameBloc`/`LoginBloc` in starterflutter-develop (part files + UIState).
@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository repository;

  OnboardingBloc(this.repository) : super(OnboardingState.initial()) {
    on<OnboardingStarted>(_onStarted);
    on<LevelSelected>(_onLevelSelected);
    on<SurahToggled>(_onSurahToggled);
    on<OnboardingSubmitted>(_onSubmitted);
  }

  void _onStarted(OnboardingStarted event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(status: UIStatus.initial, data: repository.getProfile()));
  }

  void _onLevelSelected(LevelSelected event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(data: state.profile.copyWith(level: event.level)));
  }

  void _onSurahToggled(SurahToggled event, Emitter<OnboardingState> emit) {
    final surahs = List<int>.from(state.profile.memorizedSurahs);
    if (surahs.contains(event.surahNumber)) {
      surahs.remove(event.surahNumber);
    } else {
      surahs.add(event.surahNumber);
    }
    emit(state.copyWith(data: state.profile.copyWith(memorizedSurahs: surahs)));
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
      emit(state.copyWith(
        status: UIStatus.error,
        message: mapExceptionToMessage(e),
      ));
    }
  }
}
