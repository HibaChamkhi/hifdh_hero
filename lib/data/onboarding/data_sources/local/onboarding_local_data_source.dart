import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../../domain/onboarding/models/memorization_level.dart';
import '../../../../domain/onboarding/models/onboarding_profile.dart';

abstract class OnboardingLocalDataSource {
  Future<void> saveProfile(OnboardingProfile profile);
  OnboardingProfile getProfile();
  bool isComplete();
  Future<void> setComplete(bool value);

  /// Surah numbers written by builds that tracked memorization per surah.
  /// Empty once the profile has been migrated to ayah ranges.
  List<int> legacySurahNumbers();

  Future<void> clearLegacySurahNumbers();
}

@Injectable(as: OnboardingLocalDataSource)
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  static const _kLevel = 'onboarding_level';

  /// Pre-ayah-tracking key: a list of surah numbers.
  static const _kLegacySurahs = 'onboarding_memorized_surahs';
  static const _kRanges = 'onboarding_memorized_ranges';
  static const _kComplete = 'onboarding_complete';

  @override
  Future<void> saveProfile(OnboardingProfile profile) async {
    await sharedPreferences.setString(_kLevel, profile.level.key);
    await sharedPreferences.setString(
      _kRanges,
      json.encode(profile.memorized.toJson()),
    );
    await sharedPreferences.setBool(_kComplete, profile.completed);
  }

  @override
  OnboardingProfile getProfile() {
    final level = MemorizationLevel.fromKey(
      sharedPreferences.getString(_kLevel),
    );
    return OnboardingProfile(
      level: level,
      memorized: _readMemorized(),
      completed: isComplete(),
    );
  }

  MemorizedAyahs _readMemorized() {
    final raw = sharedPreferences.getString(_kRanges);
    if (raw == null || raw.isEmpty) return MemorizedAyahs.empty;
    try {
      return MemorizedAyahs.fromJson(json.decode(raw) as List<dynamic>);
    } on FormatException {
      // Corrupt entry: better an empty profile than a crash on every launch.
      return MemorizedAyahs.empty;
    }
  }

  @override
  List<int> legacySurahNumbers() =>
      (sharedPreferences.getStringList(_kLegacySurahs) ?? [])
          .map((e) => int.tryParse(e) ?? 0)
          .where((e) => e > 0)
          .toList();

  @override
  Future<void> clearLegacySurahNumbers() =>
      sharedPreferences.remove(_kLegacySurahs);

  @override
  bool isComplete() => sharedPreferences.getBool(_kComplete) ?? false;

  @override
  Future<void> setComplete(bool value) async {
    await sharedPreferences.setBool(_kComplete, value);
  }
}
