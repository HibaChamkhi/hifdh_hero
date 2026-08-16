import 'package:equatable/equatable.dart';
import 'ayah.dart';
import 'revelation_type.dart';

/// A surah. Loaded either as lightweight metadata (empty [ayahs]) via
/// `surahs.json`, or fully (with [ayahs]) via `quran.json`.
class Surah extends Equatable {
  final int number; // 1..114
  final String name; // Arabic, e.g. "الملك"
  final String englishName; // transliteration, e.g. "Al-Mulk"
  final RevelationType revelationType;
  final int ayahCount;
  final int startJuz; // juz this surah begins in
  final List<Ayah> ayahs;

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.revelationType,
    required this.ayahCount,
    this.startJuz = 0,
    this.ayahs = const [],
  });

  bool get hasAyahs => ayahs.isNotEmpty;

  /// From `surahs.json` (metadata only).
  factory Surah.meta(Map<String, dynamic> json) => Surah(
        number: json['number'] as int,
        name: json['name'] as String,
        englishName: json['englishName'] as String,
        revelationType:
            RevelationType.fromKey(json['revelationType'] as String?),
        ayahCount: json['ayahCount'] as int,
        startJuz: (json['startJuz'] as int?) ?? 0,
      );

  /// From `quran.json` (full text).
  factory Surah.full(Map<String, dynamic> json) => Surah(
        number: json['number'] as int,
        name: json['name'] as String,
        englishName: json['englishName'] as String,
        revelationType:
            RevelationType.fromKey(json['revelationType'] as String?),
        ayahCount: json['ayahCount'] as int,
        ayahs: (json['ayahs'] as List)
            .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props =>
      [number, name, englishName, revelationType, ayahCount, startJuz, ayahs];
}
