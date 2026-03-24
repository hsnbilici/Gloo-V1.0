import 'package:flutter/widgets.dart';

import '../constants/color_constants.dart';
import 'strings_ar.dart';
import 'strings_de.dart';
import 'strings_en.dart';
import 'strings_es.dart';
import 'strings_fr.dart';
import 'strings_hi.dart';
import 'strings_ja.dart';
import 'strings_ko.dart';
import 'strings_pt.dart';
import 'strings_ru.dart';
import 'strings_tr.dart';
import 'strings_zh.dart';

// ignore_for_file: public_member_api_docs

abstract class AppStrings {
  // HUD
  String get scoreLabel;
  String get modeLabelClassic;
  String get modeLabelColorChef;
  String get modeLabelTimeTrial;
  String get modeLabelZen;
  String get modeLabelDaily;

  // Duraklatma
  String get pauseTitle;
  String get pauseResume;
  String get pauseHome;

  // Oyun sonu
  String get gameOverTitle;
  String get gameOverScoreLabel;
  String get gameOverNewRecord;
  String get gameOverGridFill;
  String get gameOverLinesCleared;
  String get gameOverSyntheses;
  String get gameOverMaxCombo;
  String get gridFillClean;
  String get gridFillGood;
  String get gridFillCrowded;
  String get gridFillFull;
  String get gameOverTipSynthesis;
  String get gameOverTipCombo;
  String get gameOverModeClassic;
  String get gameOverModeColorChef;
  String get gameOverModeTimeTrial;
  String get gameOverModeZen;
  String get gameOverModeDaily;
  String get gameOverReplay;
  String get gameOverHome;

  // Combo efektleri
  String get comboSmall;
  String get comboMedium;
  String get comboLarge;
  String get comboEpic;

  // Near-miss
  String get nearMissStandard;
  String get nearMissCritical;

  // Toast
  String get toastSlotUsed;
  String get toastSelectShape;
  String get toastCannotPlace;

  // Ana ekran — mod kartları
  String get modeClassicName;
  String get modeClassicDesc;
  String get modeColorChefName;
  String get modeColorChefDesc;
  String get modeTimeTrialName;
  String get modeTimeTrialDesc;
  String get modeZenName;
  String get modeZenDesc;

  // Faz 4: Yeni modlar
  String get modeLevelName;
  String get modeLevelDesc;
  String get modeDuelName;
  String get modeDuelDesc;

  // Ana ekran — diğer
  String get homeSubtitle;
  String get homeBadgeBeginning;
  String get homeScoreLast;
  String get homeScoreBest;
  String get homeScoreBeatIt;
  String get homeScoreNewBest;
  String get navLeaderboard;
  String get navShop;
  String get navSettings;

  // Ayarlar
  String get settingsTitle;
  String get settingsSectionLanguage;
  String get settingsLanguage;
  String get settingsSectionAudio;
  String get settingsSfx;
  String get settingsMusic;
  String get settingsSectionFeedback;
  String get settingsHaptics;
  String get settingsSectionAccessibility;
  String get settingsColorBlind;
  String get settingsReduceMotion;
  String get settingsSectionAbout;
  String get settingsVersion;
  String get settingsDeveloper;

  // Tema
  String get settingsSectionTheme;
  String get settingsThemeSystem;
  String get settingsThemeLight;
  String get settingsThemeDark;

  // Color Chef
  String get chefTargetLabel;
  String get chefLevelLabel;
  String get chefLevelComplete;
  String get chefAllComplete;
  String get chefContinue;

  // Renk körü ilk açılış dialog'u
  String get colorblindDialogTitle;
  String get colorblindDialogMessage;
  String get colorblindDialogEnable;
  String get colorblindDialogSkip;

  // Onboarding
  String get onboardingSkip;
  String get onboardingNext;
  String get onboardingStart;
  String get onboardingStep1Title;
  String get onboardingStep1Desc;
  String get onboardingStep2Title;
  String get onboardingStep2Desc;
  String get onboardingStep3Title;
  String get onboardingStep3Desc;
  String get onboardingTapToPlace;
  String get onboardingGreat;
  String get onboardingLoreTitle;
  String get onboardingLoreLine1;
  String get onboardingLoreLine2;
  String get onboardingLoreLine3;

