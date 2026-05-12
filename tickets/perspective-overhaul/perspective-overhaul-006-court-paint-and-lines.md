---
id: PERSP-006
phase: perspective-overhaul
status: done
priority: high
parallel_group: paint
depends_on: [PERSP-001, PERSP-002]
blocks: [PERSP-009, PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-006 - Court Surface, Kitchens, Lines, and Apron Repaint

## Goal

Repaint the court surface so the new strong trapezoid reads clearly: lines stay visually parallel-with-the-sides (i.e. converge toward the vanishing point), kitchen panels respect the new tilt, surface texture and scuffs do not pinstripe at the near baseline, and the apron and court drop-shadow follow the trapezoid.

## Reference

- `docs/art/concepts/concept-screenshot.png` — kitchen lines and center service lines clearly converge with the side lines; surface texture does not warp obviously; apron shadow follows the trapezoid.

## Suggested file ownership

- `dink_rivals/lib/game/components/court_component.dart`
- `dink_rivals/lib/game/components/kitchen_zone_component.dart`
- `dink_rivals/test/court_component_test.dart`

Do not modify `Court.*` court constants or the kitchen rules in `match_rules_system.dart`.

## What is wrong today

- `CourtComponent._quadPath(...)` already projects rectangles via `game.courtToWorld(...)`. That is correct and pinhole-projection-friendly. The repaint work here is calibrating wear/scuff/texture sizes that were tuned to the old projection.
- Line stroke widths are `game.logicalToScreen(1.15).clamp(1.5, 3.0)` and `1.35`. With a stronger trapezoid the same logical width reads as a thick band near the camera and a hairline far away. That is *physically correct*, but the clamp `1.5..3.0` collapses the visual taper. Widen the clamp to `0.8..4.0` so the lines themselves visibly taper.
- `_drawPixelTexture` and `_drawScuffs` draw in court units and reproject — they will pick up the new trapezoid automatically, but the texture grid (`cell = 20`) may produce moiré at the far end. Increase `cell` toward the far end or limit the texture draw to a narrower court-y band.
- `_drawGeneratedSurfaceTexture` repeats an `ImageShader` in screen space, not court space. That breaks the perspective look for the surface texture. Convert the surface texture to a quad-projected fill if it is to remain on screen, or tile it in court space using small `_quadRect` chunks.

## Requirements

- All court geometry continues to be authored in court coordinates and projected via `game.courtToWorld(...)`. No screen-space rectangles for court surface.
- Line stroke widths scale with `depthScaleForY(courtY)` for the line's *midpoint*, with a wider visual range than today so the taper is visible.
- Surface texture rendering does not produce a screen-aligned pattern over a projected court. Either:
  - replace the `ImageShader` tile with a series of `_quadRect` calls in court space (low cost), or
  - leave the underlying image but apply a court-aligned mask so only the trapezoid quad is filled, with the shader transform set so tiles run along court-y not screen-y.
- Kitchen panels (`_drawServicePanels`) keep the same court coordinates but are repainted so the contrast holds at the far baseline (PHASE 5.2 palette tokens already provide `courtPlayingLight`, `courtPaint`, etc.).
- Apron drop-shadow in `ClassicEnvironmentComponent` is **not** modified here — see PERSP-007.

## Tests to extend in `test/court_component_test.dart`

- All court paths are constructed by projecting four court corners. (Probe via golden test or existing render tests if available; otherwise add a unit test that the helper `_quadPath` produces a path whose four points equal `courtToWorld(...)` for the four corners.)
- Line widths at `Court.bottom` are at least 1.6× line widths at `Court.top` (taper).

## Verification

```bash
flutter analyze
flutter test
```

Manual: emulator screenshot. Compare against `docs/art/perspective-overhaul/perspective-before-screenshot.png` — the side lines should now converge visibly and kitchen lines should run "parallel" to the side lines through the projection.

## Acceptance criteria

- All court paint is in court space.
- Line and scuff widths visibly taper with depth.
- No screen-aligned surface-texture pattern over the projected court.
- Tests pass.

## Implementation notes

(Filled in by the implementing agent.)
