import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../shared/section_header.dart';
import '../../game/meta/resource_manager.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import 'quest_widgets.dart';


class QuestOverlay extends ConsumerStatefulWidget {
  const QuestOverlay({super.key});

  @override
  ConsumerState<QuestOverlay> createState() => _QuestOverlayState();
}

class _QuestOverlayState extends ConsumerState<QuestOverlay> {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'GOREVLER',
                      style: TextStyle(
                        color: kGold,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: kGold.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const XpBadge(label: 'XP Kazan'),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),
              Expanded(
                child: _loaded
                    ? ListView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          const SectionHeader(
                            title: 'GUNLUK',
                            color: kCyan,
                            icon: Icons.today_rounded,
                            showDivider: true,
                          ).animate(delay: 50.ms).fadeIn(duration: 250.ms),
                          const SizedBox(height: 8),
                          ..._activeDailies.asMap().entries.map((e) {
                            final quest = e.value;
                            final progress = _getProgress(quest);
                            return QuestCard(
                              quest: quest,
                              progress: progress,
                              accentColor: kCyan,
                              delay: Duration(milliseconds: 80 + 60 * e.key),
                            );
                          }),
                          const SizedBox(height: 20),
                          const SectionHeader(
                            title: 'HAFTALIK',
                            color: kOrange,
                            icon: Icons.date_range_rounded,
                            showDivider: true,
                          ).animate(delay: 250.ms).fadeIn(duration: 250.ms),
                          const SizedBox(height: 8),
                          ..._activeWeeklies.asMap().entries.map((e) {
                            final quest = e.value;
                            final progress = _getProgress(quest);
                            return QuestCard(
                              quest: quest,
                              progress: progress,
                              accentColor: kOrange,
                              delay: Duration(milliseconds: 300 + 60 * e.key),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: kGold),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
