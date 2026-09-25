import 'package:http_interceptor/http_interceptor.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adds the bearer token to every outgoing request.
/// Ported from starterflutter-develop (AuthInterceptor.dart).
@Singleton()
class AuthenticatedHttpClient extends InterceptorContract {
  SharedPreferences sharedPref;

  AuthenticatedHttpClient({required this.sharedPref});

  String get userAccessToken => sharedPref.getString("token") ?? "";

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    request.headers['Content-Type'] = 'application/json; charset=utf-8';
    request.headers['Accept'] = 'application/json';
    if (userAccessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $userAccessToken';
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    return response;
  }
}
