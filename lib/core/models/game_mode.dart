enum GameMode {
  classic,
  colorChef,
  timeTrial,
  zen,
  daily,
  level, // Faz 4: Seviye modu
  duel; // Faz 4: PvP düello modu

  static GameMode fromString(String value) {
    return GameMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => GameMode.classic,
    );
  }
}
