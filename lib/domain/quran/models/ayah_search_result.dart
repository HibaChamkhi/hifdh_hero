import 'package:equatable/equatable.dart';

/// A search hit pointing at a specific ayah.
class AyahSearchResult extends Equatable {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String text;

  const AyahSearchResult({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.text,
  });

  @override
  List<Object?> get props => [surahNumber, surahName, ayahNumber, text];
}
