/// Helpers for Arabic text: diacritic-insensitive search normalization.
class ArabicText {
  ArabicText._();

  // Tashkeel (harakat), tatweel, superscript alef, small marks, quran signs.
  static final RegExp _diacritics = RegExp(r'[ؐ-ًؚ-ٰٟۖ-ۜ۟-۪ۨ-ۭـ]');

  /// Removes diacritics and normalizes letter variants so that searching for
  /// "الرحمن" matches "ٱلرَّحۡمَٰن".
  static String normalize(String input) {
    var s = input.replaceAll(_diacritics, '');
    s = s
        .replaceAll('ٱ', 'ا') // ٱ -> ا
        .replaceAll('آ', 'ا') // آ -> ا
        .replaceAll('أ', 'ا') // أ -> ا
        .replaceAll('إ', 'ا') // إ -> ا
        .replaceAll('ى', 'ي') // ى -> ي
        .replaceAll('ة', 'ه'); // ة -> ه
    return s.trim();
  }

  /// True if [haystack] contains [needle] ignoring diacritics/letter variants.
  static bool contains(String haystack, String needle) {
    if (needle.trim().isEmpty) return true;
    return normalize(haystack).contains(normalize(needle));
  }
}

/// Arabic-Indic digits, for numerals shown inside Arabic text — ayah markers
/// in the mushaf carry ٤٢, not 42.
String toArabicNumerals(int value) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return value.toString().split('').map((c) {
    final d = int.tryParse(c);
    return d == null ? c : digits[d];
  }).join();
}
