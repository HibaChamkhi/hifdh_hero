// GENERATED-STYLE CODE — hand-written so the project compiles without running
// build_runner. After adding new @injectable classes, regenerate with:
//   flutter pub run build_runner build --delete-conflicting-outputs
//
// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:http/http.dart' as _i3;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i4;
import 'package:shared_preferences/shared_preferences.dart' as _i5;

import 'core_module.dart' as _cm;
import '../interceptor/auth_interceptor.dart' as _auth;
import '../interceptor/http_interceptor.dart' as _http;
import '../network/network_info.dart' as _net;
import '../../data/onboarding/data_sources/local/onboarding_local_data_source.dart'
    as _onbLocal;
import '../../domain/onboarding/repositories/onboarding_repository.dart'
    as _onbRepo;
import '../../data/onboarding/repositories/onboarding_repository_imp.dart'
    as _onbRepoImp;
import '../../presentation/onboarding/bloc/onboarding_bloc.dart' as _onbBloc;
import '../../data/auth/data_sources/local/auth_prefutils.dart' as _authPref;
import '../../data/auth/data_sources/remote/auth_data_source.dart' as _authDs;
import '../../domain/auth/repositories/auth_repository.dart' as _authRepo;
import '../../data/auth/repositories/auth_repository_imp.dart' as _authRepoImp;
import '../../data/quran/data_sources/local/quran_local_data_source.dart'
    as _quranLocal;
import '../../domain/quran/repositories/quran_repository.dart' as _quranRepo;
import '../../data/quran/repositories/quran_repository_imp.dart'
    as _quranRepoImp;
import '../../presentation/quran/bloc/quran_bloc.dart' as _quranBloc;
import '../../domain/challenges/repositories/challenge_repository.dart'
    as _chalRepo;
import '../../data/challenges/repositories/challenge_repository_imp.dart'
    as _chalRepoImp;
import '../../presentation/challenges/bloc/challenge_bloc.dart' as _chalBloc;
import '../../presentation/auth/bloc/login_bloc/login_bloc.dart' as _loginBloc;
import '../../presentation/auth/bloc/register_bloc/register_bloc.dart'
    as _registerBloc;
import '../../presentation/auth/bloc/forgot_password_bloc/forgot_password_bloc.dart'
    as _forgotBloc;
import '../../data/revision/data_sources/local/revision_local_data_source.dart'
    as _revLocal;
import '../../domain/revision/repositories/revision_repository.dart'
    as _revRepo;
import '../../data/revision/repositories/revision_repository_imp.dart'
    as _revRepoImp;
import '../../presentation/revision/bloc/revision_bloc.dart' as _revBloc;
import '../../domain/progress/repositories/progress_repository.dart'
    as _progRepo;
import '../../data/progress/repositories/progress_repository_imp.dart'
    as _progRepoImp;
import '../../presentation/progress/bloc/progress_bloc.dart' as _progBloc;
import '../../data/profile/data_sources/local/avatar_storage.dart'
    as _avatarStore;
import '../../domain/profile/repositories/profile_repository.dart'
    as _profileRepo;
import '../../data/profile/repositories/profile_repository_imp.dart'
    as _profileRepoImp;
import '../../presentation/profile/bloc/profile_edit_bloc.dart'
    as _profileEditBloc;
import '../../domain/memorization/repositories/memorization_repository.dart'
    as _memoRepo;
import '../../data/memorization/repositories/memorization_repository_imp.dart'
    as _memoRepoImp;
import '../../data/memorization/repositories/memorization_migration.dart'
    as _memoMigration;

extension GetItInjectableX on _i1.GetIt {
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();

