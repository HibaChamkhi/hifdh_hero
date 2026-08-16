import 'package:equatable/equatable.dart';

/// One of the 30 ajza'. Boundaries follow the standard Hafs division.
class Juz extends Equatable {
  final int number; // 1..30
  final String name; // e.g. "عمّ", "تبارك", or "الجزء N"
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;

  const Juz({
    required this.number,
    required this.name,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });

  factory Juz.fromJson(Map<String, dynamic> json) => Juz(
        number: json['number'] as int,
        name: json['name'] as String,
        startSurah: json['startSurah'] as int,
        startAyah: json['startAyah'] as int,
        endSurah: json['endSurah'] as int,
        endAyah: json['endAyah'] as int,
      );

  /// Whether a given (surah, ayah) falls within this juz.
  bool contains(int surah, int ayah) {
    final afterStart =
        surah > startSurah || (surah == startSurah && ayah >= startAyah);
    final beforeEnd =
        surah < endSurah || (surah == endSurah && ayah <= endAyah);
    return afterStart && beforeEnd;
  }

  @override
  List<Object?> get props =>
      [number, name, startSurah, startAyah, endSurah, endAyah];
}
