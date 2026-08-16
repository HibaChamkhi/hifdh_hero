import 'package:equatable/equatable.dart';
import 'memorization_level.dart';

/// The profile captured by onboarding: the user's level and the surahs they
/// already have memorized (stored as surah numbers 1..114).
class OnboardingProfile extends Equatable {
  final MemorizationLevel level;
  final List<int> memorizedSurahs;
  final bool completed;

  const OnboardingProfile({
    this.level = MemorizationLevel.beginner,
    this.memorizedSurahs = const [],
    this.completed = false,
  });

  OnboardingProfile copyWith({
    MemorizationLevel? level,
    List<int>? memorizedSurahs,
    bool? completed,
  }) {
    return OnboardingProfile(
      level: level ?? this.level,
      memorizedSurahs: memorizedSurahs ?? this.memorizedSurahs,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [level, memorizedSurahs, completed];
}
