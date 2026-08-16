/// Memorization level chosen during onboarding (screen 03 "ابدأ رحلة حفظك").
enum MemorizationLevel {
  beginner,
  intermediate,
  hafiz;

  String get key => name;

  static MemorizationLevel fromKey(String? key) {
    return MemorizationLevel.values.firstWhere(
      (e) => e.key == key,
      orElse: () => MemorizationLevel.beginner,
    );
  }
}
