# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

The repo root holds the design docs; the actual app lives in a nested Flutter project. Run all Flutter commands from `dink_rivals/`, not the repo root.

- `dink_rivals/` — Flutter + Flame app (the only buildable project)
- `docs/build-spec.md` — authoritative product/architecture spec, including phase plan and non-negotiable product rules. Read this before substantive changes.
- `tickets/` — per-phase implementation tickets. The current ticket may include constraints (e.g. locked dependency list, exact directory structure) that override generic guidance.

## Common commands

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze            # must pass with zero warnings (per ticket DoD)
flutter test               # all tests must be green
flutter test test/ball_physics_system_test.dart   # single file
flutter test --plain-name "ball bounces"          # single test by name

flutter run -d <ANDROID_DEVICE_ID>
flutter run -d emulator-5554
flutter build apk --debug
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

Phase definition-of-done (from `docs/build-spec.md` §5.4) requires the app to install on a physical Android device and run for 5 minutes without crash; known issues go in `dink_rivals/PHASE_NOTES.md`.

## Local emulator QA

This machine may have a reusable Android AVD named `dink_rivals_qa`.

Start it from any directory:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\emulator\emulator.exe" -avd dink_rivals_qa
```

Then from `dink_rivals/`:

```bash
flutter devices
flutter run -d emulator-5554
```

If the app is already built:

```bash
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

If `adb` is not on `PATH`, use the SDK-local binary:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1
& $adb -s emulator-5554 shell screencap -p /sdcard/dink_rivals_qa.png
& $adb -s emulator-5554 pull /sdcard/dink_rivals_qa.png ..\dink_rivals_qa.png
```

Use emulator QA for quick launch, screenshot, and basic gameplay smoke checks. Do not treat it as a substitute for required physical-device phase closeout.

## Architecture

The game uses a deliberate **components / systems / models / config** split inside `lib/game/`. Mutating game state lives in plain Dart `models/` (e.g. `BallState`, `PlayerState`); per-frame logic lives in `systems/` (no Flame dependency where avoidable); Flame `Component`s in `components/` are thin renderers that read state and call `game.courtToWorld(...)` to draw.

`DinkRivalsGame` (`lib/game/dink_rivals_game.dart`) is the orchestrator:

- Owns the singleton systems: `InputSystem`, `MovementSystem`, `ShotSystem`, `BallPhysicsSystem`, `OpponentAISystem`.
- Owns `player.state`, `opponent.state`, `ball.state` and threads them into systems each `update(dt)`.
- Translates raw Flame pointer events into `InputSystem` and `TouchInputController` calls. Left virtual stick moves the player; right virtual stick controls racket angle and swing velocity; the SERVE button charges and releases the serve. Racket-ball contact automatically classifies dink, drive, lob, smash, block, and serve. Do not add shot buttons unless a new accepted playtest ticket changes the control contract.
- Computes `_courtScale` and `_courtOffset` in `onGameResize`, which `courtToWorld` uses for rendering.

### Logical court coordinates vs. screen pixels

Game logic operates in **logical court units** (see `config/court_constants.dart`: 220 wide × 480 long, net at y=240). Components convert to screen via `CourtProjection.courtToScreen` then `DinkRivalsGame.courtToWorld`, which applies a 3/4 perspective: `screenY = y * yCompression − z * zDisplacement` (0.65 / 0.6). Never bake screen pixels into game logic — keep state in court coordinates and project at draw time. The 3/4 top-down perspective is a non-negotiable product rule (no pure side view).

### Ball physics

Pseudo-3D: `BallState` has `(x, y, z)` + velocities. `BallPhysicsSystem.update`:

- Applies air drag, gravity scaled by `arcGravityScale` (different for dink vs drive — see `Tuning`).
- Bounces when `z <= 0` with `bounceDamping`; settles ball to rest when `vz < 10`.
- Returns a `PlayerSideCrossing` when the ball crosses `Court.netY` (used to increment rally count).

`ShotSystem.attemptShot` solves for the `vz` that lands the ball at the chosen target after `time = max(distance/speed, 0.2)`, using the same gravity scale the physics system will apply.

### Tuning

All gameplay numbers live in `lib/game/config/tuning_constants.dart` (`Tuning` class) and `court_constants.dart` (`Court` class). Prefer adding a constant there over inlining magic numbers; the spec explicitly calls for centralized tuning so designers can iterate.

## Phase discipline

Per `docs/build-spec.md`, this codebase is built in phases. Phase 0 (current) is gray-box rally only — no art, menus, audio, ads, IAP, persistence, or analytics. Do not introduce dependencies (Riverpod, GoRouter, google_mobile_ads, etc.) ahead of their phase. If a task seems to require a future-phase feature, surface the conflict instead of silently expanding scope.

Non-negotiable product rules from spec §2 (apply to all phases): no energy timers, no premium gems, no pay-to-win, no ads during rallies, no forced ad before first gameplay, 3/4 perspective only, gameplay feel before menus/monetization, every phase must run on a physical Android device.
