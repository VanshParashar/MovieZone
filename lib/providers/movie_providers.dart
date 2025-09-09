// lib/providers/movie_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the movieId received from a deep link (or null).
/// When a non-null int is set, listeners can react and navigate.
final deepLinkProvider = StateProvider<int?>((ref) => null);
