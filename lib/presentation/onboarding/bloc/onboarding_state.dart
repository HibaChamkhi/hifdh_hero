part of 'onboarding_bloc.dart';

class OnboardingState extends UIState<OnboardingProfile> {
  const OnboardingState({super.status, super.message, super.data});

  factory OnboardingState.initial() => const OnboardingState(
        status: UIStatus.initial,
        data: OnboardingProfile(),
      );

  /// Convenience: the current (never-null) profile.
  OnboardingProfile get profile => data ?? const OnboardingProfile();

  @override
  OnboardingState copyWith({
    UIStatus? status,
    String? message,
    OnboardingProfile? data,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