    // --- Core module (third-party singletons) ---
    await gh.factoryAsync<_i5.SharedPreferences>(
      () => coreModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i3.Client>(() => coreModule.httpClient);
    gh.lazySingleton<_i4.InternetConnectionChecker>(
      () => coreModule.dataConnectionChecker,
    );

    // --- Core infrastructure ---
    gh.singleton<_auth.AuthenticatedHttpClient>(
      () => _auth.AuthenticatedHttpClient(
        sharedPref: gh<_i5.SharedPreferences>(),
      ),
    );
    gh.factory<_net.NetworkInfo>(
      () => _net.NetworkInfoImpl(gh<_i4.InternetConnectionChecker>()),
    );
    gh.factory<_http.HttpInterceptor>(
      () => _http.HttpInterceptorImpl(
        httpClient: gh<_auth.AuthenticatedHttpClient>(),
      ),
    );

    // --- Auth feature ---
    gh.factory<_authPref.AuthPrefUtils>(
      () => _authPref.AuthPrefUtilsImpl(
        sharedPreferences: gh<_i5.SharedPreferences>(),
        httpClientInterceptor: gh<_auth.AuthenticatedHttpClient>(),
      ),
    );
    gh.factory<_authDs.AuthRemoteDataSource>(
      () => _authDs.AuthRemoteDataSource(
        httpClient: gh<_http.HttpInterceptor>(),
        prefUtils: gh<_authPref.AuthPrefUtils>(),
        networkInfo: gh<_net.NetworkInfo>(),
      ),
    );
    gh.factory<_authRepo.AuthRepository>(
      () => _authRepoImp.AuthRepositoryImpl(
        remoteDataSource: gh<_authDs.AuthRemoteDataSource>(),
        prefUtils: gh<_authPref.AuthPrefUtils>(),
        networkInfo: gh<_net.NetworkInfo>(),
      ),
    );
    gh.factory<_loginBloc.LoginBloc>(
      () =>
          _loginBloc.LoginBloc(authRepository: gh<_authRepo.AuthRepository>()),
    );
    gh.factory<_registerBloc.RegisterBloc>(
      () => _registerBloc.RegisterBloc(gh<_authRepo.AuthRepository>()),
    );
    gh.factory<_forgotBloc.ForgotPasswordBloc>(
      () => _forgotBloc.ForgotPasswordBloc(gh<_authRepo.AuthRepository>()),
    );

    // --- Onboarding feature ---
    gh.factory<_onbLocal.OnboardingLocalDataSource>(
      () => _onbLocal.OnboardingLocalDataSourceImpl(
        sharedPreferences: gh<_i5.SharedPreferences>(),
      ),
    );
    gh.factory<_onbRepo.OnboardingRepository>(
      () => _onbRepoImp.OnboardingRepositoryImpl(
        localDataSource: gh<_onbLocal.OnboardingLocalDataSource>(),
      ),
    );
    gh.factory<_onbBloc.OnboardingBloc>(
      () => _onbBloc.OnboardingBloc(
        gh<_onbRepo.OnboardingRepository>(),
        gh<_quranRepo.QuranRepository>(),
      ),
    );

    // --- Memorization (ayah-level tracking, shared by reader/profile) ---
    gh.factory<_memoRepo.MemorizationRepository>(
      () => _memoRepoImp.MemorizationRepositoryImpl(
        onboardingRepository: gh<_onbRepo.OnboardingRepository>(),
      ),
    );
    gh.factory<_memoMigration.MemorizationMigration>(
      () => _memoMigration.MemorizationMigration(
        localDataSource: gh<_onbLocal.OnboardingLocalDataSource>(),
        quranRepository: gh<_quranRepo.QuranRepository>(),
      ),
    );

    // --- Quran feature ---
    gh.lazySingleton<_quranLocal.QuranLocalDataSource>(
      () => _quranLocal.QuranLocalDataSourceImpl(),
    );
    gh.factory<_quranRepo.QuranRepository>(
      () => _quranRepoImp.QuranRepositoryImpl(
        localDataSource: gh<_quranLocal.QuranLocalDataSource>(),
      ),
    );
    gh.factory<_quranBloc.QuranBloc>(
      () => _quranBloc.QuranBloc(gh<_quranRepo.QuranRepository>()),
    );

    // --- Challenges feature ---
    gh.factory<_chalRepo.ChallengeRepository>(
      () => _chalRepoImp.ChallengeRepositoryImpl(
        quranRepository: gh<_quranRepo.QuranRepository>(),
      ),
    );
    gh.factory<_chalBloc.ChallengeBloc>(
      () => _chalBloc.ChallengeBloc(
        gh<_chalRepo.ChallengeRepository>(),
        gh<_revRepo.RevisionRepository>(),
      ),
    );

    // --- Revision feature ---
    gh.lazySingleton<_revLocal.RevisionLocalDataSource>(
      () => _revLocal.RevisionLocalDataSourceImpl(
        sharedPreferences: gh<_i5.SharedPreferences>(),
      ),
    );
    gh.factory<_revRepo.RevisionRepository>(
      () => _revRepoImp.RevisionRepositoryImpl(
        localDataSource: gh<_revLocal.RevisionLocalDataSource>(),
        quranRepository: gh<_quranRepo.QuranRepository>(),
        onboardingRepository: gh<_onbRepo.OnboardingRepository>(),
      ),
    );
    gh.factory<_revBloc.RevisionBloc>(
      () => _revBloc.RevisionBloc(gh<_revRepo.RevisionRepository>()),
    );

    // --- Progress feature (home / hifz map / profile) ---
    gh.factory<_progRepo.ProgressRepository>(
      () => _progRepoImp.ProgressRepositoryImpl(
        quranRepository: gh<_quranRepo.QuranRepository>(),
        onboardingRepository: gh<_onbRepo.OnboardingRepository>(),
        revisionRepository: gh<_revRepo.RevisionRepository>(),
        revisionLocalDataSource: gh<_revLocal.RevisionLocalDataSource>(),
        authPrefUtils: gh<_authPref.AuthPrefUtils>(),
      ),
    );
    gh.factory<_progBloc.ProgressBloc>(
      () => _progBloc.ProgressBloc(
        gh<_progRepo.ProgressRepository>(),
        gh<_revRepo.RevisionRepository>(),
      ),
    );

    // --- Profile editing (screen 35) ---
    gh.factory<_avatarStore.AvatarStorage>(
      () => _avatarStore.AvatarStorageImpl(),
    );
    gh.factory<_profileRepo.ProfileRepository>(
      () => _profileRepoImp.ProfileRepositoryImpl(
        prefUtils: gh<_authPref.AuthPrefUtils>(),
        onboardingRepository: gh<_onbRepo.OnboardingRepository>(),
        avatarStorage: gh<_avatarStore.AvatarStorage>(),
      ),
    );
    gh.factory<_profileEditBloc.ProfileEditBloc>(
      () => _profileEditBloc.ProfileEditBloc(
        gh<_profileRepo.ProfileRepository>(),
      ),
    );

    return this;
  }
}

class _$CoreModule extends _cm.CoreModule {}
