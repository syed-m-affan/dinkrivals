# Perspective Overhaul — Before / After

This doc accompanies the `perspective-overhaul-000` through `perspective-overhaul-010` ticket track.

## References

| Slot | File | Source |
| --- | --- | --- |
| Before | `docs/art/perspective-before-screenshot.png` | Pre-overhaul, Pixel 10 Pro XL. Court drawn synthetically over the bg with a near-rectangular projection. |
| After  | `docs/art/perspective-after-screenshot.png`  | Post-overhaul, Pixel 10 Pro XL (`58011FDCQ00992`), Quick Match rally state. Court is the painted pickleball floor in the bg image; gameplay coords land on it. |
| Target | `docs/art/concept-screenshot.png`            | Concept art used as the 2.5D direction. |
| Bg art | `dink_rivals/assets/images/environment/classic/park_background_overhaul.png` | The painted pickleball court used as the visual floor. |

## Approach

The user requested a final pivot away from a synthetic pinhole projection: paint the court directly over the bg image and fix the math so the gameplay coords land on it.

- `CourtProjection` is now a **painted-court-aligned** projection. Constants in the class hold the pixel coordinates of the painted court control points inside `park_background_overhaul.png`:
  - `paintedFarLeftX/RightX = 340 / 639` at `paintedFarY = 605`
  - `paintedNetY = 790` for the visible net boundary
  - `paintedNearLeftX/RightX = 115 / 864` at `paintedNearY = 1175`
  - `imageWidth/Height = 979 / 1606`
- `courtToScreen(courtPos, z)` maps in image-pixel space: each court y maps piecewise through the far baseline, measured net line, and near baseline; each court x maps by lerp inside the trapezoidal width at that y; z lifts the y by `zLiftForY * z`.
- `CourtLayoutSystem.resize` now applies the same cover-fit transform that `ClassicEnvironmentComponent._drawGeneratedBackgroundBase` uses for the bg image, so gameplay positions and the painted court always agree.
- `depthScaleForY(y)` derives from the painted width at that y (relative to the near baseline) — same source as the lateral projection, so they cannot drift.
- `CourtComponent` and `KitchenZoneComponent` are now no-op renderers. The painted bg image already contains the court surface, kitchens, lines, fence, foliage, sky, and apron shadow.
- `NetComponent` replays a tightly aligned crop of the painted bg net strip at `Court.netY`. It uses the exact same image pixels as the background, so far-side balls/opponents can render under the net without introducing mismatched procedural net art.
- `ClassicEnvironmentComponent` no longer draws its `_drawCourtApron`, `_drawGeneratedFenceAnchor`, `_drawGeneratedCourtShadow`, or `_drawGeneratedDepthWash` overlays when the painted bg is loaded (they were dimming the painted court). Side props (benches, lamps, planters, bags, shrubs, signs, fence segments) still render on top via `EnvironmentLayout`.
- `OpponentComponent._farCourtReadabilityScale` removed in PERSP-003 — sprites now scale solely via `depthScaleForY`. The swing lane is drawn as a tapered polygon so its width matches the racket reach at start and end depths.

- Character sprites render at a smaller world height than their source frame and compensate for the two transparent bottom pixels in the sheets, so feet sit on the projected court line instead of floating above the shadow.
- Character sheets are palette-graded with warmer highlights, darker lower/right-side shading, and lower saturation so they sit closer to the painted environment style.
- Ball radius is scaled down with the same depth factor as characters so it reads as a game ball inside the painted environment instead of a large UI token.

## Measurements

- Near baseline width / far baseline width: **2.51×** (was ~1.59× in the prior linear projection, matches the painted-bg trapezoid).
- Opponent visual depth scale / player visual depth scale at start positions: ≈ **0.49** (was ~0.67).
- Z lift at near baseline / z lift at far baseline: matches the trapezoid ratio.
- Court fills the painted court inside the bg image at any resolution; the same cover-fit math is shared between bg renderer and `CourtLayoutSystem`.

## Verification

- `flutter analyze` — clean.
- `flutter test` - 176/176 green.
- `flutter build apk --debug` — succeeded.
- Installed on Pixel 10 Pro XL (`58011FDCQ00992`); launched Quick Match into rally state; screenshot captured.
- Latest net-occlusion smoke after the painted-strip adjustment was installed and launched on emulator-5554; see docs/art/perspective-gameplay-net-smoke-emulator.png.

## Known follow-ups

- If `park_background_overhaul.png` is regenerated, re-measure the painted court corner pixel positions in `CourtProjection` and update the constants. A test could assert the projection's four corners agree with a known good set of corner image px.
- The net occluder is visual only. If a future ticket wants ball-net collisions, implement that in gameplay/rules systems instead of coupling collision to the painted-strip renderer.
- The court surface texture asset (`court_surface_texture_generated.png`) is still in the asset bundle but no longer rendered. Safe to leave; can be removed in a cleanup ticket.
- 5-minute physical-device rally and subjective signoff vs the concept is the human-validation gate.
