---
id: P0-007
phase: 0
status: done
priority: high
parallel_group: depth-cues
depends_on: []
blocks: [P0-008]
owner: codex
last_updated: 2026-05-11
revised_by: claude-2026-05-11
---

# P0-007 - Depth Cues and Entity Scale

## Goal

Add gray-box visual depth cues so the court and entities read more like a 2.5D sports game before the production art pass.

The concept screenshot sells depth through net height, foreground scale, shadows, and clear ball/shadow separation. The current Phase 2 build has a flat net line, same-size player/opponent circles, and subtle height cues, which makes the game feel top-down.

## Reference

- Desired direction: `docs/art/concept-screenshot.png`.
- Current problem reference: `docs/art/phase-2-screenshot.png`.

## Suggested File Ownership

- `dink_rivals/lib/game/components/net_component.dart`.
- `dink_rivals/lib/game/components/player_component.dart`.
- `dink_rivals/lib/game/components/opponent_component.dart`.
- `dink_rivals/lib/game/components/ball_component.dart`.
- `dink_rivals/lib/game/components/shadow_component.dart`.
- `dink_rivals/lib/game/dink_rivals_game.dart` — `_renderRackets` and the touch-control overlay live here; racket draw order needs to coordinate with the new entity bodies.

Do not add production art assets in this ticket. Keep the work gray-box and low risk.

## Concrete Issues to Address

Comparing `concept-screenshot.png` against the current build:

1. **Net is a flat 4px black line.** `NetComponent` only calls `canvas.drawLine`. The concept renders a mesh with height and two posts. Gray-box equivalent: project a second polyline at `z = ~24` and connect to the ground line at both ends (and optionally a few vertical struts), so the net visibly occupies vertical space.
2. **Player and opponent are flat 8-unit circles** drawn at their court position. The concept renders proper figures with body height. Gray-box equivalent: draw the ground footprint as a small flattened ellipse (the "feet") and a vertical capsule rising from it via `courtToWorld(pos, z=~20)`. This re-uses the existing z-displacement logic so the body naturally reads as taller for near entities and shorter for far entities.
3. **Shadow is a 12×6 logical-unit ellipse at 40% black.** Against the tan court this is nearly invisible. Increase contrast (opacity ~0.6) and scale shadow size with ball altitude: bigger and dimmer at high z, tighter and darker at z≈0, so the ball/shadow gap sells height.
4. **Ball radius bumps from 4 to 6 only above z=60.** Replace with a smooth scale of radius with z (e.g. `4 + clamp(z, 0, 100) * 0.04`) so altitude reads continuously.
5. **Draw order with the new net height.** Entities and ball whose court-y is greater than `Court.netY` must render *after* the net (in front); entities whose court-y is less than `Court.netY` must render *before* the net (behind). Today everything draws over the net because the net is a flat line and depth never mattered.

## Implementation Notes

- Add a small projection-based scale helper if convenient, but the simplest path is to lean on the existing `courtToWorld(courtPos, z)` for vertical body rendering — the projection already handles near/far.
- Preserve existing gameplay hitboxes; this ticket changes visual rendering only.
- Do not modify `racketReach`, `racketHitRadius`, or any tuning constants — those belong to control tickets.
- Keep the gray-box palette (solid fills, no textures, no sprites).

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Manual QA Checklist

- Start a rally and watch low, medium, and lobbed balls.
- Confirm the shadow makes ball height easier to judge.
- Confirm the net reads as an obstacle with height, not just a flat black divider.
- Confirm player/opponent/racket/ball draw order still looks coherent when the ball crosses the net.
- Confirm no new visual cue makes the racket hitbox feel misleading.

## Acceptance Criteria

- Net has visible height/thickness in the gray-box view.
- Ball height is easier to read than in the Phase 2 screenshot.
- Near/far entity scale or equivalent visual treatment improves depth without changing collision logic.
- Player, opponent, ball, shadow, and racket remain readable on phone.
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

Completed on 2026-05-11:

- Replaced the flat net line with a raised gray-box net: top cord, ground line, posts, and vertical mesh struts.
- Reworked player/opponent circles into simple projected bodies with feet, torso, and head using `courtToWorld(..., z)`.
- Added depth scaling for player, opponent, ball, shadow, and racket visuals without changing collision or gameplay state.
- Made ball radius scale smoothly with altitude and strengthened the ball shadow with altitude-sensitive size/opacity.
- Added y-based component priorities for ball, shadow, player, opponent, and net so near/far draw order is more coherent around the raised net.

## Verification

- `flutter analyze`: passed with no issues on 2026-05-11.
- `flutter test`: passed 52/52 on 2026-05-11.
- `flutter build apk --debug`: passed on 2026-05-11.
- Installed on Pixel 10 Pro XL (`58011FDCQ00992`) and launched Quick Match.
- Device screenshot spot-check confirmed the raised net, taller player/opponent forms, readable ball/shadow, and clear bottom controls.
