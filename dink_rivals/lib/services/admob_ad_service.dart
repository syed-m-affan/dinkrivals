import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_service.dart';

class AdMobAdService implements AdService {
  AdMobAdService({
    AdService? fallback,
    this.rewardedAdUnitId = androidTestRewardedAdUnitId,
    this.interstitialAdUnitId = androidTestInterstitialAdUnitId,
  }) : _fallback = fallback ?? FakeAdService();

  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const androidTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const androidTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  final AdService _fallback;
  final String rewardedAdUnitId;
  final String interstitialAdUnitId;

  bool _initialized = false;
  bool _initializationFailed = false;
  bool _rewardedLoading = false;
  bool _interstitialLoading = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  @override
  bool get adsRemoved => _fallback.adsRemoved;

  @override
  bool get usesNativeInterstitialUi => !_initializationFailed;

  @override
  Future<void> initialize() async {
    await _fallback.initialize();
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      unawaited(_loadRewardedAd());
      unawaited(_loadInterstitialAd());
    } catch (_) {
      _initializationFailed = true;
    }
  }

  @override
  Future<bool> isRewardedAdReady() async {
    if (_initializationFailed) {
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
    if (_initializationFailed) {
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
    if (_initializationFailed) {
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
    if (_initializationFailed) {
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
    if (!_initialized ||
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
    if (!_initialized ||
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