  // World tips (loading screen / hints)
  String get tipWorldColors;
  String get tipWorldSynthesis;
  String get tipWorldJel;
  String get tipWorldIsland;

  // Streak
  String get streakDays;
  String get streakRewardTitle;
  String get streakRewardClaim;

  // Günlük Bulmaca
  String get dailyTitle;
  String get dailyPlayButton;
  String get dailyCompleted;
  String get dailyScore;
  String get dailyShareResult;

  // Kullanıcı adı
  String get settingsUsernameLabel;
  String get settingsUsernameTitle;
  String get settingsUsernameHint;
  String get settingsUsernameSave;
  String get settingsUsernameErrorEmpty;
  String get settingsUsernameErrorTooLong;
  String get settingsUsernameErrorInvalidChars;

  // Veri Gizliliği (GDPR)
  String get settingsSectionPrivacy;
  String get settingsAnalytics;
  String get settingsDeleteAccount;
  String get settingsDeleteConfirmTitle;
  String get settingsDeleteConfirmMessage;
  String get settingsDeleteConfirmAction;
  String get settingsDeleteCancel;
  String get settingsExportData;
  String get settingsExportSuccess;

  // GDPR Consent Dialog
  String get consentTitle;
  String get consentMessage;
  String get consentAccept;
  String get consentDecline;

  // Sıralama
  String get leaderboardTitle;
  String get leaderboardComingSoon;
  String get leaderboardTabClassic;
  String get leaderboardTabTimeTrial;
  String get leaderboardFilterWeekly;
  String get leaderboardFilterAllTime;
  String get leaderboardEmpty;
  String get leaderboardYourRank;

  // Mağaza & IAP
  String get shopTitle;
  String get shopComingSoon;
  String get shopSectionRemoveAds;
  String get shopSectionSoundPacks;
  String get shopSectionTexturePacks;
  String get shopSectionSubscription;
  String get shopRemoveAds;
  String get shopRemoveAdsDesc;
  String get shopSoundCrystal;
  String get shopSoundCrystalDesc;
  String get shopSoundForest;
  String get shopSoundForestDesc;
  String get shopTexturePack;
  String get shopTexturePackDesc;
  String get shopStarterPack;
  String get shopStarterPackDesc;
  String get shopRestorePurchases;
  String get shopPurchaseSuccess;
  String get shopPurchaseError;

  // Gloo+ Abonelik
  String get glooPlusTitle;
  String get glooPlusDesc;
  String get glooPlusMonthly;
  String get glooPlusQuarter;
  String get glooPlusYearly;
  String get glooPlusBadge;
  String get premiumRequired;
  String get premiumUnlock;

  // Koleksiyon
  String get collectionTitle;
  String get collectionDiscovered;
  String get collectionLocked;
  String get collectionEmpty;

  // Redeem Code
  String get redeemCodeTitle;
  String get redeemCodeHint;
  String get redeemCodeButton;
  String get redeemCodeSuccess;
  String get redeemCodeInvalid;
  String get redeemCodeAlreadyUsed;

  // Erisilebilirlik
  String get backLabel;

  // Genel hata
  String get errorOccurred;

  // GDPR Silme Sonucu
  String get deleteDataSuccess;
  String get deleteDataError;

  // Oyun içi toast & badge
  String get toastRescueBadge;
  String get toastBombEarned;
  String get toastHighScoreBadge;
  String get toastExtraMoves;
  String get toastBombFailed;
  String get toastSelectShapeFirst;
  String get toastBombSelectCenter;
  String get toastFrozen;
  String get toastSynthesis;
  String get tipSynthesisTradeoff;
  String get tipEpicApproach;

  // Koleksiyon tamamlama
  String get collectionComplete;

