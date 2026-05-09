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
}
