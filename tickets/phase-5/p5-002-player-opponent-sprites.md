---
id: P5-002
phase: 5
status: done
priority: high
parallel_group: B
depends_on: [P5-001]
blocks: [P5-007]
owner: codex
last_updated: 2026-05-11
---

# P5-002 - Player and Opponent Sprite Components

## Goal

Replace the gray-box foot/torso/head circles in `PlayerComponent` and `OpponentComponent` with retro pixel sprites driven by existing `PlayerState` / `OpponentState`, projected through the same 3/4 system and priority-sorted by court y.

## Build Spec Coverage

Phase 5 tasks (build-spec §13):

- Add sprite components.
- Add basic sprite animations.

## Suggested File Ownership

- `dink_rivals/assets/images/sprites/player_idle.png`
- `dink_rivals/assets/images/sprites/player_run.png`
- `dink_rivals/assets/images/sprites/player_swing.png`
- `dink_rivals/assets/images/sprites/opponent_idle.png`
- `dink_rivals/assets/images/sprites/opponent_run.png`
- `dink_rivals/assets/images/sprites/opponent_swing.png`
- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/config/debug_flags.dart` — add `useSprites` flag (default `true`).
- `dink_rivals/test/player_component_test.dart` (new smoke test).

Do not edit `racket_component.dart`, `ball_component.dart`, or any system in this ticket.

## Requirements

- Ship at least 1 sprite sheet per state (idle / run / swing) for both player and opponent. Frame count and FPS are tunable but should produce visible motion (idle ≈ 2 frames @ 2 fps, run ≈ 4 frames @ 8 fps, swing ≈ 3 frames @ 18 fps).
- Animation selection rules (read-only consumption of state):
  - `isSwinging == true` → play swing animation once, then fall back to idle/run.
  - `velocity.length > runThreshold` (e.g. 12.0 court units/sec) → run animation.
  - Else → idle animation.
- Sprites must be projected through `game.courtToWorld(state.position, 0)` and scaled by `game.depthScaleForY(state.position.y)`.
- Preserve current `priority = state.position.y.round()` ordering so depth sorting still works.
- Add `debugFlags.useSprites` (default `true`). When `false`, fall back to the existing primitive render path so missing assets degrade gracefully and so existing tests can opt out.
- Colors and tints come from `VisualPalette` (P5-001) — no new hardcoded color literals.

## Non-Goals

- No new shot buttons.
- No change to `PlayerState` / `OpponentState` shape.
- No racket/paddle sprite (P5-003).
- No ball sprite (P5-003).
- No scoreboard/feedback/UI restyle (P5-004).
- No audio or haptics.
- No 4-character art variants — Phase 5 ships one player skin and one opponent skin. Character-keyed art is Phase 6+.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Required tests:

- Smoke test: `PlayerComponent` mounts with all three sprite states without throwing.
- Smoke test: animation switches when `state.velocity` and `state.isSwinging` change.
- Existing tests remain green.

## Acceptance Criteria

- Player and opponent render as sprites at runtime.
- Idle / run / swing animations switch off `PlayerState` without polling the renderer.
- Depth-scale and priority-sort behavior unchanged.
- `debugFlags.useSprites = false` restores the gray-box circles.
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

- Added generated placeholder pixel sprite sheets for player/opponent idle, run, and swing states.
- `PlayerComponent` and `OpponentComponent` now load sprite sheets when `DebugFlags.useSprites` is true, retain primitive fallback rendering, preserve y-priority sorting, and select idle/run/swing animation from `PlayerState`.
- Added `player_component_test.dart` coverage for idle/run/swing selection.

## Verification

- `flutter analyze`: passed, zero issues.
- `flutter test`: passed, 96 tests.
- `flutter build apk --debug`: passed.
