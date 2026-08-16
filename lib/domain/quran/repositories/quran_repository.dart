import '../models/ayah.dart';
import '../models/ayah_search_result.dart';
import '../models/juz.dart';
import '../models/surah.dart';

/// Read access to the bundled Quran corpus (offline / local).
abstract class QuranRepository {
  /// Lightweight metadata for all 114 surahs (no ayah text).
  Future<List<Surah>> getSurahs();

  /// A single surah including its ayahs.
  Future<Surah> getSurah(int surahNumber);

  /// The ayahs of a surah.
  Future<List<Ayah>> getAyahs(int surahNumber);

  /// All 30 juz with their boundaries.
  Future<List<Juz>> getJuzList();

  /// Metadata for every surah that overlaps the given juz.
  Future<List<Surah>> getSurahsInJuz(int juzNumber);

  /// Diacritic-insensitive search across ayah text.
  Future<List<AyahSearchResult>> searchAyahs(String query, {int limit = 30});

  /// Surahs whose Arabic/English name matches [query].
  Future<List<Surah>> searchSurahs(String query);
}
