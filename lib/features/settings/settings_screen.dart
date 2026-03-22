import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../audio/sound_bank.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../data/local/data_models.dart';
import '../shared/section_header.dart';
import '../../core/utils/motion_utils.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/theme_provider.dart';
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
    final profileAsync = ref.watch(userProfileProvider);
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
          label: l.backLabel,
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
                child: Icon(
                  directionalBackIcon(dir),
                  color: textColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          l.settingsTitle,
          style: TextStyle(
            color: textColor,
            fontSize: MediaQuery.textScalerOf(context).scale(18),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Stack(
        children: [
          const _SettingsBackground(),
          ListView(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
            children: [
              SectionHeader(title: l.settingsUsernameLabel, color: kCyan),
              UsernameTile(
                label: l.settingsUsernameLabel,
                currentUsername: profileAsync.valueOrNull?.username ?? '',
                dialogTitle: l.settingsUsernameTitle,
                dialogHint: l.settingsUsernameHint,
                saveLabel: l.settingsUsernameSave,
                errorEmpty: l.settingsUsernameErrorEmpty,
                errorTooLong: l.settingsUsernameErrorTooLong,
                errorInvalidChars: l.settingsUsernameErrorInvalidChars,
                onSave: (newName) async {
                  final repo = await ref.read(localRepositoryProvider.future);
                  final profile =
                      await repo.getProfile() ?? UserProfile(username: newName);
                  profile.username = newName;
                  await repo.saveProfile(profile);
                  ref.invalidate(userProfileProvider);
                },
              ),
              SectionHeader(title: l.settingsSectionAudio, color: kCyan),
              SettingsToggleTile(
                label: l.settingsSfx,
                icon: Icons.volume_up_rounded,
                value: audio.sfxEnabled,
                accentColor: kCyan,
                onChanged: (_) {
                  SoundBank().onButtonTap();
                  notifier.toggleSfx();
                },
              ),
              SettingsToggleTile(
                label: l.settingsMusic,
                icon: Icons.music_note_rounded,
                value: audio.musicEnabled,
                accentColor: kCyan,
                onChanged: (_) {
                  SoundBank().onButtonTap();
                  notifier.toggleMusic();
                },
              ),
              SectionHeader(title: l.settingsSectionFeedback, color: kColorZen),
              SettingsToggleTile(
                label: l.settingsHaptics,
                icon: Icons.vibration_rounded,
                value: audio.hapticsEnabled,
                accentColor: kColorZen,
                onChanged: (_) {
                  SoundBank().onButtonTap();
                  notifier.toggleHaptics();
                },
              ),
              SectionHeader(
                  title: l.settingsSectionAccessibility,
                  color: kColorTimeTrial),
              SettingsToggleTile(
                label: l.settingsColorBlind,
                icon: Icons.palette_outlined,
                value: audio.colorBlindMode,
                accentColor: kColorTimeTrial,
                onChanged: (_) {
                  SoundBank().onButtonTap();
                  notifier.toggleColorBlindMode();
                },
              ),
              SettingsToggleTile(
                label: l.settingsReduceMotion,
                icon: Icons.animation_rounded,
                value: shouldReduceMotion(context),
                accentColor: kColorTimeTrial,
                onChanged: (_) {},
              ),
              SectionHeader(
                  title: l.settingsSectionLanguage, color: kColorChef),
              LanguageTile(
                label: l.settingsLanguage,
                currentLocale: currentLocale,
                accentColor: kColorChef,
                onTap: () {
                  SoundBank().onButtonTap();
                  _showLanguageSheet(context, ref, currentLocale);
                },
              ),
              SectionHeader(
                  title: l.settingsSectionTheme, color: kThemeTertiary),
              ThemeSelectorTile(
                currentMode: ref.watch(themeModeProvider),
                systemLabel: l.settingsThemeSystem,
                lightLabel: l.settingsThemeLight,
                darkLabel: l.settingsThemeDark,
                accentColor: kThemeTertiary,
                onTap: () {
                  SoundBank().onButtonTap();
                  _showThemeSheet(context, ref);
                },
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
              ExportDataTile(
                label: l.settingsExportData,
                onExport: () async {
                  final repo = await ref.read(localRepositoryProvider.future);
                  final data = await repo.exportAllData();
                  final json = const JsonEncoder.withIndent('  ').convert(data);
                  if (!context.mounted) return;
                  if (kIsWeb) {
                    // Web: panoya kopyala
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.settingsExportSuccess),
                        backgroundColor: kCyan,
                      ),
                    );
                    return;
                  }
                  final dir = await getTemporaryDirectory();
                  final file = File('${dir.path}/gloo_data_export.json');
                  await file.writeAsString(json);
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    subject: 'Gloo Data Export',
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.settingsExportSuccess),
                      backgroundColor: kCyan,
                    ),
                  );
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
                        backgroundColor: kSuccessGreen,
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
              SettingsInfoTile(
                  label: l.settingsDeveloper, value: 'Gloo Studio'),
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

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ThemeSheet(
        currentMode: ref.read(themeModeProvider),
        systemLabel: ref.read(stringsProvider).settingsThemeSystem,
        lightLabel: ref.read(stringsProvider).settingsThemeLight,
        darkLabel: ref.read(stringsProvider).settingsThemeDark,
        onSelect: (mode) {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
          ref.read(localRepositoryProvider.future).then((repo) {
            repo.setThemeMode(mode);
          });
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
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    return Stack(
      children: [
        Container(color: bgColor),
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
