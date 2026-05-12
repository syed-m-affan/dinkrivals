---
id: PERSP-007
phase: perspective-overhaul
status: done
priority: medium
parallel_group: paint
depends_on: [PERSP-001, PERSP-002]
blocks: [PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-007 - Environment Back-Band, Fence, and Apron Realignment

## Goal

Reflow `ClassicEnvironmentComponent` so the painted environment (back fence, foliage band, court apron drop shadow, prop placements, and depth wash) lines up with the new trapezoid. The generated background image is left in place; only the components that anchor to court coordinates need recalibration.

## Reference

- `docs/art/concepts/concept-screenshot.png` — the back fence and foliage band sits just above the far baseline, far baseline meets the court apron without a visible step, and props (benches, lamps) anchor to court coordinates that respect the new perspective.

## Suggested file ownership

- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/test/environment_layout_test.dart`

Do not regenerate or replace the generated background asset. Do not modify `Court.*` constants.

## What is wrong today

- `_drawGeneratedBackgroundBase(...)` covers the whole screen and is fine.
- `_drawGeneratedFenceAnchor`, `_drawGeneratedCourtShadow`, `_drawCourtApron` use court-coordinate quads with hard margins (e.g. `margin: 36`, `margin: 58`, offsets `Court.left - 44`). These pick up the new trapezoid automatically but the chosen margins were tuned for the old projection — the apron may now overhang the bottom of the screen or feather too wide far away.
- Prop placements in `EnvironmentLayout.classicProps` anchor to court coordinates, then scale by `depthScaleForY`. After PERSP-001 the scale curve changes — props at the back will read as significantly smaller than today. Audit and bump any prop logical sizes where the new scale makes them visually disappear.
- The back tree-line and hedge in `_drawBackTreeLine` are drawn in *screen space* (`game.size.y * 0.105`). With the new projection the far baseline shifts; the tree line should anchor to a court y just outside `Court.top`, projected once, so it remains glued to the back of the court instead of floating on the HUD.
- `_drawControlQuieting` draws an oval at `game.size.y * 0.92`. That is screen-space and fine to leave alone — but the `_farShadePaint` band at the top 26% of screen is meant to sit *above* the back fence. With a taller projected court that band may overlap the far baseline. Anchor the band to the projected far baseline instead.

## Requirements

- Audit every anchor in `ClassicEnvironmentComponent` and `EnvironmentLayout.classicProps`. Anchors that represent ground points must use court coordinates; anchors that represent sky/back-wall regions must reference the projected far baseline (e.g. `game.courtToWorld(Vector2(Court.width/2, Court.top - 40))`).
- Apron drop-shadow translations expressed in court units (offset court y/x), not in screen pixels.
- Tree line and hedge anchored to court y < `Court.top` and projected; their screen-y is whatever the projection says.
- Prop logical sizes bumped where needed so the smallest far-court prop still reads at ≥ 14 logical px on a 1080-wide viewport. Document each bump.
- Drop-shadow features should preserve readability of the court baseline (no dark band overlapping the far baseline).

## Tests to extend in `test/environment_layout_test.dart`

- The back tree line top-y is < projected `Court.top` y after `resize(Vector2(1080, 2400))` — i.e. trees sit above the court.
- The court apron drop-shadow bounds extend below the projected `Court.bottom` y — i.e. the shadow lies under the court.
- Smallest prop logical size is at least 14 court units after readability bumps.

## Verification

```bash
flutter analyze
flutter test test/environment_layout_test.dart
flutter test
```

Manual: emulator screenshot. The back fence band sits along the far baseline, no environment element crosses the play area, and props anchor correctly to court coordinates.

## Acceptance criteria

- Environment anchors that conceptually represent ground/back-wall regions are projected via `game.courtToWorld`.
- Props that disappear into the far court are bumped in `EnvironmentLayout`.
- `flutter analyze` and `flutter test` pass.

## Implementation notes

(Filled in by the implementing agent.)
