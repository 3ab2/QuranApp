// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Application Coran';

  @override
  String get homeQuran => 'Coran';

  @override
  String get homeTafsir => 'Tafsir';

  @override
  String get homeAudio => 'Récitations';

  @override
  String get homeStories => 'Histoires des prophètes';

  @override
  String get homeAdhan => 'Adhan';

  @override
  String get homeMiracles => 'Miracles';

  @override
  String get homeSettings => 'Paramètres';

  @override
  String get topBarAbout => 'À propos';

  @override
  String get topBarHelp => 'Aide';

  @override
  String get topBarRate => 'Nous noter';

  @override
  String get topBarSources => 'Sources fiables';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAdhanEnabled => 'Activer l\'Adhan';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsPrayerReminder => 'Rappel de prière';

  @override
  String get settingsSelectReciter => 'Choisir le récitateur';

  @override
  String get settingsSelectLanguage => 'Choisir la langue';

  @override
  String get settingsVolume => 'Niveau du volume';

  @override
  String get settingsClearTempData => 'Supprimer les données temporaires';

  @override
  String get settingsTempDataDeleted => 'Données temporaires supprimées';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get audioPageTitle => 'Écouter la récitation';

  @override
  String get audioLoadError =>
      'Impossible de charger la liste audio des sourates.';

  @override
  String get audioLocalPlayback => 'Lecture depuis le fichier local téléchargé';

  @override
  String get audioPlayError =>
      'Impossible de lancer la récitation. Aucun fichier local valide ni source en ligne disponible.';

  @override
  String get adhanPageTitle => 'Adhan et horaires de prière';

  @override
  String get adhanLoadingPrayerTimes => 'Chargement des horaires de prière...';

  @override
  String get adhanLocationNotDetected => 'Votre position n\'a pas été détectée';

  @override
  String get adhanLocationPrompt =>
      'Appuyez sur Paramètres pour choisir votre position';

  @override
  String get adhanLocationSettings => 'Paramètres de position';

  @override
  String get tafsirTitle => 'Tafsir Al-Muyassar';

  @override
  String get tafsirLoading => 'Chargement du tafsir...';

  @override
  String get tafsirRetry => 'Réessayer';

  @override
  String get tafsirFetchError =>
      'Impossible de récupérer le tafsir. Veuillez réessayer plus tard.';

  @override
  String get tafsirNetworkError =>
      'Erreur réseau. Vérifiez votre connexion puis réessayez.';

  @override
  String tafsirContextTitle(Object surah, Object ayah) {
    return 'Tafsir - Sourate $surah Verset $ayah';
  }

  @override
  String get storyPlay => 'Lire l\'histoire';

  @override
  String get storyPauseAudio => 'Pause';

  @override
  String get playbackSpeedSheetTitle => 'Vitesse de lecture';

  @override
  String get storyYoutubeStreamUnavailable =>
      'Impossible de démarrer le flux de narration. Vérifiez la connexion et réessayez.';

  @override
  String get storyYoutubeWebAudioUnavailable =>
      'La narration des histoires en arrière-plan n’est pas disponible dans le navigateur web. Utilisez l’application sur téléphone ou tablette.';

  @override
  String get storyStop => 'Arrêter l\'audio';

  @override
  String get storyAudioError => 'Impossible de lire l\'audio de l\'histoire.';

  @override
  String get storyNoAudio => 'Aucune narration disponible pour cette histoire';

  @override
  String get storyLoadError =>
      'Les histoires sont indisponibles pour le moment.';

  @override
  String get storyRetry => 'Réessayer';

  @override
  String get storyReadDone => 'Lecture terminée';

  @override
  String get prophetStoriesSearchHint =>
      'Rechercher un prophète ou une histoire…';

  @override
  String get prophetStoriesSearchEmpty =>
      'Aucune histoire de prophète ne correspond. Essayez d’autres mots.';

  @override
  String get prophetStoriesSearchOpenTooltip => 'Rechercher dans les histoires';

  @override
  String get surahSearchHint => 'Rechercher dans les versets...';

  @override
  String get surahIncreaseFont => 'Augmenter la taille du texte';

  @override
  String get surahDecreaseFont => 'Réduire la taille du texte';

  @override
  String get surahOpenTafsir => 'Ouvrir le tafsir';

  @override
  String get tafsirUnavailableForAyah =>
      'Le tafsir n\'est pas disponible pour ce contexte.';

  @override
  String get surahOpenTafsirCurrentAyah =>
      'Ouvrir le tafsir pour le verset sélectionné';

  @override
  String get tafsirSourceMuyassarNote =>
      'Texte principal : Tafsir Al-Muyassar (arabe, Quran.com). Autres éditions bientôt.';

  @override
  String get tafsirSelectSurah => 'Sourate';

  @override
  String get tafsirBrowseSurahs => 'Sourates';

  @override
  String get tafsirAyahNumber => 'Verset';

  @override
  String get tafsirGo => 'Aller';

  @override
  String get tafsirSearchHint =>
      'Verset, tafsir, sourate ou thème scientifique…';

  @override
  String get tafsirSearchCacheHint =>
      'Inclut cette page, les sourates en cache et les miracles.';

  @override
  String get tafsirSearchEmpty =>
      'Aucun résultat. Essayez d’autres mots ou ouvrez une sourate.';

  @override
  String get tafsirJumpInvalidAyah =>
      'Indiquez un numéro de verset valide pour cette sourate.';

  @override
  String get tafsirJumpNotInFeed =>
      'Ce verset n’apparaît pas dans la liste. Il peut être absent dans la source.';

  @override
  String get miraclesOpenTafsir => 'Ouvrir le tafsir Al-Muyassar';

  @override
  String get miraclesContinueInTafsirPage => 'Poursuivre sur la page Tafsir';

  @override
  String get miraclesLoading => 'Chargement…';

  @override
  String get miraclesTafsirPreview => 'Aperçu du tafsir';

  @override
  String get miraclesModerateNote =>
      'Notes courtes et prudentes ; consultez des savants pour la croyance et la jurisprudence.';

  @override
  String get miraclesPageTitle => 'Miracles scientifiques dans le Coran';

  @override
  String get miraclesSearchHint => 'Verset, sujet ou explication scientifique…';

  @override
  String get miraclesEmptyResults => 'Aucun résultat';

  @override
  String get miraclesFilterAll => 'Tout';

  @override
  String get quranContinueReading => 'Reprendre';

  @override
  String get quranBookmarkSaved => 'Position de lecture enregistrée.';

  @override
  String get quranSurahPickerHint => 'Chercher une sourate…';

  @override
  String get quranSurahNumberLabel => 'Sourate';

  @override
  String get quranMadaniShort => 'Médinoise';

  @override
  String get quranMakkiShort => 'Mecquoise';

  @override
  String get quranSearchClose => 'Fermer la recherche';

  @override
  String get quranSearchOpen => 'Rechercher dans le Coran';

  @override
  String get quranSaveBookmark => 'Enregistrer la position';

  @override
  String get quranLineSpacingIncrease => 'Augmenter l’interligne';

  @override
  String get quranLineSpacingDecrease => 'Réduire l’interligne';

  @override
  String get quranMushafModeToggle => 'Mode mushaf (bientôt)';

  @override
  String get quranReaderSearchHint =>
      'Texte du verset, nom ou numéro de sourate…';

  @override
  String get quranSearchEmpty =>
      'Aucun résultat. Essayez d’autres mots ou un numéro de sourate.';

  @override
  String get quranBackToHome => 'Accueil';

  @override
  String get tilawatDownloadComplete =>
      'Sourate enregistrée pour l’écoute hors ligne.';

  @override
  String get tilawatDownloadFailed =>
      'Échec du téléchargement. Vérifiez la connexion.';

  @override
  String get tilawatDownloaded => 'Téléchargée';

  @override
  String get tilawatDownloadForOffline => 'Télécharger pour hors ligne';

  @override
  String get tilawatAutoPlayNext => 'Lecture auto de la sourate suivante';

  @override
  String get tilawatSleepTimer => 'Minuteur de sommeil';

  @override
  String get tilawatSleepOff => 'Désactivé';

  @override
  String tilawatSleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String tilawatSleepEndsAt(String time) {
    return 'Arrêt vers $time';
  }

  @override
  String get tilawatContinueListening => 'Continuer l’écoute';

  @override
  String get tilawatTooltipSleepTimer =>
      'Minuteur de sommeil — choisir l’arrêt';

  @override
  String get tilawatTooltipDownload => 'Télécharger pour écoute hors ligne';

  @override
  String get tilawatTooltipAutoNext =>
      'Lire automatiquement la sourate suivante';

  @override
  String get tilawatTooltipRepeatOne => 'Répéter cette sourate';

  @override
  String tilawatReciterFallbackNotice(String name) {
    return 'Audio du récitateur indisponible. Lecture avec le récitateur par défaut ($name).';
  }

  @override
  String get tilawatSleepChooseDuration => 'Choisir la durée';

  @override
  String get tilawatSleepOneHour => '1 heure';

  @override
  String get tilawatSleepOneHourThirty => '1 h 30';

  @override
  String get tilawatSleepTwoHours => '2 heures';

  @override
  String tilawatSleepActiveRemaining(int minutes) {
    return '$minutes min restantes';
  }

  @override
  String get storyYoutubePlayerTitle => 'Récit de l’histoire';

  @override
  String get storyYoutubeUnavailable =>
      'Aucune narration YouTube vérifiée n’est liée à cette histoire pour le moment.';

  @override
  String get storyYoutubeInvalidChannel =>
      'Cette vidéo ne provient pas d’une chaîne approuvée.';

  @override
  String get storyYoutubeLoadError =>
      'Impossible de charger le lecteur YouTube. Vérifiez votre connexion et réessayez.';

  @override
  String get storyYoutubeNarrator => 'Narrateur';

  @override
  String get storyYoutubePrevious => 'Histoire précédente';

  @override
  String get storyYoutubeNext => 'Histoire suivante';

  @override
  String get storyYoutubeBackgroundHint =>
      'La lecture en arrière-plan dépend de l’appareil ; gardez l’application dans les applications récentes pour de meilleurs résultats.';

  @override
  String get storyYoutubeOpenPlayer => 'Écouter le récit';

  @override
  String get storyYoutubeNoNarration =>
      'Aucune narration disponible pour cette histoire.';

  @override
  String get storyYoutubeSleepTimer => 'Minuteur de sommeil';

  @override
  String get storyYoutubeSleepOff => 'Désactivé';

  @override
  String storyYoutubeSleepMinutes(int minutes) {
    return 'Arrêter après $minutes min';
  }

  @override
  String get storyYoutubeSleepEnded => 'Le minuteur a mis la lecture en pause.';

  @override
  String storyYoutubePlaybackSpeedLabel(String speed) {
    return '${speed}x';
  }

  @override
  String get storyYoutubeCopyLink => 'Copier le lien de la vidéo';

  @override
  String get storyYoutubeLinkCopied =>
      'Lien YouTube copié dans le presse-papiers.';

  @override
  String get storyYoutubeFullscreen => 'Plein écran';

  @override
  String get storyYoutubeDownloadHint =>
      'Utilisez l’icône lien pour copier l’URL. Le téléchargement hors ligne de la vidéo YouTube n’est pas disponible dans cette application.';

  @override
  String get prayerPhaseCalm => 'Prochaine prière';

  @override
  String get prayerPhaseApproaching => 'La prière approche';

  @override
  String get prayerPhaseAtAdhan => 'C’est le moment de la prière';

  @override
  String get prayerPhaseGrace => 'Prenez ce moment avec douceur';

  @override
  String prayerCountdownRemaining(String hms) {
    return 'Restant : $hms';
  }

  @override
  String prayerCurrentPeriod(String name) {
    return 'Période actuelle : $name';
  }

  @override
  String get prayerAtAdhanMoment =>
      'Moment de l’adhan — recentrez-vous doucement sur Allah';

  @override
  String get prayerOpenQibla => 'Qibla';

  @override
  String get prayerAdhanStop => 'Arrêter';

  @override
  String get prayerAdhanSnooze => 'Rappeler';

  @override
  String get prayerAdhanMute => 'Silence';

  @override
  String get prayerAdhanUnmute => 'Son';

  @override
  String get prayerImmersiveHint =>
      'Mouvement discret seulement — pensé pour un cœur apaisé';

  @override
  String get prayerQiblaTitle => 'Qibla';

  @override
  String get prayerQiblaWebUnavailable =>
      'La boussole qibla en direct utilise les capteurs du téléphone et est disponible dans l’application mobile.';

  @override
  String get prayerQiblaLocationDisabled =>
      'Activez la localisation et l’autorisation pour utiliser la boussole qibla.';

  @override
  String get prayerQiblaError =>
      'Impossible de lire la boussole sur cet appareil.';

  @override
  String get prayerQiblaEmulatorUnavailable =>
      'Les capteurs de boussole ne sont pas disponibles sur cet appareil ou émulateur. Utilisez le guide Qibla statique ci-dessous.';

  @override
  String prayerQiblaDistanceKm(String km) {
    return 'Environ $km km jusqu’à la Kaaba';
  }

  @override
  String get prayerQiblaAlignedHint =>
      'Vous êtes aligné — qu’Allah accepte votre prière';

  @override
  String get prayerQiblaRotateHint =>
      'Tournez lentement jusqu’à ce que l’aiguille se stabilise vers la Kaaba';

  @override
  String get prayerQiblaFallbackSubtitle =>
      'Direction de la Qibla depuis votre position';

  @override
  String get prayerQiblaFallbackExplanation =>
      'La boussole en direct a besoin des capteurs magnétiques et d’orientation du téléphone. Elle fonctionne pleinement dans l’application mobile.';

  @override
  String get prayerQiblaFallbackBrowserNote =>
      'Les navigateurs web et les ordinateurs n’exposent souvent pas les capteurs nécessaires à une boussole en direct.';

  @override
  String get prayerQiblaFallbackStaticHint =>
      'Qibla approximative depuis votre position enregistrée';

  @override
  String prayerQiblaFallbackAngle(String angle) {
    return 'Azimut de la Qibla : $angle depuis le nord';
  }

  @override
  String get prayerQiblaFallbackLocationTitle => 'Votre position';

  @override
  String get prayerQiblaFallbackLocationUnknown => 'Position non définie';

  @override
  String get prayerQiblaFallbackLocationHint =>
      'Choisissez votre ville sur la page Prière pour afficher l’angle de la Qibla chez vous.';

  @override
  String get prayerQiblaFallbackKaabaTitle => 'Vers la Kaaba';

  @override
  String get prayerQiblaFallbackMobileTitle => 'Boussole en direct sur mobile';

  @override
  String get prayerQiblaFallbackMobileBody =>
      'Ouvrez l’application sur votre téléphone pour une boussole en temps réel qui suit votre orientation vers la Qibla.';

  @override
  String get prayerQiblaFallbackDragHint =>
      'Glissez doucement pour explorer — relâchez pour vous réaligner sur la Qibla';

  @override
  String get prayerQiblaFallbackInfoTitle => 'La Qibla en un coup d’œil';

  @override
  String get prayerQiblaFallbackAngleLabel => 'Angle Qibla';

  @override
  String get prayerQiblaFallbackDistanceLabel => 'Vers la Kaaba';

  @override
  String get prayerQiblaFallbackHeadingLabel => 'Mode boussole';

  @override
  String get prayerQiblaFallbackHeadingValue => 'Guide statique';

  @override
  String get prayerSettingsReminder => 'Rappel avant la prière';

  @override
  String get prayerReminderEnabledHelp =>
      'Une notification simple quelques minutes avant chaque prière pour vous préparer.';

  @override
  String get prayerAdhanEnabledHelp =>
      'Notification à l\'heure exacte de la prière et lecture manuelle de l\'adhan depuis la liste.';

  @override
  String get prayerReminderPreset5 => '5 min';

  @override
  String get prayerReminderPreset10 => '10 min';

  @override
  String get prayerReminderPreset15 => '15 min';

  @override
  String get prayerReminderCustomHint => 'Personnalisé (1–120 min)';

  @override
  String get prayerMuezzinVoice => 'Voix du muezzin / adhan';

  @override
  String get prayerPreviewVoice => 'Écouter';

  @override
  String get prayerMosqueMode => 'Mode mosquée (expérimental)';

  @override
  String get prayerMosqueModeHelp =>
      'Si activé, un crochet réservé s’exécute dans la fenêtre d’approche. Le mode silencieux complet nécessitera une intégration système ultérieure.';

  @override
  String get prayerAfterAdhkar => 'Après la prière — rappel de dhikr';

  @override
  String get prayerAfterAdhkarBody =>
      'Dites subhan Allah (33), al-hamdu lillah (33), Allahu akbar (33) — ou récitez Ayat al-Kursi avec calme.';

  @override
  String get prayerSpiritualTip0 =>
      'Invoquez Allah avec légèreté — Il est proche.';

  @override
  String get prayerSpiritualTip1 =>
      'Deux rakʿa duha apportent de la lumière à la journée.';

  @override
  String get prayerSpiritualTip2 =>
      'Pausez avant la prière — le silence est aussi une adoration.';

  @override
  String get prayerSpiritualTip3 =>
      'Que le cœur arrive avant que le corps ne se lève.';

  @override
  String get prayerLocationSheetTitle => 'Lieu des prières';

  @override
  String get prayerLocationAutoGps => 'Automatique (GPS)';

  @override
  String get prayerLocationAutoGpsSubtitle =>
      'Utilise votre position actuelle pour les horaires.';

  @override
  String get prayerLocationUseGpsNow => 'Utiliser la position actuelle';

  @override
  String get prayerLocationSearchCountry => 'Rechercher un pays';

  @override
  String get prayerLocationSearchCity => 'Rechercher une ville';

  @override
  String get prayerLocationGpsDenied =>
      'L’autorisation de localisation est nécessaire pour le mode automatique.';

  @override
  String get prayerLocationGpsFailed =>
      'Impossible de lire votre position. Essayez la sélection manuelle.';

  @override
  String get aboutSubtitle =>
      'Clarté, recueillement, et un rythme quotidien apaisant avec le Livre d\'Allah.';

  @override
  String get aboutHeroMission =>
      'Un compagnon discret pour lire, écouter, comprendre et se souvenir.';

  @override
  String get aboutSectionMissionTitle => 'Mission';

  @override
  String get aboutSectionMissionBody =>
      'Rapprocher le Coran, une explication fiable et une écoute saine de votre journée — sans bruit ni surcharge.';

  @override
  String get aboutSectionVisionTitle => 'Vision';

  @override
  String get aboutSectionVisionBody =>
      'Une expérience alignée spirituellement : belle typographie, sources respectueuses, et outils qui favorisent la concentration.';

  @override
  String get aboutSectionWhyTitle => 'Pourquoi cette application';

  @override
  String get aboutSectionWhyBody =>
      'Beaucoup cherchent un lieu de confiance pour la lecture Mushaf, le tafsir, la tilâwat, la prière et des récits mesurés — avec adab et clarté.';

  @override
  String get aboutSectionPillarsTitle => 'Ce que vous y trouverez';

  @override
  String get aboutPillarQuran =>
      'Lecteur du Coran avec recherche, signets et mise en page arabe lisible.';

  @override
  String get aboutPillarTafsir =>
      'Flux tafsir Al-Muyassar pour le contexte à côté des ayāt.';

  @override
  String get aboutPillarTilawat =>
      'Récitations avec téléchargements pour les trajets et la faible connectivité.';

  @override
  String get aboutPillarStories =>
      'Récits des prophètes avec politique de narration prudente et références sélectionnées.';

  @override
  String get aboutSectionPrivacyTitle => 'Confidentialité et respect';

  @override
  String get aboutSectionPrivacyBody =>
      'Nous privilégions l\'usage local quand c\'est possible, peu de surprises, et des choix qui respectent le texte sacré et les limites savantes.';

  @override
  String get aboutSectionOfflineTitle => 'Esprit hors-ligne d\'abord';

  @override
  String get aboutSectionOfflineBody =>
      'Le texte central et les téléchargements sont pensés pour fonctionner quand le réseau faillit — afin que le rappel reste à portée.';

  @override
  String get aboutSectionLangTitle => 'Interface multilingue';

  @override
  String get aboutSectionLangBody =>
      'Arabe, anglais et français pour que familles et étudiants naviguent sereinement.';

  @override
  String get aboutIllustrationCaption =>
      'Barakallahu fikum pour ce chemin ensemble.';

  @override
  String aboutAppVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutCreditsLine =>
      'Conçu avec soin pour la Oumma. Tout bien vient d\'Allah ; toute erreur est la nôtre.';

  @override
  String get helpSubtitle =>
      'Réponses courtes, mise en page calme — moins de recherche, plus de profit.';

  @override
  String get helpCardIntro =>
      'Utilisez les sections ci-dessous pour vous orienter, puis ouvrez la FAQ pour le détail.';

  @override
  String get helpSectionGuides => 'Guides rapides';

  @override
  String get helpGuideQuranTitle => 'Page Coran';

  @override
  String get helpGuideQuranBody =>
      'Ouvrez une sourate, ajustez police et interligne, recherchez des versets, ouvrez le tafsir depuis la barre d\'outils.';

  @override
  String get helpGuideTilawatTitle => 'Tilâwat (récitations)';

  @override
  String get helpGuideTilawatBody =>
      'Choisissez le réciteur dans Réglages, lisez depuis la page audio, agrandissez le mini-lecteur, utilisez le lecteur complet pour vitesse et répétition.';

  @override
  String get helpGuideDownloadTitle => 'Télécharger des sourates';

  @override
  String get helpGuideDownloadBody =>
      'Utilisez l\'action de téléchargement sur la tilâwat quand elle est proposée ; les fichiers sont stockés pour une lecture hors ligne si le miroir le permet.';

  @override
  String get helpGuidePrayerNotifyTitle => 'Notifications de prière';

  @override
  String get helpGuidePrayerNotifyBody =>
      'Activez les rappels dans Réglages, définissez le lieu dans Adhan, et accordez la permission de notification pour des alertes douces.';

  @override
  String get helpGuideBackgroundAudioTitle => 'Audio en arrière-plan';

  @override
  String get helpGuideBackgroundAudioBody =>
      'La tilâwat peut continuer pendant la navigation ; la narration des histoires peut être limitée sur le web — utilisez l\'application mobile pour l\'arrière-plan complet.';

  @override
  String get helpGuideBookmarkTitle => 'Signets';

  @override
  String get helpGuideBookmarkBody =>
      'Enregistrez votre position de lecture depuis la sourate quand c\'est proposé ; revenez via les entrées « continuer la lecture » sur la page Coran.';

  @override
  String get helpSectionFaq => 'FAQ';

  @override
  String get helpFaqQuranTitle => 'Comment chercher dans une sourate ?';

  @override
  String get helpFaqQuranBody =>
      'Ouvrez la sourate, activez la recherche dans la barre d\'outils, saisissez un texte ou un numéro, puis touchez un résultat pour y aller.';

  @override
  String get helpFaqTilawatTitle =>
      'Pourquoi l\'audio s\'arrête-t-il en quittant la page ?';

  @override
  String get helpFaqTilawatBody =>
      'Si le mini-lecteur est masqué, relancez la lecture depuis Tilâwat ; sur le web, le navigateur peut mettre en pause sans session active du mini-lecteur.';

  @override
  String get helpFaqDownloadTitle =>
      'Pourquoi un téléchargement a-t-il échoué ?';

  @override
  String get helpFaqDownloadBody =>
      'Vérifiez la connexion et l\'espace disque ; certains miroirs peuvent être indisponibles — réessayez après quelques minutes.';

  @override
  String get helpFaqNotifyTitle => 'Je ne reçois pas les alertes de prière';

  @override
  String get helpFaqNotifyBody =>
      'Vérifiez la permission système, les optimisations batterie du fabricant, et la position ou la ville manuelle pour des horaires corrects.';

  @override
  String get helpFaqBgAudioTitle =>
      'Les histoires en arrière-plan sur le site ?';

  @override
  String get helpFaqBgAudioBody =>
      'Les navigateurs limitent la média en arrière-plan ; installez la version Android pour l\'écoute écran éteint.';

  @override
  String get helpFaqBookmarkTitle => 'Où est stocké mon signet ?';

  @override
  String get helpFaqBookmarkBody =>
      'Il reste sur cet appareil pour reprendre la lecture localement — il n\'est pas envoyé à un serveur.';

  @override
  String get helpFaqTroubleTitle => 'Dépannage général';

  @override
  String get helpFaqTroubleBody =>
      'Redémarrez l\'application, vérifiez date et heure automatiques, mettez à jour, et si l\'erreur persiste notez la page concernée avant de nous écrire.';

  @override
  String get rateSubtitle =>
      'Votre note encourage l\'équipe et nourrit les améliorations.';

  @override
  String get rateHeroTitle => 'Jazakum Allahu khayran';

  @override
  String get rateHeroBody =>
      'Si cette app vous aide pour le Coran ou la salât, un avis bienveillant aide d\'autres personnes en quête.';

  @override
  String get rateStarsCaption =>
      'Cinq cœurs derrière cinq étoiles — merci pour votre confiance.';

  @override
  String get rateBtnStore => 'Noter sur le Play Store';

  @override
  String get rateBtnShare => 'Partager l\'application';

  @override
  String get rateBtnFeedback => 'Envoyer un retour';

  @override
  String get rateSnackStoreFail =>
      'Impossible d\'ouvrir le store depuis cet appareil.';

  @override
  String get rateSnackShareFail => 'Impossible d\'ouvrir le partage.';

  @override
  String get rateSnackMailFail =>
      'Impossible d\'ouvrir l\'application mail sur cet appareil.';

  @override
  String rateShareText(Object url) {
    return 'Essayez cette application Coran : $url';
  }

  @override
  String get rateFeedbackSubject => 'Retour sur l\'application Coran';

  @override
  String get sourcesSubtitle =>
      'La transparence nourrit la confiance — voici comment le contenu vous parvient.';

  @override
  String get sourcesIntro =>
      'Nous privilégions des hôtes établis, des API documentées et des textes attribués. En cas de doute, nous restons prudents.';

  @override
  String get sourcesTrustLine =>
      'Parcours sélectionnés — pas de grattage anonyme.';

  @override
  String get sourcesVisitWebsite => 'Site officiel';

  @override
  String get sourcesQuranTitle => 'Texte du Coran (Mushaf)';

  @override
  String get sourcesQuranBody =>
      'Les ayāt arabes sont intégrées à l\'app depuis un jeu de données de style Othmani aligné sur des publications Tanzil largement révisées.';

  @override
  String get sourcesTafsirTitle => 'Tafsir (Al-Muyassar)';

  @override
  String get sourcesTafsirBody =>
      'Le commentaire arabe Al-Muyassar est récupéré via les API publiques Quran.com avec des identifiants d\'édition documentés.';

  @override
  String get sourcesPrayerTitle => 'Horaires de prière';

  @override
  String get sourcesPrayerBody =>
      'Les coordonnées et la méthode de calcul sont envoyées à l\'API Aladhan (Islamic Network) pour afficher les horaires de votre lieu.';

  @override
  String get sourcesAudioTitle => 'Audio de récitation';

  @override
  String get sourcesAudioBody =>
      'La diffusion et les téléchargements utilisent des miroirs de réciteurs réputés tels que MP3 Quran et des hôtes de type Quranicaudio référencés dans le catalogue.';

  @override
  String get sourcesStoriesTitle => 'Récits des prophètes (narration)';

  @override
  String get sourcesStoriesBody =>
      'La narration YouTube est limitée à une politique de chaînes autorisées ; chaque récit privilégie une vidéo vérifiée unique.';

  @override
  String get sourcesMiraclesTitle => 'Section miracles scientifiques';

  @override
  String get sourcesMiraclesBody =>
      'Sujets sélectionnés avec une formulation mesurée et des liens d\'ayat explicites ; indications pédagogiques — pas un avis juridique ni un traité de croyance.';

  @override
  String get sourcesOpenLinkFailed =>
      'Impossible d\'ouvrir ce lien sur cet appareil.';

  @override
  String get homeQuranicDuas => 'Invocations coraniques';

  @override
  String get homeKhatmDua => 'Doua de khatm';

  @override
  String get quranicDuasTitle => 'Invocations tirées du Coran';

  @override
  String get quranicDuasSearchHint => 'Texte, thème ou sourate…';

  @override
  String get quranicDuasSearchOpenTooltip => 'Rechercher des invocations';

  @override
  String get quranicDuasFilterTooltip => 'Filtrer par sourate et thème';

  @override
  String get quranicDuasFilterTitle => 'Filtres';

  @override
  String get quranicDuasAllSurahs => 'Toutes les sourates';

  @override
  String get quranicDuasAllTopics => 'Tous les thèmes';

  @override
  String get quranicDuasApplyFilters => 'Appliquer';

  @override
  String get quranicDuasClearFilters => 'Effacer les filtres';

  @override
  String get quranicDuasEmpty =>
      'Aucune invocation ne correspond à votre recherche ou filtres.';

  @override
  String get quranicDuasLoadError =>
      'Impossible de charger les invocations. Réessayez ou rouvrez la page.';

  @override
  String get quranicDuasOpenQuran => 'Ouvrir dans le Coran';

  @override
  String get quranicDuasOpenTafsir => 'Ouvrir le tafsir';

  @override
  String get quranicDuasCopy => 'Copier';

  @override
  String get quranicDuasShare => 'Partager';

  @override
  String get quranicDuasFavoriteOn => 'Enregistré localement';

  @override
  String get quranicDuasFavoriteOff => 'Enregistrer';

  @override
  String get quranicDuasCopied => 'Copié dans le presse-papiers.';

  @override
  String get quranicDuasShareSubject => 'Invocation du Coran';

  @override
  String get khatmDuaTitle => 'Doua de khatm al-Qur\'an';

  @override
  String get khatmDuaSubtitle => 'Une lecture posée pour clore et remercier';

  @override
  String get khatmDuaLoadError =>
      'Impossible de charger cette page. Réessayez.';

  @override
  String get khatmDuaAudioSoon =>
      'Une récitation audio sera proposée dans une prochaine mise à jour.';

  @override
  String get khatmDuaFooterNote =>
      'Ce texte sert à la lecture et à la méditation ; rapprochez-vous d’une formulation recommandée par des savants ou votre communauté pour le khatm.';

  @override
  String get duaTopicMercy => 'Miséricorde';

  @override
  String get duaTopicForgiveness => 'Pardon';

  @override
  String get duaTopicRizq => 'Provision';

  @override
  String get duaTopicPatience => 'Patience';

  @override
  String get duaTopicGuidance => 'Orientation';

  @override
  String get duaTopicProtection => 'Protection';

  @override
  String get duaTopicParents => 'Parents';

  @override
  String get duaTopicSuccess => 'Réussite';

  @override
  String get duaTopicGratitude => 'Reconnaissance';

  @override
  String get duaTopicKnowledge => 'Savoir';

  @override
  String get duaTopicRefuge => 'Confiance et refuge';

  @override
  String get duaTopicFamily => 'Famille';

  @override
  String get duaTopicTaqwa => 'Piété';

  @override
  String get duaTopicHealing => 'Épreuve et guérison';

  @override
  String duaRefLine(Object surahName, Object ayahPart) {
    return '$surahName · $ayahPart';
  }
}
