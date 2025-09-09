// lib/viewmodels/search_vm.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie_model.dart';
import '../data/repositories/movie_repository.dart';
import '../providers.dart';

class SearchState {
  final List<MovieModel> results;
  final bool loading;
  final String? error;
  final String query;

  SearchState({
    required this.results,
    this.loading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    List<MovieModel>? results,
    bool? loading,
    String? error,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      loading: loading ?? this.loading,
      error: error,
      query: query ?? this.query,
    );
  }
}

class SearchViewModel extends StateNotifier<SearchState> {
  final MovieRepository repo;
  Timer? _debounce;

  SearchViewModel(this.repo) : super(SearchState(results: []));

  /// Call when the query text changes in the TextField.
  /// This method debounces the input and triggers `search` after 300ms
  /// of inactivity. Use this for live-search behavior.
  void onQueryChanged(String q) {
    final query = q.trim();
    // update immediate query in state so UI can reflect current text/search term
    state = state.copyWith(query: query);

    // cancel previous debounce timer
    _debounce?.cancel();

    if (query.isEmpty) {
      // clear results if field cleared
      state = state.copyWith(results: [], loading: false, error: null);
      return;
    }

    // start debounce timer
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // call search (this will update state.loading etc)
      search(query);
    });
  }

  /// Explicit search call (used for submit button, or manual triggering).
  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      state = state.copyWith(results: [], loading: false, error: null);
      return;
    }

    state = state.copyWith(loading: true, error: null, query: q);

    // show cached results instantly if any
    final cached = repo.getCachedSearchResults(q);
    if (cached.isNotEmpty) {
      state = state.copyWith(results: cached, loading: true);
    }

    try {
      final results = await repo.searchMovies(q);
      state = state.copyWith(results: results, loading: false, error: null);
    } catch (e) {
      final fallback = repo.getCachedSearchResults(q);
      state = state.copyWith(results: fallback, loading: false, error: e.toString());
    }
  }

  /// Optional: clear current query & results (used by UI clear button)
  void clear() {
    _debounce?.cancel();
    state = state.copyWith(query: '', results: [], loading: false, error: null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// Provider
final searchVMProvider = StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  final repo = ref.read(movieRepoProvider);
  return SearchViewModel(repo);
});
