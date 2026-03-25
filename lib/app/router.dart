import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/daily_puzzle/daily_puzzle_screen.dart';
import '../features/game_screen/game_screen.dart';
import '../features/home_screen/home_screen.dart';
import '../features/loading/loading_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../game/levels/level_progression.dart';
import '../core/models/game_mode.dart';
import '../features/character/character_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/profile/my_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/collection/collection_screen.dart';
import '../features/island/island_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/level_select/level_select_screen.dart';
import '../features/pvp/pvp_lobby_screen.dart';
import '../features/season_pass/season_pass_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shop/shop_screen.dart';
import '../audio/audio_manager.dart';
import '../core/constants/audio_constants.dart';

/// Route geçişlerinde hafif swoosh sesi çalan observer.
class _SoundNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      AudioManager().playSfx(AudioPaths.undoWhoosh, pitchVariation: false, volume: 0.4);
    }
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/loading',
    observers: [_SoundNavigatorObserver()],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '404',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => GoRouter.of(context).go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Faz 4: Seviye secim ekrani
      GoRoute(
        path: '/levels',
        builder: (context, state) => const LevelSelectScreen(),
      ),
      // Faz 4: PvP Lobby ekrani
      GoRoute(
        path: '/pvp-lobby',
        builder: (context, state) => const PvpLobbyScreen(),
      ),
      // CD.27c: Challenge modu (spesifik rota — genel /game/:mode'dan ONCE olmali)
      GoRoute(
        path: '/game/challenge',
        builder: (context, state) {
          final challengeId = state.uri.queryParameters['challengeId'] ?? '';
          final mode = state.uri.queryParameters['mode'] ?? 'classic';
          final seed =
              int.tryParse(state.uri.queryParameters['seed'] ?? '');
          return GameScreen(
            key: ValueKey('challenge_$challengeId'),
            mode: GameMode.fromString(mode),
            challengeId: challengeId.isNotEmpty ? challengeId : null,
            challengeSeed: seed,
          );
        },
      ),
      // Faz 4: Seviye modu (spesifik rota — genel /game/:mode'dan ONCE olmali)
      GoRoute(
        path: '/game/level/:levelId',
        builder: (context, state) {
          final levelId =
              int.tryParse(state.pathParameters['levelId'] ?? '1') ?? 1;
          final levelData = LevelProgression.getLevel(levelId);
          return GameScreen(
            key: ValueKey('level_$levelId'),
            mode: GameMode.level,
            levelData: levelData,
          );
        },
      ),
      // Faz 4: PvP Düello modu (spesifik rota — genel /game/:mode'dan ONCE olmali)
      GoRoute(
        path: '/game/duel',
        builder: (context, state) {
          final matchId = state.uri.queryParameters['matchId'];
          final seed = int.tryParse(state.uri.queryParameters['seed'] ?? '');
          final isBot = state.uri.queryParameters['isBot'] == 'true';
          final opponentElo =
              int.tryParse(state.uri.queryParameters['opponentElo'] ?? '');
          return GameScreen(
            mode: GameMode.duel,
            duelMatchId: matchId,
            duelSeed: seed,
            duelIsBot: isBot,
            duelOpponentElo: opponentElo,
          );
        },
      ),
      GoRoute(
        path: '/game/:mode',
        builder: (context, state) {
          final mode = state.pathParameters['mode'] ?? 'classic';
          return GameScreen(mode: GameMode.fromString(mode));
        },
      ),
      GoRoute(
        path: '/daily',
        builder: (context, state) => const DailyPuzzleScreen(),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/collection',
        builder: (context, state) => const CollectionScreen(),
      ),
      // Faz 4: Meta-game ekranlari
      GoRoute(
        path: '/island',
        builder: (context, state) => const IslandScreen(),
      ),
      GoRoute(
        path: '/character',
        builder: (context, state) => const CharacterScreen(),
      ),
      GoRoute(
        path: '/season-pass',
        builder: (context, state) => const SeasonPassScreen(),
      ),
      // CD.27: Arkadaş sistemi
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/friend/:code',
        builder: (context, state) {
          final code = state.pathParameters['code'] ?? '';
          return FriendsScreen(initialCode: code);
        },
      ),
      // CD.27c: Challenge deep link ve liste
      GoRoute(
        path: '/challenge/:challengeId',
        builder: (context, state) {
          // Will pass initialChallengeId to FriendsScreen in Task 9
          return const FriendsScreen();
        },
      ),
      GoRoute(
        path: '/challenges',
        builder: (context, state) => const FriendsScreen(),
      ),
      // CD.27b: Profil ekranları
      GoRoute(
        path: '/my-profile',
        builder: (context, state) => const MyProfileScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return ProfileScreen(userId: userId);
        },
      ),
    ],
  );
});
