import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobConfig {
  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const androidTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const androidTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static const bool useProductionIds = bool.fromEnvironment(
    'DINK_RIVALS_USE_PRODUCTION_ADMOB_IDS',
  );
  static const bool requestConsent = bool.fromEnvironment(
    'DINK_RIVALS_REQUEST_AD_CONSENT',
    defaultValue: true,
  );
  static const bool resetConsentForDebug = bool.fromEnvironment(
    'DINK_RIVALS_RESET_AD_CONSENT',
  );
  static const String consentDebugGeographyName = String.fromEnvironment(
    'DINK_RIVALS_AD_CONSENT_DEBUG_GEOGRAPHY',
  );
  static const String consentDebugDeviceIdCsv = String.fromEnvironment(
    'DINK_RIVALS_AD_CONSENT_DEBUG_DEVICE_IDS',
  );
  static const String productionBannerAdUnitId = String.fromEnvironment(
    'DINK_RIVALS_ADMOB_BANNER_AD_UNIT_ID',
  );
  static const String productionRewardedAdUnitId = String.fromEnvironment(
    'DINK_RIVALS_ADMOB_REWARDED_AD_UNIT_ID',
  );
  static const String productionInterstitialAdUnitId = String.fromEnvironment(
    'DINK_RIVALS_ADMOB_INTERSTITIAL_AD_UNIT_ID',
  );

  static bool get hasCompleteProductionAdUnitIds =>
      productionBannerAdUnitId.trim().isNotEmpty &&
      productionRewardedAdUnitId.trim().isNotEmpty &&
      productionInterstitialAdUnitId.trim().isNotEmpty;

  static bool get canRequestConfiguredNativeAds =>
      !useProductionIds || hasCompleteProductionAdUnitIds;

  static String? get bannerAdUnitId => _selectedAdUnitId(
        productionBannerAdUnitId,
        androidTestBannerAdUnitId,
      );

  static String? get rewardedAdUnitId => _selectedAdUnitId(
        productionRewardedAdUnitId,
        androidTestRewardedAdUnitId,
      );

  static String? get interstitialAdUnitId => _selectedAdUnitId(
        productionInterstitialAdUnitId,
        androidTestInterstitialAdUnitId,
      );

  static DebugGeography? get consentDebugGeography =>
      debugGeographyFromName(consentDebugGeographyName);

  static List<String> get consentDebugDeviceIds =>
      parseCsv(consentDebugDeviceIdCsv);

  static List<String> parseCsv(String csv) {
    return csv
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  static DebugGeography? debugGeographyFromName(String value) {
    switch (value.trim().toLowerCase()) {
      case '':
      case 'disabled':
      case 'off':
        return null;
      case 'eea':
        return DebugGeography.debugGeographyEea;
      case 'regulated_us':
      case 'regulated-us':
      case 'regulated_us_state':
      case 'regulated-us-state':
      case 'us':
        return DebugGeography.debugGeographyRegulatedUsState;
      case 'other':
      case 'not_eea':
      case 'not-eea':
        return DebugGeography.debugGeographyOther;
    }
    return null;
  }

  static String? _selectedAdUnitId(
    String productionId,
    String testId,
  ) {
    if (!useProductionIds) {
      return testId;
    }
    final trimmed = productionId.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
