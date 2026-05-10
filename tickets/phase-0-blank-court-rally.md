# Ticket: Phase 0 — Blank Court Rally Loop

---
id: P0-001
phase: 0
status: review
priority: high
parallel_group: legacy
depends_on: []
blocks: [P0-002]
owner: prior-agents
last_updated: 2026-05-10
---

## Context

You are implementing Phase 0 of Dink Rivals, a retro arcade pickleball mobile game. This is the foundational "gray-box" phase. There is no art, no menus, no monetization, no progression. The only goal of this phase is to prove that the core rally loop feels like pickleball when played on an Android phone.

Read `docs/build-spec.md` before starting. The non-negotiable rules in Section 2 of the spec apply to all code you write. Pay particular attention to:

- 3/4 top-down court perspective (NOT side-view)
- Pseudo-3D ball with separate shadow
- Visible kitchen zones
- Logical court coordinates separate from screen pixels

If anything in this ticket conflicts with the build spec, ask before proceeding. Do not silently resolve conflicts.

## Current Control Direction

This legacy ticket has been superseded by Phase 0 playtesting. Treat the original tap/hold shot-button controls as obsolete. The accepted Phase 0 direction is:

- Left virtual stick moves the player.
- Right virtual stick swings the racket left/right through the front 180-degree arc.
- The right stick sets racket angle and swing velocity; it does not choose dink or drive.
- The full racket segment from player body to racket tip is the hitbox.
- The ball is hit automatically when racket contact occurs at hittable height with enough relative speed.
- Soft/firm contact may still be classified as `dink`/`drive` for debug labels, feedback, AI decisions, and tests, but those are not buttons.

If a future agent uses this legacy ticket for context, preserve the current swing-control model and follow `P0-002` for closeout.

## Goal

Produce a Flutter + Flame app that runs on a physical Android phone and lets a human play sustained pickleball rallies against a basic AI opponent on a gray-box court. No art, no menus, no sound. Just gameplay primitives.

## Deliverable

A single Flutter project named `dink_rivals` that:

1. Builds successfully via `flutter build apk --debug`
2. Installs and runs on a physical Android device
3. Boots directly into the gameplay scene (no menu)
4. Allows a 10+ second rally to occur within 30 seconds of app launch
5. Passes `flutter analyze` with zero warnings
6. Passes `flutter test` with all included tests green

## Tech Stack (locked)

- Flutter (latest stable)
- Flame (latest stable, install via `flutter pub add flame`)
- Dart
- No other dependencies in this phase

Do NOT add: Riverpod, GoRouter, audio, ads, IAP, analytics, persistence, or any sprite assets in this phase. Those come in later phases.

## Repository Structure

Create exactly this structure. Do not invent additional directories or files.

```
dink_rivals/
  pubspec.yaml
  analysis_options.yaml
  README.md
  PHASE_NOTES.md
  lib/
    main.dart
    game/
      dink_rivals_game.dart
      config/
        court_constants.dart
        tuning_constants.dart
        debug_flags.dart
      components/
        court_component.dart
        net_component.dart
        kitchen_zone_component.dart
        player_component.dart
        opponent_component.dart
        ball_component.dart
        shadow_component.dart
        debug_overlay_component.dart
        reset_button_component.dart
      systems/
        input_system.dart
        movement_system.dart
        shot_system.dart
        ball_physics_system.dart
        opponent_ai_system.dart
      models/
        shot_type.dart
        player_side.dart
        ball_state.dart
        player_state.dart
      util/
        court_projection.dart
  test/
    ball_physics_system_test.dart
    court_projection_test.dart
```

## Coordinate System

Use a logical court coordinate system, fully separate from screen pixels.

Logical court space (defined in `court_constants.dart`):

- Court width (x-axis): 220 logical units
- Court length (y-axis, total both sides): 480 logical units
- Net at y = 240 (midpoint)
- Player side: y in [240, 480]
- Opponent side: y in [0, 240]
- Player kitchen: y in [240, 274] (34 units deep, behind net on player side)
- Opponent kitchen: y in [206, 240]
- Ball z (height): logical units, 0 = ground, positive = up

The 3/4 projection should compress the y-axis to about 65% of its true length when projected to screen, creating the foreshortened arcade look. Implement `courtToScreen(Vector2 courtPos, double z)` in `court_projection.dart`. Ball z displaces the rendered y-position upward by `z * 0.6` screen units. Shadow is drawn at z=0 projection, ball is drawn at z>0 projection.

## Models

`shot_type.dart`:

```dart
enum ShotType { dink, drive }
```

Only two debug classifications in Phase 0. They are derived from racket contact strength, racket angle, incoming ball motion, and swing speed, not explicit buttons. Lob, smash, block, serve come in Phase 1.

`player_side.dart`:

```dart
enum PlayerSide { player, opponent }
```

`ball_state.dart`:

```dart
class BallState {
  double x;       // logical court x
  double y;       // logical court y
  double z;       // height above ground
  double vx;      // velocity x
  double vy;      // velocity y
  double vz;      // velocity z
  PlayerSide? lastHitBy;
  bool hasBouncedThisSide;
  bool isInPlay;
}
```

