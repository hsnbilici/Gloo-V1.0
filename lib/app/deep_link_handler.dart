import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Handles incoming deep links and routes them via GoRouter.
///
/// Supported URL patterns:
///   https://gloogame.com/share/daily             → /daily
///   https://gloogame.com/share/daily?date=...    → /daily
///   https://gloogame.com/share/duel?id=<matchId> → /pvp-lobby?invite=<matchId>
///   any other gloogame.com URL                   → / (HomeScreen)
class DeepLinkHandler {
  static const _host = 'gloogame.com';

  final AppLinks _appLinks;

  DeepLinkHandler({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  /// Initialises deep link listening.
  ///
  /// Call once after [GoRouter] is ready (e.g. inside [GlooApp.build] or
  /// just after [runApp]). Returns the subscription so the caller can cancel
  /// it on dispose if needed.
  void listen(GoRouter router) {
    // Handle the link that launched the app cold (if any).
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _navigate(router, uri);
    }).catchError((Object e) {
      if (kDebugMode) debugPrint('DeepLinkHandler.getInitialLink error: $e');
    });

    // Handle links arriving while the app is already running.
    _appLinks.uriLinkStream.listen(
      (uri) => _navigate(router, uri),
      onError: (Object e) {
        if (kDebugMode) debugPrint('DeepLinkHandler.uriLinkStream error: $e');
      },
    );
  }

  void _navigate(GoRouter router, Uri uri) {
    final path = resolve(uri);
    if (path != null) {
      if (kDebugMode) debugPrint('DeepLinkHandler: $uri → $path');
      router.go(path);
    }
  }

  /// Parses [uri] and returns the matching GoRouter path, or null if the
  /// URI host does not belong to this app.
  ///
  /// Exposed as a static method so it can be unit-tested without I/O.
  static String? resolve(Uri uri) {
    if (uri.host != _host) return null;

    final segments = uri.pathSegments;

    // /friend/<code> → arkadaş ekleme
    if (segments.isNotEmpty && segments[0] == 'friend' && segments.length >= 2) {
      return '/friend/${segments[1]}';
    }

    // /share/<type>[?params]
    if (segments.isNotEmpty && segments[0] == 'share') {
      if (segments.length >= 2) {
        final type = segments[1];
        if (type == 'daily') return '/daily';
        if (type == 'duel') {
          final matchId = uri.queryParameters['id'];
          if (matchId != null && matchId.isNotEmpty) {
            return '/pvp-lobby?invite=$matchId';
          }
          return '/pvp-lobby';
        }
      }
    }

    // Fallback → HomeScreen
    return '/';
  }
}