  // Renk adları (Color Chef & Koleksiyon)
  String get colorRed;
  String get colorYellow;
  String get colorBlue;
  String get colorOrange;
  String get colorGreen;
  String get colorPurple;
  String get colorPink;
  String get colorLightBlue;
  String get colorLime;
  String get colorMaroon;
  String get colorBrown;
  String get colorWhite;

  // H.13: Hardcoded string'ler → l10n
  String get levelLabel;
  String get duelLabel;
  String get pvpWinLabel;
  String get pvpLossLabel;
  String get pvpRatioLabel;
  String get cancelLabel;
  String get playAgainLabel;
  String get mainMenuLabel;
  String get nextLevelLabel;
  String get levelListLabel;
  String get watchAdLabel;
  String get newBadge;
  String get islandLabel;
  String get characterLabel;
  String get seasonLabel;

  // Level complete & second chance
  String get levelCompleteAnnounce;
  String get completedLabel;
  String get secondChanceMoves;

  // ELO lig adları
  String get leagueBronze;
  String get leagueSilver;
  String get leagueGold;
  String get leagueDiamond;
  String get leagueGlooMaster;

  // Paylaşım koçanı (viral)
  String get sharePromptTitle;
  String get sharePromptMessage;
  String get sharePromptShare;
  String get sharePromptSkip;

  // İlk oyun öğreticisi
  String get tutorialStep1;
  String get tutorialStep2;
  String get tutorialStep3;
  String get tutorialGotIt;

  // Level section names
  String get levelSectionGelValley;
  String get levelSectionIcyFields;
  String get levelSectionStoneMaze;
  String get levelSectionColorGarden;
  String get levelSectionDarkCellar;

  // PvP / Duel UI
  String get duelSearchMatch;
  String get duelSearching;
  String duelWaitSeconds(int current, int max);
  String get duelOutcomeWin;
  String get duelOutcomeLoss;
  String get duelOutcomeDraw;
  String get duelYou;
  String get duelVs;
  String get duelOpponent;
  String duelGelReward(int amount);

  // Share texts
  String shareScoreCaption(String modeName, String score);
  String shareDailyCaption(String dateLabel, String score);
  String shareComboCaption(String comboLabel, String modeName, String score);
  String get shareScoreChallenge;
  String get shareDailyChallenge;

  // Colorblind inline prompt (Game Over)
  String get colorblindPromptText;
  String get colorblindPromptAction;

  // Personal record comparison (Game Over)
  String get gameOverNewStatRecord;
  String gameOverRecordComparison(int current, int record);

  // GD.MO2: Watch Ad → Free Bomb (Game Over)
  String get gameOverWatchAdBomb;

  // GD.RO12: Share high score button
  String get gameOverShareScore;

  // GD.RO7: Progressive mode unlock
  String modeLockedGames(int remaining);

  // GD.PO6: PvP Leaderboard tab
  String get leaderboardTabPvp;

  // GD.RO11: Streak Freeze
  String get streakFreezeLabel;
  String get streakFreezeUsed;
  String get streakFreezeBuy;

  // GD.MO5: Jel Özü consumable IAP
  String get shopJelOzu100;
  String get shopJelOzu500;
  String get shopSectionCurrency;

  // GD.O4: Level 1-10 mikro görevler
  String get levelMicroTask1;
  String get levelMicroTask2;
  String get levelMicroTask3;
  String get levelMicroTask4;
  String get levelMicroTask5;
  String get levelMicroTask6;
  String get levelMicroTask7;
  String get levelMicroTask8;
  String get levelMicroTask9;
  String get levelMicroTask10;
  String get levelSelectTitle;

  // GD.PO10: Rematch
  String get duelRematch;

  // GD.MO4: Daily Quests
  String get questsTitle;
  String get weeklyQuestsTitle;
  String get questsCompleted;

  // UX-03: Grid hücre semantics label'ları
  String get semanticsCellEmpty;
  String get semanticsCellPreview;
  String get semanticsCellStone;
  String get semanticsCellIce;
  String get semanticsCellLocked;
  String get semanticsCellGravity;
  String get semanticsCellRainbow;

