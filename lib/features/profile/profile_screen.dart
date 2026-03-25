import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../data/remote/friend_repository.dart';
import '../../providers/friend_provider.dart';
import '../../providers/locale_provider.dart';
import '../shared/section_header.dart';
import '../shared/skill_radar_chart.dart';
import 'profile_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Future<UserProfileData?> _profileFuture;
  bool _isFollowing = false;
  bool _isMutual = false;
  bool _followLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final repo = ref.read(friendRepositoryProvider);
    _profileFuture = repo.getUserProfile(widget.userId);
    _profileFuture.then((data) {
      if (data != null && mounted) {
        setState(() {
          _isFollowing = data.isFollowing;
          _isMutual = data.isMutual;
        });
      }
    });
  }

  Future<void> _toggleFollow() async {
    if (_followLoading) return;
    setState(() => _followLoading = true);
    final repo = ref.read(friendRepositoryProvider);
    if (_isFollowing) {
      await repo.unfollow(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = false;
          _isMutual = false;
          _followLoading = false;
        });
      }
    } else {
      final ok = await repo.follow(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = ok;
          _followLoading = false;
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
    final mutedColor =
        resolveColor(brightness, dark: kMuted, light: kMutedLight);

    return ResponsiveScaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _BackButton(
          icon: directionalBackIcon(dir),
          iconColor: textColor,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          onTap: () => context.pop(),
        ),
        title: Text(
          l.profileTitle,
          style: TextStyle(
            color: textColor,
            fontSize: MediaQuery.textScalerOf(context).scale(18),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: FutureBuilder<UserProfileData?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Text(
                'Profile not found',
                style: TextStyle(color: mutedColor, fontSize: 14),
              ),
            );
          }

          final followBtn = _FollowButton(
            isFollowing: _isFollowing,
            isLoading: _followLoading,
            followLabel: l.friendFollow,
            unfollowLabel: l.friendUnfollow,
            onTap: _toggleFollow,
          );

          final recentScores = data.recentScores
              .take(5)
              .map((s) => ActivityItem(
                    mode: s.mode,
                    score: s.score,
                    playedAt: s.playedAt,
                  ))
              .toList();

          return ListView(
            padding:
                EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
            children: [
              const SizedBox(height: Spacing.md),
              ProfileHeader(
                username: data.username,
                friendCode: data.friendCode,
                brightness: brightness,
                followButton: followBtn,
                isMutual: _isMutual,
              ),
              const SizedBox(height: Spacing.xl),

              SectionHeader(
                title: l.profileHighScore.toUpperCase(),
                color: kCyan,
              ),
              const SizedBox(height: Spacing.sm),
              StatCards(
                classicBest: data.classicHighScore,
                timeTrialBest: data.timeTrialHighScore,
                elo: data.elo,
                totalGames: data.totalGames,
                linesCleared: 0,
                syntheses: 0,
                brightness: brightness,
                labels: [
                  'Classic ${l.profileHighScore}',
                  'TimeTrial ${l.profileHighScore}',
                  'ELO',
                  l.profileTotalGames,
                  l.profileTotalLines,
                  l.profileTotalSyntheses,
                ],
              ),
              const SizedBox(height: Spacing.xl),

              // Skill Radar
              if (data.skillProfile != null) ...[
                SectionHeader(
                  title: l.skillProfileTitle.toUpperCase(),
                  color: kCyan,
                ),
                const SizedBox(height: Spacing.sm),
                Center(
                  child: SkillRadarChart(
                    gridEfficiency:
                        data.skillProfile!['gridEfficiency'] ?? 0.5,
                    synthesisSkill:
                        data.skillProfile!['synthesisSkill'] ?? 0.5,
                    comboSkill: data.skillProfile!['comboSkill'] ?? 0.5,
                    pressureResilience:
                        data.skillProfile!['pressureResilience'] ?? 0.5,
                    labels: [
                      l.skillGridEfficiency,
                      l.skillSynthesis,
                      l.skillCombo,
                      l.skillPressure,
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),
              ],

              // Recent Activity
              SectionHeader(
                title: l.profileRecentActivity.toUpperCase(),
                color: kCyan,
              ),
              const SizedBox(height: Spacing.sm),
              ActivityList(
                scores: recentScores,
                emptyText: l.profileNoActivity,
                brightness: brightness,
              ),
              const SizedBox(height: Spacing.xl),
            ],
          );
        },
      ),
    );
  }
}

// ─── Follow Button ───────────────────────────────────────────────────────────

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.isFollowing,
    required this.isLoading,
    required this.followLabel,
    required this.unfollowLabel,
    required this.onTap,
  });

  final bool isFollowing;
  final bool isLoading;
  final String followLabel;
  final String unfollowLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isFollowing ? kMuted : kCyan;
    return Semantics(
      label: isFollowing ? unfollowLabel : followLabel,
      button: true,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: isLoading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  isFollowing ? unfollowLabel : followLabel,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Simple back button ──────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.icon,
    required this.iconColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color surfaceColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Back',
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(UIConstants.radiusSm),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ),
      ),
    );
  }
}
