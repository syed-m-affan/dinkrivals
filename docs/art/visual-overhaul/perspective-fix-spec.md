# Perspective Fix Spec

Status: draft for the next visual pass.

## Problem

The current court is playable, but it still reads too top-down compared with the
concept art. A stronger non-linear perspective experiment made the court look
less top-down, but it also caused environment props and generated background art
to clash with the court and made gameplay feel wrong. The next fix must preserve
gameplay feel while improving the camera illusion.

## Current Architecture

The code already separates logical game state from visual projection:

- Gameplay uses court-space coordinates: ball `x/y/z`, player/opponent `x/y`,
  shot paths, hitboxes, and physics remain in `dink_rivals/lib/game/systems/`.
- Rendering goes through `CourtProjection` and `CourtLayoutSystem`.
- Ball height is already visual-only through `courtToWorld(courtPosition, z)`.
- Player/opponent/ball scale already comes from `depthScaleForY`.
- Draw order already follows court depth: larger court `y` is closer to the
  camera, so `priority = state.position.y.round()` is the correct direction for
  this coordinate system.

Do not move physics, hitboxes, or input controls into screen coordinates.

## Target

The court should feel like a 3/4 mobile sports court, closer to the concept art:

- Far court visibly narrower than near court.
- Far player smaller than near player, but still readable.
- Net remains a stable visual anchor and does not become oversized.
- Ball shadow stays grounded at the court point while the ball sprite rises on
  the `z` axis.
- Court and environment agree on one camera angle; props should not intersect
  the active court unless explicitly allowed as backdrop underlap.
- Touch controls and serve flow must feel unchanged.

## Constraints

- Preserve logical court dimensions and rules.
- Preserve manual control semantics and hitbox calculations.
- Keep the first implementation inside `CourtProjection` and
  `CourtLayoutSystem`; add a new base component only if repeated render code
  becomes the blocker.
- Avoid a single large projection jump. Tune in small increments and validate on
  Pixel after each step.
- Do not commit a projection change if `environment_layout_test.dart` fails or
  if Pixel gameplay feels displaced under the controls.

## Recommended Implementation Plan

1. Capture current Pixel baseline:
   - menu
   - serve setup
   - rally after serve
   - one swing/VFX state
2. Add projection debug documentation:
   - far baseline width
   - net width
   - near baseline width
   - projected court height
   - player/opponent scale at start positions
3. Tune the existing linear projection first:
   - slightly lower `yCompression`
   - slightly lower `farWidthScale`
   - only slightly raise `nearWidthScale`
   - keep `depthScaleForY` close to current values
4. Reposition or mark environment props only after the projection is chosen.
5. Capture the same Pixel screenshots and compare against baseline.
6. If linear tuning cannot satisfy the target, prototype non-linear depth behind
   a config flag and update prop layout in the same branch before user review.

## Guardrails

The previous failed experiment used an aggressive perspective divide and curved
Y mapping. It made the far court smaller, but it also changed too many visual
relationships at once. Avoid repeating that approach without a full art-layout
branch.

Minimum checks before committing a perspective change:

```powershell
cd dink_rivals
flutter test test/court_projection_test.dart test/court_layout_system_test.dart test/environment_layout_test.dart
flutter analyze
flutter build apk --debug
flutter install -d 58011FDCQ00992 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

Required evidence before closeout:

- `docs/art/visual-overhaul/evidence/perspective-before-menu.png`
- `docs/art/visual-overhaul/evidence/perspective-before-serve.png`
- `docs/art/visual-overhaul/evidence/perspective-after-menu.png`
- `docs/art/visual-overhaul/evidence/perspective-after-serve.png`
- notes explaining any prop-layout changes made to match the new camera.
