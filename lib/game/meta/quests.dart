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
    required this.id,
    required this.type,
    required this.description,
    required this.targetCount,
    required this.xpReward,
    required this.gelReward,
    this.isWeekly = false,
  });

  final String id;
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
      id: 'd_cl10',
      type: QuestType.clearLines,
      description: '10 satır temizle',
      targetCount: 10,
      xpReward: 50,
      gelReward: 3),
  Quest(
      id: 'd_ms5',
      type: QuestType.makeSyntheses,
      description: '5 renk sentezi yap',
      targetCount: 5,
      xpReward: 60,
      gelReward: 4),
  Quest(
      id: 'd_rc3',
      type: QuestType.reachCombo,
      description: 'Medium+ kombo yap',
      targetCount: 1,
      xpReward: 40,
      gelReward: 2),
  Quest(
      id: 'd_dp1',
      type: QuestType.completeDailyPuzzle,
      description: 'Günlük bulmacayı tamamla',
      targetCount: 1,
      xpReward: 80,
      gelReward: 5),
  Quest(
      id: 'd_pg3',
      type: QuestType.playGames,
      description: '3 oyun oyna',
      targetCount: 3,
      xpReward: 30,
      gelReward: 2),
  Quest(
      id: 'd_rs800',
      type: QuestType.reachScore,
      description: '800+ skor yap',
      targetCount: 1,
      xpReward: 50,
      gelReward: 3),
  Quest(
      id: 'd_cl15',
      type: QuestType.clearLines,
      description: '15 satir temizle',
      targetCount: 15,
      xpReward: 40,
      gelReward: 3),
  Quest(
      id: 'd_rs500',
      type: QuestType.reachScore,
      description: '500 puana ulas',
      targetCount: 500,
      xpReward: 35,
      gelReward: 2),
  Quest(
      id: 'd_ms8',
      type: QuestType.makeSyntheses,
      description: '8 sentez yap',
      targetCount: 8,
      xpReward: 50,
      gelReward: 4),
  Quest(
      id: 'd_rc5',
      type: QuestType.reachCombo,
      description: '5 kombo yap',
      targetCount: 5,
      xpReward: 60,
      gelReward: 4),
  Quest(
      id: 'd_pg5',
      type: QuestType.playGames,
      description: '5 oyun oyna',
      targetCount: 5,
      xpReward: 45,
      gelReward: 3),
  Quest(
      id: 'd_cl20',
      type: QuestType.clearLines,
      description: '20 satir temizle',
      targetCount: 20,
      xpReward: 55,
      gelReward: 4),
];

/// Haftalık görev şablonları (5/hafta).
const List<Quest> kWeeklyQuestPool = [
  Quest(
      id: 'w_cl100',
      type: QuestType.clearLines,
      description: '100 satır temizle',
      targetCount: 100,
      xpReward: 200,
      gelReward: 15,
      isWeekly: true),
  Quest(
      id: 'w_ms30',
      type: QuestType.makeSyntheses,
      description: '30 renk sentezi yap',
      targetCount: 30,
      xpReward: 250,
      gelReward: 20,
      isWeekly: true),
  Quest(
      id: 'w_rc10',
      type: QuestType.reachCombo,
      description: 'Epic kombo yap',
      targetCount: 1,
      xpReward: 150,
      gelReward: 10,
      isWeekly: true),
  Quest(
      id: 'w_pg20',
      type: QuestType.playGames,
      description: '20 oyun oyna',
      targetCount: 20,
      xpReward: 180,
      gelReward: 12,
      isWeekly: true),
  Quest(
      id: 'w_rs5000',
      type: QuestType.reachScore,
      description: '5000+ skor yap',
      targetCount: 1,
      xpReward: 300,
      gelReward: 25,
      isWeekly: true),
];
