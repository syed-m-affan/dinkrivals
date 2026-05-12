---
id: P5-005
phase: 5
status: done
priority: high
parallel_group: A
depends_on: []
blocks: [P5-007]
owner: codex
last_updated: 2026-05-11
---

# P5-005 - Audio Service and Basic SFX

## Goal

Introduce a small audio service and basic SFX (hit, bounce, point, fault, menu click), wired to the persisted `soundEnabled` flag so the Phase 2 settings toggle finally has effect. Mirror the Riverpod provider shape already used for `SaveService` and `FakeAdService`.

## Build Spec Coverage

Phase 5 tasks (build-spec §13):

- Add SFX: hit, bounce, point, fault, menu click.

## Suggested File Ownership

- `dink_rivals/lib/services/audio_service.dart` (new).
- `dink_rivals/lib/app/audio_provider.dart` (new).
- `dink_rivals/lib/main.dart` — preload SFX before `runApp(...)`.
- `dink_rivals/lib/game/systems/shot_system.dart` — call `playHit()` on successful player/opponent racket contact.
- `dink_rivals/lib/game/systems/ball_physics_system.dart` — call `playBounce()` when the ball crosses `z = 0` with `|vz|` above the settle threshold.
- `dink_rivals/lib/game/systems/scoring_system.dart` — call `playPoint()` when a point is awarded.
- `dink_rivals/lib/game/systems/match_rules_system.dart` — call `playFault()` for kitchen-volley and OOB faults.
- `dink_rivals/lib/screens/main_menu_screen.dart`, `lib/screens/settings_screen.dart`, `lib/screens/roster_screen.dart`, `lib/screens/end_match_screen.dart`, `lib/screens/game_screen.dart` — `playMenuClick()` on user-initiated button taps (not on pause-resume from system back).
- `dink_rivals/assets/audio/sfx/{hit,bounce,point,fault,menu_click}.{wav|ogg}` (new).
- `dink_rivals/test/audio_service_test.dart` (new).
- `dink_rivals/pubspec.yaml` — add `flame_audio` dependency.

Do not edit `SaveService` or settings UI in this ticket; the toggle and persistence already exist.

## Requirements

- Add `flame_audio` via `flutter pub add flame_audio`. Do not pin a fake version number.
- Define an `AudioService` interface:
  - `Future<void> initialize()` — preload short SFX into cache.
  - `Future<void> playHit()`
  - `Future<void> playBounce()`
  - `Future<void> playPoint()`
  - `Future<void> playFault()`
  - `Future<void> playMenuClick()`
- Provide a `FlameAudioService` implementation backed by `FlameAudio.play(...)` and a `FakeAudioService` for tests that records call counts.
- Each `play*` call must no-op when `soundEnabled == false`. Read the flag from the live `SaveData` snapshot (e.g. via the existing `saveDataProvider`) rather than caching at construction.
- Expose `audioServiceProvider` mirroring `adServiceProvider` / `saveServiceProvider`. Override the provider in `ProviderScope` at bootstrap with the initialized instance.
- `main.dart` calls `audioService.initialize()` after `SaveService.load()` and before `runApp(...)`.
- Wire callers as listed above. Avoid wiring inside hot inner loops more than once per event (e.g. one bounce SFX per `z`-crossing, not per frame).
- SFX assets are short royalty-free placeholders. Do not commit licensed audio. If clear-license placeholders are unavailable, ship silent stubs and note the gap in `PHASE_NOTES.md`.

## Non-Goals

- No music track (loop / menu music) — SFX only.
- No haptics (P5-006).
- No real ad audio mixing.
- No new settings toggles.
- No change to scoring, rules, or AI.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Required tests (using `FakeAudioService`):

- `soundEnabled == false` short-circuits every `play*` method.
- `soundEnabled == true` invokes the underlying playback exactly once per call.
- `initialize()` is idempotent.
- Provider returns the initialized fake during tests.

Manual smoke check (also documented in P5-007):

- Toggle Sound off in Settings → return to game, swing racket → no hit SFX.
- Toggle Sound on → hit SFX returns.

## Acceptance Criteria

- `AudioService` and `FlameAudioService` exist and are testable behind a fake.
- All five SFX play at the correct gameplay events.
- Sound toggle in Settings actually silences SFX.
- No SFX plays during forbidden moments (ads modal, paused state, before first user interaction beyond bootstrap).
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

- Added `flame_audio`, `AudioService`, `FlameAudioService`, `FakeAudioService`, and `audioServiceProvider`.
- Generated short placeholder WAV SFX for hit, bounce, point, fault, and menu click.
- Wired hit, bounce, fault, point, and menu-click calls to existing gameplay/menu transitions without changing gameplay math.
- The service reads the live `saveDataProvider` sound flag through its provider-backed getter.
- Added `audio_service_test.dart`.

## Verification

- `flutter analyze`: passed, zero issues.
- `flutter test`: passed, 96 tests.
- `flutter build apk --debug`: passed.
