---
id: PERSP-003
phase: perspective-overhaul
status: done
priority: high
parallel_group: entities
depends_on: [PERSP-001, PERSP-002]
blocks: [PERSP-009, PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-003 - Player, Opponent, and Racket Depth Scaling

## Goal

Make the player, opponent, and their rackets scale and lift in a way that matches the new pinhole projection so a far-court rival is visibly smaller than a near-court player (concept ratio ≈ 0.55–0.65).

## Reference

- `docs/art/concept-screenshot.png` — opponent height is roughly 0.6× the player's projected height; both stand on the court surface and their feet anchor to the projected ground.

## Suggested file ownership

- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/components/racket_component.dart`
- `dink_rivals/test/player_component_test.dart`
- `dink_rivals/test/character_visuals_test.dart`

Do not change `PlayerState`, `PlayerSide`, animation frame logic, or hit/contact systems.

## What is wrong today

- `PlayerComponent._spriteWidth/_spriteHeight = 34/51` is scaled by `depthScaleForY(state.position.y)` only. With the old curve (0.72→1.08) the rival reads at ~0.67× — close enough that it does not sell depth.
- `OpponentComponent.visualScaleFor(depthScale) = depthScale * _farCourtReadabilityScale (1.34)` hacks the rival *larger* to keep them readable. With the new projection that hack actively works against the perspective.
- Racket draw in `RacketComponent` uses `depthScaleForY(courtStart.y)` once for stroke width and ignores that the racket head moves up the screen non-linearly with z.

## Requirements

- All three components must drive scale from `game.depthScaleForY(courtY)` only — no per-component multipliers like `_farCourtReadabilityScale`. The readability floor lives in `CourtProjection` (PERSP-001).
- Player and opponent feet anchor to `game.courtToWorld(state.position, 0)`. Sprite is drawn upward from feet using `game.courtToWorld(state.position, spriteHeight)` for the top so the body lift respects `zLiftForY(courtY)`.
- Rackets draw between `game.courtToWorld(hitter.position, racketContactZ)` and `game.courtToWorld(racketTipCourtPos, racketContactZ)`, so the racket head sits at the correct projected altitude both near and far.
- Component `priority` continues to be `state.position.y.round()` so the y-order draws correctly around the raised net.
- Hit confirm, point result, and swing pose lookups are unchanged.

## What about the readability hack?

`_farCourtReadabilityScale = 1.34` was added because at the old far depth (~0.72) the opponent at sprite size 34×51 was illegible. PERSP-001 sets the `minDepthScale` floor at 0.55. To preserve readability without breaking perspective, bump the *base* opponent sprite logical size in this ticket if needed (e.g. 36×54) rather than reintroducing a far-court multiplier. Document the bump in the ticket notes.

## Tests to extend

- `opponent visual height is at most 0.7x player visual height when both stand at start positions` (start positions are `Court.playerStartX/Y` vs. `Court.opponentStartX/Y`).
- `player visual height changes by less than 8% if the player moves laterally at the same court y` (lateral motion must not change depth scale).
- `racket draw end position equals courtToWorld(playerRacketPosition(), racketContactZ)` (no separate scale).
- `OpponentComponent.visualScaleFor` either is removed or asserts `visualScaleFor(x) == x`.

## Verification

```bash
flutter analyze
flutter test test/player_component_test.dart test/character_visuals_test.dart
flutter test
```

Manual: launch a Quick Match on `emulator-5554`, screenshot via `adb shell screencap`, and confirm the rival reads as visibly smaller than the player.

## Acceptance criteria

- Player, opponent, and racket scale only through `depthScaleForY`.
- `_farCourtReadabilityScale` and any per-component perspective multipliers are gone.
- Opponent visual height ≤ 0.7× player visual height at start positions, ≥ 0.55× (readability floor).
- All tests pass.
- Implementation notes record any base-size bump and link the emulator screenshot.

## Implementation notes

(Filled in by the implementing agent.)
