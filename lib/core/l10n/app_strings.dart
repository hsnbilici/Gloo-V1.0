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

  // Yaş kapısı (COPPA)
  String get ageGateTitle;
  String get ageGateMessage;
  String get ageGateConfirm;
  String get ageGateUnder13;

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

  // Share texts
  String shareScoreCaption(String modeName, String score);
  String shareDailyCaption(String dateLabel, String score);
  String shareComboCaption(String comboLabel, String modeName, String score);
  String get shareScoreChallenge;
  String get shareDailyChallenge;

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
