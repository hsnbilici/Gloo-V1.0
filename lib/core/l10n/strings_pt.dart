import 'app_strings.dart';

class StringsPt extends AppStrings {
  @override String get scoreLabel => 'PONTOS';
  @override String get modeLabelClassic => 'CLÁSSICO';
  @override String get modeLabelColorChef => 'COLOR CHEF';
  @override String get modeLabelTimeTrial => 'TEMPO';
  @override String get modeLabelZen => 'ZEN';
  @override String get modeLabelDaily => 'DIÁRIO';

  @override String get pauseTitle => 'PAUSADO';
  @override String get pauseResume => 'Continuar';
  @override String get pauseHome => 'Menu Principal';

  @override String get gameOverTitle => 'FIM DE JOGO';
  @override String get gameOverScoreLabel => 'PONTOS';
  @override String get gameOverNewRecord => 'NOVO RECORDE!';
  @override String get gameOverGridFill => 'Grade Preenchida';
  @override String get gameOverModeClassic => 'CLÁSSICO';
  @override String get gameOverModeColorChef => 'COLOR CHEF';
  @override String get gameOverModeTimeTrial => 'CONTRA O TEMPO';
  @override String get gameOverModeZen => 'ZEN';
  @override String get gameOverModeDaily => 'PUZZLE DIÁRIO';
  @override String get gameOverReplay => 'Jogar Novamente';
  @override String get gameOverHome => 'Menu Principal';

  @override String get comboSmall => 'COMBO';
  @override String get comboMedium => 'SUPER COMBO';
  @override String get comboLarge => 'MEGA COMBO';
  @override String get comboEpic => 'COMBO ÉPICO';

  @override String get nearMissStandard => 'QUASE!';
  @override String get nearMissCritical => 'CRÍTICO!';

  @override String get toastSlotUsed => 'Espaço já utilizado';
  @override String get toastSelectShape => 'Selecione uma forma primeiro';
  @override String get toastCannotPlace => 'Não pode ser colocado aqui';

  @override String get modeClassicName => 'Clássico';
  @override String get modeClassicDesc => 'Jogue até a grade ficar cheia';
  @override String get modeColorChefName => 'Color Chef';
  @override String get modeColorChefDesc => 'Sintetize a cor alvo';
  @override String get modeTimeTrialName => 'Contra o Tempo';
  @override String get modeTimeTrialDesc => '90 segundos — perfeito para TikTok';
  @override String get modeZenName => 'Zen';
  @override String get modeZenDesc => 'Sem pontos, sem timer — puro ASMR';
  @override String get modeLevelName => 'Níveis';
  @override String get modeLevelDesc => 'Mapas com obstáculos, dificuldade crescente';
  @override String get modeDuelName => 'Duelo';
  @override String get modeDuelDesc => 'Derrote seu rival, ganhe ELO';

  @override String get homeSubtitle => 'A S M R   P U Z Z L E';
  @override String get homeBadgeBeginning => 'INICIANTE';
  @override String get navLeaderboard => 'Ranking';
  @override String get navShop => 'Loja';
  @override String get navSettings => 'Configurações';

  @override String get settingsTitle => 'Configurações';
  @override String get settingsSectionLanguage => 'IDIOMA';
  @override String get settingsLanguage => 'Idioma do App';
  @override String get settingsSectionAudio => 'ÁUDIO';
  @override String get settingsSfx => 'Efeitos Sonoros';
  @override String get settingsMusic => 'Música';
  @override String get settingsSectionFeedback => 'FEEDBACK';
  @override String get settingsHaptics => 'Vibração Háptica';
  @override String get settingsSectionAccessibility => 'ACESSIBILIDADE';
  @override String get settingsColorBlind => 'Modo Daltonismo';
  @override String get settingsSectionAbout => 'SOBRE';
  @override String get settingsVersion => 'Versão';
  @override String get settingsDeveloper => 'Desenvolvedor';

  @override String get chefTargetLabel => 'ALVO';
  @override String get chefLevelLabel => 'NÍVEL';
  @override String get chefLevelComplete => 'NÍVEL COMPLETO';
  @override String get chefAllComplete => 'TODOS OS NÍVEIS COMPLETOS';
  @override String get chefContinue => 'Continuar';

  @override String get colorblindDialogTitle => 'Acessibilidade';
  @override String get colorblindDialogMessage => 'Você tem dificuldade em distinguir cores? Gostaria de ativar o Modo Daltonismo?';
  @override String get colorblindDialogEnable => 'Ativar';
  @override String get colorblindDialogSkip => 'Não, obrigado';

