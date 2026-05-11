import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/app/ad_provider.dart';

void main() {
  test('fake service initializes without side effects', () async {
    final service = FakeAdService();

    await service.initialize();

    expect(service.initialized, isTrue);
    expect(service.rewardedShows, 0);
    expect(service.interstitialShows, 0);
    expect(service.adsRemoved, isFalse);
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
}
