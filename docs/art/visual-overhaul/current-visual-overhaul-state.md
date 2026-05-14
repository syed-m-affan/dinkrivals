# Current Visual Overhaul State

Last updated: 2026-05-13

## Summary

The current runtime visual direction is a graybox projection sandbox, not the
painted park-court environment described by earlier VO2 closeout notes.

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

The active blocker is visual space and camera clarity:

1. Finalize perspective/projection.
2. Finalize the gameplay boundaries and how they are drawn.
3. Rebuild the environment graphics from scratch around the locked projection
   and boundary read.

## Current Runtime Render Path

The game screen intentionally does not use the old painted court environment.

- `ClassicEnvironmentComponent` fills the full game canvas with a flat gray
  background.
- `CourtComponent` draws only projected court guide lines: the outer gameplay
  boundary, kitchen/service guide lines, center service lines, and a small net
  center mark.
- `NetComponent` draws a procedural projected net in the same graybox language.
- `KitchenZoneComponent` does not draw a separate filled kitchen tint.
- Player, opponent, ball, shadows, paddles, controls, scoreboard, rally strip,
  and VFX remain live on top of the gray projection sandbox.

The older environment layer assets may still exist in the repo as historical
art/evidence, but they are not the current environment target. Do not treat
`layer_sky_trees.png`, `layer_fence_signage.png`, `layer_court_base.png`,
`layer_net.png`, or the earlier painted park captures as accepted runtime
closeout evidence for the current visual pass.

## Why The Environment Was Reset

The previous generated/painted environment work did not give a consistent
enough theme and made projection problems harder to see. The gray background is
intentional: it removes art noise so the court trapezoid, scale, z lift,
boundary placement, net read, and actor depth can be finalized before any new
environment assets are built.

Environment art should be generated or painted only after the projection and
boundary language are stable. New art must be fitted to the locked guide, not
used to hide unresolved projection issues.

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

Finalize `CourtProjection` and `CourtLayoutSystem` while the gray background is
active. Acceptance should focus on:

- Court trapezoid reads as 3/4, not flat top-down or side-view.
- Near/far player scale feels coherent.
- Ball z lift and shadow separation are understandable.
- Racket and swing lane stay aligned with the same court-space math.
- Controls and HUD do not hide important play-space edges on tall phones.

### 2. Gameplay Boundaries

Finalize the graybox guide before environment art:

- Decide exactly which lines must be visible during play: outer boundary,
  baselines, sidelines, kitchens, service center lines, and net plane.
- Make out-of-bounds and in-bounds reads obvious without relying on a finished
  court texture.
- Keep line contrast high enough for QA, but avoid drawing extra decorative
  structure that future art will have to fight.
- Preserve logical court constants and gameplay rules unless a specific tuning
  ticket changes them.

### 3. Environment Rebuild

After projection and boundaries are stable, create the environment from scratch:

- Use a consistent theme and palette across court, ground, fence, props, and
  UI-adjacent visual elements.
- Build assets to the finalized projection guide.
- Avoid reintroducing the previous painted-court mismatch or incompatible
  signage/net assumptions.
- Capture serve, rally, shot, point, pause, menu, roster, settings, and
  end-match evidence after the new environment lands.

## Documentation Status

Earlier VO2/VO3 docs remain useful historical context, especially for failed
approaches and sprite-generation evidence. They should not be read as the
current closeout plan where they describe a painted park court, replacement
signage, or layer-net validation as active runtime goals.
