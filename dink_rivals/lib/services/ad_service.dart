import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AdService {
  Future<void> initialize();
  Future<bool> isRewardedAdReady();
  Future<bool> showRewardedAd({required String placement});
  Future<bool> isInterstitialReady();
  Future<bool> maybeShowInterstitial({required String placement});
  bool get adsRemoved;
}

class FakeAdService implements AdService {
  FakeAdService({
    bool rewardedReady = true,
    bool interstitialReady = true,
  })  : _rewardedReady = rewardedReady,
        _interstitialReady = interstitialReady;

  bool _initialized = false;
  bool _rewardedReady;
  bool _interstitialReady;

  int rewardedShows = 0;
  int interstitialShows = 0;
  String? lastRewardedPlacement;
  String? lastInterstitialPlacement;

  bool get initialized => _initialized;

  set rewardedReady(bool value) => _rewardedReady = value;
  set interstitialReady(bool value) => _interstitialReady = value;

  @override
  bool get adsRemoved => false;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<bool> isRewardedAdReady() async => _rewardedReady && !adsRemoved;

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
  Future<bool> isInterstitialReady() async => _interstitialReady && !adsRemoved;

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

final adServiceProvider = Provider<AdService>((ref) {
  throw UnimplementedError('adServiceProvider must be overridden in main.dart');
});
