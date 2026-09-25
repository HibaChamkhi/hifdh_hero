import 'package:equatable/equatable.dart';
import '../../memorization/models/memorized_ayahs.dart';
import 'memorization_level.dart';

/// The profile captured by onboarding: the user's level and what they have
/// already memorized, tracked at ayah resolution so a long surah can be
/// partly done.
class OnboardingProfile extends Equatable {
  final MemorizationLevel level;
  final MemorizedAyahs memorized;
  final bool completed;

  const OnboardingProfile({
    this.level = MemorizationLevel.beginner,
    this.memorized = MemorizedAyahs.empty,
    this.completed = false,
  });

  OnboardingProfile copyWith({
    MemorizationLevel? level,
    MemorizedAyahs? memorized,
    bool? completed,
  }) {
    return OnboardingProfile(
      level: level ?? this.level,
      memorized: memorized ?? this.memorized,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [level, memorized, completed];
}
