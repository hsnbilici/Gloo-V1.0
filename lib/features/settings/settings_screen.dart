import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';

// kColorChef: dil bölümü için vurgu rengi (neon mint)
const _kLangAccent = kColorChef;

// Tehlikeli eylemler için vurgu rengi (veri silme)
const _kPrivacyAccent = Color(0xFFFF4D6D);

// ─── Ekran ────────────────────────────────────────────────────────────────────

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
              _SectionHeader(title: l.settingsSectionAudio, color: kCyan),
              _ToggleTile(
                label: l.settingsSfx,
                icon: Icons.volume_up_rounded,
                value: audio.sfxEnabled,
                accentColor: kCyan,
                onChanged: (_) => notifier.toggleSfx(),
              ),
              _ToggleTile(
                label: l.settingsMusic,
                icon: Icons.music_note_rounded,
                value: audio.musicEnabled,
                accentColor: kCyan,
                onChanged: (_) => notifier.toggleMusic(),
              ),
              _SectionHeader(
                  title: l.settingsSectionFeedback, color: kColorZen),
              _ToggleTile(
                label: l.settingsHaptics,
                icon: Icons.vibration_rounded,
                value: audio.hapticsEnabled,
                accentColor: kColorZen,
                onChanged: (_) => notifier.toggleHaptics(),
              ),
              _SectionHeader(
                  title: l.settingsSectionAccessibility,
                  color: kColorTimeTrial),
              _ToggleTile(
                label: l.settingsColorBlind,
                icon: Icons.palette_outlined,
                value: audio.colorBlindMode,
                accentColor: kColorTimeTrial,
                onChanged: (_) => notifier.toggleColorBlindMode(),
              ),
              _SectionHeader(
                  title: l.settingsSectionLanguage, color: _kLangAccent),
              _LanguageTile(
                label: l.settingsLanguage,
                currentLocale: currentLocale,
                accentColor: _kLangAccent,
                onTap: () => _showLanguageSheet(context, ref, currentLocale),
              ),
              _SectionHeader(
                  title: l.settingsSectionPrivacy, color: _kPrivacyAccent),
              _ToggleTile(
                label: l.settingsAnalytics,
                icon: Icons.analytics_outlined,
                value: audio.analyticsEnabled,
                accentColor: _kPrivacyAccent,
                onChanged: (_) {
                  notifier.toggleAnalytics();
                  final newValue = !audio.analyticsEnabled;
                  ref.read(analyticsServiceProvider).setEnabled(newValue);
                  ref.read(localRepositoryProvider.future).then((repo) {
                    repo.setAnalyticsEnabled(newValue);
                  });
                },
              ),
              _DeleteDataTile(
                label: l.settingsDeleteAccount,
                confirmTitle: l.settingsDeleteConfirmTitle,
                confirmMessage: l.settingsDeleteConfirmMessage,
                confirmAction: l.settingsDeleteConfirmAction,
                cancelLabel: l.settingsDeleteCancel,
                onDelete: () async {
                  final repo = await ref.read(localRepositoryProvider.future);
                  final success = await ref.read(remoteRepositoryProvider).deleteUserData();
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
                        backgroundColor: _kPrivacyAccent,
                      ),
                    );
                  }
                },
              ),
              _SectionHeader(title: l.settingsSectionAbout, color: kMuted),
              _InfoTile(label: l.settingsVersion, value: '1.0.0'),
              _InfoTile(label: l.settingsDeveloper, value: 'Gloo Studio'),
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
      builder: (_) => _LanguageSheet(
        currentLocale: currentLocale,
        onSelect: (locale) {
          ref.read(localeProvider.notifier).setLocale(locale);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Arkaplan ─────────────────────────────────────────────────────────────────

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

// ─── Bölüm başlığı ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(UIConstants.radiusXxs),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle satırı ────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final Color accentColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? accentColor.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(
          color: value
              ? accentColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? accentColor : kMuted,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.3),
            inactiveThumbColor: kMuted,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
          ),
        ],
      ),
    );
  }
}

// ─── Bilgi satırı ─────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: kMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dil seçim satırı ─────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.currentLocale,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final Locale currentLocale;
  final Color accentColor;
  final VoidCallback onTap;

  String get _currentNativeName {
    for (final lang in kLanguageOptions) {
      if (lang.code == currentLocale.languageCode) return lang.nativeName;
    }
    return currentLocale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(UIConstants.radiusTile),
            border: Border.all(color: accentColor.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(Icons.language_rounded, color: accentColor, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _currentNativeName,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: accentColor.withValues(alpha: 0.70),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dil seçim bottom sheet ───────────────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({
    required this.currentLocale,
    required this.onSelect,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1420),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(UIConstants.radiusXxl)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tutamak çubuğu
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(UIConstants.radiusXxs),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 3'lü ızgara
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.0,
            ),
            itemCount: kLanguageOptions.length,
            itemBuilder: (context, i) {
              final lang = kLanguageOptions[i];
              final isSelected = lang.code == currentLocale.languageCode;
              return _LangChip(
                code: lang.code.toUpperCase(),
                nativeName: lang.nativeName,
                isSelected: isSelected,
                onTap: () => onSelect(Locale(lang.code)),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Veri silme satırı ────────────────────────────────────────────────────────

class _DeleteDataTile extends StatelessWidget {
  const _DeleteDataTile({
    required this.label,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.confirmAction,
    required this.cancelLabel,
    required this.onDelete,
  });

  final String label;
  final String confirmTitle;
  final String confirmMessage;
  final String confirmAction;
  final String cancelLabel;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: () => _showConfirm(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _kPrivacyAccent.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(UIConstants.radiusTile),
            border: Border.all(color: _kPrivacyAccent.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded,
                  color: _kPrivacyAccent, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: _kPrivacyAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) => _DeleteConfirmDialog(
        title: confirmTitle,
        message: confirmMessage,
        confirmAction: confirmAction,
        cancelLabel: cancelLabel,
      ),
    );
    if (confirmed == true && context.mounted) {
      await onDelete();
    }
  }
}

// ─── Veri silme onay diyalogu ─────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmAction,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final String confirmAction;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F1420),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        side: BorderSide(color: _kPrivacyAccent.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: _kPrivacyAccent, size: 36),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusMd),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        cancelLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _kPrivacyAccent.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusMd),
                        border: Border.all(
                            color: _kPrivacyAccent.withValues(alpha: 0.55)),
                      ),
                      child: Text(
                        confirmAction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _kPrivacyAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dil chip'i ───────────────────────────────────────────────────────────────

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.code,
    required this.nativeName,
    required this.isSelected,
    required this.onTap,
  });

  final String code;
  final String nativeName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = _kLangAccent;
    return Semantics(
      label: nativeName,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(UIConstants.radiusMd),
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.09),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nativeName,
                style: TextStyle(
                  color: isSelected ? accent : Colors.white,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                code,
                style: TextStyle(
                  color: isSelected
                      ? accent.withValues(alpha: 0.75)
                      : kMuted.withValues(alpha: 0.60),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
