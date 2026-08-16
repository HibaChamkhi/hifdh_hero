import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/interceptor/auth_interceptor.dart';

/// Token persistence for auth. Ported from starterflutter-develop.
abstract class AuthPrefUtils {
  void setToken(String token);
  void setRefreshToken(String token);
  String? getToken();
  void clear();
}

@Injectable(as: AuthPrefUtils)
class AuthPrefUtilsImpl implements AuthPrefUtils {
  final SharedPreferences sharedPreferences;
  final AuthenticatedHttpClient httpClientInterceptor;

  AuthPrefUtilsImpl({
    required this.sharedPreferences,
    required this.httpClientInterceptor,
  });

  @override
  void setToken(String token) => sharedPreferences.setString('token', token);

  @override
  void setRefreshToken(String token) =>
      sharedPreferences.setString('refreshToken', token);

  @override
  String? getToken() => sharedPreferences.getString('token');

  @override
  void clear() {
    sharedPreferences.remove('token');
    sharedPreferences.remove('refreshToken');
  }
}
