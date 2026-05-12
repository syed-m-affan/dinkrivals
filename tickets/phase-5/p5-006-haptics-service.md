---
id: P5-006
phase: 5
status: done
priority: medium
parallel_group: A
depends_on: []
blocks: [P5-007]
owner: codex
last_updated: 2026-05-11
---

# P5-006 - Haptics Service for Hit and Point

## Goal

Add a tiny haptics service that fires light vibration on the player's successful racket contact and medium vibration when a point is awarded. Honor the persisted `hapticsEnabled` flag.

## Build Spec Coverage

Phase 5 tasks (build-spec §13):

- Add haptics for hit/point.

## Suggested File Ownership

- `dink_rivals/lib/services/haptics_service.dart` (new).
- `dink_rivals/lib/app/haptics_provider.dart` (new).
- `dink_rivals/lib/main.dart` — initialize provider override.
- `dink_rivals/lib/game/systems/shot_system.dart` — call `light()` only on a successful **player-side** racket contact.
- `dink_rivals/lib/game/systems/scoring_system.dart` — call `medium()` when a point is awarded to the player.
- `dink_rivals/test/haptics_service_test.dart` (new).

Do not edit `SaveService` or settings UI. The toggle and persistence already exist.

## Requirements

- `HapticsService` interface:
  - `Future<void> initialize()` (no-op acceptable).
  - `Future<void> light()` — used for player hit.
  - `Future<void> medium()` — used for point award (player win).
- Provide a real implementation using `package:flutter/services.dart` `HapticFeedback.lightImpact()` / `HapticFeedback.mediumImpact()`, plus a `FakeHapticsService` for tests.
- Each call no-ops when `hapticsEnabled == false`. Read the flag from the live `SaveData` snapshot, not a cached copy.
- Trigger only on player-driven events. Opponent contacts and opponent point-wins do **not** fire haptics.
- Expose `hapticsServiceProvider` mirroring `audioServiceProvider`.

## Non-Goals

- No use of third-party vibration packages — Flutter's built-in `HapticFeedback` is sufficient.
- No haptics for menu navigation, UI button taps, or ball bounce.
- No new settings toggles.
- No change to scoring, rules, or AI.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Required tests (using `FakeHapticsService`):

- `hapticsEnabled == false` short-circuits `light()` and `medium()`.
- `hapticsEnabled == true` invokes the underlying impact exactly once.
- Opponent-side hit does not trigger `light()`.
- Opponent point win does not trigger `medium()`.

Manual smoke check (also documented in P5-007):

- Toggle Haptics off → no buzz on player hit or point.
- Toggle Haptics on → light buzz on player racket contact, medium buzz on player point win.

## Acceptance Criteria

- `HapticsService` exists with `light()` and `medium()`.
- Haptics fire only on player-driven hit and point-win events.
- Settings toggle actually silences haptics.
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

- Added `HapticsService`, `FlutterHapticsService`, `FakeHapticsService`, and `hapticsServiceProvider`.
- Player racket contact triggers light haptics; player point wins trigger medium haptics. Opponent hits and opponent point wins do not trigger haptics.
- The service reads the live `saveDataProvider` haptics flag through its provider-backed getter.
- Added `haptics_service_test.dart`.

## Verification

- `flutter analyze`: passed, zero issues.
- `flutter test`: passed, 96 tests.
- `flutter build apk --debug`: passed.