  @override String get onboardingSkip => 'Pular';
  @override String get onboardingNext => 'Próximo';
  @override String get onboardingStart => 'Jogar!';
  @override String get onboardingStep1Title => 'Coloque os Gels';
  @override String get onboardingStep1Desc => 'Selecione uma forma da sua mão e coloque na grade. Linhas e colunas completas são limpas automaticamente.';
  @override String get onboardingStep2Title => 'Faça Combos';
  @override String get onboardingStep2Desc => 'Limpe linhas consecutivamente! Cada cadeia aumenta seu multiplicador e preenche sua pontuação.';
  @override String get onboardingStep3Title => 'Sintetize Cores';
  @override String get onboardingStep3Desc => 'Cores primárias adjacentes se fundem automaticamente para criar novas cores. Descubra combinações raras!';

  @override String get streakDays => 'DIAS';

  @override String get dailyTitle => 'Puzzle Diário';
  @override String get dailyPlayButton => 'Jogar Hoje';
  @override String get dailyCompleted => 'Concluído';
  @override String get dailyScore => 'Pontuação de Hoje';
  @override String get dailyShareResult => 'Compartilhar';

  @override String get settingsSectionPrivacy => 'PRIVACIDADE';
  @override String get settingsAnalytics => 'Análises e Relatórios de Falhas';
  @override String get settingsDeleteAccount => 'Excluir Todos os Dados';
  @override String get settingsDeleteConfirmTitle => 'Excluir Todos os Dados?';
  @override String get settingsDeleteConfirmMessage => 'Pontuações, sequências e todas as preferências serão excluídas permanentemente. Isso não pode ser desfeito.';
  @override String get settingsDeleteConfirmAction => 'Excluir';
  @override String get settingsDeleteCancel => 'Cancelar';

  @override String get leaderboardTitle => 'Ranking';
  @override String get leaderboardComingSoon => 'Ranking online em breve';
  @override String get leaderboardTabClassic => 'Clássico';
  @override String get leaderboardTabTimeTrial => 'Contra o Tempo';
  @override String get leaderboardFilterWeekly => 'Semanal';
  @override String get leaderboardFilterAllTime => 'Geral';
  @override String get leaderboardEmpty => 'Nenhuma pontuação ainda';
  @override String get leaderboardYourRank => 'Sua Posição';

  @override String get shopTitle => 'Loja';
  @override String get shopComingSoon => 'Em Breve';
  @override String get shopSectionRemoveAds => 'SEM ANÚNCIOS';
  @override String get shopSectionSoundPacks => 'PACOTES DE SOM';
  @override String get shopSectionTexturePacks => 'PACOTES DE TEXTURA';
  @override String get shopSectionSubscription => 'GLOO+';
  @override String get shopRemoveAds => 'Remover Anúncios';
  @override String get shopRemoveAdsDesc => 'Remova todos os anúncios permanentemente';
  @override String get shopSoundCrystal => 'Cristal ASMR';
  @override String get shopSoundCrystalDesc => '15 efeitos sonoros de cristal';
  @override String get shopSoundForest => 'Floresta Profunda';
  @override String get shopSoundForestDesc => 'Sons da natureza + perfil háptico';
  @override String get shopTexturePack => 'Pacote de Texturas Gel';
  @override String get shopTexturePackDesc => '20 novas aparências de gel';
  @override String get shopStarterPack => 'Pacote Inicial';
  @override String get shopStarterPackDesc => 'Sem anúncios + 2 pacotes de som + 1 pacote de textura';
  @override String get shopRestorePurchases => 'Restaurar Compras';
  @override String get shopPurchaseSuccess => 'Compra realizada!';
  @override String get shopPurchaseError => 'Falha na compra';

  @override String get glooPlusTitle => 'Gloo+';
  @override String get glooPlusDesc => 'Sem anúncios, todos os pacotes de som, Modo Zen, acesso antecipado';
  @override String get glooPlusMonthly => 'Mensal';
  @override String get glooPlusYearly => 'Anual';
  @override String get glooPlusBadge => 'MELHOR VALOR';
  @override String get premiumRequired => 'Gloo+ Necessário';
  @override String get premiumUnlock => 'Desbloquear';

  @override String get collectionTitle => 'Coleção';
  @override String get collectionDiscovered => 'Descobertas';
  @override String get collectionLocked => 'Bloqueado';
  @override String get collectionEmpty => 'Nenhuma cor descoberta ainda. Jogue para encontrar cores raras!';

  @override String get redeemCodeTitle => 'RESGATAR CÓDIGO';
  @override String get redeemCodeHint => 'Digite seu código';
  @override String get redeemCodeButton => 'Resgatar';
  @override String get redeemCodeSuccess => 'Código resgatado com sucesso!';
  @override String get redeemCodeInvalid => 'Código inválido ou expirado';
  @override String get redeemCodeAlreadyUsed => 'Este código já foi utilizado';
}
