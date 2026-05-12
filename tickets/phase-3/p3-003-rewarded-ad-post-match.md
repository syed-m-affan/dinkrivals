---
id: P3-003
phase: 3
status: done
priority: high
parallel_group: C
depends_on: [P3-001]
blocks: [P3-006]
owner: codex
last_updated: 2026-05-11
revised_by: claude-2026-05-11
---

# P3-003 - Fake Rewarded Ad on Post-Match Screen

## Goal

Add an optional fake rewarded-ad action to the end-match screen so Phase 3 can validate rewarded placement without interrupting gameplay.

## Build Spec Coverage

Phase 3 tasks:

- Add post-match "watch ad to double stars" fake button.
- Fake rewarded ad only appears after user taps button.
- Fake rewarded ad grants reward.

## Suggested File Ownership

- `dink_rivals/lib/screens/end_match_screen.dart`.
- `dink_rivals/lib/services/ad_service.dart` only for provider/export wiring if needed.
- `dink_rivals/test/end_match_screen_test.dart`.

Do not alter match scoring, unlocks, real currency, ad frequency rules, or gameplay.

## Requirements

- Add a clearly optional post-match fake rewarded button on the end-match screen, labelled along the lines of "WATCH AD: 2× REWARD".
- The button must not appear during gameplay and must not trigger automatically.
- Use `FakeAdService.showRewardedAd(...)` after the user taps. Do **not** route through `AdPlacementSystem` — rewarded is user-initiated and uncapped (see P3-002 note).
- "Reward" is a label-only UI badge: e.g. swap "REWARD CLAIMED 2×" / a doubled placeholder number on the existing end-match summary. No persistent state. No edits to `SaveService`, `matchesCompleted`, or any future stars/currency. Phase 3 has no economy and must not create one.
- The button is one-shot per visit to the end-match screen — disable it once tapped so the player can't farm the simulated reward.
- If fake rewarded ad is unavailable (`isRewardedAdReady() == false`), keep the screen usable and either hide the button or disable it with a "not available" label — no blocking error.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Required tests:

- End-match screen includes the optional rewarded action.
- Reward is not granted before tapping.
- Tapping the rewarded action calls the fake ad path and updates the reward display.
- Rematch and Return to Menu still work after the rewarded action.

## Acceptance Criteria

- Rewarded ad simulation is optional and user-initiated.
- No rewarded ad appears or runs during gameplay.
- Rewarded result is visible after tap.
- No persistent economy is added.
- Existing end-match behavior still passes tests.

## Implementation Notes

Completed on 2026-05-11:

- Added optional `WATCH AD: 2X REWARD` action on `EndMatchScreen`.
- Rewarded ads call `AdService.showRewardedAd(...)` only after user tap.
- Added one-shot placeholder reward UI (`REWARD CLAIMED 2X`) with no persistence or economy changes.
- Added widget test coverage for user-initiated reward behavior.

## Verification

- `flutter analyze`: passed with no issues.
- `flutter test`: passed 73/73.
- `flutter build apk --debug`: passed.
