import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../shared/glow_orb.dart';
import '../../game/pvp/matchmaking.dart';
import '../../providers/locale_provider.dart';
import '../../data/remote/pvp_realtime_service.dart';
import '../../providers/pvp_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import 'pvp_lobby_matchmaking.dart';
import 'pvp_lobby_widgets.dart';

// ─── PvP Lobby Ekrani ────────────────────────────────────────────────────────

class PvpLobbyScreen extends ConsumerStatefulWidget {
  const PvpLobbyScreen({super.key});

  @override
  ConsumerState<PvpLobbyScreen> createState() => _PvpLobbyScreenState();
}

class _PvpLobbyScreenState extends ConsumerState<PvpLobbyScreen>
    with SingleTickerProviderStateMixin {
  bool _searching = false;
  int _waitSeconds = 0;
  Timer? _searchTimer;
  late final AnimationController _pulseCtrl;
  late final PvpRealtimeService _realtimeService;

  int _playerElo = 1000;
  EloLeague _league = EloLeague.silver;
  int _pvpWins = 0;
  int _pvpLosses = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _realtimeService = ref.read(pvpRealtimeServiceProvider);
    ref.read(localRepositoryProvider.future).then((repo) async {
      if (!mounted) return;
      final elo = await repo.getElo();
      final wins = await repo.getPvpWins();
      final losses = await repo.getPvpLosses();
      if (!mounted) return;
      setState(() {
        _playerElo = elo;
        _league = EloLeagueInfo.fromElo(_playerElo);
        _pvpWins = wins;
        _pvpLosses = losses;
      });
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _searching = true;
      _waitSeconds = 0;
    });
    _pulseCtrl.repeat(reverse: true);

    // UI sayaci
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _waitSeconds++);
    });

    // Supabase Realtime eslestirme kuyruguna katil
    final userId = ref.read(currentUserIdProvider) ?? 'local_player';
    final request = MatchRequest(
      userId: userId,
      elo: _playerElo,
      region: 'global',
      timestamp: DateTime.now(),
    );

    _realtimeService.joinMatchmakingQueue(
      request: request,
      onMatch: (result) {
        if (!mounted) return;
        _onMatchFound(result: result);
      },
    );
  }

  void _cancelSearch() {
    _searchTimer?.cancel();
    _realtimeService.cancelMatchmaking();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    setState(() => _searching = false);
  }

  void _onMatchFound({required MatchResult result}) {
    _searchTimer?.cancel();
    _pulseCtrl.stop();
    // matchId ve seed bilgisini query parametreleri ile ilet
    context.go(
      '/game/duel?matchId=${result.matchId}'
      '&seed=${result.seed}'
      '&isBot=${result.isBot}'
      '&opponentElo=${result.opponentElo ?? ''}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final surfaceColor = resolveColor(brightness, dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness, dark: Colors.white.withValues(alpha: 0.10), light: kCardBorderLight);
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Arkaplan
          const _PvpBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsiveMaxWidth(screenWidth)),
                child: Column(
              children: [
                const SizedBox(height: 12),
                // Ust bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Row(
                    children: [
                      Semantics(
                        label: 'Geri',
                        button: true,
                        child: GestureDetector(
                          onTap: () => context.go('/'),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius:
                                  BorderRadius.circular(UIConstants.radiusMd),
                              border: Border.all(color: borderColor),
                            ),
                            child: Icon(directionalBackIcon(dir),
                                color: kColorClassic, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'PvP DUELLO',
                        style: TextStyle(
                          color: kColorClassic,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: kColorClassic.withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0, duration: 300.ms),
                // Merkez icerik
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Lig rozeti
                        LeagueBadge(
                          elo: _playerElo,
                          league: _league,
                        ).animate(delay: 100.ms).fadeIn(duration: 400.ms).scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 32),
                        // PvP kayit
                        _buildPvpStats(),
                        const SizedBox(height: 40),
                        // Eslestirme butonu / bekleme
                        if (_searching)
                          SearchingIndicator(
                            waitSeconds: _waitSeconds,
                            pulseCtrl: _pulseCtrl,
                            onCancel: _cancelSearch,
                            cancelLabel: ref.watch(stringsProvider).cancelLabel,
                          )
                        else
                          MatchButton(onTap: _startSearch)
                              .animate(delay: 300.ms)
                              .fadeIn(duration: 350.ms)
                              .slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPvpStats() {
    final l = ref.watch(stringsProvider);
    final wins = _pvpWins;
    final losses = _pvpLosses;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PvpStatChip(label: l.pvpWinLabel, value: '$wins', color: kGreen),
        const SizedBox(width: 12),
        PvpStatChip(
            label: l.pvpLossLabel, value: '$losses', color: kColorClassic),
        const SizedBox(width: 12),
        PvpStatChip(
          label: l.pvpRatioLabel,
          value: wins + losses > 0
              ? '${(wins / (wins + losses) * 100).round()}%'
              : '-',
          color: kGold,
        ),
      ],
    ).animate(delay: 200.ms).fadeIn(duration: 350.ms);
  }
}

// ─── Arkaplan ────────────────────────────────────────────────────────────────

class _PvpBackground extends StatelessWidget {
  const _PvpBackground();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    return Stack(
      children: [
        Container(color: bgColor),
        const Positioned(
          top: -120,
          left: -80,
          child: GlowOrb(
            size: 360,
            color: kColorClassic,
            opacity: 0.08,
          ),
        ),
        const Positioned(
          bottom: -100,
          right: -60,
          child: GlowOrb(
            size: 280,
            color: kGold,
            opacity: 0.06,
          ),
        ),
      ],
    );
  }
}
