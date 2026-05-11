---
id: P3-002
phase: 3
status: done
priority: high
parallel_group: B
depends_on: []
blocks: [P3-004, P3-005, P3-006]
owner: codex
last_updated: 2026-05-11
revised_by: claude-2026-05-11
---

# P3-002 - Ad Placement Frequency Rules

## Goal

Create a pure, deterministic ad placement system that enforces Phase 3 interstitial frequency rules before any UI or fake modal is wired in.

## Build Spec Coverage

Phase 3 tasks:

- Create `AdPlacementSystem`.
- Track completed matches this session.
- Track time since last interstitial.
- Add unit tests for ad frequency.

## Suggested File Ownership

- `dink_rivals/lib/game/systems/ad_placement_system.dart`.
- `dink_rivals/test/ad_placement_system_test.dart`.

Avoid editing screens or services in this ticket. UI and service calls belong to `P3-004` and `P3-005`.

## Requirements

- Implement a pure Dart system that can decide whether an interstitial is eligible at a natural break.
- Enforce the build-spec policy:
  - No interstitial before the user has completed 3 matches **this session**.
  - No interstitial more often than once every 3 completed matches (gate resets when an interstitial fires).
  - No interstitial more often than once every 4 real minutes (gate resets when an interstitial fires).
  - No interstitial during active gameplay.
- **Rewarded ads bypass this system entirely.** Rewarded is user-initiated (P3-003) and has no match or time cap. The placement system gates interstitials only.
- Provide methods for recording match completion, advancing elapsed time, and recording an interstitial shown.
- Time advancement model: expose either (a) an injectable clock or (b) an `advance(Duration dt)` / `tick(double seconds)` method. Do not read `DateTime.now()` directly inside eligibility logic — tests must be deterministic.
- Track session counters in-memory only. Do not depend on `SaveService.matchesCompleted` (that's cross-session) or persist Phase 3 counters; sessions reset on app relaunch by design.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

Required tests:

- First 3 completed matches are not eligible.
- Eligibility becomes true only at an allowed post-match break.
- Showing an interstitial resets match and time frequency gates.
- Four-minute cap blocks otherwise eligible interstitials.
- Active gameplay always blocks interstitial eligibility.
- Rewarded ad path is not gated by this system (verify by direct system call or by leaving rewarded paths out of the placement API).

## Acceptance Criteria

- Frequency rules are implemented in a testable non-UI system.
- No fake ad UI appears yet.
- No real ad SDK is introduced.
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

Completed on 2026-05-11:

- Added `AdPlacementSystem` with in-memory session match count, matches since interstitial, and deterministic elapsed-time advancement.
- Added `adPlacementSystemProvider`.
- Wired match completion from `GameScreen._handleMatchOver()` into the placement system.
- Added debug summary helpers for Phase 3 QA visibility.
- Added `ad_placement_system_test.dart` coverage for first-3-match gate, natural break gate, time cap, reset after show, and debug summary.

## Verification

- `flutter analyze`: passed with no issues.
- `flutter test`: passed 73/73.
- `flutter build apk --debug`: passed.