  // UX-05: Shop tab labels
  String get shopTabCurrency;
  String get shopTabPromo;

  // UX-03: Power-up semantics label'ları
  String get semanticsPowerUpRotate;
  String get semanticsPowerUpBomb;
  String get semanticsPowerUpUndo;
  String get semanticsPowerUpFreeze;
  String get semanticsPowerUpPeek;

  // UX-07: Quick Play
  String get quickPlayLabel;

  // Notifications
  String get notifStreakTitle;
  String get notifStreakBody;
  String get notifDailyTitle;
  String get notifDailyBody;
  String get notifComebackTitle;
  String get notifComebackBody;
  String get settingsNotifications;

  // CD.12-15: Character screen section headers
  String get sectionPersonalities;
  String get sectionCharacter;
  String get sectionTalents;

  // CD.12-15: Share collection caption
  String shareCollectionCaption(int found, int total);

  // CD.31: Mod flavor text (dünya dili alt başlıkları)
  String get modeClassicFlavor;
  String get modeColorChefFlavor;
  String get modeTimeTrialFlavor;
  String get modeZenFlavor;
  String get modeLevelFlavor;
  String get modeDuelFlavor;
  String get modeDailyFlavor;

  // CD.31: Rank label (ELO → dünya dili)
  String get rankLabel;

  // CD.34: ELO değerini dil-uyumlu biçimde interpolate eder (ör. "1200 Power" / "パワー 1200")
  String eloDisplay(int elo);

  // CD.12: Kişilik arketipleri
  String get personalityOrange;
  String get personalityGreen;
  String get personalityPurple;
  String get personalityPink;
  String get personalityLightBlue;
  String get personalityLime;
  String get personalityMaroon;
  String get personalityBrown;

  /// GelColor enum'undan çevrilmiş renk adını döner.
  String colorName(GelColor color) => switch (color) {
        GelColor.red => colorRed,
        GelColor.yellow => colorYellow,
        GelColor.blue => colorBlue,
        GelColor.orange => colorOrange,
        GelColor.green => colorGreen,
        GelColor.purple => colorPurple,
        GelColor.pink => colorPink,
        GelColor.lightBlue => colorLightBlue,
        GelColor.lime => colorLime,
        GelColor.maroon => colorMaroon,
        GelColor.brown => colorBrown,
        GelColor.white => colorWhite,
      };

  /// Mikro görev anahtarından çevrilmiş metni döner.
  String? microTaskText(String? key) => switch (key) {
        'levelMicroTask1' => levelMicroTask1,
        'levelMicroTask2' => levelMicroTask2,
        'levelMicroTask3' => levelMicroTask3,
        'levelMicroTask4' => levelMicroTask4,
        'levelMicroTask5' => levelMicroTask5,
        'levelMicroTask6' => levelMicroTask6,
        'levelMicroTask7' => levelMicroTask7,
        'levelMicroTask8' => levelMicroTask8,
        'levelMicroTask9' => levelMicroTask9,
        'levelMicroTask10' => levelMicroTask10,
        _ => null,
      };

  // Skill Profile
  String get skillProfileTitle;
  String get skillGridEfficiency;
  String get skillSynthesis;
  String get skillCombo;
  String get skillPressure;

  // Factory: sistem diline göre doğru implementasyonu döner
  static AppStrings forLocale(Locale locale) {
    return switch (locale.languageCode) {
      'en' => StringsEn(),
      'de' => StringsDe(),
      'zh' => StringsZh(),
      'ja' => StringsJa(),
      'ko' => StringsKo(),
      'ru' => StringsRu(),
      'es' => StringsEs(),
      'fr' => StringsFr(),
      'hi' => StringsHi(),
      'pt' => StringsPt(),
      'ar' => StringsAr(),
      'tr' => StringsTr(),
      _ => StringsEn(), // Desteklenmeyen diller → İngilizce
    };
  }
}
