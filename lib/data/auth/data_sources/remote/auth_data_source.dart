import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/error_utils.dart';
import '../../../../core/interceptor/http_interceptor.dart';
import '../../../../core/network/network_info.dart';
import '../local/auth_prefutils.dart';

/// Ported from starterflutter-develop. Uses [AppConfig.apiBaseUrl] for the real
/// API, and a mock path (AppConfig.useMockAuth) so the flow works with no
/// backend during development.
@injectable
class AuthRemoteDataSource {
  final HttpInterceptor httpClient;
  final AuthPrefUtils prefUtils;
  final NetworkInfo networkInfo;

  AuthRemoteDataSource({
    required this.httpClient,
    required this.prefUtils,
    required this.networkInfo,
  });

  Future<Either<Exception, Unit>> register(
    Map<String, dynamic> userInfo,
  ) async {
    if (AppConfig.useMockAuth) return _mockAuthSuccess();
    final body = json.encode(userInfo);
    return performNetworkRequest<Unit>(
      operation: () async => httpClient.httpInterceptor().post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ),
      handleResponse: (responseJson) {
        _storeTokens(responseJson);
        return unit;
      },
      networkInfo: networkInfo,
    );
  }

  Future<Either<Exception, Unit>> login(String email, String password) async {
    if (AppConfig.useMockAuth) return _mockAuthSuccess();
    final body = json.encode({'email': email, 'password': password});
    return performNetworkRequest<Unit>(
      operation: () async => httpClient.httpInterceptor().post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ),
      handleResponse: (responseJson) {
        _storeTokens(responseJson);
        return unit;
      },
      networkInfo: networkInfo,
    );
  }

  Future<Either<Exception, Unit>> forgotPassword(String email) async {
    if (AppConfig.useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return const Right(unit);
    }
    final body = json.encode({'email': email});
    return performNetworkRequest<Unit>(
      operation: () async => httpClient.httpInterceptor().post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ),
      handleResponse: (_) => unit,
      networkInfo: networkInfo,
    );
  }

  Future<Either<Exception, Unit>> logout() async {
    if (AppConfig.useMockAuth) {
      prefUtils.clear();
      return const Right(unit);
    }
    return performNetworkRequest<Unit>(
      operation: () async => httpClient.httpInterceptor().delete(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/logout'),
      ),
      handleResponse: (_) {
        prefUtils.clear();
        return unit;
      },
      networkInfo: networkInfo,
    );
  }

  // ---- helpers ----

  void _storeTokens(Map<String, dynamic> responseJson) {
    final tokens = responseJson['data']?['tokens'];
    if (tokens != null) {
      prefUtils
        ..clear()
        ..setToken(tokens['accessToken'] as String)
        ..setRefreshToken(tokens['refreshToken'] as String);
    } else {
      throw Exception('لم يتم العثور على رموز الدخول');
    }
  }

  Future<Either<Exception, Unit>> _mockAuthSuccess() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    prefUtils
      ..clear()
      ..setToken('mock-access-token')
      ..setRefreshToken('mock-refresh-token');
    return const Right(unit);
  }
}
