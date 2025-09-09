// lib/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/data_sources/local_data_source.dart';
import 'data/data_sources/remote_data_source.dart';
import 'data/repositories/movie_repository.dart';

// singletons
final localDataSourceProvider = Provider<LocalDataSource>((ref) => LocalDataSource());
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) => RemoteDataSource());
final movieRepoProvider = Provider<MovieRepository>((ref) {
  final local = ref.read(localDataSourceProvider);
  final remote = ref.read(remoteDataSourceProvider);
  return MovieRepository(remote: remote, local: local);
});