`player_state.dart`:

```dart
class PlayerState {
  Vector2 position;     // logical court coords
  Vector2 velocity;
  PlayerSide side;
  double racketAngle;
  double racketAngularVelocity;
  bool canHit;
  bool isSwinging;
}
```

## Tuning Constants

In `tuning_constants.dart`, define these exact starting values. They are deliberately tunable; do not hardcode them anywhere else.

```dart
class Tuning {
  // Movement
  static const double playerMaxSpeed = 140.0;       // logical units / sec
  static const double playerAcceleration = 800.0;
  static const double opponentMaxSpeed = 110.0;

  // Hit windows
  static const double hitWindowRadius = 42.0;       // logical units
  static const double perfectHitWindowRadius = 22.0;
  static const double racketReach = 42.0;
  static const double racketHitRadius = 13.0;
  static const double maxRacketAngleRadians = 1.5708;
  static const double minRacketContactSpeed = 5.0;

  // Ball physics
  static const double gravity = 520.0;              // logical units / sec^2
  static const double bounceDamping = 0.62;         // z velocity retention on bounce
  static const double airDrag = 0.04;               // per second

  // Contact output
  static const double softContactSpeed = 72.0;
  static const double firmContactSpeed = 138.0;
  static const double driveContactThreshold = 96.0;
  static const double swingPowerScale = 0.58;
  static const double incomingPowerScale = 0.22;
  static const double contactLiftBase = 36.0;
  static const double contactLiftScale = 0.16;

  // AI/debug shot speeds
  static const double dinkSpeedXY = 82.0;
  static const double dinkInitialZ = 34.0;
  static const double dinkArcGravityScale = 0.75;

  static const double driveSpeedXY = 132.0;
  static const double driveInitialZ = 30.0;
  static const double driveArcGravityScale = 0.5;

  // AI
  static const double opponentReactionDelaySec = 0.25;
  static const double opponentMissChance = 0.18;
  static const double opponentDinkProbability = 0.55; // vs drive
}
```

## Components

### CourtComponent

Renders a tan/khaki rectangle for the full court area, with white lines for sidelines, baselines, the net line, and the kitchen lines. Use simple Flame `RectangleComponent` and `LineComponent` (or paint primitives). No textures.

### NetComponent

A solid horizontal line at y=240 court coords, rendered slightly thicker than court lines. Color: dark gray.

### KitchenZoneComponent

Two semi-transparent overlays (one per side) over the kitchen areas. Color: light blue with alpha 0.25. Must be visually distinct from the rest of the court.

### PlayerComponent

A solid colored circle, radius 10 logical units, color blue. Initial position: (110, 400) court coords. Holds a `PlayerState`.

### OpponentComponent

Same as PlayerComponent but red, initial position (110, 80).

### BallComponent

A solid colored circle, radius 4 logical units (scales up to radius 6 when z > 60 to convey height), color yellow. Holds a `BallState`.

### ShadowComponent

A flat dark gray ellipse drawn at the ball's (x, y) court position with z=0. Slightly larger than the ball, semi-transparent. Always renders below the ball component in z-order.

### DebugOverlayComponent

Top-left corner text overlay showing:

