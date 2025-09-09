// lib/services/deep_link_service.dart
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_providers.dart';

class DeepLinkService {
  static const MethodChannel _channel = MethodChannel('deep_link_channel');

  /// Initialize once with a WidgetRef. This installs a platform method handler.
  static void initialize(WidgetRef ref) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'handleDeepLink') {
        final String? link = call.arguments as String?;
        if (link != null) {
          _handleDeepLink(ref, link);
        }
      }
    });
  }

  static void _handleDeepLink(WidgetRef ref, String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    // Accept either custom scheme (moviesapp://movie/123) or https host (/movie/123)
    if ((uri.scheme == 'moviesapp' || uri.scheme.startsWith('http')) && uri.pathSegments.isNotEmpty) {
      final seg0 = uri.pathSegments[0];
      if (seg0 == 'movie' && uri.pathSegments.length > 1) {
        final movieIdStr = uri.pathSegments[1];
        final movieId = int.tryParse(movieIdStr);
        if (movieId != null) {
          ref.read(deepLinkProvider.notifier).state = movieId;
        }
      }
    }
  }

  /// Simulate deep link for demo (call from UI code)
  static void simulateDeepLink(WidgetRef ref, int movieId) {
    ref.read(deepLinkProvider.notifier).state = movieId;
  }
}
