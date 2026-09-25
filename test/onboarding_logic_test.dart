import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/domain/onboarding/models/memorization_level.dart';
import 'package:hifdh_hero/domain/memorization/models/ayah_range.dart';
import 'package:hifdh_hero/domain/memorization/models/memorized_ayahs.dart';
import 'package:hifdh_hero/domain/onboarding/models/onboarding_profile.dart';

void main() {
  group('MemorizationLevel', () {
    test('fromKey resolves known values', () {
      expect(
        MemorizationLevel.fromKey('intermediate'),
        MemorizationLevel.intermediate,
      );
      expect(MemorizationLevel.fromKey('hafiz'), MemorizationLevel.hafiz);
    });

    test('fromKey falls back to beginner for unknown/null', () {
      expect(MemorizationLevel.fromKey(null), MemorizationLevel.beginner);
      expect(MemorizationLevel.fromKey('nope'), MemorizationLevel.beginner);
    });
  });

  group('OnboardingProfile', () {
    test('copyWith updates only provided fields', () {
      const p = OnboardingProfile();
      final p2 = p.copyWith(
        level: MemorizationLevel.hafiz,
        memorized: MemorizedAyahs.wholeSurahs(
          const [1, 112],
          const {1: 7, 112: 4},
        ),
      );
      expect(p2.level, MemorizationLevel.hafiz);
      expect(p2.memorized.startedSurahs, {1, 112});
      expect(p2.memorized.totalAyahs, 11);
      expect(p2.completed, isFalse); // unchanged
    });

    test('value equality via Equatable', () {
      final a = OnboardingProfile(
        memorized: MemorizedAyahs.of(const [
          AyahRange(surah: 1, start: 1, end: 7),
        ]),
      );
      final b = OnboardingProfile(
        memorized: MemorizedAyahs.of(const [
          AyahRange(surah: 1, start: 1, end: 7),
        ]),
      );
      expect(a, b);
    });
  });
}
