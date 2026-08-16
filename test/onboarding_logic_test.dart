import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/domain/onboarding/models/memorization_level.dart';
import 'package:hifdh_hero/domain/onboarding/models/onboarding_profile.dart';

void main() {
  group('MemorizationLevel', () {
    test('fromKey resolves known values', () {
      expect(MemorizationLevel.fromKey('intermediate'),
          MemorizationLevel.intermediate);
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
        memorizedSurahs: [1, 112],
      );
      expect(p2.level, MemorizationLevel.hafiz);
      expect(p2.memorizedSurahs, [1, 112]);
      expect(p2.completed, isFalse); // unchanged
    });

    test('value equality via Equatable', () {
      const a = OnboardingProfile(memorizedSurahs: [1, 2]);
      const b = OnboardingProfile(memorizedSurahs: [1, 2]);
      expect(a, b);
    });
  });
}
