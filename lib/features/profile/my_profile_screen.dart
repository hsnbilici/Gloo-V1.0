import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../data/local/data_models.dart';
import '../../providers/friend_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import '../shared/section_header.dart';
import '../shared/skill_radar_chart.dart';
import 'profile_widgets.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final repoAsync = ref.watch(localRepositoryProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final friendsAsync = ref.watch(friendsProvider);
    final eloAsync = ref.watch(eloProvider);
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
      body: repoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
        data: (repo) {
          final username =
              profileAsync.valueOrNull?.username ?? '';
          final friendCode =
              friendsAsync.valueOrNull?.myCode ?? '';
          final elo = eloAsync.valueOrNull ?? 0;
          final classicBest = repo.getStatRecord('classic_high') > 0
              ? repo.getStatRecord('classic_high')
              : 0;
          final timeTrialBest = repo.getStatRecord('timeTrial_high') > 0
              ? repo.getStatRecord('timeTrial_high')
              : 0;
          final totalGames = repo.getTotalGamesPlayed();
          final linesCleared = repo.getStatRecord('totalLinesCleared');
          final syntheses = repo.getStatRecord('totalSynthesisCount');
          final discovered = repo.getDiscoveredColors();
          final skillProfile = repo.getSkillProfile();

          return ListView(
            padding:
                EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
            children: [
              const SizedBox(height: Spacing.md),
              // Header
              ProfileHeader(
                username: username,
                friendCode: friendCode,
                brightness: brightness,
                onEditTap: () => _showEditDialog(username),
              ),
              const SizedBox(height: Spacing.xl),

              // Stats
              SectionHeader(
                title: l.profileHighScore.toUpperCase(),
                color: kCyan,
              ),
              const SizedBox(height: Spacing.sm),
              StatCards(
                classicBest: classicBest,
                timeTrialBest: timeTrialBest,
                elo: elo,
                totalGames: totalGames,
                linesCleared: linesCleared,
                syntheses: syntheses,
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
              if (!skillProfile.isCalibrating) ...[
                SectionHeader(
                  title: l.skillProfileTitle.toUpperCase(),
                  color: kCyan,
                ),
                const SizedBox(height: Spacing.sm),
                Center(
                  child: SkillRadarChart(
                    gridEfficiency: skillProfile.gridEfficiency,
                    synthesisSkill: skillProfile.synthesisSkill,
                    comboSkill: skillProfile.comboSkill,
                    pressureResilience: skillProfile.pressureResilience,
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

              // Collection
              const SectionHeader(
                title: 'COLLECTION',
                color: kGold,
              ),
              const SizedBox(height: Spacing.sm),
              CollectionMini(discoveredColors: discovered),
              const SizedBox(height: Spacing.xl),

              // Recent Activity — we show an empty state since
              // local recent scores are not persisted as a list.
              SectionHeader(
                title: l.profileRecentActivity.toUpperCase(),
                color: kCyan,
              ),
              const SizedBox(height: Spacing.sm),
              ActivityList(
                scores: const [],
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

  Future<void> _showEditDialog(String currentUsername) async {
    final l = ref.read(stringsProvider);
    final controller = TextEditingController(text: currentUsername);
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: resolveColor(
                Theme.of(ctx).brightness,
                dark: const Color(0xFF0F1420),
                light: kCardBgLight,
              ),
              title: Text(
                l.settingsUsernameTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: UserProfile.maxUsernameLength,
                decoration: InputDecoration(
                  hintText: l.settingsUsernameHint,
                  errorText: errorText,
                ),
                onChanged: (v) {
                  final err = UserProfile.validateUsername(v);
                  setDialogState(() {
                    errorText = switch (err) {
                      'empty' => l.settingsUsernameErrorEmpty,
                      'tooLong' => l.settingsUsernameErrorTooLong,
                      'invalidChars' => l.settingsUsernameErrorInvalidChars,
                      _ => null,
                    };
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l.backLabel),
                ),
                TextButton(
                  onPressed: errorText != null
                      ? null
                      : () {
                          final name = controller.text.trim();
                          if (UserProfile.validateUsername(name) == null) {
                            Navigator.of(ctx).pop(name);
                          }
                        },
                  child: Text(l.settingsUsernameSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty && mounted) {
      final repo = await ref.read(localRepositoryProvider.future);
      final profile =
          await repo.getProfile() ?? UserProfile(username: result);
      profile.username = result;
      await repo.saveProfile(profile);
      ref.invalidate(userProfileProvider);
      ref.read(remoteRepositoryProvider).ensureProfile(username: result);
    }
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
