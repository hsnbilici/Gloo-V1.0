import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/local_repository.dart';
import '../game/meta/quests.dart';
import 'user_provider.dart';

/// Immutable quest state snapshot.
class QuestProgress {
  const QuestProgress({
    required this.dailyQuests,
    required this.progress,
  });

  final List<Quest> dailyQuests;
  final Map<String, int> progress;

  int getQuestProgress(Quest quest) {
    final key = '${quest.type.name}_${quest.isWeekly ? 'w' : 'd'}';
    return progress[key] ?? 0;
  }

  bool isCompleted(Quest quest) => getQuestProgress(quest) >= quest.targetCount;
}

/// Loads today's daily quests and their progress from local storage.
final questProvider = FutureProvider<QuestProgress>((ref) async {
  final repo = await ref.watch(localRepositoryProvider.future);
  final today = _todayKey();
  final savedDate = repo.getDailyQuestDate();
  Map<String, int> progress;
  if (savedDate != today) {
    progress = {};
    await repo.saveDailyQuestProgress({});
    await repo.saveDailyQuestDate(today);
  } else {
    progress = repo.getDailyQuestProgress();
  }

  final daySeed = DateTime.now().difference(DateTime(2024)).inDays;
  final dailies = _pickQuests(kDailyQuestPool, 3, daySeed);

  return QuestProgress(dailyQuests: dailies, progress: progress);
});

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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
  final key = '${type.name}_d';
  final current = state.progress[key] ?? 0;
  final updated = Map<String, int>.from(state.progress);
  updated[key] = current + amount;
  await repo.saveDailyQuestProgress(updated);

  int reward = 0;
  for (final quest in state.dailyQuests) {
    if (quest.type == type &&
        current < quest.targetCount &&
        updated[key]! >= quest.targetCount) {
      reward += quest.gelReward;
    }
  }
  return reward;
}
