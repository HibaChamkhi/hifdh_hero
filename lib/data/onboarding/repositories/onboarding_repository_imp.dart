import 'package:injectable/injectable.dart';
import '../../../domain/onboarding/models/onboarding_profile.dart';
import '../../../domain/onboarding/repositories/onboarding_repository.dart';
import '../data_sources/local/onboarding_local_data_source.dart';

@Injectable(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveProfile(OnboardingProfile profile) =>
      localDataSource.saveProfile(profile);

  @override
  OnboardingProfile getProfile() => localDataSource.getProfile();

  @override
  bool isOnboardingComplete() => localDataSource.isComplete();

  @override
  Future<void> completeOnboarding() => localDataSource.setComplete(true);
}
