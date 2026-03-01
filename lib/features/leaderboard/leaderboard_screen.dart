import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/glow_orb.dart';
import '../../data/remote/dto/leaderboard_entry.dart';
import '../../data/remote/remote_repository.dart';
import '../../providers/locale_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = RemoteRepository();

  bool _weekly = true;
  bool _loading = true;
  List<LeaderboardEntry> _scores = [];
  int? _userRank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _fetchData();
    });
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentMode =>
      _tabController.index == 0 ? 'classic' : 'timetrial';

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _repo.getGlobalLeaderboard(mode: _currentMode, weekly: _weekly),
      _repo.getUserRank(mode: _currentMode, weekly: _weekly),
    ]);
    if (!mounted) return;
    setState(() {
      _scores = results[0] as List<LeaderboardEntry>;
      _userRank = results[1] as int?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          label: 'Geri',
          button: true,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
        title: Text(
          l.leaderboardTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Stack(
        children: [
          const _LeaderboardBackground(),
          Column(
            children: [
              const SizedBox(height: 8),
              // Mod sekmeleri
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ModeTabs(
                  controller: _tabController,
                  classicLabel: l.leaderboardTabClassic,
                  timeTrialLabel: l.leaderboardTabTimeTrial,
                ),
              ),
              const SizedBox(height: 12),
              // Haftalık / Tüm zamanlar filtresi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _FilterRow(
                  weeklyLabel: l.leaderboardFilterWeekly,
                  allTimeLabel: l.leaderboardFilterAllTime,
                  isWeekly: _weekly,
                  onChanged: (weekly) {
                    setState(() => _weekly = weekly);
                    _fetchData();
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Kullanıcı sırası
              if (_userRank != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _UserRankBanner(
                      rank: _userRank!, label: l.leaderboardYourRank),
                ),
              const SizedBox(height: 8),
              // Skor listesi
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: kCyan, strokeWidth: 2),
                      )
                    : _scores.isEmpty
                        ? Center(
                            child: Text(
                              l.leaderboardEmpty,
                              style:
                                  const TextStyle(color: kMuted, fontSize: 14),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _scores.length,
                            itemBuilder: (context, index) {
                              final entry = _scores[index];
                              final rank = index + 1;
                              return _ScoreRow(
                                rank: rank,
                                username: entry.username,
                                score: entry.score,
                              )
                                  .animate(delay: (40 * index).ms)
                                  .fadeIn(duration: 250.ms)
                                  .slideX(
                                    begin: 0.05,
                                    end: 0,
                                    duration: 250.ms,
                                    curve: Curves.easeOutCubic,
                                  );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Arkaplan ─────────────────────────────────────────────────────────────────

class _LeaderboardBackground extends StatelessWidget {
  const _LeaderboardBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -100,
          left: -60,
          child: GlowOrb(size: 280, color: kColorClassic, opacity: 0.06),
        ),
        const Positioned(
          bottom: -80,
          right: -50,
          child: GlowOrb(size: 240, color: kCyan, opacity: 0.05),
        ),
      ],
    );
  }
}

// ─── Mod sekmeleri ────────────────────────────────────────────────────────────

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({
    required this.controller,
    required this.classicLabel,
    required this.timeTrialLabel,
  });

  final TabController controller;
  final String classicLabel;
  final String timeTrialLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: kCyan.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(color: kCyan.withValues(alpha: 0.40)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelColor: kCyan,
        unselectedLabelColor: kMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: classicLabel),
          Tab(text: timeTrialLabel),
        ],
      ),
    );
  }
}

// ─── Filtre satırı ────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.weeklyLabel,
    required this.allTimeLabel,
    required this.isWeekly,
    required this.onChanged,
  });

  final String weeklyLabel;
  final String allTimeLabel;
  final bool isWeekly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: weeklyLabel,
          isSelected: isWeekly,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: allTimeLabel,
          isSelected: !isWeekly,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? kCyan.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusSm),
          border: Border.all(
            color: isSelected
                ? kCyan.withValues(alpha: 0.40)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kCyan : kMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Kullanıcı sırası banner'ı ───────────────────────────────────────────────

class _UserRankBanner extends StatelessWidget {
  const _UserRankBanner({required this.rank, required this.label});

  final int rank;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kCyan.withValues(alpha: 0.10),
            kCyan.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(color: kCyan.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kCyan.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: kCyan.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: kCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skor satırı ──────────────────────────────────────────────────────────────

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.rank,
    required this.username,
    required this.score,
  });

  final int rank;
  final String username;
  final int score;

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return kMuted;
  }

  IconData? get _rankIcon {
    if (rank <= 3) return Icons.emoji_events_rounded;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: rank <= 3
            ? _rankColor.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(
          color: rank <= 3
              ? _rankColor.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: _rankIcon != null
                ? Icon(_rankIcon, color: _rankColor, size: 18)
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                color: rank <= 3
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.80),
                fontSize: 14,
                fontWeight: rank <= 3 ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatScore(score),
            style: TextStyle(
              color: rank <= 3 ? _rankColor : kMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}
