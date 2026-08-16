/// Auth contract. Ported from starterflutter-develop, extended with
/// forgotPassword (screen 06) and isLoggedIn.
abstract class AuthRepository {
  Future<void> register(Map<String, dynamic> userInfo);
  Future<void> login(String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  bool get isLoggedIn;
}
