---
id: P3-004
phase: 3
status: done
priority: high
parallel_group: D
depends_on: [P3-001, P3-002]
blocks: [P3-006]
owner: codex
last_updated: 2026-05-11
revised_by: claude-2026-05-11
---

# P3-004 - Fake Interstitial at Natural Breaks

## Goal

Wire fake interstitial simulation into post-match natural breaks using the Phase 3 placement rules, without ever showing ads during active gameplay.

## Build Spec Coverage

Phase 3 tasks:

- Add fake interstitial modal.
- Fake interstitial appears only after allowed match break.
- No fake ad appears during gameplay.

## Suggested File Ownership

- `dink_rivals/lib/screens/end_match_screen.dart`.
- `dink_rivals/lib/app/router.dart` or app-level provider wiring if needed.
- `dink_rivals/lib/game/systems/ad_placement_system.dart` only for small integration helpers if needed.
- `dink_rivals/test/end_match_screen_test.dart`.
- `dink_rivals/test/ad_placement_system_test.dart` if integration reveals missing frequency coverage.

Do not add AdMob, banners, rewarded changes, or gameplay interruptions in this ticket.

## Requirements

- **Placement point**: the interstitial fires when the user taps `Return to Menu` on the end-match screen. The flow becomes `tap Return to Menu → check AdPlacementSystem → if eligible, show fake interstitial → on dismiss, navigate to `/` menu`. This keeps the end-match summary readable (no interruption mid-summary) and ties the ad to a user-initiated transition.
  - Alternative considered and rejected: showing the interstitial *before* the end-match summary appears. Rejected because it would interrupt the user's reading of their final score.
- Evaluate eligibility only after a match has completed and the user is leaving the end-match screen. Do not evaluate at match-over time itself — let the summary render first.
- Show a fake interstitial modal/dialog only when `AdPlacementSystem.isInterstitialEligible(...)` says it is eligible.
- The fake modal must be dismissible (close X or auto-close button) and on dismiss must complete the deferred navigation to `/`.
- Never show interstitial on app launch, before first gameplay, during a rally, during point reset, from pause, from the Rematch button, or from settings/roster. The only entry point is `Return to Menu` from `/end-match`.
- After showing, call `AdPlacementSystem.recordInterstitialShown(...)` so frequency gates reset.
- Ensure `matchesCompleted` from Phase 2 still increments exactly once per completed match. The Phase 2 increment is in `GameScreen._handleMatchOver`; do not move or duplicate it.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Required tests:

- No fake interstitial before the first 3 completed matches.
- Fake interstitial appears only after an eligible completed match.
- Dismissing fake interstitial completes the deferred navigation to `/`.
- Tapping `Rematch` does **not** trigger the interstitial.
- No interstitial is shown from active game screen or pause screen.
- `AdPlacementSystem.recordInterstitialShown` is called exactly once when the modal appears.

## Acceptance Criteria

- Interstitial simulation follows Phase 3 frequency rules.
- Interstitials appear only at natural post-match breaks.
- No fake interstitial can interrupt active gameplay.
- Existing match completion and navigation flows still pass tests.

## Implementation Notes

Completed on 2026-05-11:

- Wired fake interstitial evaluation only into `Return to Menu` from `EndMatchScreen`.
- Added dismissible fake interstitial dialog and deferred menu navigation until dismissal.
- `Rematch`, active gameplay, pause, app launch, settings, and roster do not trigger interstitial checks.
- Added widget tests for ineligible skip, eligible dialog + deferred navigation, and rematch bypass.

## Verification

- `flutter analyze`: passed with no issues.
- `flutter test`: passed 73/73.
- `flutter build apk --debug`: passed.
