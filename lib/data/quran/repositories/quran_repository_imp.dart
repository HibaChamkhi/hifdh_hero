import 'package:injectable/injectable.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../domain/quran/models/ayah.dart';
import '../../../domain/quran/models/ayah_search_result.dart';
import '../../../domain/quran/models/juz.dart';
import '../../../domain/quran/models/surah.dart';
import '../../../domain/quran/repositories/quran_repository.dart';
import '../data_sources/local/quran_local_data_source.dart';

@Injectable(as: QuranRepository)
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource localDataSource;

  QuranRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Surah>> getSurahs() => localDataSource.loadSurahMeta();

  @override
  Future<Surah> getSurah(int surahNumber) =>
      localDataSource.loadSurah(surahNumber);

  @override
  Future<List<Ayah>> getAyahs(int surahNumber) async {
    final surah = await localDataSource.loadSurah(surahNumber);
    return surah.ayahs;
  }

  @override
  Future<List<Juz>> getJuzList() => localDataSource.loadJuz();

  @override
  Future<List<Surah>> getSurahsInJuz(int juzNumber) async {
    final juzList = await localDataSource.loadJuz();
    final juz = juzList.firstWhere(
      (j) => j.number == juzNumber,
      orElse: () => throw ArgumentError('Invalid juz $juzNumber'),
    );
    final meta = await localDataSource.loadSurahMeta();
    return meta
        .where((s) => s.number >= juz.startSurah && s.number <= juz.endSurah)
        .toList();
  }

  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 30,
  }) async {
    if (query.trim().isEmpty) return const [];
    final meta = await localDataSource.loadSurahMeta();
    final results = <AyahSearchResult>[];
    for (final s in meta) {
      final surah = await localDataSource.loadSurah(s.number);
      for (final Ayah a in surah.ayahs) {
        if (ArabicText.contains(a.text, query)) {
          results.add(
            AyahSearchResult(
              surahNumber: surah.number,
              surahName: surah.name,
              ayahNumber: a.number,
              text: a.text,
            ),
          );
          if (results.length >= limit) return results;
        }
      }
    }
    return results;
  }

  @override
  Future<List<Surah>> searchSurahs(String query) async {
    final meta = await localDataSource.loadSurahMeta();
    if (query.trim().isEmpty) return meta;
    final q = query.trim().toLowerCase();
    return meta
        .where(
          (s) =>
              ArabicText.contains(s.name, query) ||
              s.englishName.toLowerCase().contains(q),
        )
        .toList();
  }
}
