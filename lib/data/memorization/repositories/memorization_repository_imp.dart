import 'package:injectable/injectable.dart';
import '../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../domain/memorization/repositories/memorization_repository.dart';
import '../../../domain/onboarding/repositories/onboarding_repository.dart';

/// Stores memorization on the onboarding profile, preserving the level and the
/// completed flag so writing from the reader never re-triggers onboarding.
@Injectable(as: MemorizationRepository)
class MemorizationRepositoryImpl implements MemorizationRepository {
  final OnboardingRepository onboardingRepository;

  MemorizationRepositoryImpl({required this.onboardingRepository});

  @override
  MemorizedAyahs get() => onboardingRepository.getProfile().memorized;

  @override
  Future<void> save(MemorizedAyahs memorized) async {
    final profile = onboardingRepository.getProfile();
    await onboardingRepository.saveProfile(
      profile.copyWith(memorized: memorized),
    );
  }

  @override
  Future<MemorizedAyahs> toggleAyah(int surah, int ayah) async {
    final next = get().toggleAyah(surah, ayah);
    await save(next);
    return next;
  }

  @override
  Future<MemorizedAyahs> setWholeSurah(
    int surah,
    int ayahCount, {
    required bool memorized,
  }) async {
    final next = get().setWholeSurah(surah, ayahCount, memorized);
    await save(next);
    return next;
  }
}
