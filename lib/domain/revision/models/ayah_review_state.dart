import 'package:equatable/equatable.dart';

/// Spaced-repetition state for a single ayah (Leitner boxes 0..5).
class AyahReviewState extends Equatable {
  final int surahNumber;
  final int ayahNumber;

  /// Leitner box 0..5 — higher means better retained.
  final int box;

  /// Day number (days since epoch) this ayah is next due.
  final int dueDay;

  /// Day number it was last reviewed (-1 = never).
  final int lastReviewedDay;

  final int reviewCount;
  final int lapses;

  const AyahReviewState({
    required this.surahNumber,
    required this.ayahNumber,
    this.box = 0,
    this.dueDay = 0,
    this.lastReviewedDay = -1,
    this.reviewCount = 0,
    this.lapses = 0,
  });

  static const int maxBox = 5;

  /// 0..100 retention indicator (drives the star rating in the UI).
  int get strengthPercent => ((box / maxBox) * 100).round();

  /// 0..5 stars.
  int get stars => box;

  bool isDue(int today) => dueDay <= today;

  /// "Weak" = low box or overdue — the ayahs that need extra focus (screen 31).
  bool isWeak(int today) => box <= 2 || (today - dueDay) > 0;

  String get key => '$surahNumber:$ayahNumber';

  AyahReviewState copyWith({
    int? box,
    int? dueDay,
    int? lastReviewedDay,
    int? reviewCount,
    int? lapses,
  }) {
    return AyahReviewState(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      box: box ?? this.box,
      dueDay: dueDay ?? this.dueDay,
      lastReviewedDay: lastReviewedDay ?? this.lastReviewedDay,
      reviewCount: reviewCount ?? this.reviewCount,
      lapses: lapses ?? this.lapses,
    );
  }

  Map<String, dynamic> toJson() => {
        's': surahNumber,
        'a': ayahNumber,
        'box': box,
        'due': dueDay,
        'last': lastReviewedDay,
        'count': reviewCount,
        'lapses': lapses,
      };

  factory AyahReviewState.fromJson(Map<String, dynamic> j) => AyahReviewState(
        surahNumber: j['s'] as int,
        ayahNumber: j['a'] as int,
        box: j['box'] as int? ?? 0,
        dueDay: j['due'] as int? ?? 0,
        lastReviewedDay: j['last'] as int? ?? -1,
        reviewCount: j['count'] as int? ?? 0,
        lapses: j['lapses'] as int? ?? 0,
      );

  @override
  List<Object?> get props =>
      [surahNumber, ayahNumber, box, dueDay, lastReviewedDay, reviewCount, lapses];
}
