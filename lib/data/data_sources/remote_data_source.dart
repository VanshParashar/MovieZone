// lib/data/data_sources/remote_data_source.dart
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../models/movie_model.dart';
import '../models/movie_detail.dart';
import '../../core/constants.dart';

class RemoteDataSource {
  final Dio _dio;

  RemoteDataSource([Dio? dio])
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: TMDB_BASE_URL,
        connectTimeout: 10000,   // milliseconds (int)
        receiveTimeout: 10000,
        sendTimeout: 10000,
      ));

  // Generic GET with retries + exponential backoff for socket/network errors.
  Future<Response> _requestWithRetry(
      String path, {
        Map<String, dynamic>? queryParameters,
        int maxAttempts = 3,
      }) async {
    var attempt = 0;
    var delay = const Duration(milliseconds: 500);

    while (true) {
      attempt++;
      try {
        final resp = await _dio.get(path, queryParameters: queryParameters);
        return resp;
      } on DioError catch (e) {
        // Determine if this is a retryable network/socket error.
        final isSocketError =
            e.type == DioErrorType.other ||
                (e.error is SocketException);



        if (!isSocketError || attempt >= maxAttempts) {
          // Not retryable or last attempt -> rethrow the DioError
          rethrow;
        }

        // retryable -> wait then retry
        await Future.delayed(delay);
        delay *= 2;
        continue;
      } on SocketException catch (_) {
        if (attempt >= maxAttempts) rethrow;
        await Future.delayed(delay);
        delay *= 2;
        continue;
      } catch (e) {
        // non-network error -> rethrow
        rethrow;
      }
    }
  }

  Future<List<MovieModel>> getTrending({int page = 1}) async {
    try {
      final resp = await _requestWithRetry('/trending/movie/day', queryParameters: {
        'api_key': TMDB_API_KEY,
        'page': page,
      });

      final data = resp.data;
      final results = (data['results'] as List).map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e))).toList();
      return results;
    }  on DioError catch (e) {
      if (e.error is SocketException) {
        throw Exception("No internet connection. Please refresh.");
      }
      rethrow;
    } on SocketException {
      throw Exception("No internet connection. Please refresh.");
    }
  }

  Future<List<MovieModel>> getNowPlaying({int page = 1, String region = 'IN'}) async {
    try {
      final resp = await _requestWithRetry('/movie/now_playing', queryParameters: {
        'api_key': TMDB_API_KEY,
        'page': page,
        'region': region,
      });

      final data = resp.data;
      final results = (data['results'] as List).map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e))).toList();
      return results;
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw Exception("No internet connection. Please refresh.");
      }
      rethrow;
    } on SocketException {
      throw Exception("No internet connection. Please refresh.");
    }
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    try {
      final resp = await _requestWithRetry('/search/movie', queryParameters: {
        'api_key': TMDB_API_KEY,
        'query': query,
        'page': page,
      });

      final data = resp.data;
      final results = (data['results'] as List).map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e))).toList();
      return results;
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw Exception("No internet connection. Please refresh.");
      }
      rethrow;
    } on SocketException {
      throw Exception("No internet connection. Please refresh.");
    }
  }

  Future<MovieDetail> getMovieDetail(int id) async {
    try {
      final res = await _dio.get('/movie/$id', queryParameters: {
        'api_key': TMDB_API_KEY,
      });
      return MovieDetail.fromJson(Map<String, dynamic>.from(res.data));
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw Exception("No internet connection. Please refresh.");
      }
      rethrow;
    } on SocketException {
      throw Exception("No internet connection. Please refresh.");
    }
  }

}
