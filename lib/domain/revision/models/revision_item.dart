import 'package:equatable/equatable.dart';
import 'ayah_review_state.dart';

/// A review-state enriched with its surah name, ready for display
/// (weak-ayahs list, today's plan).
class RevisionItem extends Equatable {
  final AyahReviewState state;
  final String surahName;

  const RevisionItem({required this.state, required this.surahName});

  int get surahNumber => state.surahNumber;
  int get ayahNumber => state.ayahNumber;

  @override
  List<Object?> get props => [state, surahName];
}
