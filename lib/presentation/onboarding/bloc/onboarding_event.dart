part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Load any previously saved profile.
class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

class LevelSelected extends OnboardingEvent {
  final MemorizationLevel level;
  const LevelSelected(this.level);

  @override
  List<Object?> get props => [level];
}

class SurahToggled extends OnboardingEvent {
  final int surahNumber;
  const SurahToggled(this.surahNumber);

  @override
  List<Object?> get props => [surahNumber];
}

class OnboardingSubmitted extends OnboardingEvent {
  const OnboardingSubmitted();
}
