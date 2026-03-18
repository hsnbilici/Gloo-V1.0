import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/section_header.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import 'settings_language.dart';
import 'settings_privacy.dart';
import 'settings_tiles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final l = ref.watch(stringsProvider);
    final currentLocale = ref.watch(localeProvider);

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
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          l.settingsTitle,
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
          const _SettingsBackground(),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              SectionHeader(title: l.settingsSectionAudio, color: kCyan),
              SettingsToggleTile(
                label: l.settingsSfx,
                icon: Icons.volume_up_rounded,
                value: audio.sfxEnabled,
                accentColor: kCyan,
                onChanged: (_) => notifier.toggleSfx(),
              ),
              SettingsToggleTile(
                label: l.settingsMusic,
                icon: Icons.music_note_rounded,
                value: audio.musicEnabled,
                accentColor: kCyan,
                onChanged: (_) => notifier.toggleMusic(),
              ),
              SectionHeader(title: l.settingsSectionFeedback, color: kColorZen),
              SettingsToggleTile(
                label: l.settingsHaptics,
                icon: Icons.vibration_rounded,
                value: audio.hapticsEnabled,
                accentColor: kColorZen,
                onChanged: (_) => notifier.toggleHaptics(),
              ),
              SectionHeader(
                  title: l.settingsSectionAccessibility,
                  color: kColorTimeTrial),
              SettingsToggleTile(
                label: l.settingsColorBlind,
                icon: Icons.palette_outlined,
                value: audio.colorBlindMode,
                accentColor: kColorTimeTrial,
                onChanged: (_) => notifier.toggleColorBlindMode(),
              ),
              SectionHeader(
                  title: l.settingsSectionLanguage, color: kColorChef),
              LanguageTile(
                label: l.settingsLanguage,
                currentLocale: currentLocale,
                accentColor: kColorChef,
                onTap: () => _showLanguageSheet(context, ref, currentLocale),
              ),
              SectionHeader(
                  title: l.settingsSectionPrivacy, color: kColorClassic),
              SettingsToggleTile(
                label: l.settingsAnalytics,
                icon: Icons.analytics_outlined,
                value: audio.analyticsEnabled,
                accentColor: kColorClassic,
                onChanged: (_) {
                  notifier.toggleAnalytics();
                  final newValue = !audio.analyticsEnabled;
                  ref.read(analyticsServiceProvider).setEnabled(newValue);
                  ref.read(localRepositoryProvider.future).then((repo) {
                    repo.setAnalyticsEnabled(newValue);
                  });
                },
              ),
              DeleteDataTile(
                label: l.settingsDeleteAccount,
                confirmTitle: l.settingsDeleteConfirmTitle,
                confirmMessage: l.settingsDeleteConfirmMessage,
                confirmAction: l.settingsDeleteConfirmAction,
                cancelLabel: l.settingsDeleteCancel,
                onDelete: () async {
                  final repo = await ref.read(localRepositoryProvider.future);
                  final success =
                      await ref.read(remoteRepositoryProvider).deleteUserData();
                  if (!context.mounted) return;
                  if (success) {
                    await repo.clearAllData();
                    ref.read(analyticsServiceProvider).setEnabled(false);
                    ref.invalidate(appSettingsProvider);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.deleteDataSuccess),
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    );
                    context.go('/onboarding');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.deleteDataError),
                        backgroundColor: kColorClassic,
                      ),
                    );
                  }
                },
              ),
              SectionHeader(title: l.settingsSectionAbout, color: kMuted),
              SettingsInfoTile(label: l.settingsVersion, value: '1.0.0'),
              SettingsInfoTile(label: l.settingsDeveloper, value: 'Gloo Studio'),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LanguageSheet(
        currentLocale: currentLocale,
        onSelect: (locale) {
          ref.read(localeProvider.notifier).setLocale(locale);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Arkaplan ────────────────────────────────────────────────────────────────

class _SettingsBackground extends StatelessWidget {
  const _SettingsBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  kCyan.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -40,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  kColorZen.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
