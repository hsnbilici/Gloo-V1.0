import 'skill_profile.dart';

/// Immutable set of difficulty levers derived from a [SkillProfile].
class DifficultyModifiers {
  const DifficultyModifiers({
    this.smallShapeBonus = 0.0,
    this.largeShapeBonus = 0.0,
    this.synthesisFriendly,
    this.comboSetup = false,
    this.pressureMercy = false,
  });

  /// Neutral modifiers — no effect on difficulty.
  const DifficultyModifiers.neutral()
      : smallShapeBonus = 0.0,
        largeShapeBonus = 0.0,
        synthesisFriendly = null,
        comboSetup = false,
        pressureMercy = false;

  /// Added to small shape weight (+0.0 to +0.15).
  final double smallShapeBonus;

  /// Added to large shape weight (+0.0 to +0.20).
  final double largeShapeBonus;

  /// Synthesis renk ağırlıklandırması:
  /// - `true` → sentez-dostu renklere +%30 boost (düşük beceri)
  /// - `null` → nötr, mevcut ters ağırlık sistemi aynen çalışır
  /// - `false` → ters ağırlık kapalı, düz rastgele (yüksek beceri)
  final bool? synthesisFriendly;

  /// When true, shapes that fit near-full rows are favoured.
  /// TODO: CD.28 Phase 2 — henüz ShapeGenerator'da consume edilmiyor.
  final bool comboSetup;

  /// When true, a small shape is guaranteed when the grid is >60% full.
  final bool pressureMercy;
}

/// Converts a [SkillProfile] into [DifficultyModifiers] using per-axis bands.
class AdaptiveDifficulty {
  const AdaptiveDifficulty._();

  static const double _lowThreshold = 0.3;
  static const double _highThreshold = 0.7;

  /// Returns [DifficultyModifiers.neutral] while the profile is calibrating
  /// (fewer than 3 games). Otherwise maps each skill axis to a modifier.
  static DifficultyModifiers calculate(SkillProfile profile) {
    if (profile.isCalibrating) return const DifficultyModifiers.neutral();

    final gridEff = profile.gridEfficiency;
    final synth = profile.synthesisSkill;
    final combo = profile.comboSkill;
    final pressure = profile.pressureResilience;

    // gridEfficiency axis
    final double smallShapeBonus;
    final double largeShapeBonus;
    if (gridEff < _lowThreshold) {
      final intensity = (_lowThreshold - gridEff) / _lowThreshold;
      smallShapeBonus = 0.15 * intensity;
      largeShapeBonus = 0.0;
    } else if (gridEff > _highThreshold) {
      final intensity = (gridEff - _highThreshold) / (1.0 - _highThreshold);
      smallShapeBonus = 0.0;
      largeShapeBonus = 0.20 * intensity;
    } else {
      smallShapeBonus = 0.0;
      largeShapeBonus = 0.0;
    }

    // synthesisSkill axis: true (boost) / null (nötr) / false (disable)
    final bool? synthesisFriendly;
    if (synth < _lowThreshold) {
      synthesisFriendly = true;
    } else if (synth > _highThreshold) {
      synthesisFriendly = false;
    } else {
      synthesisFriendly = null; // nötr — mevcut ters ağırlık korunur
    }

    // comboSkill axis
    final comboSetup = combo < _lowThreshold;

    // pressureResilience axis
    final pressureMercy = pressure < _lowThreshold;

    return DifficultyModifiers(
      smallShapeBonus: smallShapeBonus,
      largeShapeBonus: largeShapeBonus,
      synthesisFriendly: synthesisFriendly,
      comboSetup: comboSetup,
      pressureMercy: pressureMercy,
    );
  }
}
