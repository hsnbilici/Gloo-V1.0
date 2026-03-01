import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/meta/resource_manager.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';

// ─── Gorev Paneli ────────────────────────────────────────────────────────────

class QuestOverlay extends ConsumerStatefulWidget {
  const QuestOverlay({super.key});

  @override
  ConsumerState<QuestOverlay> createState() => _QuestOverlayState();
}

class _QuestOverlayState extends ConsumerState<QuestOverlay> {
  static const _kDaily = Color(0xFF00E5FF);
  static const _kWeekly = Color(0xFFFF8C42);
  static const _kXp = Color(0xFFFFD700);

  bool _loaded = false;
  Map<String, int> _dailyProgress = {};
  List<Quest> _activeDailies = [];
  List<Quest> _activeWeeklies = [];

  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    final repo = await ref.read(localRepositoryProvider.future);
    final today = _todayKey();

    // Gun degistiyse gunluk gorevleri sifirla
    final savedDate = repo.getDailyQuestDate();
    if (savedDate != today) {
      _dailyProgress = {};
      await repo.saveDailyQuestProgress({});
      await repo.saveDailyQuestDate(today);
    } else {
      _dailyProgress = repo.getDailyQuestProgress();
    }

    // Seed bazli gunluk gorev secimi (gune gore 3 gorev)
    final daySeed = DateTime.now().difference(DateTime(2024)).inDays;
    _activeDailies = _pickQuests(kDailyQuestPool, 3, daySeed);

    // Haftalik gorevler (hafta bazli, 5 gorev)
    final weekSeed = daySeed ~/ 7;
    _activeWeeklies = _pickQuests(kWeeklyQuestPool, 5, weekSeed);

    setState(() => _loaded = true);

    // Backend'den sync
    final remote = ref.read(remoteRepositoryProvider);
    final meta = await remote.loadMetaState();
    if (meta != null && mounted) {
      final backendProgress = meta.questProgress;
      final backendDate = meta.questDate;
      if (backendProgress != null &&
          backendDate == today &&
          backendProgress.isNotEmpty) {
        _dailyProgress = backendProgress.map((k, v) => MapEntry(k, v as int));
        await repo.saveDailyQuestProgress(_dailyProgress);
        setState(() {});
      }
    }
  }

  List<Quest> _pickQuests(List<Quest> pool, int count, int seed) {
    final shuffled = List<Quest>.from(pool);
    // Basit deterministik karistirma
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = (seed * 31 + i * 17) % (i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled.take(count).toList();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int _getProgress(Quest quest) {
    final key = '${quest.type.name}_${quest.isWeekly ? 'w' : 'd'}';
    return _dailyProgress[key] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: kBgDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.50),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              // Tutma cubugu
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Baslik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'GOREVLER',
                      style: TextStyle(
                        color: _kXp,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: _kXp.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const _XpBadge(label: 'XP Kazan'),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),
              // Gorev listesi
              Expanded(
                child: _loaded
                    ? ListView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Gunluk gorevler
                          const _SectionHeader(
                            label: 'GUNLUK',
                            color: _kDaily,
                            icon: Icons.today_rounded,
                          ).animate(delay: 50.ms).fadeIn(duration: 250.ms),
                          const SizedBox(height: 8),
                          ..._activeDailies.asMap().entries.map((e) {
                            final quest = e.value;
                            final progress = _getProgress(quest);
                            return _QuestCard(
                              quest: quest,
                              progress: progress,
                              accentColor: _kDaily,
                              delay: Duration(milliseconds: 80 + 60 * e.key),
                            );
                          }),
                          const SizedBox(height: 20),
                          // Haftalik gorevler
                          const _SectionHeader(
                            label: 'HAFTALIK',
                            color: _kWeekly,
                            icon: Icons.date_range_rounded,
                          ).animate(delay: 250.ms).fadeIn(duration: 250.ms),
                          const SizedBox(height: 8),
                          ..._activeWeeklies.asMap().entries.map((e) {
                            final quest = e.value;
                            final progress = _getProgress(quest);
                            return _QuestCard(
                              quest: quest,
                              progress: progress,
                              accentColor: _kWeekly,
                              delay: Duration(milliseconds: 300 + 60 * e.key),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: _kXp),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Bolum Basligi ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

// ─── Gorev Karti ─────────────────────────────────────────────────────────────

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
    required this.progress,
    required this.accentColor,
    required this.delay,
  });

  final Quest quest;
  final int progress;
  final Color accentColor;
  final Duration delay;

  IconData get _questIcon => switch (quest.type) {
        QuestType.clearLines => Icons.horizontal_rule_rounded,
        QuestType.makeSyntheses => Icons.merge_type_rounded,
        QuestType.reachCombo => Icons.flash_on_rounded,
        QuestType.completeDailyPuzzle => Icons.calendar_today_rounded,
        QuestType.playGames => Icons.sports_esports_rounded,
        QuestType.useColorSynthesis => Icons.palette_rounded,
        QuestType.reachScore => Icons.emoji_events_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= quest.targetCount;
    final ratio = quest.targetCount > 0
        ? (progress / quest.targetCount).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isComplete
              ? accentColor.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(
            color: isComplete
                ? accentColor.withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Ikon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isComplete ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                border: Border.all(
                  color:
                      accentColor.withValues(alpha: isComplete ? 0.35 : 0.15),
                ),
              ),
              child: Icon(
                isComplete ? Icons.check_rounded : _questIcon,
                color: isComplete
                    ? accentColor
                    : accentColor.withValues(alpha: 0.60),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            // Aciklama ve ilerleme cubugu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.description,
                    style: TextStyle(
                      color: isComplete
                          ? Colors.white.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.80),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration:
                          isComplete ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white.withValues(alpha: 0.30),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Ilerleme cubugu
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor,
                                    accentColor.withValues(alpha: 0.70),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Ilerleme sayisi
                  Text(
                    '$progress / ${quest.targetCount}',
                    style: TextStyle(
                      color: isComplete
                          ? accentColor.withValues(alpha: 0.60)
                          : Colors.white.withValues(alpha: 0.35),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Odul
            Column(
              children: [
                _RewardChip(
                  icon: Icons.star_rounded,
                  label: '${quest.xpReward}',
                  color: const Color(0xFFFFD700),
                ),
                const SizedBox(height: 3),
                _RewardChip(
                  icon: Icons.water_drop_rounded,
                  label: '${quest.gelReward}',
                  color: const Color(0xFF3CFF8B),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 200.ms)
        .slideX(begin: 0.06, end: 0, duration: 200.ms);
  }
}

// ─── Odul Chip ───────────────────────────────────────────────────────────────

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(UIConstants.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP Badge ────────────────────────────────────────────────────────────────

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(UIConstants.radiusSm),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 12),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
