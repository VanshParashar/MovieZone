// lib/viewmodels/bookmark_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie_model.dart';
import '../data/repositories/movie_repository.dart';
import '../providers.dart';

class BookmarkState {
  final List<MovieModel> bookmarks;
  final bool loading;
  BookmarkState({required this.bookmarks, this.loading = false});
  BookmarkState copyWith({List<MovieModel>? bookmarks, bool? loading}) {
    return BookmarkState(bookmarks: bookmarks ?? this.bookmarks, loading: loading ?? this.loading);
  }
}

class BookmarkViewModel extends StateNotifier<BookmarkState> {
  final MovieRepository repo;
  BookmarkViewModel(this.repo) : super(BookmarkState(bookmarks: [], loading: false)) {
    load();
  }

  Future<void> load() async {
    final list = repo.getBookmarks();
    state = state.copyWith(bookmarks: list, loading: false);
  }

  Future<void> toggleBookmark(int id) async {
    final currently = repo.isBookmarked(id);
    await repo.toggleBookmark(id, !currently);
    load();
  }

  Future<void> setBookmark(int id, bool value) async {
    await repo.setBookmark(id, value);
    load();
  }
}

final bookmarkVMProvider = StateNotifierProvider<BookmarkViewModel, BookmarkState>((ref) {
  final repo = ref.read(movieRepoProvider);
  return BookmarkViewModel(repo);
});
