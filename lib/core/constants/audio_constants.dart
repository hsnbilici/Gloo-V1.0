abstract final class AudioPaths {
  static const String _sfx = 'assets/audio/sfx';
  static const String _music = 'assets/audio/music';

  /// iOS AVAudioPlayer .ogg'yi native desteklemez. just_audio codec
  /// çeviricisi kullanır ama latency riski var. Ses dosyaları üretilirken
  /// hem .ogg hem .m4a formatında üretilmeli. iOS'ta .m4a, Android'de .ogg
  /// kullanılacak. Web'de her iki format da desteklenir.
  ///
  /// Mevcut haliyle tüm yollar .ogg — ses dosyaları henüz üretilmediği için
  /// iOS platformunda just_audio'nun .ogg desteğine güvenilir. Ses dosyaları
  /// üretildiğinde [_sfxExt] getter'ı ile platform bazlı uzantı seçimi
  /// aktifleştirilebilir.
  // static String get _sfxExt => Platform.isIOS ? 'm4a' : 'ogg';

  // Yerleştirme sesleri
  static const String gelPlace = '$_sfx/gel_place.ogg';
  static const String gelPlaceSoft = '$_sfx/gel_place_soft.ogg';

  // Birleşim sesleri
  static const String gelMergeSmall = '$_sfx/gel_merge_small.ogg';
  static const String gelMergeMedium = '$_sfx/gel_merge_medium.ogg';
  static const String gelMergeLarge = '$_sfx/gel_merge_large.ogg';

  // Patlama sesleri
  static const String lineClear = '$_sfx/line_clear.ogg';
  static const String lineClearCrystal = '$_sfx/line_clear_crystal.ogg';

  // Kombo sesleri
  static const String comboSmall = '$_sfx/combo_small.ogg';
  static const String comboMedium = '$_sfx/combo_medium.ogg';
  static const String comboLarge = '$_sfx/combo_large.ogg';
  static const String comboEpic = '$_sfx/combo_epic.ogg';

  // UI sesleri
  static const String buttonTap = '$_sfx/button_tap.ogg';
  static const String levelComplete = '$_sfx/level_complete.ogg';
  static const String gameOver = '$_sfx/game_over.ogg';
  static const String nearMissTension = '$_sfx/near_miss_tension.ogg';
  static const String nearMissRelief = '$_sfx/near_miss_relief.ogg';

  // Arka plan müziği
  static const String bgMenuLofi = '$_music/menu_lofi.mp3';
  static const String bgGameRelax = '$_music/game_relax.mp3';
  static const String bgGameTension = '$_music/game_tension.mp3';
  static const String bgZenMode = '$_music/zen_ambient.mp3';

  // ─── Faz 4: Yeni ses yolları ────────────────────────────────────────────

  // Buz kırılması
  static const String iceBreak = '$_sfx/ice_break.ogg';
  static const String iceCrack = '$_sfx/ice_crack.ogg';

  // Power-up sesleri
  static const String powerupActivate = '$_sfx/powerup_activate.ogg';
  static const String bombExplosion = '$_sfx/bomb_explosion.ogg';
  static const String rotateClick = '$_sfx/rotate_click.ogg';
  static const String undoWhoosh = '$_sfx/undo_whoosh.ogg';
  static const String freezeChime = '$_sfx/freeze_chime.ogg';

  // Yerçekimi düşüş
  static const String gravityDrop = '$_sfx/gravity_drop.ogg';

  // Renk sentezi
  static const String colorSynth = '$_sfx/color_synth.ogg';
  static const String colorSynthesis = '$_sfx/color_synthesis.ogg';

  // PvP sesleri
  static const String pvpObstacleSent = '$_sfx/pvp_obstacle_sent.ogg';
  static const String pvpObstacleReceived = '$_sfx/pvp_obstacle_received.ogg';
  static const String pvpVictory = '$_sfx/pvp_victory.ogg';
  static const String pvpDefeat = '$_sfx/pvp_defeat.ogg';

  // Seviye tamamlama
  static const String levelCompleteNew = '$_sfx/level_complete_new.ogg';

  // Jel Özü kazanma
  static const String gelOzuEarn = '$_sfx/gel_ozu_earn.ogg';
}

abstract final class AudioConfig {
  static const double masterVolume = 1.0;
  static const double sfxVolume = 0.85;
  static const double musicVolume = 0.4;
  static const int maxConcurrentSfxChannels = 8;

  // Pitch varyasyon aralığı — tekrar hissi azaltır
  static const double pitchVarianceMin = 0.92;
  static const double pitchVarianceMax = 1.08;

  // ─── Faz 4: ASMR Ses Frekans Haritalama ───────────────────────────────

  /// Jel Yerleştirme: 200-400Hz temel, 800-1200Hz harmonik
  /// Reverb tail: 300-500ms
  /// Format: WAV 48kHz, mono, -6dBFS normalize

  /// Satır Temizleme: Ascending arpeggio C4→E4→G4→C5 (400ms)
  /// Her hücre için 35ms stagger (burst animasyonuyla senkron)
  /// Crystal chime overlay: 2000-4000Hz

  /// Kombo Zincirleri:
  /// Small: Tek nota ping (E5, 1500Hz)
  /// Medium: 2 nota (E5→G5), reverb artışı
  /// Large: 3 nota arpeggio + sub-bass hit (60-80Hz)
  /// Epic: Tam akor + reversed cymbal swell + heavy sub-bass

  /// Renk Sentezi: Bubble merge efekti 150-300Hz → pitch slide yukarı 800Hz
  /// Harmonik buzzing: 100ms

  // Yerleştirme-Temizleme Senkronizasyonu:
  // t+0ms: Haptic + SFX + Görsel (aynı frame'de < 5ms)
  // Stagger: 35ms per cell
}
