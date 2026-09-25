import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:injectable/injectable.dart';
import 'auth_interceptor.dart';

abstract class HttpInterceptor {
  InterceptedHttp httpInterceptor();
}

/// Ported from starterflutter-develop (HttpInterceptor.dart).
@Injectable(as: HttpInterceptor)
class HttpInterceptorImpl implements HttpInterceptor {
  final AuthenticatedHttpClient httpClient;

  const HttpInterceptorImpl({required this.httpClient});

  @override
  InterceptedHttp httpInterceptor() {
    final client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    final ioClient = IOClient(client);
    return InterceptedHttp.build(client: ioClient, interceptors: [httpClient]);
  }
}