- "PHASE 0"
- FPS (use Flame's FpsTextComponent or implement simple counter)
- Ball position: `x: 123.4  y: 234.5  z: 12.3`
- Rally count (number of times ball has crossed the net this point)
- Last contact classification: "dink" or "drive" or "—"

Always visible. White text on a black 50% alpha background.

### ResetButtonComponent

A button in the top-right corner labeled "RESET POINT". On tap, resets ball to a serve/start position reachable by the player's default racket, with zero velocity, opponent to (110, 80), player keeps current position. Sets `isInPlay = false` until next racket contact.

## Systems

### InputSystem

- Detects visible left virtual stick input for movement.
- Detects visible right virtual stick input for racket swing.
- Right-stick horizontal motion rotates the racket through the front 180-degree arc.
- Tracks racket angle and angular velocity.
- Does not queue tap/hold shot button events.
- Does not create separate dink/drive UI buttons.
- Forwards movement to MovementSystem and racket state to ShotSystem.

### MovementSystem

- Reads drag delta, updates player velocity toward drag direction at `playerAcceleration`, clamped to `playerMaxSpeed`
- Applies friction when no input (decelerate to 0 over ~0.2 sec)
- Clamps player to player side of court, including allowing them to enter their own kitchen but not cross the net

### ShotSystem

- Each update, checks whether the ball intersects the racket capsule from player body to racket tip AND is on the hitter's side AND z is between 0 and 90.
- If valid contact has enough relative speed, computes outgoing velocity from racket angle, racket swing speed, and incoming ball speed/angle.
- Classifies contact as `dink` for soft contact or `drive` for firm contact.
- Applies vx, vy, vz to the ball, sets `lastHitBy`, resets `hasBouncedThisSide`, and starts play.
- Uses a short hit cooldown so one overlap does not hit the ball every frame.
- The reset/start hit must use the same racket capsule as in-play hits; do not special-case body contact.

### BallPhysicsSystem

- Each frame, integrates ball position using vx, vy, vz
- Applies gravity (scaled by current shot's `arcGravityScale` if tracked, else default)
- Applies air drag
- On z <= 0: bounce with damping, set `hasBouncedThisSide = true` for current side
- Tracks which side ball is on by sign of (y - 240)
- When ball crosses net (y passes 240), reset `hasBouncedThisSide` for new side
- For Phase 0, do NOT enforce double-bounce or out-of-bounds rules. Just keep playing. (Rules come in Phase 1.)

### OpponentAISystem

- Predicts where ball will land on opponent side using simple physics extrapolation
- Moves opponent toward predicted landing point at `opponentMaxSpeed`, with `opponentReactionDelaySec` delay
- When ball is within hit window, decides shot type based on `opponentDinkProbability`
- Applies `opponentMissChance` — on miss, swings but ball passes by (no shot applied)
- Targets vary slightly to keep player moving

## Game Loop (DinkRivalsGame)

```dart
class DinkRivalsGame extends FlameGame with HasTappableComponents, HasDraggableComponents {
  @override
  Future<void> onLoad() async {
    // Add components in correct z-order:
    // 1. Court
    // 2. Kitchen zones
    // 3. Net
    // 4. Shadow
    // 5. Player, Opponent
    // 6. Ball
    // 7. Debug overlay
    // 8. Reset button
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Run systems in order: input → movement → shot → ball physics → AI
  }
}
```

## main.dart

Bootstraps Flutter app, sets portrait orientation lock, hides system UI for immersive mode, and runs `GameWidget(game: DinkRivalsGame())`.

## Tests

### `test/court_projection_test.dart`

- Test that `courtToScreen` is monotonic in x and y
- Test that increasing z displaces the rendered y upward
- Test that net y (240) maps to a consistent screen y regardless of z

### `test/ball_physics_system_test.dart`

- Test that a ball with positive vz rises then falls
- Test that ball bounces with reduced velocity when z hits 0
- Test that ball comes to rest after multiple bounces (z velocity decays)
- Test that ball position updates correctly across one second of integration

Tests must pass via `flutter test`. Use mock or pure-Dart construction; do not require Flame's render layer in tests.

## PHASE_NOTES.md

Create this file with the following template, ready for the human to fill in during QA:

```markdown
# Phase 0 — Notes

## Build info
- Flutter version:
- Flame version:
- Tested device:
- Build date:

## What works
-

## What doesn't feel right
-

## Bugs found
-

## Tuning suggestions
-
```

## Acceptance Criteria

The ticket is complete when ALL of these are true:

1. `flutter pub get` succeeds with no errors
2. `flutter analyze` reports zero issues
3. `flutter test` runs all included tests and they pass
4. `flutter build apk --debug` produces a valid APK
5. The APK installs and launches on a physical Android device without crash
6. On launch, gameplay scene appears within 3 seconds — no splash, no menu
7. The "PHASE 0" debug label is visible
8. Player can move their circle by dragging the left half of the screen
9. Player can swing the right stick to hit with the racket; there is no dink/drive button
10. The opponent moves toward the ball and returns shots with at least 60% success rate at default tuning
11. Sustained rallies of 10+ ball-crossings are achievable by a competent human player within the first 2 minutes of play
12. The kitchen zones are visibly distinct from the rest of the court
13. The ball has a visible shadow that stays on the ground while the ball arcs above it
14. The ball gets visually larger when high (z > 60)
15. The reset button returns the ball to a serve/start position reachable by the racket hitbox
16. The app runs for 5 minutes of normal play without crashing or dropping below 30fps on a mid-tier 2022+ Android phone

## Out of Scope (Do NOT Build)

- Sound, music, haptics
- Sprites, art, textures, fonts beyond default
- Score tracking, win conditions, match flow
- Lob, smash, block, serve shot types
- In/out detection, double-bounce rule, kitchen volley fault (these come in Phase 1)
- Main menu, settings, pause
- Save/load
- Ads, IAP, analytics
- Multiple courts or characters
- Tournament, season, roster
- Animations beyond basic position interpolation

If you find yourself reaching for any of these, stop and confirm with the human first.

## Self-Verification Checklist

Before declaring this ticket complete, verify each item:

- [ ] Repository structure matches the spec exactly
- [ ] All listed files exist and contain non-stub implementations
- [ ] No dependencies beyond Flutter and Flame
- [ ] Tuning values match the spec exactly
- [ ] No hardcoded numbers outside `tuning_constants.dart` and `court_constants.dart` (other than colors and z-orders)
- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] APK builds
- [ ] PHASE_NOTES.md exists with template
- [ ] README.md describes how to run the project on Android

## Reporting Back

When complete, produce a summary that includes:

1. Confirmation each acceptance criterion is met
2. Any deviations from the spec and why
3. Open questions for the human
4. The exact `flutter run` command to launch on Android
5. A list of tuning values you suspect will need adjustment after first playtest

Do not declare the ticket complete based on code alone. The acceptance criteria require running on a physical device. If you cannot run on a physical device, report which acceptance criteria you have verified and which are pending human verification.
