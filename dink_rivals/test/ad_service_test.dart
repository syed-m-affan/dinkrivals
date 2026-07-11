import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/app/admob_config.dart';
import 'package:dink_rivals/services/admob_ad_service.dart';

class _BlockingConsentGateway implements AdConsentGateway {
  @override
  Future<bool> gatherConsent({
    required bool resetForDebug,
    required DebugGeography? debugGeography,
    required List<String> testDeviceIds,
  }) async {
    return false;
  }
}

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

  test('disposed fake service stops serving ads', () async {
    final service = FakeAdService();

    service.dispose();
    await service.initialize();

    expect(service.disposed, isTrue);
    expect(service.initialized, isFalse);
    expect(await service.isRewardedAdReady(), isFalse);
    expect(await service.showRewardedAd(placement: 'post_match'), isFalse);
    expect(await service.isInterstitialReady(), isFalse);
    expect(await service.maybeShowInterstitial(placement: 'menu'), isFalse);
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

  test('no-ads service never serves ads', () async {
    final service = NoAdsService();

    await service.initialize();

    expect(service.initialized, isTrue);
    expect(service.usesNativeInterstitialUi, isFalse);
    expect(await service.isRewardedAdReady(), isFalse);
    expect(await service.showRewardedAd(placement: 'post_match'), isFalse);
    expect(await service.isInterstitialReady(), isFalse);
    expect(await service.maybeShowInterstitial(placement: 'menu'), isFalse);
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

  test('AdMob config defaults to test unit IDs', () {
    expect(AdMobConfig.canRequestConfiguredNativeAds, isTrue);
    expect(AdMobConfig.bannerAdUnitId, AdMobConfig.androidTestBannerAdUnitId);
    expect(
      AdMobConfig.rewardedAdUnitId,
      AdMobConfig.androidTestRewardedAdUnitId,
    );
    expect(
      AdMobConfig.interstitialAdUnitId,
      AdMobConfig.androidTestInterstitialAdUnitId,
    );
  });

  test('AdMob config parses consent debug settings', () {
    expect(
      AdMobConfig.parseCsv(' alpha, beta ,, gamma '),
      ['alpha', 'beta', 'gamma'],
    );
    expect(
      AdMobConfig.debugGeographyFromName('eea'),
      DebugGeography.debugGeographyEea,
    );
    expect(
      AdMobConfig.debugGeographyFromName('regulated-us-state'),
      DebugGeography.debugGeographyRegulatedUsState,
    );
    expect(
      AdMobConfig.debugGeographyFromName('other'),
      DebugGeography.debugGeographyOther,
    );
    expect(AdMobConfig.debugGeographyFromName('unexpected'), isNull);
  });

  test('production AdMob mode does not fall back to fake ads when blocked',
      () async {
    final fallback = FakeAdService();
    final service = AdMobAdService(
      fallback: fallback,
      fallbackOnInitializationFailure: false,
      consentGateway: _BlockingConsentGateway(),
    );

    await service.initialize();

    expect(service.initializationFailed, isTrue);
    expect(service.usesNativeInterstitialUi, isFalse);
    expect(await service.isRewardedAdReady(), isFalse);
    expect(await service.showRewardedAd(placement: 'post_match'), isFalse);
    expect(await service.isInterstitialReady(), isFalse);
    expect(await service.maybeShowInterstitial(placement: 'menu'), isFalse);
    expect(fallback.rewardedShows, 0);
    expect(fallback.interstitialShows, 0);
  });

  test('test AdMob mode can fall back to fake ads when blocked', () async {
    final fallback = FakeAdService();
    final service = AdMobAdService(
      fallback: fallback,
      consentGateway: _BlockingConsentGateway(),
    );

    await service.initialize();

    expect(service.initializationFailed, isTrue);
    expect(await service.isRewardedAdReady(), isTrue);
    expect(await service.showRewardedAd(placement: 'post_match'), isTrue);
    expect(await service.isInterstitialReady(), isTrue);
    expect(await service.maybeShowInterstitial(placement: 'menu'), isTrue);
    expect(fallback.rewardedShows, 1);
    expect(fallback.interstitialShows, 1);
  });
}
