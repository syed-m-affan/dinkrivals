class AppConfig {
  static const String phaseLabel = 'MVP Release Candidate';
  static const bool showQaUi = bool.fromEnvironment(
    'DINK_RIVALS_SHOW_QA_UI',
  );
  static const bool useFakeAds = bool.fromEnvironment(
    'DINK_RIVALS_USE_FAKE_ADS',
  );
  static const bool showAdPlaceholders = bool.fromEnvironment(
    'DINK_RIVALS_SHOW_AD_PLACEHOLDERS',
  );
  static const bool useAdMob = bool.fromEnvironment(
    'DINK_RIVALS_USE_ADMOB',
  );
}
