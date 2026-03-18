import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../data/remote/dto/leaderboard_entry.dart';
import '../../providers/locale_provider.dart';
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
      ref
          .read(remoteRepositoryProvider)
          .getGlobalLeaderboard(mode: _currentMode, weekly: _weekly),
      ref
          .read(remoteRepositoryProvider)
          .getUserRank(mode: _currentMode, weekly: _weekly),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final dir = Directionality.of(context);

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
                margin: const EdgeInsetsDirectional.only(start: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Icon(directionalBackIcon(dir),
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
      body: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: responsiveMaxWidth(screenWidth)),
          child: Stack(
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
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          rank: _userRank!, label: l.leaderboardYourRank),
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
                                  style: const TextStyle(
                                      color: kMuted, fontSize: 14),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: hPadding),
                                itemCount: _scores.length,
                                itemBuilder: (context, index) {
                                  final entry = _scores[index];
                                  final rank = index + 1;
                                  return ScoreRow(
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
        ),
      ),
    );
  }
}
