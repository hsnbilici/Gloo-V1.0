import '../../core/constants/game_constants.dart';
import 'combo_detector.dart';

class ScoreSystem {
  ScoreSystem({this.colorMasterBonus = 0.0});

  /// Talent bonusu: sentez puanına çarpan (0.0–0.5).
  final double colorMasterBonus;

  int _score = 0;
  int _highScore = 0;

  int get score => _score;
  int get highScore => _highScore;
  bool get isNewHighScore => _score > _highScore;

  void reset() => _score = 0;

  /// Kalıcı depodan yüklenen önceki oturum rekoru ile başlat.
  void setInitialHighScore(int value) {
    if (value > _highScore) _highScore = value;
  }

  /// Şekil yerleştirme puanı: hücre başına 10 puan.
  int addPlacementScore(int cellCount) {
    final points = cellCount * 10;
    _score += points;
    if (_score > _highScore) _highScore = _score;
    return points;
  }

  int addLineClear({
    required int linesCleared,
    required ComboEvent combo,
    int colorSynthesisCount = 0,
  }) {
    int points = switch (linesCleared) {
      1 => GameConstants.singleLineClear,
      2 => 400,
      3 => 1000,
      4 => 2000,
      _ => 2000 + (linesCleared - 4) * 1000,
    };

    points = (points * combo.multiplier).round();
    points +=
        (colorSynthesisCount * GameConstants.colorSynthesisBonus * (1 + colorMasterBonus)).round();

    _score += points;
    if (_score > _highScore) _highScore = _score;

    return points; // UI animasyonu için anlık kazanım
  }
}
