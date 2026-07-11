import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app/admob_config.dart';
import 'ad_service.dart';

abstract class AdConsentGateway {
  Future<bool> gatherConsent({
    required bool resetForDebug,
    required DebugGeography? debugGeography,
    required List<String> testDeviceIds,
  });
}

class GoogleUmpAdConsentGateway implements AdConsentGateway {
  @override
  Future<bool> gatherConsent({
    required bool resetForDebug,
    required DebugGeography? debugGeography,
    required List<String> testDeviceIds,
  }) async {
    if (resetForDebug) {
      await ConsentInformation.instance.reset();
    }

    final params = ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      consentDebugSettings: debugGeography == null && testDeviceIds.isEmpty
          ? null
          : ConsentDebugSettings(
              debugGeography: debugGeography,
              testIdentifiers: testDeviceIds,
            ),
    );
    final updateCompleted = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        if (!updateCompleted.isCompleted) {
          updateCompleted.complete();
        }
      },
      (_) {
        if (!updateCompleted.isCompleted) {
          updateCompleted.complete();
        }
      },
    );

    try {
      await updateCompleted.future.timeout(const Duration(seconds: 15));
    } catch (_) {
      return _canRequestAds();
    }

    FormError? formError;
    try {
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        formError = error;
      });
    } catch (_) {
      return _canRequestAds();
    }
    if (formError != null) {
      return _canRequestAds();
    }
    return _canRequestAds();
  }

  Future<bool> _canRequestAds() async {
    try {
      return ConsentInformation.instance.canRequestAds();
    } catch (_) {
      return false;
    }
  }
}

class AdMobAdService implements AdService {
  AdMobAdService({
    AdService? fallback,
    this.fallbackOnInitializationFailure = true,
    this.bannerAdUnitId = androidTestBannerAdUnitId,
    this.rewardedAdUnitId = androidTestRewardedAdUnitId,
    this.interstitialAdUnitId = androidTestInterstitialAdUnitId,
    this.requestConsent = true,
    this.resetConsentForDebug = false,
    this.consentDebugGeography,
    this.consentTestDeviceIds = const [],
    AdConsentGateway? consentGateway,
  })  : _fallback = fallback ?? FakeAdService(),
        _consentGateway = consentGateway ?? GoogleUmpAdConsentGateway();

  static const androidTestAppId = AdMobConfig.androidTestAppId;
  static const androidTestBannerAdUnitId =
      AdMobConfig.androidTestBannerAdUnitId;
  static const androidTestRewardedAdUnitId =
      AdMobConfig.androidTestRewardedAdUnitId;
  static const androidTestInterstitialAdUnitId =
      AdMobConfig.androidTestInterstitialAdUnitId;

  final AdService _fallback;
  final AdConsentGateway _consentGateway;
  final bool fallbackOnInitializationFailure;
  final String bannerAdUnitId;
  final String rewardedAdUnitId;
  final String interstitialAdUnitId;
  final bool requestConsent;
  final bool resetConsentForDebug;
  final DebugGeography? consentDebugGeography;
  final List<String> consentTestDeviceIds;

  bool _initialized = false;
  bool _initializationFailed = false;
  bool _rewardedLoading = false;
  bool _interstitialLoading = false;
  bool _disposed = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  @override
  bool get adsRemoved => _fallback.adsRemoved;

  @override
  bool get usesNativeInterstitialUi =>
      !_disposed && _initialized && !_initializationFailed;

  bool get initialized => _initialized;
  bool get initializationFailed => _initializationFailed;

  bool get _shouldUseFallback =>
      _initializationFailed && fallbackOnInitializationFailure;

