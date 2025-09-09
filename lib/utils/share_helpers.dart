// example: lib/utils/share_helpers.dart
import 'package:share_plus/share_plus.dart';

String intentLinkFor(int movieId, String packageName) {
  // Android intent URI (works in many Android clients, e.g. WhatsApp)
  return 'intent://movie/$movieId#Intent;scheme=moviesapp;package=$packageName;end';
}

String schemeLinkFor(int movieId) {
  return 'moviesapp://movie/$movieId';
}

String redirectWebLinkFor(int movieId, String webBase) {
  // webBase e.g. https://yourdomain.com/redirect.html
  return '$webBase?movie=$movieId';
}

Future<void> shareIntentLink(int movieId, String packageName, String title) async {
  final link = intentLinkFor(movieId, packageName);
  await Share.share('$title\nOpen in app: $link');
}

Future<void> shareSchemeLink(int movieId, String title) async {
  final link = schemeLinkFor(movieId);
  await Share.share('$title\nOpen in app: $link');
}

Future<void> shareWebRedirect(int movieId, String webBase, String title) async {
  final link = redirectWebLinkFor(movieId, webBase);
  await Share.share('$title\nOpen in app: $link');
}
