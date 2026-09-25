import 'package:injectable/injectable.dart';
import '../../../core/network/network_info.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../data_sources/local/auth_prefutils.dart';
import '../data_sources/remote/auth_data_source.dart';

/// Ported from starterflutter-develop, extended with forgotPassword/isLoggedIn.
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthPrefUtils prefUtils;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.prefUtils,
    required this.networkInfo,
  });

  @override
  Future<void> register(Map<String, dynamic> userInfo) async {
    final response = await remoteDataSource.register(userInfo);
    response.fold((e) => throw e, (_) {
      // Kept locally so the home/profile screens can greet the user; the
      // token write in the data source clears prefs, so this must follow it.
      final name = (userInfo['name'] as String?)?.trim() ?? '';
      if (name.isNotEmpty) prefUtils.setUserName(name);
    });
  }

  @override
  Future<void> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    response.fold((e) => throw e, (_) {});
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response = await remoteDataSource.forgotPassword(email);
    response.fold((e) => throw e, (_) {});
  }

  @override
  Future<void> logout() async {
    final response = await remoteDataSource.logout();
    response.fold((e) => throw e, (_) {});
  }

  @override
  bool get isLoggedIn => (prefUtils.getToken() ?? '').isNotEmpty;
}
