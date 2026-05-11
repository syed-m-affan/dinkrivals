import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AdPlacementSystem {
  static const int minCompletedMatchesBeforeInterstitial = 3;
  static const int minMatchesBetweenInterstitials = 3;
  static const Duration minTimeBetweenInterstitials = Duration(minutes: 4);

  int _sessionCompletedMatches = 0;
  int _matchesSinceInterstitial = 0;
  Duration _timeSinceInterstitial = Duration.zero;

  int get sessionCompletedMatches => _sessionCompletedMatches;
  int get matchesSinceInterstitial => _matchesSinceInterstitial;
  Duration get timeSinceInterstitial => _timeSinceInterstitial;

  void advance(Duration dt) {
    if (dt.isNegative) {
      return;
    }
    _timeSinceInterstitial += dt;
  }

  void recordMatchCompleted() {
    _sessionCompletedMatches++;
    _matchesSinceInterstitial++;
  }

  bool isInterstitialEligible({required bool isNaturalBreak}) {
    if (!isNaturalBreak) {
      return false;
    }
    if (_sessionCompletedMatches < minCompletedMatchesBeforeInterstitial) {
      return false;
    }
    if (_matchesSinceInterstitial < minMatchesBetweenInterstitials) {
      return false;
    }
    if (_timeSinceInterstitial < minTimeBetweenInterstitials) {
      return false;
    }
    return true;
  }

  void recordInterstitialShown() {
    _matchesSinceInterstitial = 0;
    _timeSinceInterstitial = Duration.zero;
  }

  int get matchesUntilEligible {
    final sessionGate = math.max(
      0,
      minCompletedMatchesBeforeInterstitial - _sessionCompletedMatches,
    );
    final cadenceGate = math.max(
      0,
      minMatchesBetweenInterstitials - _matchesSinceInterstitial,
    );
    return math.max(sessionGate, cadenceGate);
  }

  Duration get timeUntilEligible {
    final remaining = minTimeBetweenInterstitials - _timeSinceInterstitial;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String debugSummary({required bool isNaturalBreak}) {
    final time = timeUntilEligible.inSeconds;
    return 'Ads: matches $_sessionCompletedMatches, '
        'next in $matchesUntilEligible match(es), ${time}s, '
        'break ${isNaturalBreak ? 'yes' : 'no'}';
  }
}

final adPlacementSystemProvider = Provider<AdPlacementSystem>((ref) {
  return AdPlacementSystem();
});

final adPlacementTickProvider = StateProvider<int>((ref) => 0);
