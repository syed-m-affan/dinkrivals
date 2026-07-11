import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AdService {
  Future<void> initialize();
  void dispose();
  Future<bool> isRewardedAdReady();
  Future<bool> showRewardedAd({required String placement});
  Future<bool> isInterstitialReady();
  Future<bool> maybeShowInterstitial({required String placement});
  bool get adsRemoved;
  bool get usesNativeInterstitialUi;
}

class FakeAdService implements AdService {
  FakeAdService({
    bool rewardedReady = true,
    bool interstitialReady = true,
  })  : _rewardedReady = rewardedReady,
        _interstitialReady = interstitialReady;

  bool _initialized = false;
  bool _disposed = false;
  bool _rewardedReady;
  bool _interstitialReady;

  int rewardedShows = 0;
  int interstitialShows = 0;
  String? lastRewardedPlacement;
  String? lastInterstitialPlacement;

  bool get initialized => _initialized;
  bool get disposed => _disposed;

  set rewardedReady(bool value) => _rewardedReady = value;
  set interstitialReady(bool value) => _interstitialReady = value;

  @override
  bool get adsRemoved => false;

  @override
  bool get usesNativeInterstitialUi => false;

  @override
  Future<void> initialize() async {
    if (_disposed) {
      return;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _disposed = true;
  }

  @override
  Future<bool> isRewardedAdReady() async =>
      !_disposed && _rewardedReady && !adsRemoved;

  @override
  Future<bool> showRewardedAd({required String placement}) async {
    if (!await isRewardedAdReady()) {
      return false;
    }
    rewardedShows++;
    lastRewardedPlacement = placement;
    return true;
  }

  @override
  Future<bool> isInterstitialReady() async =>
      !_disposed && _interstitialReady && !adsRemoved;

  @override
  Future<bool> maybeShowInterstitial({required String placement}) async {
    if (!await isInterstitialReady()) {
      return false;
    }
    interstitialShows++;
    lastInterstitialPlacement = placement;
    return true;
  }
}

class NoAdsService implements AdService {
  bool _initialized = false;
  bool _disposed = false;

  bool get initialized => _initialized;
  bool get disposed => _disposed;

  @override
  bool get adsRemoved => false;

  @override
  bool get usesNativeInterstitialUi => false;

  @override
  Future<void> initialize() async {
    if (_disposed) {
      return;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _disposed = true;
  }

  @override
  Future<bool> isRewardedAdReady() async => false;

  @override
  Future<bool> showRewardedAd({required String placement}) async => false;

  @override
  Future<bool> isInterstitialReady() async => false;

  @override
  Future<bool> maybeShowInterstitial({required String placement}) async =>
      false;
}

final adServiceProvider = Provider<AdService>((ref) {
  throw UnimplementedError('adServiceProvider must be overridden in main.dart');
});
