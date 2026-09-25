import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/interceptor/auth_interceptor.dart';

/// Token persistence for auth. Ported from starterflutter-develop.
abstract class AuthPrefUtils {
  void setToken(String token);
  void setRefreshToken(String token);
  String? getToken();

  /// The display name captured at registration; drives the home greeting and
  /// the profile header. Null when the user signed in on a fresh install.
  void setUserName(String name);
  String? getUserName();

  /// Absolute path to the avatar image in app storage; null clears it.
  void setAvatarPath(String? path);
  String? getAvatarPath();

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
  void setUserName(String name) =>
      sharedPreferences.setString('userName', name);

  @override
  String? getUserName() => sharedPreferences.getString('userName');

  @override
  void setAvatarPath(String? path) {
    if (path == null || path.isEmpty) {
      sharedPreferences.remove('avatarPath');
    } else {
      sharedPreferences.setString('avatarPath', path);
    }
  }

  @override
  String? getAvatarPath() => sharedPreferences.getString('avatarPath');

  @override
  void clear() {
    sharedPreferences.remove('token');
    sharedPreferences.remove('refreshToken');
    sharedPreferences.remove('userName');
    sharedPreferences.remove('avatarPath');
  }
}
