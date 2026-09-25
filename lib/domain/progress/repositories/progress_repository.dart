import '../models/user_progress.dart';

/// Read-only aggregate over onboarding, the Quran corpus and the review log.
/// Backs the home, hifz-map and profile screens.
abstract class ProgressRepository {
  Future<UserProgress> getUserProgress();
}
