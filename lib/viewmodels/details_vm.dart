// lib/viewmodels/details_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie_detail.dart';
import '../data/models/movie_model.dart';
import '../data/repositories/movie_repository.dart';
import '../providers.dart';

class DetailsState {
  final MovieDetail? movie;
  final bool loading;
  final String? error;
  final bool isBookmarked;

  DetailsState({
    this.movie,
    this.loading = false,
    this.error,
    this.isBookmarked = false,
  });

  DetailsState copyWith({
    MovieDetail? movie,
    bool? loading,
    String? error,
    bool? isBookmarked,
  }) {
    return DetailsState(
      movie: movie ?? this.movie,
      loading: loading ?? this.loading,
      error: error,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class DetailsViewModel extends StateNotifier<DetailsState> {
  final MovieRepository repo;
  DetailsViewModel(this.repo) : super(DetailsState());

  /// Improved load:
  /// 1) Try to return cached detail immediately (if present) so UI can show it.
  /// 2) Start remote fetch in background; if it returns, update state and cache.
  /// 3) Only show "not found" when both cache absent AND remote failed.
  Future<void> load(int id, {bool forceRefresh = false}) async {
    state = state.copyWith(loading: true, error: null);

    // 1) immediate cached attempt
    try {
      final cached = repo.getCachedDetail(id);
      if (cached != null && !forceRefresh) {
        // show cached immediately, but still refresh in background
        final bookmarked = repo.isBookmarked(id);
        state = state.copyWith(movie: cached, loading: true, error: null, isBookmarked: bookmarked);
        // continue to remote fetch (fire-and-forget style but update when done)
        _fetchAndUpdate(id, forceRefresh: forceRefresh);
        return;
      }
    } catch (_) {
      // ignore cache read errors; continue to fetch remote
    }

    // 2) no cache (or forced refresh) -> fetch remote and show loader
    try {
      final detail = await repo.getMovieDetail(id, forceRefresh: forceRefresh);
      final bookmarked = repo.isBookmarked(id);
      state = state.copyWith(movie: detail, loading: false, error: null, isBookmarked: bookmarked);
    } catch (e) {
      // remote failed; try cache again (in case race)
      final fallback = repo.getCachedDetail(id);
      if (fallback != null) {
        final bookmarked = repo.isBookmarked(id);
        state = state.copyWith(movie: fallback, loading: false, error: null, isBookmarked: bookmarked);
      } else {
        state = state.copyWith(movie: null, loading: false, error: e.toString(), isBookmarked: repo.isBookmarked(id));
      }
    }
  }

  /// helper: fetch remote and update state if newer
  Future<void> _fetchAndUpdate(int id, {bool forceRefresh = false}) async {
    try {
      final detail = await repo.getMovieDetail(id, forceRefresh: forceRefresh);
      // update state only if different or current movie is null
      if (mounted) {
        final bookmarked = repo.isBookmarked(id);
        state = state.copyWith(movie: detail, loading: false, error: null, isBookmarked: bookmarked);
      }
    } catch (e) {
      // if remote fails, do not overwrite existing cached UI; but if no movie shown, set error
      if (mounted && (state.movie == null)) {
        state = state.copyWith(error: e.toString(), loading: false, isBookmarked: repo.isBookmarked(id));
      }
    }
  }
  /// Toggle bookmark for this movie (persist + update state)
  Future<void> toggleBookmark(int id, bool value) async {
    try {
      // if detailed movie exists, use snapshot to save richer MovieModel into bookmarks
      if (state.movie != null) {
        final d = state.movie!;
        final snapshot = MovieModel(
          id: d.id,
          title: d.title,
          originalTitle: d.originalTitle,
          overview: d.overview,
          posterPath: d.posterPath,
          backdropPath: d.backdropPath,
          releaseDate: d.releaseDate,
          voteAverage: d.voteAverage,
          voteCount: d.voteCount,
          adult: d.adult,
          originalLanguage: d.originalLanguage,
          genreIds: d.genres.map((g) => g.id).toList(),
          popularity: d.popularity,
          video: d.video,
          isBookmarked: value,
        );
        await repo.setBookmark(id, value, snapshot: snapshot);
      } else {
        await repo.setBookmark(id, value);
      }
    } catch (_) {
      // ignore for now
    }

    if (mounted) state = state.copyWith(isBookmarked: value);
  }
}

/// provider family - loads automatically
final detailsVMProvider = StateNotifierProvider.family<DetailsViewModel, DetailsState, int>((ref, id) {
  final repo = ref.read(movieRepoProvider);
  final vm = DetailsViewModel(repo);
  vm.load(id); // auto-start
  return vm;
});
