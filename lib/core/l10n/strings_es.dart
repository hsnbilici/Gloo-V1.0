import 'app_strings.dart';

class StringsEs extends AppStrings {
  @override String get scoreLabel => 'PUNTOS';
  @override String get modeLabelClassic => 'CLÁSICO';
  @override String get modeLabelColorChef => 'CHEF DE COLOR';
  @override String get modeLabelTimeTrial => 'TIEMPO';
  @override String get modeLabelZen => 'ZEN';
  @override String get modeLabelDaily => 'DIARIO';

  @override String get pauseTitle => 'EN PAUSA';
  @override String get pauseResume => 'Continuar';
  @override String get pauseHome => 'Menú principal';

  @override String get gameOverTitle => 'FIN DEL JUEGO';
  @override String get gameOverScoreLabel => 'PUNTOS';
  @override String get gameOverNewRecord => '¡NUEVO RÉCORD!';
  @override String get gameOverGridFill => 'Llenado de cuadrícula';
  @override String get gameOverModeClassic => 'CLÁSICO';
  @override String get gameOverModeColorChef => 'CHEF DE COLOR';
  @override String get gameOverModeTimeTrial => 'CONTRARRELOJ';
  @override String get gameOverModeZen => 'ZEN';
  @override String get gameOverModeDaily => 'DIARIO';
  @override String get gameOverReplay => 'Jugar de nuevo';
  @override String get gameOverHome => 'Menú principal';

  @override String get comboSmall => 'COMBO';
  @override String get comboMedium => 'SUPER COMBO';
  @override String get comboLarge => 'MEGA COMBO';
  @override String get comboEpic => 'COMBO ÉPICO';

  @override String get nearMissStandard => '¡CASI!';
  @override String get nearMissCritical => '¡CRÍTICO!';

  @override String get toastSlotUsed => 'Ranura ya usada';
  @override String get toastSelectShape => 'Primero elige una forma';
  @override String get toastCannotPlace => 'No se puede colocar aquí';

  @override String get modeClassicName => 'Clásico';
  @override String get modeClassicDesc => 'Juega hasta llenar la cuadrícula';
  @override String get modeColorChefName => 'Chef de Color';
  @override String get modeColorChefDesc => 'Sintetiza el color objetivo';
  @override String get modeTimeTrialName => 'Contrarreloj';
  @override String get modeTimeTrialDesc => '90 segundos — perfecto para TikTok';
  @override String get modeZenName => 'Zen';
  @override String get modeZenDesc => 'Sin puntos, sin tiempo — ASMR puro';
  @override String get modeLevelName => 'Niveles';
  @override String get modeLevelDesc => 'Mapas con obstáculos';
  @override String get modeDuelName => 'Duelo';
  @override String get modeDuelDesc => 'Vence a tu rival, gana ELO';

  @override String get homeSubtitle => 'A S M R   P U Z Z L E';
  @override String get homeBadgeBeginning => 'PRINCIPIANTE';
  @override String get navLeaderboard => 'Clasificación';
  @override String get navShop => 'Tienda';
  @override String get navSettings => 'Ajustes';

  @override String get settingsTitle => 'Ajustes';
  @override String get settingsSectionLanguage => 'IDIOMA';
  @override String get settingsLanguage => 'Idioma de la app';
  @override String get settingsSectionAudio => 'AUDIO';
  @override String get settingsSfx => 'Efectos de sonido';
  @override String get settingsMusic => 'Música';
  @override String get settingsSectionFeedback => 'RETROALIMENTACIÓN';
  @override String get settingsHaptics => 'Vibración háptica';
  @override String get settingsSectionAccessibility => 'ACCESIBILIDAD';
  @override String get settingsColorBlind => 'Modo daltonismo';
  @override String get settingsSectionAbout => 'ACERCA DE';
  @override String get settingsVersion => 'Versión';
  @override String get settingsDeveloper => 'Desarrollador';

  @override String get chefTargetLabel => 'OBJETIVO';
  @override String get chefLevelLabel => 'NIVEL';
  @override String get chefLevelComplete => 'NIVEL COMPLETADO';
  @override String get chefAllComplete => 'TODOS LOS NIVELES';
  @override String get chefContinue => 'Continuar';

  @override String get colorblindDialogTitle => 'Accesibilidad';
  @override String get colorblindDialogMessage => '¿Tiene dificultades para distinguir colores? ¿Desea activar el modo daltonismo?';
  @override String get colorblindDialogEnable => 'Activar';
  @override String get colorblindDialogSkip => 'No, gracias';

