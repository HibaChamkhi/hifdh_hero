import 'package:equatable/equatable.dart';
import '../../quran/models/juz.dart';

/// How far the user has come in one juz (screens 07 "رحلة حفظك" and 08
/// "خريطة الحفظ").
///
/// [memorizedAyahs] counts the ayahs of this juz that belong to a surah the
/// user marked as memorized during onboarding, so the map reflects their
/// starting point immediately rather than waiting for review history.
class JuzProgress extends Equatable {
  final Juz juz;
  final int memorizedAyahs;
  final int totalAyahs;

  const JuzProgress({
    required this.juz,
    required this.memorizedAyahs,
    required this.totalAyahs,
  });

  /// 0.0 – 1.0.
  double get ratio =>
      totalAyahs <= 0 ? 0 : (memorizedAyahs / totalAyahs).clamp(0.0, 1.0);

  int get percent => (ratio * 100).round();

  bool get isComplete => totalAyahs > 0 && memorizedAyahs >= totalAyahs;

  bool get isStarted => memorizedAyahs > 0;

  @override
  List<Object?> get props => [juz, memorizedAyahs, totalAyahs];
}
