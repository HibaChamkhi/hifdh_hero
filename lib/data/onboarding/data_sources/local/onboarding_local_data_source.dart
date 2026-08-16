import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/onboarding/models/memorization_level.dart';
import '../../../../domain/onboarding/models/onboarding_profile.dart';

abstract class OnboardingLocalDataSource {
  Future<void> saveProfile(OnboardingProfile profile);
  OnboardingProfile getProfile();
  bool isComplete();
  Future<void> setComplete(bool value);
}

@Injectable(as: OnboardingLocalDataSource)
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  static const _kLevel = 'onboarding_level';
  static const _kSurahs = 'onboarding_memorized_surahs';
  static const _kComplete = 'onboarding_complete';

  @override
  Future<void> saveProfile(OnboardingProfile profile) async {
    await sharedPreferences.setString(_kLevel, profile.level.key);
    await sharedPreferences.setStringList(
      _kSurahs,
      profile.memorizedSurahs.map((e) => e.toString()).toList(),
    );
    await sharedPreferences.setBool(_kComplete, profile.completed);
  }

  @override
  OnboardingProfile getProfile() {
    final level = MemorizationLevel.fromKey(sharedPreferences.getString(_kLevel));
    final surahs = (sharedPreferences.getStringList(_kSurahs) ?? [])
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e > 0)
        .toList();
    return OnboardingProfile(
      level: level,
      memorizedSurahs: surahs,
      completed: isComplete(),
    );
  }

  @override
  bool isComplete() => sharedPreferences.getBool(_kComplete) ?? false;

  @override
  Future<void> setComplete(bool value) async {
    await sharedPreferences.setBool(_kComplete, value);
  }
}