  @override String get onboardingSkip => 'Saltar';
  @override String get onboardingNext => 'Siguiente';
  @override String get onboardingStart => '¡Jugar!';
  @override String get onboardingStep1Title => 'Coloca geles';
  @override String get onboardingStep1Desc => 'Selecciona una forma de tu mano y colócala en la cuadrícula. Las filas o columnas llenas se borran automáticamente.';
  @override String get onboardingStep2Title => 'Haz combos';
  @override String get onboardingStep2Desc => '¡Limpia líneas una tras otra! Cada cadena aumenta el multiplicador y acumula puntos.';
  @override String get onboardingStep3Title => 'Sintetiza colores';
  @override String get onboardingStep3Desc => 'Los colores primarios adyacentes se fusionan automáticamente para crear nuevos. ¡Descubre combinaciones raras!';

  @override String get streakDays => 'DÍAS';

  @override String get dailyTitle => 'Rompecabezas diario';
  @override String get dailyPlayButton => 'Jugar hoy';
  @override String get dailyCompleted => 'Completado';
  @override String get dailyScore => 'Puntuación de hoy';
  @override String get dailyShareResult => 'Compartir';

  @override String get settingsSectionPrivacy => 'PRIVACIDAD';
  @override String get settingsAnalytics => 'Análisis e informes de fallos';
  @override String get settingsDeleteAccount => 'Eliminar todos los datos';
  @override String get settingsDeleteConfirmTitle => '¿Eliminar todos los datos?';
  @override String get settingsDeleteConfirmMessage => 'Los puntos, rachas y todas las preferencias se eliminarán permanentemente. Esta acción no se puede deshacer.';
  @override String get settingsDeleteConfirmAction => 'Eliminar';
  @override String get settingsDeleteCancel => 'Cancelar';

  @override String get leaderboardTitle => 'Clasificación';
  @override String get leaderboardComingSoon => 'Clasificación en línea próximamente';
  @override String get shopTitle => 'Tienda';
  @override String get shopComingSoon => 'Próximamente';

  // --- Faz 3: Leaderboard ---
  @override String get leaderboardTabClassic => 'Clásico';
  @override String get leaderboardTabTimeTrial => 'Contrarreloj';
  @override String get leaderboardFilterWeekly => 'Semanal';
  @override String get leaderboardFilterAllTime => 'Todo el tiempo';
  @override String get leaderboardEmpty => 'Sin puntuaciones aún';
  @override String get leaderboardYourRank => 'Tu rango';

  // --- Faz 3: Shop ---
  @override String get shopSectionRemoveAds => 'SIN ANUNCIOS';
  @override String get shopSectionSoundPacks => 'PAQUETES DE SONIDO';
  @override String get shopSectionTexturePacks => 'PAQUETES DE TEXTURA';
  @override String get shopSectionSubscription => 'GLOO+';
  @override String get shopRemoveAds => 'Eliminar anuncios';
  @override String get shopRemoveAdsDesc => 'Eliminar todos los anuncios permanentemente';
  @override String get shopSoundCrystal => 'Cristal ASMR';
  @override String get shopSoundCrystalDesc => '15 efectos de sonido cristal';
  @override String get shopSoundForest => 'Bosque Profundo';
  @override String get shopSoundForestDesc => 'Sonidos de la naturaleza + perfil háptico';
  @override String get shopTexturePack => 'Paquete de texturas gel';
  @override String get shopTexturePackDesc => '20 nuevas apariencias de gel';
  @override String get shopStarterPack => 'Paquete inicial';
  @override String get shopStarterPackDesc => 'Sin anuncios + 2 paquetes de sonido + 1 paquete de textura';
  @override String get shopRestorePurchases => 'Restaurar compras';
  @override String get shopPurchaseSuccess => 'Compra exitosa!';
  @override String get shopPurchaseError => 'Error en la compra';

  // --- Faz 3: Gloo+ ---
  @override String get glooPlusTitle => 'Gloo+';
  @override String get glooPlusDesc => 'Sin anuncios todos los paquetes de sonido Modo Zen acceso anticipado';
  @override String get glooPlusMonthly => 'Mensual';
  @override String get glooPlusYearly => 'Anual';
  @override String get glooPlusBadge => 'MEJOR VALOR';
  @override String get premiumRequired => 'Se requiere Gloo+';
  @override String get premiumUnlock => 'Desbloquear';

  // --- Faz 3: Collection ---
  @override String get collectionTitle => 'Colección';
  @override String get collectionDiscovered => 'Descubierto';
  @override String get collectionLocked => 'Bloqueado';
  @override String get collectionEmpty => 'Aún no se han descubierto colores. ¡Juega para encontrar colores raros!';

  @override String get redeemCodeTitle => 'CANJEAR CÓDIGO';
  @override String get redeemCodeHint => 'Ingresa tu código';
  @override String get redeemCodeButton => 'Canjear';
  @override String get redeemCodeSuccess => '¡Código canjeado exitosamente!';
  @override String get redeemCodeInvalid => 'Código inválido o expirado';
  @override String get redeemCodeAlreadyUsed => 'Este código ya ha sido utilizado';
}
