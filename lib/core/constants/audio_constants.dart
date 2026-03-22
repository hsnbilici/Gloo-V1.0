import 'package:flutter/foundation.dart';

abstract final class AudioPaths {
  static const String _sfx = 'assets/audio/sfx';
  static const String _music = 'assets/audio/music';

  /// iOS AVAudioPlayer .ogg'yi native desteklemez — software decoding
  /// latency ve batarya maliyeti yaratir. iOS'ta .m4a (AAC), digerlerde .ogg.
  /// Web (Safari) da .ogg'yi desteklemez — web'de .m4a kullan.
  static String get _sfxExt {
    if (kIsWeb) return 'm4a';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'm4a';
    return 'ogg';
  }

  // Yerlestirme sesleri
  static String get gelPlace => '$_sfx/gel_place.$_sfxExt';
  static String get gelPlaceSoft => '$_sfx/gel_place_soft.$_sfxExt';

  // Birlesim sesleri
  static String get gelMergeSmall => '$_sfx/gel_merge_small.$_sfxExt';
  static String get gelMergeMedium => '$_sfx/gel_merge_medium.$_sfxExt';
  static String get gelMergeLarge => '$_sfx/gel_merge_large.$_sfxExt';

  // Patlama sesleri
  static String get lineClear => '$_sfx/line_clear.$_sfxExt';
  static String get lineClearCrystal => '$_sfx/line_clear_crystal.$_sfxExt';

  // Kombo sesleri
  static String get comboSmall => '$_sfx/combo_small.$_sfxExt';
  static String get comboMedium => '$_sfx/combo_medium.$_sfxExt';
  static String get comboLarge => '$_sfx/combo_large.$_sfxExt';
  static String get comboEpic => '$_sfx/combo_epic.$_sfxExt';

  // UI sesleri
  static String get buttonTap => '$_sfx/button_tap.$_sfxExt';
  static String get levelComplete => '$_sfx/level_complete.$_sfxExt';
  static String get gameOver => '$_sfx/game_over.$_sfxExt';
  static String get nearMissTension => '$_sfx/near_miss_tension.$_sfxExt';
  static String get nearMissRelief => '$_sfx/near_miss_relief.$_sfxExt';

  // Arka plan muzigi
  static const String bgMenuLofi = '$_music/menu_lofi.mp3';
  static const String bgGameRelax = '$_music/game_relax.mp3';
  static const String bgGameTension = '$_music/game_tension.mp3';
  static const String bgZenMode = '$_music/zen_ambient.mp3';

  // Buz kirilmasi
  static String get iceBreak => '$_sfx/ice_break.$_sfxExt';
  static String get iceCrack => '$_sfx/ice_crack.$_sfxExt';

  // Power-up sesleri
  static String get powerupActivate => '$_sfx/powerup_activate.$_sfxExt';
  static String get bombExplosion => '$_sfx/bomb_explosion.$_sfxExt';
  static String get rotateClick => '$_sfx/rotate_click.$_sfxExt';
  static String get undoWhoosh => '$_sfx/undo_whoosh.$_sfxExt';
  static String get freezeChime => '$_sfx/freeze_chime.$_sfxExt';

  // Yercekimi dusus
  static String get gravityDrop => '$_sfx/gravity_drop.$_sfxExt';

  // Renk sentezi
  static String get colorSynth => '$_sfx/color_synth.$_sfxExt';
  static String get colorSynthesis => '$_sfx/color_synthesis.$_sfxExt';

  // PvP sesleri
  static String get pvpObstacleSent => '$_sfx/pvp_obstacle_sent.$_sfxExt';
  static String get pvpObstacleReceived =>
      '$_sfx/pvp_obstacle_received.$_sfxExt';
  static String get pvpVictory => '$_sfx/pvp_victory.$_sfxExt';
  static String get pvpDefeat => '$_sfx/pvp_defeat.$_sfxExt';

  // Seviye tamamlama
  static String get levelCompleteNew => '$_sfx/level_complete_new.$_sfxExt';

  // Jel Ozu kazanma
  static String get gelOzuEarn => '$_sfx/gel_ozu_earn.$_sfxExt';
}

abstract final class AudioConfig {
  static const double masterVolume = 1.0;
  static const double sfxVolume = 0.85;
  static const double musicVolume = 0.4;
  static const int maxConcurrentSfxChannels = 8;

  // Pitch varyasyon araligi — tekrar hissi azaltir
  static const double pitchVarianceMin = 0.92;
  static const double pitchVarianceMax = 1.08;

  // ─── Faz 4: ASMR Ses Frekans Haritalama ───────────────────────────────

  /// Jel Yerlestirme: 200-400Hz temel, 800-1200Hz harmonik
  /// Reverb tail: 300-500ms
  /// Format: WAV 48kHz, mono, -6dBFS normalize

  /// Satir Temizleme: Ascending arpeggio C4→E4→G4→C5 (400ms)
  /// Her hucre icin 35ms stagger (burst animasyonuyla senkron)
  /// Crystal chime overlay: 2000-4000Hz

  /// Kombo Zincirleri:
  /// Small: Tek nota ping (E5, 1500Hz)
  /// Medium: 2 nota (E5→G5), reverb artisi
  /// Large: 3 nota arpeggio + sub-bass hit (60-80Hz)
  /// Epic: Tam akor + reversed cymbal swell + heavy sub-bass

  /// Renk Sentezi: Bubble merge efekti 150-300Hz → pitch slide yukari 800Hz
  /// Harmonik buzzing: 100ms

  // Yerlestirme-Temizleme Senkronizasyonu:
  // t+0ms: Haptic + SFX + Gorsel (ayni frame'de < 5ms)
  // Stagger: 35ms per cell
}
