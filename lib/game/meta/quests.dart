// ─── Günlük / Haftalık Görevler ──────────────────────────────────────────────

/// Görev türleri.
enum QuestType {
  clearLines, // "5 satırı tek hamlelede temizle"
  makeSyntheses, // "3 renk sentezi yap"
  reachCombo, // "Kombo zinciri 4+ yap"
  completeDailyPuzzle, // "Daily Puzzle'ı tamamla"
  playGames, // "3 oyun oyna"
  useColorSynthesis, // "Belirli renk sentezle"
  reachScore, // "1000+ skor yap"
}

/// Görev tanımı.
class Quest {
  const Quest({
    required this.type,
    required this.description,
    required this.targetCount,
    required this.xpReward,
    required this.gelReward,
    this.isWeekly = false,
  });

  final QuestType type;
  final String description;
  final int targetCount;
  final int xpReward;
  final int gelReward;
  final bool isWeekly;
}

/// Günlük görev şablonları (3/gün).
const List<Quest> kDailyQuestPool = [
  Quest(
      type: QuestType.clearLines,
      description: '10 satır temizle',
      targetCount: 10,
      xpReward: 50,
      gelReward: 3),
  Quest(
      type: QuestType.makeSyntheses,
      description: '5 renk sentezi yap',
      targetCount: 5,
      xpReward: 60,
      gelReward: 4),
  Quest(
      type: QuestType.reachCombo,
      description: 'Medium+ kombo yap',
      targetCount: 1,
      xpReward: 40,
      gelReward: 2),
  Quest(
      type: QuestType.completeDailyPuzzle,
      description: 'Günlük bulmacayı tamamla',
      targetCount: 1,
      xpReward: 80,
      gelReward: 5),
  Quest(
      type: QuestType.playGames,
      description: '3 oyun oyna',
      targetCount: 3,
      xpReward: 30,
      gelReward: 2),
  Quest(
      type: QuestType.reachScore,
      description: '800+ skor yap',
      targetCount: 1,
      xpReward: 50,
      gelReward: 3),
];

/// Haftalık görev şablonları (5/hafta).
const List<Quest> kWeeklyQuestPool = [
  Quest(
      type: QuestType.clearLines,
      description: '100 satır temizle',
      targetCount: 100,
      xpReward: 200,
      gelReward: 15,
      isWeekly: true),
  Quest(
      type: QuestType.makeSyntheses,
      description: '30 renk sentezi yap',
      targetCount: 30,
      xpReward: 250,
      gelReward: 20,
      isWeekly: true),
  Quest(
      type: QuestType.reachCombo,
      description: 'Epic kombo yap',
      targetCount: 1,
      xpReward: 150,
      gelReward: 10,
      isWeekly: true),
  Quest(
      type: QuestType.playGames,
      description: '20 oyun oyna',
      targetCount: 20,
      xpReward: 180,
      gelReward: 12,
      isWeekly: true),
  Quest(
      type: QuestType.reachScore,
      description: '5000+ skor yap',
      targetCount: 1,
      xpReward: 300,
      gelReward: 25,
      isWeekly: true),
];
