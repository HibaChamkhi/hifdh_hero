import 'package:equatable/equatable.dart';

/// A single ayah within a surah.
class Ayah extends Equatable {
  final int number; // 1-based, within the surah
  final String text; // Uthmani Arabic

  const Ayah({required this.number, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json) =>
      Ayah(number: json['number'] as int, text: json['text'] as String);

  @override
  List<Object?> get props => [number, text];
}
