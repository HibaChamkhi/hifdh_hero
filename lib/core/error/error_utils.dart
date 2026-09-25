import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart';
import '../network/network_info.dart';
import 'exception.dart';

/// Maps a thrown [Exception] to a human-readable message for the UI.
/// Ported from starterflutter-develop.
String mapExceptionToMessage(Exception e) {
  if (e is ServerException) return e.message;
  if (e is UnauthorizedException) return e.message;
  if (e is BadRequestException) return e.message;
  if (e is UnknownNetworkException) return e.message;
  if (e is ServerErrorException) return e.message;
  if (e is NetworkException) return e.message;
  if (e is CacheException) return e.message;
  return 'حدث خطأ غير متوقع';
}

String _getErrorMessage(Response response) {
  try {
    final Map<String, dynamic> decodedJson = json.decode(response.body);
    return decodedJson['message'] ?? 'حدث خطأ غير معروف';
  } catch (_) {
    return 'تعذّر قراءة رسالة الخطأ';
  }
}

/// Standard network wrapper: checks connectivity, runs the request, maps
/// status codes to typed exceptions, and returns an [Either].
/// Ported from starterflutter-develop.
Future<Either<Exception, T>> performNetworkRequest<T>({
  required Future<Response> Function() operation,
  required T Function(Map<String, dynamic>) handleResponse,
  required NetworkInfo networkInfo,
}) async {
  if (await networkInfo.isConnected) {
    try {
      final response = await operation();
      switch (response.statusCode) {
        case 200:
        case 201:
        case 202:
        case 204:
          final Map<String, dynamic> decodedJson = response.body.isEmpty
              ? {}
              : json.decode(response.body);
          return Right(handleResponse(decodedJson));
        case 401:
          throw UnauthorizedException(message: 'طلب غير مصرّح به');
        case 400:
        case 403:
        case 404:
        case 429:
          throw BadRequestException(message: _getErrorMessage(response));
        case 500:
        case 502:
        case 503:
        case 504:
          throw ServerErrorException(message: 'حدث خطأ في الخادم');
        default:
          throw UnknownNetworkException(
            message: 'خطأ غير معروف (رمز ${response.statusCode})',
          );
      }
    } on FormatException catch (e) {
      return Left(
        ServerException(message: 'صيغة JSON غير صالحة: ${e.message}'),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  } else {
    return Left(NetworkException(message: 'لا يوجد اتصال بالإنترنت'));
  }
}
