// lib/data/local/local_data_source.dart
import 'package:hive/hive.dart';
import '../models/movie_model.dart';
import '../models/movie_detail.dart';

class LocalDataSource {
  static const trendingBoxName = 'trendingBox';
  static const nowPlayingBoxName = 'nowPlayingBox';
  static const searchBoxName = 'searchBox';
  static const detailsBoxName = 'movieDetailsBox';
  static const bookmarksBoxName = 'bookmarksBox';

  // TRENDING
  Box<MovieModel> get _trendingBox => Hive.box<MovieModel>(trendingBoxName);
  Future<void> saveTrending(List<MovieModel> movies) async {
    // replace existing trending data
    await _trendingBox.clear();
    for (final m in movies) {
      await _trendingBox.put(m.id, m);
    }
  }
  List<MovieModel> getCachedTrending() => _trendingBox.values.toList();
  Future<void> clearTrending() async => await _trendingBox.clear();

  // NOW PLAYING
  Box<MovieModel> get _nowPlayingBox => Hive.box<MovieModel>(nowPlayingBoxName);
  Future<void> saveNowPlaying(List<MovieModel> movies) async {
    await _nowPlayingBox.clear();
    for (final m in movies) {
      await _nowPlayingBox.put(m.id, m);
    }
  }
  List<MovieModel> getCachedNowPlaying() => _nowPlayingBox.values.toList();
  Future<void> clearNowPlaying() async => await _nowPlayingBox.clear();

  // SEARCH: store list under query key (store JSON list)
  Box<List> get _searchBox => Hive.box<List>(searchBoxName);
  Future<void> saveSearchResults(String query, List<MovieModel> movies) async {
    final key = query.trim().toLowerCase();
    final jsonList = movies.map((m) => m.toJson()).toList();
    await _searchBox.put(key, jsonList);
  }
  List<MovieModel> getCachedSearchResults(String query) {
    final key = query.trim().toLowerCase();
    final stored = _searchBox.get(key);
    if (stored == null) return [];
    return stored.map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  Future<void> clearSearchCacheForQuery(String query) async {
    await _searchBox.delete(query.trim().toLowerCase());
  }
  Future<void> clearAllSearchCache() async => await _searchBox.clear();

  // MOVIE DETAILS
  Box<MovieDetail> get _detailsBox => Hive.box<MovieDetail>(detailsBoxName);
  Future<void> saveMovieDetail(MovieDetail detail) async {
    await _detailsBox.put(detail.id, detail);
  }
  MovieDetail? getCachedMovieDetail(int id) => _detailsBox.get(id);
  Future<void> clearMovieDetail(int id) async => await _detailsBox.delete(id);
  Future<void> clearAllDetails() async => await _detailsBox.clear();

  // BOOKMARKS (store MovieModel entries keyed by id)
  Box<MovieModel> get _bookmarksBox => Hive.box<MovieModel>(bookmarksBoxName);
  Future<void> saveBookmark(MovieModel m) async {
    await _bookmarksBox.put(m.id, m);
  }
  Future<void> removeBookmark(int id) async {
    await _bookmarksBox.delete(id);
  }
  List<MovieModel> getBookmarks() => _bookmarksBox.values.toList();
  bool isBookmarked(int id) => _bookmarksBox.containsKey(id);

  // Helper - update a single MovieModel inside trending/nowPlaying if present
  Future<void> updateTrendingItem(MovieModel updated) async {
    if (_trendingBox.containsKey(updated.id)) {
      await _trendingBox.put(updated.id, updated);
    }
  }
  Future<void> updateNowPlayingItem(MovieModel updated) async {
    if (_nowPlayingBox.containsKey(updated.id)) {
      await _nowPlayingBox.put(updated.id, updated);
    }
  }
}
