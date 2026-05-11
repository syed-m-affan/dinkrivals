import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/app/ad_provider.dart';

void main() {
  test('first three completed matches are not eligible', () {
    final system = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);

    system.recordMatchCompleted();
    system.recordMatchCompleted();

    expect(system.isInterstitialEligible(isNaturalBreak: true), isFalse);

    system.recordMatchCompleted();

    expect(system.isInterstitialEligible(isNaturalBreak: true), isTrue);
  });

  test('active gameplay blocks otherwise eligible interstitial', () {
    final system = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);
    for (var i = 0; i < 3; i++) {
      system.recordMatchCompleted();
    }

    expect(system.isInterstitialEligible(isNaturalBreak: false), isFalse);
    expect(system.isInterstitialEligible(isNaturalBreak: true), isTrue);
  });

  test('showing interstitial resets match and time gates', () {
    final system = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);
    for (var i = 0; i < 3; i++) {
      system.recordMatchCompleted();
    }
    expect(system.isInterstitialEligible(isNaturalBreak: true), isTrue);

    system.recordInterstitialShown();

    expect(system.matchesSinceInterstitial, 0);
    expect(system.timeSinceInterstitial, Duration.zero);
    expect(system.isInterstitialEligible(isNaturalBreak: true), isFalse);
  });

  test('four minute cap blocks otherwise eligible interstitials', () {
    final system = AdPlacementSystem();
    for (var i = 0; i < 3; i++) {
      system.recordMatchCompleted();
    }

    expect(system.matchesUntilEligible, 0);
    expect(system.isInterstitialEligible(isNaturalBreak: true), isFalse);

    system.advance(AdPlacementSystem.minTimeBetweenInterstitials);

    expect(system.isInterstitialEligible(isNaturalBreak: true), isTrue);
  });

  test('debug summary exposes QA gates', () {
    final system = AdPlacementSystem();
    system.recordMatchCompleted();

    final summary = system.debugSummary(isNaturalBreak: true);

    expect(summary, contains('matches 1'));
    expect(summary, contains('next in 2'));
    expect(summary, contains('break yes'));
  });
}
