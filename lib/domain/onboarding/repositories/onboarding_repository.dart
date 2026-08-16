import '../models/onboarding_profile.dart';

/// Contract for persisting the onboarding profile. The domain layer depends
/// only on this abstraction (data layer provides the implementation).
abstract class OnboardingRepository {
  Future<void> saveProfile(OnboardingProfile profile);
  OnboardingProfile getProfile();
  bool isOnboardingComplete();
  Future<void> completeOnboarding();
}
