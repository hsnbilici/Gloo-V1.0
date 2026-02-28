import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/daily_puzzle/daily_puzzle_screen.dart';
import '../features/game_screen/game_screen.dart';
import '../features/home_screen/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../game/levels/level_progression.dart';
import '../game/world/game_world.dart';
import '../features/character/character_screen.dart';
import '../features/collection/collection_screen.dart';
import '../features/island/island_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/level_select/level_select_screen.dart';
import '../features/pvp/pvp_lobby_screen.dart';
import '../features/season_pass/season_pass_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shop/shop_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
      // Faz 4: Seviye modu (spesifik rota — genel /game/:mode'dan ONCE olmali)
      GoRoute(
        path: '/game/level/:levelId',
        builder: (context, state) {
          final levelId = int.tryParse(state.pathParameters['levelId'] ?? '1') ?? 1;
          final levelData = LevelProgression.getLevel(levelId);
          return GameScreen(
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
          final seed = int.tryParse(
              state.uri.queryParameters['seed'] ?? '');
          final isBot =
              state.uri.queryParameters['isBot'] == 'true';
          return GameScreen(
            mode: GameMode.duel,
            duelMatchId: matchId,
            duelSeed: seed,
            duelIsBot: isBot,
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
    ],
  );
});