  @override
  Future<void> initialize() async {
    if (_disposed) {
      return;
    }
    await _fallback.initialize();
    try {
      if (requestConsent) {
        final canRequestAds = await _consentGateway.gatherConsent(
          resetForDebug: resetConsentForDebug,
          debugGeography: consentDebugGeography,
          testDeviceIds: consentTestDeviceIds,
        );
        if (!canRequestAds) {
          _initializationFailed = true;
          return;
        }
      }
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.pg,
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
        ),
      );
      await MobileAds.instance.initialize();
      if (_disposed) {
        return;
      }
      _initialized = true;
      unawaited(_loadRewardedAd());
      unawaited(_loadInterstitialAd());
    } catch (_) {
      _initializationFailed = true;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _rewardedLoading = false;
    _interstitialLoading = false;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _fallback.dispose();
  }

  @override
  Future<bool> isRewardedAdReady() async {
    if (_disposed) {
      return false;
    }
    if (_shouldUseFallback) {
      return _fallback.isRewardedAdReady();
    }
    if (!_initialized || adsRemoved) {
      return false;
    }
    if (_rewardedAd == null) {
      unawaited(_loadRewardedAd());
      return false;
    }
    return true;
  }

  @override
  Future<bool> showRewardedAd({required String placement}) async {
    if (_disposed) {
      return false;
    }
    if (_shouldUseFallback) {
      return _fallback.showRewardedAd(placement: placement);
    }
    if (!await isRewardedAdReady()) {
      return false;
    }
    final ad = _rewardedAd;
    if (ad == null) {
      return false;
    }
    _rewardedAd = null;
    var earnedReward = false;
    final completed = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadRewardedAd());
        if (!completed.isCompleted) {
          completed.complete(earnedReward);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        unawaited(_loadRewardedAd());
        if (!completed.isCompleted) {
          completed.complete(false);
        }
      },
    );
    try {
      await ad.show(
        onUserEarnedReward: (_, __) {
          earnedReward = true;
        },
      );
    } catch (_) {
      ad.dispose();
      unawaited(_loadRewardedAd());
      return false;
    }
    return completed.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => earnedReward,
    );
  }

  @override
  Future<bool> isInterstitialReady() async {
    if (_disposed) {
      return false;
    }
    if (_shouldUseFallback) {
      return _fallback.isInterstitialReady();
    }
    if (!_initialized || adsRemoved) {
      return false;
    }
    if (_interstitialAd == null) {
      unawaited(_loadInterstitialAd());
      return false;
    }
    return true;
  }

  @override
  Future<bool> maybeShowInterstitial({required String placement}) async {
    if (_disposed) {
      return false;
    }
    if (_shouldUseFallback) {
      return _fallback.maybeShowInterstitial(placement: placement);
    }
    if (!await isInterstitialReady()) {
      return false;
    }
    final ad = _interstitialAd;
    if (ad == null) {
      return false;
    }
    _interstitialAd = null;
    final completed = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadInterstitialAd());
        if (!completed.isCompleted) {
          completed.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        unawaited(_loadInterstitialAd());
        if (!completed.isCompleted) {
          completed.complete(false);
        }
      },
    );
    try {
      await ad.show();
    } catch (_) {
      ad.dispose();
      unawaited(_loadInterstitialAd());
      return false;
    }
    return completed.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => true,
    );
  }

  Future<void> _loadRewardedAd() async {
    if (_disposed ||
        !_initialized ||
        _initializationFailed ||
        adsRemoved ||
        _rewardedLoading ||
        _rewardedAd != null) {
      return;
    }
    _rewardedLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (_disposed) {
              ad.dispose();
              _rewardedLoading = false;
              return;
            }
            _rewardedAd = ad;
            _rewardedLoading = false;
          },
          onAdFailedToLoad: (_) {
            _rewardedLoading = false;
          },
        ),
      );
    } catch (_) {
      _rewardedLoading = false;
    }
  }

  Future<void> _loadInterstitialAd() async {
    if (_disposed ||
        !_initialized ||
        _initializationFailed ||
        adsRemoved ||
        _interstitialLoading ||
        _interstitialAd != null) {
      return;
    }
    _interstitialLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (_disposed) {
              ad.dispose();
              _interstitialLoading = false;
              return;
            }
            _interstitialAd = ad;
            _interstitialLoading = false;
          },
          onAdFailedToLoad: (_) {
            _interstitialLoading = false;
          },
        ),
      );
    } catch (_) {
      _interstitialLoading = false;
    }
  }
}
