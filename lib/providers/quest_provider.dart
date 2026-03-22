import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/local_repository.dart';
import '../game/meta/quests.dart';
import 'user_provider.dart';

/// Immutable quest state snapshot.
class QuestProgress {
  const QuestProgress({
    required this.dailyQuests,
    required this.progress,
    this.weeklyQuests = const [],
    this.weeklyProgress = const {},
  });

  final List<Quest> dailyQuests;
  final Map<String, int> progress;
  final List<Quest> weeklyQuests;
  final Map<String, int> weeklyProgress;

  int getQuestProgress(Quest quest) {
    if (quest.isWeekly) return weeklyProgress[quest.id] ?? 0;
    return progress[quest.id] ?? 0;
  }

  bool isCompleted(Quest quest) => getQuestProgress(quest) >= quest.targetCount;
}

/// Loads today's daily quests and their progress from local storage.
final questProvider = FutureProvider<QuestProgress>((ref) async {
  final repo = await ref.watch(localRepositoryProvider.future);

  // ── Daily reset ───────────────────────────────────────────────────────────
  final today = _todayKey();
  final savedDate = repo.getDailyQuestDate();
  Map<String, int> dailyProgress;
  if (savedDate != today) {
    dailyProgress = {};
    await repo.saveDailyQuestProgress({});
    await repo.saveDailyQuestDate(today);
  } else {
    dailyProgress = repo.getDailyQuestProgress();
  }

  final daySeed = DateTime.now().difference(DateTime(2024)).inDays;
  final dailies = _pickQuests(kDailyQuestPool, 3, daySeed);

  // ── Migration: old type-based keys (e.g. "clearLines_d") → quest.id keys
  if (savedDate == today && dailyProgress.isNotEmpty) {
    final hasOldKeys = dailyProgress.keys.any((k) => k.endsWith('_d'));
    if (hasOldKeys) {
      final newProgress = <String, int>{};
      for (final quest in dailies) {
        final oldKey = '${quest.type.name}_d';
        if (dailyProgress.containsKey(oldKey)) {
          newProgress[quest.id] = dailyProgress[oldKey]!;
        }
      }
      if (newProgress.isNotEmpty) {
        dailyProgress = newProgress;
        await repo.saveDailyQuestProgress(newProgress);
      }
    }
  }

  // ── Weekly reset ──────────────────────────────────────────────────────────
  final now = DateTime.now();
  final (isoYear, isoWeek) = _isoYearWeek(now);
  final currentWeekKey = '$isoYear-W${isoWeek.toString().padLeft(2, '0')}';
  final savedWeekKey = repo.getWeeklyQuestWeek();
  Map<String, int> weeklyProgress;
  if (savedWeekKey != currentWeekKey) {
    weeklyProgress = {};
    await repo.saveWeeklyQuestProgress({});
    await repo.saveWeeklyQuestWeek(currentWeekKey);
  } else {
    weeklyProgress = await repo.getWeeklyQuestProgress();
  }

  final weekSeed = isoYear * 100 + isoWeek;
  final weeklies = _pickQuests(kWeeklyQuestPool, 5, weekSeed);

  return QuestProgress(
    dailyQuests: dailies,
    progress: dailyProgress,
    weeklyQuests: weeklies,
    weeklyProgress: weeklyProgress,
  );
});

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

/// Returns (isoYear, isoWeek) using Thursday-based ISO 8601 calculation.
(int, int) _isoYearWeek(DateTime date) {
  // ISO 8601: the week's year is determined by which year the Thursday falls in.
  final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
  final jan1 = DateTime(thursday.year, 1, 1);
  final week = (thursday.difference(jan1).inDays ~/ 7) + 1;
  return (thursday.year, week);
}

List<Quest> _pickQuests(List<Quest> pool, int count, int seed) {
  final shuffled = List<Quest>.from(pool);
  for (int i = shuffled.length - 1; i > 0; i--) {
    final j = (seed * 31 + i * 17) % (i + 1);
    final temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }
  return shuffled.take(count).toList();
}

/// Increments quest progress and persists. Returns total gel reward if any
/// quest was just completed.
Future<int> incrementQuestProgress(
  LocalRepository repo,
  QuestProgress state,
  QuestType type, {
  int amount = 1,
}) async {
  int reward = 0;

  // ── Daily quests ──────────────────────────────────────────────────────────
  final dailyMatches = state.dailyQuests.where((q) => q.type == type).toList();
  if (dailyMatches.isNotEmpty) {
    final updated = Map<String, int>.from(state.progress);
    for (final quest in dailyMatches) {
      final current = updated[quest.id] ?? 0;
      updated[quest.id] = current + amount;
      if (current < quest.targetCount && updated[quest.id]! >= quest.targetCount) {
        reward += quest.gelReward;
      }
    }
    await repo.saveDailyQuestProgress(updated);
  }

  // ── Weekly quests (parallel update for matching type) ─────────────────────
  final weeklyMatches = state.weeklyQuests.where((q) => q.type == type).toList();
  if (weeklyMatches.isNotEmpty) {
    final updatedWeekly = Map<String, int>.from(state.weeklyProgress);
    for (final quest in weeklyMatches) {
      final current = updatedWeekly[quest.id] ?? 0;
      updatedWeekly[quest.id] = current + amount;
      if (current < quest.targetCount && updatedWeekly[quest.id]! >= quest.targetCount) {
        reward += quest.gelReward;
      }
    }
    await repo.saveWeeklyQuestProgress(updatedWeekly);
  }

  return reward;
}
