class AppConfig {
  static const String phaseLabel = 'Phase 5';
  static const bool showAdPlaceholders = bool.fromEnvironment(
    'DINK_RIVALS_SHOW_AD_PLACEHOLDERS',
    defaultValue: true,
  );
  static const bool useAdMob = bool.fromEnvironment(
    'DINK_RIVALS_USE_ADMOB',
  );
}
