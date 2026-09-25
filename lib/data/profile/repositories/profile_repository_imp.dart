import 'package:injectable/injectable.dart';
import '../../../domain/onboarding/repositories/onboarding_repository.dart';
import '../../../domain/profile/models/editable_profile.dart';
import '../../../domain/profile/repositories/profile_repository.dart';
import '../../auth/data_sources/local/auth_prefutils.dart';
import '../data_sources/local/avatar_storage.dart';

/// Identity (name, avatar) lives in shared preferences alongside the session;
/// level and memorized surahs stay in the onboarding profile so the revision
/// schedule and the hifz map keep reading one source of truth.
@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final AuthPrefUtils prefUtils;
  final OnboardingRepository onboardingRepository;
  final AvatarStorage avatarStorage;

  ProfileRepositoryImpl({
    required this.prefUtils,
    required this.onboardingRepository,
    required this.avatarStorage,
  });

  @override
  EditableProfile getProfile() {
    final onboarding = onboardingRepository.getProfile();
    return EditableProfile(
      name: prefUtils.getUserName() ?? '',
      avatarPath: prefUtils.getAvatarPath(),
      level: onboarding.level,
      memorized: onboarding.memorized,
    );
  }

  @override
  Future<void> save(EditableProfile profile) async {
    prefUtils.setUserName(profile.name.trim());
    prefUtils.setAvatarPath(profile.avatarPath);
    // Preserve `completed` — editing the profile must not send the user back
    // through onboarding on the next launch.
    final onboarding = onboardingRepository.getProfile();
    await onboardingRepository.saveProfile(
      onboarding.copyWith(level: profile.level, memorized: profile.memorized),
    );
  }

  @override
  Future<String> persistAvatar(String pickedPath) =>
      avatarStorage.store(pickedPath);
}
