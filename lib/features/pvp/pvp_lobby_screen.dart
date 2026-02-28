import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/widgets/glow_orb.dart';
import '../../data/remote/pvp_realtime_service.dart';
import '../../data/remote/supabase_client.dart';
import '../../game/pvp/matchmaking.dart';
import '../../providers/user_provider.dart';

// ─── PvP Lobby Ekrani ────────────────────────────────────────────────────────

class PvpLobbyScreen extends ConsumerStatefulWidget {
  const PvpLobbyScreen({super.key});

  @override
  ConsumerState<PvpLobbyScreen> createState() => _PvpLobbyScreenState();
}

class _PvpLobbyScreenState extends ConsumerState<PvpLobbyScreen>
    with SingleTickerProviderStateMixin {
  static const _kAccent = Color(0xFFFF4D6D);
  static const _kGold = Color(0xFFFFD700);

  bool _searching = false;
  int _waitSeconds = 0;
  Timer? _searchTimer;
  late final AnimationController _pulseCtrl;
  late final PvpRealtimeService _realtimeService;

  int _playerElo = 1000;
  EloLeague _league = EloLeague.silver;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _realtimeService = PvpRealtimeService();
    ref.read(localRepositoryProvider.future).then((repo) {
      if (!mounted) return;
      setState(() {
        _playerElo = repo.getElo();
        _league = EloLeagueInfo.fromElo(_playerElo);
      });
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _realtimeService.dispose();
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
    final userId = SupabaseConfig.currentUserId ?? 'local_player';
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
      '&isBot=${result.isBot}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          // Arkaplan
          const _PvpBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Ust bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusMd),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white70, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'PvP DUELLO',
                        style: TextStyle(
                          color: _kAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: _kAccent.withValues(alpha: 0.5),
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
                        _LeagueBadge(
                          elo: _playerElo,
                          league: _league,
                        )
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 400.ms)
                            .scale(
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
                          _SearchingIndicator(
                            waitSeconds: _waitSeconds,
                            pulseCtrl: _pulseCtrl,
                            onCancel: _cancelSearch,
                          )
                        else
                          _MatchButton(onTap: _startSearch)
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
        ],
      ),
    );
  }

  Widget _buildPvpStats() {
    final repoAsync = ref.watch(localRepositoryProvider);
    final wins = repoAsync.valueOrNull?.getPvpWins() ?? 0;
    final losses = repoAsync.valueOrNull?.getPvpLosses() ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatChip(label: 'Galibiyet', value: '$wins', color: const Color(0xFF3CFF8B)),
        const SizedBox(width: 12),
        _StatChip(label: 'Maglubiyet', value: '$losses', color: _kAccent),
        const SizedBox(width: 12),
        _StatChip(
          label: 'Oran',
          value: wins + losses > 0
              ? '${(wins / (wins + losses) * 100).round()}%'
              : '-',
          color: _kGold,
        ),
      ],
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 350.ms);
  }
}

// ─── Lig Rozeti ──────────────────────────────────────────────────────────────

class _LeagueBadge extends StatelessWidget {
  const _LeagueBadge({required this.elo, required this.league});

  final int elo;
  final EloLeague league;

  Color get _leagueColor => switch (league) {
        EloLeague.bronze     => const Color(0xFFCD7F32),
        EloLeague.silver     => const Color(0xFFC0C0C0),
        EloLeague.gold       => const Color(0xFFFFD700),
        EloLeague.diamond    => const Color(0xFF00BFFF),
        EloLeague.glooMaster => const Color(0xFFFF3CFF),
      };

  IconData get _leagueIcon => switch (league) {
        EloLeague.bronze     => Icons.shield_rounded,
        EloLeague.silver     => Icons.shield_rounded,
        EloLeague.gold       => Icons.shield_rounded,
        EloLeague.diamond    => Icons.diamond_rounded,
        EloLeague.glooMaster => Icons.stars_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = _leagueColor;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.50), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(_leagueIcon, color: color, size: 36),
        ),
        const SizedBox(height: 12),
        Text(
          league.displayName,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$elo ELO',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Istatistik chip ────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Eslestirme Ara butonu ──────────────────────────────────────────────────

class _MatchButton extends StatefulWidget {
  const _MatchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MatchButton> createState() => _MatchButtonState();
}

class _MatchButtonState extends State<_MatchButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFFF4D6D);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.diagonal3Values(
            _pressed ? 0.96 : 1.0, _pressed ? 0.96 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.20),
              color.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusXl),
          border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_mma_rounded, color: color, size: 22),
            SizedBox(width: 10),
            Text(
              'Eslestirme Ara',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Eslestirme bekleme gostergesi ──────────────────────────────────────────

class _SearchingIndicator extends StatelessWidget {
  const _SearchingIndicator({
    required this.waitSeconds,
    required this.pulseCtrl,
    required this.onCancel,
  });

  final int waitSeconds;
  final AnimationController pulseCtrl;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFFF4D6D);
    return Column(
      children: [
        // Donen halka / pulse
        AnimatedBuilder(
          animation: pulseCtrl,
          builder: (_, __) {
            final scale = 1.0 + pulseCtrl.value * 0.15;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.5 + pulseCtrl.value * 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15 + pulseCtrl.value * 0.15),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: color,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Rakip araniyor...',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${waitSeconds}sn / ${MatchmakingManager.maxWaitSeconds}sn',
          style: const TextStyle(
            color: kMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onCancel,
          child: Text(
            'Iptal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Arkaplan ───────────────────────────────────────────────────────────────

class _PvpBackground extends StatelessWidget {
  const _PvpBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -120,
          left: -80,
          child: GlowOrb(
            size: 360,
            color: Color(0xFFFF4D6D),
            opacity: 0.08,
          ),
        ),
        const Positioned(
          bottom: -100,
          right: -60,
          child: GlowOrb(
            size: 280,
            color: Color(0xFFFFD700),
            opacity: 0.06,
          ),
        ),
      ],
    );
  }
}
