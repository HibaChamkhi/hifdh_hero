import 'package:injectable/injectable.dart';
import '../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../domain/quran/repositories/quran_repository.dart';
import '../../onboarding/data_sources/local/onboarding_local_data_source.dart';

/// One-time upgrade of profiles written before memorization was tracked per
/// ayah: each surah the user had marked becomes a full-length range, so nobody
/// loses progress on update.
///
/// Lives here rather than in the data source because it needs the corpus to
/// know how many ayahs a surah has, and that load is async.
@injectable
class MemorizationMigration {
  final OnboardingLocalDataSource localDataSource;
  final QuranRepository quranRepository;

  MemorizationMigration({
    required this.localDataSource,
    required this.quranRepository,
  });

  /// Cheap no-op once migrated — the legacy key is removed on success.
  Future<void> run() async {
    final legacy = localDataSource.legacySurahNumbers();
    if (legacy.isEmpty) return;

    final profile = localDataSource.getProfile();
    // Anything already stored as ranges wins; only fill in from the old key.
    if (profile.memorized.isEmpty) {
      final meta = await quranRepository.getSurahs();
      final counts = {for (final s in meta) s.number: s.ayahCount};
      await localDataSource.saveProfile(
        profile.copyWith(memorized: MemorizedAyahs.wholeSurahs(legacy, counts)),
      );
    }
    await localDataSource.clearLegacySurahNumbers();
  }
}
