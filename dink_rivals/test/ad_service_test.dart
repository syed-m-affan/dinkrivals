import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/services/admob_ad_service.dart';

void main() {
  test('fake service initializes without side effects', () async {
    final service = FakeAdService();

    await service.initialize();

    expect(service.initialized, isTrue);
    expect(service.rewardedShows, 0);
    expect(service.interstitialShows, 0);
    expect(service.adsRemoved, isFalse);
    expect(service.usesNativeInterstitialUi, isFalse);
  });

  test('fake rewarded readiness and show are deterministic', () async {
    final service = FakeAdService();

    expect(await service.isRewardedAdReady(), isTrue);
    expect(
      await service.showRewardedAd(placement: 'post_match_double_reward'),
      isTrue,
    );
    expect(service.rewardedShows, 1);
    expect(service.lastRewardedPlacement, 'post_match_double_reward');
  });

  test('fake interstitial readiness and show are deterministic', () async {
    final service = FakeAdService();

    expect(await service.isInterstitialReady(), isTrue);
    expect(
      await service.maybeShowInterstitial(placement: 'return_to_menu'),
      isTrue,
    );
    expect(service.interstitialShows, 1);
    expect(service.lastInterstitialPlacement, 'return_to_menu');
  });

  test('provider can return initialized fake service', () async {
    final service = FakeAdService();
    await service.initialize();
    final container = ProviderContainer(
      overrides: [adServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final read = container.read(adServiceProvider);

    expect(read, same(service));
    expect((read as FakeAdService).initialized, isTrue);
  });

  test('AdMob service exposes Google test ad IDs', () {
    expect(
      AdMobAdService.androidTestAppId,
      'ca-app-pub-3940256099942544~3347511713',
    );
    expect(
      AdMobAdService.androidTestBannerAdUnitId,
      'ca-app-pub-3940256099942544/6300978111',
    );
    expect(
      AdMobAdService.androidTestRewardedAdUnitId,
      'ca-app-pub-3940256099942544/5224354917',
    );
    expect(
      AdMobAdService.androidTestInterstitialAdUnitId,
      'ca-app-pub-3940256099942544/1033173712',
    );
  });
}
