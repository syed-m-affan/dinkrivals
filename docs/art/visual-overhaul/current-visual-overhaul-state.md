# Current Visual Overhaul State

Last updated: 2026-05-14

## Summary

The current runtime visual direction is a projection-locked park court built
from the graybox control points, not the retired painted park-court environment
described by earlier VO2 closeout notes.

Player and opponent sprite production is complete for the current pass. The
accepted runtime sheets and gameplay animations were created with the sprite
generation workflow documented in
`docs/art/visual-overhaul/sprite-generator-skill-workflow.md`, using the
`character-animation-creator` run under
`docs/art/visual-overhaul/skill-runs/character-animation-creator-2026-05-12/`.
Future character sprite edits should continue through that workflow. Do not use
`dink_rivals/tool/generate_chibi_64_sprites.py` for production character work
unless the user explicitly asks for the legacy procedural fallback.

Ball rendering and VFX are mostly acceptable for now. They are not the active
blocker unless a projection, boundary, or environment change exposes a new
readability problem.

The active visual-overhaul sequence has advanced from graybox into the first
runtime environment rebuild:

1. Projection/perspective uses the locked `CourtProjection` control points.
2. Gameplay boundaries remain procedural in `CourtComponent` so line placement
   cannot drift from gameplay.
3. The environment art is generated from those control points by
   `dink_rivals/tool/generate_projection_environment.py` into
   `dink_rivals/assets/images/environment/classic/projection_environment_v1.png`.

## Current Runtime Render Path

The game screen intentionally does not use the old painted court environment.

- `ClassicEnvironmentComponent` draws `projection_environment_v1.png` with the
  same cover-fit transform used by `CourtLayoutSystem`.
- `ParkBackdrop` now uses the same projection environment asset for menu,
  settings, roster, and end-match widget surfaces, replacing the retired
  `park_background_overhaul.png` backdrop on those screens.
- `CourtComponent` draws projected gameplay boundaries above the bitmap: the
  outer boundary, kitchen/service guide lines, center service lines, and a small
  net center mark. The debug rally screen also highlights both kitchen zones.
- `NetComponent` draws a procedural projected net with the current palette so
  balls and players still sort correctly around the net plane.
- `KitchenZoneComponent` does not draw a separate filled kitchen tint.
- Player, opponent, ball, shadows, paddles, controls, scoreboard, rally strip,
  and VFX remain live on top of the projection-locked environment.
- `TouchControlsComponent` keeps the shot-indicator chips inside the portrait
  canvas so `LOB/SMASH` no longer clips at the right edge.
- Build-time QA launch defines can open a seeded end-match state for visual
  evidence without changing normal app startup:
  `DINK_RIVALS_INITIAL_ROUTE`, `DINK_RIVALS_QA_END_MATCH`, and
  `DINK_RIVALS_QA_END_MATCH_WINNER`.

The older environment layer assets may still exist in the repo as historical
art/evidence, but they are not the current environment target. Do not treat
`layer_sky_trees.png`, `layer_fence_signage.png`, `layer_court_base.png`,
`layer_net.png`, or the earlier painted park captures as accepted runtime
closeout evidence for the current visual pass.

## Why The Environment Was Reset

The previous generated/painted environment work did not give a consistent
enough theme and made projection problems harder to see. The gray background
was intentional while the court trapezoid, scale, z lift, boundary placement,
net read, and actor depth were being finalized.

The new environment art is fitted to the locked guide instead of used to hide
projection issues. It uses the concept screenshot and concept sheet for
composition cues: blue court, green park apron, dark fence/signage band, side
benches, planters, lamps, and chunky arcade pixel styling compatible with the
accepted player/opponent sprites.

## Character State

Character work is done for this stage:

- Player and opponent runtime sheets use 64x64 cells.
- Idle, ready, run, swing/serve, dink, drive, lob, smash, and hit-confirm
  gameplay animations are wired.
- Point-result visuals no longer fall back to the rejected old/manual model.
- Frame slicing, visible silhouette height, chroma cleanup, and runtime
  integration are covered by the existing sprite workflow evidence and tests.

The character art can still receive polish later, but it is not the next
production dependency.

## Ball And VFX State

Ball/VFX are mostly done for now:

- Ball scale, z lift, shadow separation, trail, contact, bounce, point, and miss
  effects are implemented and test-covered.
- Revisit only if the final projection or environment changes reduce ball,
  shadow, or contact readability.

## Next Work Sequence

### 1. Projection And Perspective

Current runtime uses the locked `CourtProjection` and `CourtLayoutSystem`.
Regression acceptance should focus on:

- Court trapezoid reads as 3/4, not flat top-down or side-view.
- Near/far player scale feels coherent.
- Ball z lift and shadow separation are understandable.
- Racket and swing lane stay aligned with the same court-space math.
- Controls and HUD do not hide important play-space edges on tall phones.

### 2. Gameplay Boundaries

Gameplay boundaries are now a procedural overlay above the environment asset:

- Decide exactly which lines must be visible during play: outer boundary,
  baselines, sidelines, kitchens, service center lines, and net plane.
- Make out-of-bounds and in-bounds reads obvious without relying on a finished
  court texture.
- Keep line contrast high enough for QA, but avoid drawing extra decorative
  structure that future art will have to fight.
- Preserve logical court constants and gameplay rules unless a specific tuning
  ticket changes them.

### 3. Environment Rebuild

The first rebuilt environment asset is active:

- Runtime asset:
  `dink_rivals/assets/images/environment/classic/projection_environment_v1.png`
- Generator:
  `dink_rivals/tool/generate_projection_environment.py`
- Manifest:
  `docs/art/visual-overhaul/projection-environment-v1-manifest.json`

Emulator evidence under
`docs/art/visual-overhaul/evidence/projection-environment-v1/` now includes
menu, settings, roster, game/serve, pause, debug rally, debug dink/drive/lob/
smash captures, point aftermath, shot feedback, five-minute debug-rally smoke,
and a widget-rendered end-match capture with the new environment active.
`end-match-live.png` is also captured from the running emulator through the QA
launch seed. The completion audit is
`docs/art/visual-overhaul/projection-environment-v1-completion-audit.md`.
Remaining closeout evidence still needs physical-device evidence and human
visual signoff. If the final QA requires end-match evidence reached through an
organic full match, that remains separate from the seeded live-app capture.

## Documentation Status

Earlier VO2/VO3 docs remain useful historical context, especially for failed
approaches and sprite-generation evidence. They should not be read as the
current closeout plan where they describe a painted park court, replacement
signage, or layer-net validation as active runtime goals.
