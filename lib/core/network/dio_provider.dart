// lib/core/dio_provider.dart
import 'package:dio/dio.dart';

import '../constants.dart';

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: TMDB_BASE_URL,
    connectTimeout: 20000, // Dio 4.x expects int milliseconds
    receiveTimeout: 20000,
    sendTimeout: 20000,
    responseType: ResponseType.json,
  ));

  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    // add API key param
    options.queryParameters = Map<String, dynamic>.from(options.queryParameters ?? {})
      ..putIfAbsent('api_key', () => TMDB_API_KEY);
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  }, onError: (err, handler) async {
    final shouldRetry = err.type == DioErrorType.other ||
        err.type == DioErrorType.receiveTimeout ||
        err.type == DioErrorType.sendTimeout;
    if (shouldRetry) {
      final req = err.requestOptions;
      final retries = req.extra['retries'] as int? ?? 0;
      if (retries < 2) {
        req.extra['retries'] = retries + 1;
        await Future.delayed(Duration(milliseconds: 300 * (retries + 1)));
        try {
          final response = await dio.request(
            req.path,
            data: req.data,
            queryParameters: req.queryParameters,
            options: Options(
              method: req.method,
              headers: req.headers,
              responseType: req.responseType,
            ),
            cancelToken: req.cancelToken,
            onReceiveProgress: req.onReceiveProgress,
          );
          return handler.resolve(response);
        } catch (_) {}
      }
    }
    return handler.next(err);
  }));

  return dio;
}
