import '../models/memorized_ayahs.dart';

/// Read/write access to what the user has memorized.
///
/// A seam of its own so the reader doesn't have to know that this lives on the
/// onboarding profile; everything that changes memorization goes through here.
abstract class MemorizationRepository {
  MemorizedAyahs get();

  Future<void> save(MemorizedAyahs memorized);

  Future<MemorizedAyahs> toggleAyah(int surah, int ayah);

  Future<MemorizedAyahs> setWholeSurah(
    int surah,
    int ayahCount, {
    required bool memorized,
  });
}
