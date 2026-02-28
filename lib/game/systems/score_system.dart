import '../../core/constants/game_constants.dart';
import 'combo_detector.dart';

class ScoreSystem {
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

  int addLineClear({
    required int linesCleared,
    required ComboEvent combo,
    int colorSynthesisCount = 0,
  }) {
    int points = switch (linesCleared) {
      1 => GameConstants.singleLineClear,
      _ => GameConstants.multiLineClear * (linesCleared - 1),
    };

    points = (points * combo.multiplier).round();
    points += colorSynthesisCount * GameConstants.colorSynthesisBonus;

    _score += points;
    if (_score > _highScore) _highScore = _score;

    return points; // UI animasyonu için anlık kazanım
  }
}
