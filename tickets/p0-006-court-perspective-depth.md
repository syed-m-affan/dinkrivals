---
id: P0-006
phase: 0
status: done
priority: high
parallel_group: perspective
depends_on: []
blocks: [P0-008]
owner: codex
last_updated: 2026-05-11
revised_by: claude-2026-05-11
---

# P0-006 - Court Perspective Depth

## Goal

Retune the gray-box court projection so the gameplay camera feels closer to `docs/art/concept-screenshot.png` and less like the flatter `docs/art/phase-2-screenshot.png`.

The current Phase 2 court reads too top-down: the court nearly fills as a flat trapezoid, the foreground does not feel much closer than the far side, and the net/kitchen area does not create enough depth.

## Reference

- Desired direction: `docs/art/concept-screenshot.png`.
- Current problem reference: `docs/art/phase-2-screenshot.png`.

Key visual target:

- Longer vertical court read.
- Stronger near-vs-far width difference.
- Less top-down/rectangular feel.
- Full court, kitchens, baselines, sidelines, controls, and HUD still visible on phone.

## Suggested File Ownership

- `dink_rivals/lib/game/util/court_projection.dart`.
- `dink_rivals/lib/game/dink_rivals_game.dart`.
- `dink_rivals/test/court_projection_test.dart`.

Do not change scoring, rules, shot classification, AI, or input behavior in this ticket.

## Root Cause Observed

The Phase 2 screenshot's "top-down" feel is mostly a **framing** problem, not a trapezoid-ratio problem:

- `CourtProjection.yCompression = 0.68` shrinks the court's projected screen-space height to `480 × 0.68 = 326`.
- Combined with projected width `220 × 1.08 = 238`, the projected aspect is ~0.73 — much wider-than-tall relative to a typical phone (~0.45).
- `DinkRivalsGame.onGameResize` therefore scales-to-fit by width and the court occupies ~50% of the screen vertically, leaving big black bands top and bottom.
- The far/near width ratio is already 1.08/0.68 = 1.59:1, which is in the same ballpark as the concept (~1.4:1). The trapezoid looks weak only because the whole court is small.

## Implementation Notes

- Primary tuning surface is `CourtProjection`. Suggested starting targets (iterate on device):
  - `yCompression`: 0.68 → ~1.20 so the projected court is taller than it is wide and fills the available vertical space.
  - `nearWidthScale`: 1.08 → ~1.15 and `farWidthScale`: 0.68 → ~0.62 for a slightly stronger trapezoid once the framing fills the screen.
  - `zDisplacement`: 1.05 → ~1.25 so ball height reads more clearly against the new court height.
- Update `DinkRivalsGame.onGameResize` only if needed so the larger projected court still leaves room for the bottom joysticks / SERVE button and the top HUD strip without overlap.
- The current Phase 0 debug overlay (PHASE label, FPS, ball coords, rally, last shot) consumes ~15% of the top of the screen and is the main reason the gameplay area feels cramped vs. the concept. Either hide it by default (debug flag) or compress it to a single line so the court can extend further upward.
- Keep logical court coordinates unchanged; this should be a screen projection/framing change, not a gameplay bounds rewrite.
- Preserve monotonic x/y mapping and z displacement semantics.
- Update / extend `test/court_projection_test.dart`:
  - Near baseline projects wider than far baseline by at least ~1.5×.
  - Screen y increases from far court to near court.
  - Increasing ball z still moves the rendered ball upward.
  - Projected court aspect ratio (width/height) is < 0.6 so it fills phone screens vertically.

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Manual QA Checklist

- Launch Quick Match on a phone-sized viewport or Android device.
- Compare the new view against `docs/art/concept-screenshot.png` and `docs/art/phase-2-screenshot.png`.
- Confirm the court no longer feels like a mostly top-down board.
- Confirm kitchens and net remain visible and understandable.
- Confirm bottom controls do not cover the player baseline or serve state in normal play.

## Acceptance Criteria

- Gray-box court has a visibly stronger 3/4 depth read than the Phase 2 screenshot.
- Near side reads closer/larger than far side.
- Full court remains visible on Pixel 10 Pro XL-class portrait screens.
- Ball, player, opponent, net, and kitchen zones remain readable.
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

Completed on 2026-05-11:

- Retuned `CourtProjection` to a taller court (`yCompression = 1.08`) with stronger near/far width scaling and stronger z displacement.
- Added `CourtProjection.depthScaleForY(...)` for near/far rendering scale.
- Updated `DinkRivalsGame.onGameResize(...)` to reserve top HUD and bottom control space before fitting the projected court.
- Compressed the debug overlay to one line so it no longer consumes the large top-left block from the Phase 2 screenshot.
- Added projection tests for near/far width ratio, portrait-friendly projected aspect, and depth scale.

## Verification

- `flutter analyze`: passed with no issues on 2026-05-11.
- `flutter test`: passed 52/52 on 2026-05-11.
- `flutter build apk --debug`: passed on 2026-05-11.
- Installed on Pixel 10 Pro XL (`58011FDCQ00992`) and launched Quick Match.
- Device screenshot spot-check confirmed the court is much taller than the Phase 2 screenshot, the near baseline reads wider than the far baseline, and the bottom controls no longer cover the court baseline.
