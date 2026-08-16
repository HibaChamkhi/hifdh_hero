import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';
import '../../../../core/error/exception.dart';
import '../../../../domain/quran/models/juz.dart';
import '../../../../domain/quran/models/surah.dart';

/// Reads the bundled Quran JSON assets and caches them in memory.
///
/// Assets (see `assets/data/`):
///  - surahs.json : slim metadata for all 114 surahs
///  - quran.json  : full Uthmani text (source: risan/quran-json, verified)
///  - juz.json    : the 30 juz boundaries (standard Hafs division)
abstract class QuranLocalDataSource {
  Future<List<Surah>> loadSurahMeta();
  Future<Surah> loadSurah(int surahNumber);
  Future<List<Juz>> loadJuz();
}

@LazySingleton(as: QuranLocalDataSource)
class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  static const _surahsAsset = 'assets/data/surahs.json';
  static const _quranAsset = 'assets/data/quran.json';
  static const _juzAsset = 'assets/data/juz.json';

  List<Surah>? _metaCache;
  List<Juz>? _juzCache;
  final Map<int, Surah> _surahCache = {};

  @override
  Future<List<Surah>> loadSurahMeta() async {
    if (_metaCache != null) return _metaCache!;
    try {
      final raw = await rootBundle.loadString(_surahsAsset);
      final list = json.decode(raw) as List;
      _metaCache = list
          .map((e) => Surah.meta(e as Map<String, dynamic>))
          .toList(growable: false);
      return _metaCache!;
    } catch (e) {
      throw CacheException(message: 'تعذّر تحميل بيانات السور: $e');
    }
  }

  @override
  Future<Surah> loadSurah(int surahNumber) async {
    if (_surahCache.containsKey(surahNumber)) return _surahCache[surahNumber]!;
    try {
      final raw = await rootBundle.loadString(_quranAsset);
      final map = json.decode(raw) as Map<String, dynamic>;
      final surahs = (map['surahs'] as List).cast<Map<String, dynamic>>();
      for (final s in surahs) {
        final full = Surah.full(s);
        _surahCache[full.number] = full;
      }
      final result = _surahCache[surahNumber];
      if (result == null) {
        throw CacheException(message: 'السورة $surahNumber غير موجودة');
      }
      return result;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'تعذّر تحميل نص السورة: $e');
    }
  }

  @override
  Future<List<Juz>> loadJuz() async {
    if (_juzCache != null) return _juzCache!;
    try {
      final raw = await rootBundle.loadString(_juzAsset);
      final list = json.decode(raw) as List;
      _juzCache = list
          .map((e) => Juz.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      return _juzCache!;
    } catch (e) {
      throw CacheException(message: 'تعذّر تحميل بيانات الأجزاء: $e');
    }
  }
}
