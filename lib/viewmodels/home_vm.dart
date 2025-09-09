// lib/viewmodels/home_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie_model.dart';
import '../data/repositories/movie_repository.dart';
import '../providers.dart';

class HomeState {
  final List<MovieModel> trending;
  final List<MovieModel> nowPlaying;
  final bool loading;
  final String? error;

  HomeState({
    required this.trending,
    required this.nowPlaying,
    this.loading = false,
    this.error,
  });

  HomeState copyWith({
    List<MovieModel>? trending,
    List<MovieModel>? nowPlaying,
    bool? loading,
    String? error,
  }) {
    return HomeState(
      trending: trending ?? this.trending,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final MovieRepository repo;
  HomeViewModel(this.repo) : super(HomeState(trending: [], nowPlaying: [], loading: false));

  /// Load cached then remote trending & now playing
  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);

    // show cached immediately if available
    final cachedTrending = repo.getCachedTrending();
    final cachedNow = repo.getCachedNowPlaying();
    if (cachedTrending.isNotEmpty || cachedNow.isNotEmpty) {
      state = state.copyWith(trending: cachedTrending, nowPlaying: cachedNow, loading: true);
    }

    try {
      final results = await Future.wait([
        repo.getTrending(forceRefresh: true),
        repo.getNowPlaying(forceRefresh: true),
      ]);
      state = state.copyWith(trending: results[0], nowPlaying: results[1], loading: false);
    } catch (e) {
      // keep cached results but expose error
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Utility: refresh data explicitly
  Future<void> refresh() async {
    await load();
  }
  /// Toggle bookmark (UI calls this). Updates repo and then in-memory lists so UI reflects immediately.
  Future<void> toggleBookmark(int id, [bool? forceValue]) async {
    // find snapshot in current lists
    MovieModel? snapshot;
    bool current = false;

    final tIdx = state.trending.indexWhere((m) => m.id == id);
    if (tIdx != -1) {
      snapshot = state.trending[tIdx];
      current = snapshot.isBookmarked;
    } else {
      final nIdx = state.nowPlaying.indexWhere((m) => m.id == id);
      if (nIdx != -1) {
        snapshot = state.nowPlaying[nIdx];
        current = snapshot.isBookmarked;
      } else {
        // fallback to repo's bookmark status
        current = repo.isBookmarked(id);
      }
    }

    final newVal = forceValue ?? !current;

    // persist change
    await repo.setBookmark(id, newVal, snapshot: snapshot);

    // update in-memory lists for immediate UI update
    final newTrending = state.trending.map((m) {
      if (m.id == id) m.isBookmarked = newVal;
      return m;
    }).toList();

    final newNow = state.nowPlaying.map((m) {
      if (m.id == id) m.isBookmarked = newVal;
      return m;
    }).toList();

    state = state.copyWith(trending: newTrending, nowPlaying: newNow);
  }
}

/// Provider (keep your existing provider pattern)
final homeVMProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repo = ref.read(movieRepoProvider);
  final vm = HomeViewModel(repo);
  vm.load();
  return vm;
});
