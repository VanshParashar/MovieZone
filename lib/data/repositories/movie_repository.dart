// lib/data/repositories/movie_repository.dart
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import '../data_sources/local_data_source.dart';
import '../data_sources/remote_data_source.dart';
import '../models/movie_model.dart';
import '../models/movie_detail.dart';

class MovieRepository {
  final RemoteDataSource remote;
  final LocalDataSource local;

  MovieRepository({required this.remote, required this.local});

  // TRENDING
  Future<List<MovieModel>> getTrending({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = local.getCachedTrending();
      if (cached.isNotEmpty) return cached;
    }
    try {
      final list = await remote.getTrending();
      await local.saveTrending(list);
      return list;
    } catch (e) {
      final cached = local.getCachedTrending();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  List<MovieModel> getCachedTrending() => local.getCachedTrending();

  // NOW PLAYING
  Future<List<MovieModel>> getNowPlaying({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = local.getCachedNowPlaying();
      if (cached.isNotEmpty) return cached;
    }
    try {
      final list = await remote.getNowPlaying();
      await local.saveNowPlaying(list);
      return list;
    } catch (e) {
      final cached = local.getCachedNowPlaying();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  List<MovieModel> getCachedNowPlaying() => local.getCachedNowPlaying();

  // SEARCH
  Future<List<MovieModel>> searchMovies(String query) async {
    final cached = local.getCachedSearchResults(query);
    // try remote nevertheless
    try {
      final results = await remote.searchMovies(query);
      await local.saveSearchResults(query, results);
      return results;
    } catch (e) {
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  List<MovieModel> getCachedSearchResults(String query) => local.getCachedSearchResults(query);

  // DETAILS
  Future<MovieDetail> getMovieDetail(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = local.getCachedMovieDetail(id);
      if (cached != null) return cached;
    }

    try {
      final detail = await remote.getMovieDetail(id);
      await local.saveMovieDetail(detail);
      return detail;
    } catch (e) {
      final cached = local.getCachedMovieDetail(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  MovieDetail? getCachedDetail(int id) => local.getCachedMovieDetail(id);

  // inside MovieRepository class

  // --- Bookmark handling: unified, simple & synchronous-ish ---
  /// Set bookmark value for movie id.
  /// If `snapshot` is provided (a MovieModel from lists), it will be stored in bookmarksBox.
  /// If snapshot is null, repo will try cached lists, and if not found will create a minimal MovieModel.
  Future<void> setBookmark(int movieId, bool value, {MovieModel? snapshot}) async {
    if (value) {
      // save
      MovieModel? model = snapshot;

      // try find in cached lists if no snapshot provided
      if (model == null) {
        final t = getCachedTrending();
        final idxT = t.indexWhere((m) => m.id == movieId);
        if (idxT != -1) model = t[idxT];
      }
      if (model == null) {
        final n = getCachedNowPlaying();
        final idxN = n.indexWhere((m) => m.id == movieId);
        if (idxN != -1) model = n[idxN];
      }

      // best effort: if still null, try to build from detail (network)
      if (model == null) {
        try {
          final detail = await getMovieDetail(movieId);
          model = MovieModel(
            id: detail.id,
            title: detail.title,
            originalTitle: detail.originalTitle,
            overview: detail.overview,
            posterPath: detail.posterPath,
            backdropPath: detail.backdropPath,
            releaseDate: detail.releaseDate,
            voteAverage: detail.voteAverage,
            voteCount: detail.voteCount,
            adult: detail.adult,
            originalLanguage: detail.originalLanguage,
            genreIds: detail.genres.map((g) => g.id).toList(),
            popularity: detail.popularity,
            video: detail.video,
            isBookmarked: true,
          );
        } catch (_) {
          // network failed -> create minimal placeholder
          model = MovieModel(
            id: movieId,
            title: 'Unknown',
            originalTitle: null,
            overview: null,
            posterPath: null,
            backdropPath: null,
            releaseDate: null,
            voteAverage: null,
            voteCount: null,
            adult: false,
            originalLanguage: null,
            genreIds: const [],
            popularity: null,
            video: null,
            isBookmarked: true,
          );
        }
      } else {
        model.isBookmarked = true;
      }

      // persist to bookmarks box
      await local.saveBookmark(model);

      // also update cached lists entries (if present)
      await local.updateTrendingItem(model);
      await local.updateNowPlayingItem(model);

    } else {
      // remove bookmark
      await local.removeBookmark(movieId);

      // update cached lists entries if present: set isBookmarked=false
      final trending = getCachedTrending();
      final idxT = trending.indexWhere((m) => m.id == movieId);
      if (idxT != -1) {
        final m = trending[idxT];
        m.isBookmarked = false;
        await local.updateTrendingItem(m);
      }
      final now = getCachedNowPlaying();
      final idxN = now.indexWhere((m) => m.id == movieId);
      if (idxN != -1) {
        final m = now[idxN];
        m.isBookmarked = false;
        await local.updateNowPlayingItem(m);
      }
    }
  }
  List<MovieModel> getBookmarks() => local.getBookmarks();
  bool isBookmarked(int id) => local.isBookmarked(id);

  /// Convenience toggle wrapper (keeps compatibility with older code)
  Future<void> toggleBookmark(int movieId, bool value, {MovieModel? snapshot}) => setBookmark(movieId, value, snapshot: snapshot);
}
