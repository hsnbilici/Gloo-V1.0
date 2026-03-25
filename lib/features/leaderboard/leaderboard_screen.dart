import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/models/game_mode.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/remote/dto/leaderboard_entry.dart';
import '../../providers/locale_provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/pvp_provider.dart';
import '../../providers/service_providers.dart';
import 'leaderboard_background.dart';
import 'leaderboard_widgets.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _weekly = true;
  bool _loading = true;
  List<LeaderboardEntry> _scores = [];
  int? _userRank;
  int? _userScore;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  bool get _isPvpTab => _tabController.index == 2;
  bool get _isFriendsTab => _tabController.index == 3;

  String get _currentMode => switch (_tabController.index) {
        0 => GameMode.classic.name,
        1 => GameMode.timeTrial.name,
        2 => 'pvp',
        _ => GameMode.classic.name, // friends tab default mode
      };

  String _friendsMode = GameMode.classic.name;

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      if (_isFriendsTab) {
        final repo = ref.read(friendRepositoryProvider);
        final scores = await repo.getFriendsLeaderboard(
            mode: _friendsMode, weekly: _weekly);
        if (!mounted) return;
        setState(() {
          _scores = scores;
          _userRank = null;
          _userScore = null;
          _loading = false;
        });
        return;
      }
      if (_isPvpTab) {
        final scores =
            await ref.read(remoteRepositoryProvider).getEloLeaderboard();
        if (!mounted) return;
        final userId = ref.read(currentUserIdProvider);
        int? pvpRank;
        int? pvpScore;
        if (userId != null) {
          final idx = scores.indexWhere((e) => e.userId == userId);
          if (idx >= 0) {
            pvpRank = idx + 1;
            pvpScore = scores[idx].score;
          }
        }
        setState(() {
          _scores = scores;
          _userRank = pvpRank;
          _userScore = pvpScore;
          _loading = false;
        });
      } else {
        final results = await Future.wait([
          ref
              .read(remoteRepositoryProvider)
              .getGlobalLeaderboard(mode: _currentMode, weekly: _weekly),
          ref
              .read(remoteRepositoryProvider)
              .getUserRank(mode: _currentMode, weekly: _weekly),
        ]);
        if (!mounted) return;
        final fetchedScores = results[0] as List<LeaderboardEntry>;
        final fetchedRank = results[1] as int?;
        final userId = ref.read(currentUserIdProvider);
        int? fetchedScore;
        if (userId != null) {
          final match = fetchedScores.where((e) => e.userId == userId);
          if (match.isNotEmpty) fetchedScore = match.first.score;
        }
        setState(() {
          _scores = fetchedScores;
          _userRank = fetchedRank;
          _userScore = fetchedScore;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _scores = [];
          _userRank = null;
          _userScore = null;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final dir = Directionality.of(context);
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final surfaceColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.1), light: kCardBorderLight);

    return ResponsiveScaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          label: ref.read(stringsProvider).backLabel,
          button: true,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsetsDirectional.only(start: 12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border: Border.all(color: borderColor),
                ),
                child:
                    Icon(directionalBackIcon(dir), color: textColor, size: 18),
              ),
            ),
          ),
        ),
        title: Text(
          l.leaderboardTitle,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Stack(
        children: [
          const LeaderboardBackground(),
          Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: ModeTabs(
                  controller: _tabController,
                  classicLabel: l.leaderboardTabClassic,
                  timeTrialLabel: l.leaderboardTabTimeTrial,
                  pvpLabel: l.leaderboardTabPvp,
                  friendsLabel: l.leaderboardTabFriends,
                ),
              ),
              const SizedBox(height: 12),
              if (!_isPvpTab)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: FilterRow(
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
              if (_userRank != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: UserRankBanner(
                    rank: _userRank!,
                    label: l.leaderboardYourRank,
                    score: _userScore,
                    isPvp: _isPvpTab,
                    strings: l,
                  ),
                ),
              const SizedBox(height: 8),
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
                            padding: EdgeInsets.symmetric(horizontal: hPadding),
                            itemCount: _scores.length,
                            itemBuilder: (context, index) {
                              final entry = _scores[index];
                              final rank = index + 1;
                              final userId =
                                  ref.read(currentUserIdProvider);
                              return ScoreRow(
                                rank: rank,
                                username: entry.username,
                                score: entry.score,
                                isCurrentUser: userId != null &&
                                    entry.userId == userId,
                                isPvp: _isPvpTab,
                                strings: l,
                                onTap: entry.userId.isNotEmpty
                                    ? () => context
                                        .push('/profile/${entry.userId}')
                                    : null,
                              )
                                  .animateOrSkip(
                                      reduceMotion: shouldReduceMotion(context),
                                      delay: (40 * index).ms)
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
