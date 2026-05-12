---
id: PERSP-001
phase: perspective-overhaul
status: done
priority: critical
parallel_group: foundation
depends_on: [PERSP-000]
blocks: [PERSP-002, PERSP-003, PERSP-004, PERSP-005, PERSP-006, PERSP-007, PERSP-008, PERSP-009, PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-001 - Pinhole-Camera Rewrite of `CourtProjection`

## Goal

Replace the current linear-interpolation projection with a true pinhole / vanishing-point camera so that screen-x, screen-y, depth scale, and z lift all derive from one consistent model. This is the foundation every other perspective-overhaul ticket builds on.

## Reference

- Problem: `docs/art/perspective-overhaul/perspective-before-screenshot.png` — weak trapezoid, equal entity sizes, flat z lift.
- Target: `docs/art/concepts/concept-screenshot.png` — strong trapezoid, near baseline visibly wider than far, near entities clearly larger, ball lift reads clearly.

## Suggested file ownership

- `dink_rivals/lib/game/util/court_projection.dart` (rewrite)
- `dink_rivals/test/court_projection_test.dart` (extend)

Do not touch any rendering component, system, or `CourtLayoutSystem` in this ticket. Layout fit-to-screen is PERSP-002.

## What is wrong today

`CourtProjection` projects:

```
widthScale(y)  = farWidthScale + (nearWidthScale - farWidthScale) * (y / Court.length)
screenX(c, y)  = Court.width/2 + (c.x - Court.width/2) * widthScale(y)
screenY(y, z)  = y * yCompression - z * zDisplacement
depthScale(y)  = 0.72 + 0.36 * (y / Court.length)
```

Three problems:

1. `screenY` is linear in court-y. In a real forced perspective, screen-y is non-linear in court-y — far-court court-y steps should consume *fewer* screen pixels than near-court steps.
2. `zDisplacement` is constant. A ball at z=50 near the player should rise more pixels than the same z=50 at the far baseline.
3. `depthScale` is a separate linear curve that has no mathematical relationship to the position projection. A sprite scaled by it can drift relative to the lines on the court when constants are retuned independently.

## Required model

Implement an analytical pinhole projection. Recommended formulation (agents may adjust constant names but must preserve the contract):

```
// Camera parameters (constants in CourtProjection)
focalLength    // controls field-of-view; ~480
cameraHeight   // virtual altitude above court plane in court units
cameraTilt     // pitch angle in radians; 0 = pure top-down, pi/2 = pure side
nearOffset     // distance from camera to nearest visible court point, in court units; >0
courtCenterX   // = Court.width / 2

// Per-point depth from camera (monotonic in courtY: bigger courtY = nearer)
distance(courtY) = nearOffset + (Court.length - courtY) * cos(cameraTilt)
                   + cameraHeight * sin(cameraTilt)

// Screen projection
screenX(courtX, courtY) = courtCenterX
    + (courtX - courtCenterX) * focalLength / distance(courtY)

screenY(courtY, z) =
    focalLength * (cameraHeight - z) * cos(cameraTilt) / distance(courtY)
    + focalLength * (Court.length - courtY) * sin(cameraTilt) / distance(courtY)

// Same-camera derived helpers
depthScaleForY(courtY) = clamp(
    focalLength / distance(courtY) / referenceScale,
    minDepthScale, maxDepthScale)

zLiftForY(courtY) = focalLength * cos(cameraTilt) / distance(courtY)
```

The agent is free to substitute an equivalent closed form (e.g. directly parameterizing horizon-y + vanishing focal in screen space) so long as the four contract properties below hold.

### Contract properties (all must be true; cover in tests)

1. **Monotonic x**: for any fixed `courtY`, `screenX` is strictly monotonic in `courtX`.
2. **Monotonic depth-y**: `screenY(courtY, 0)` is strictly increasing in `courtY` (far court → smaller screen-y, near court → larger screen-y).
3. **Non-linear y**: equal court-y steps near `Court.bottom` produce strictly larger screen-y deltas than equal steps near `Court.top`. Specifically, for `dy = 40`:
   `screenY(Court.bottom, 0) − screenY(Court.bottom − dy, 0) > 1.6 × (screenY(Court.top + dy, 0) − screenY(Court.top, 0))`.
4. **Trapezoid strength**: near baseline projected width ≥ 1.7× far baseline projected width.
5. **Z lift scales with depth**: for the same `z`, `screenY` reduction (lift) at `courtY = Court.bottom` is strictly greater than at `courtY = Court.top`.
6. **Depth scale derived from same camera**: `depthScaleForY(Court.bottom) / depthScaleForY(Court.top) ≈ distance(Court.top) / distance(Court.bottom)` (within 5%).
7. **Readability clamp**: `depthScaleForY` never drops below `0.55` so far-court characters remain legible. Reasonable starting values: `minDepthScale = 0.55`, `maxDepthScale = 1.15`.

### API the rest of the codebase will call

Keep these two existing entry points so PERSP-002+ can pick this up with zero non-fitting churn:

```dart
class CourtProjection {
  static Vector2 courtToScreen(Vector2 courtPos, double z); // existing signature
  static double depthScaleForY(double courtY);              // existing signature
  // New, optional but recommended:
  static double zLiftForY(double courtY);                   // pixels of lift per court-z unit at this y
  static double distanceForY(double courtY);                // camera-to-point depth, exposed for QA/debug
}
```

`zLiftForY` is the value `(screenY(y, 0) - screenY(y, 1))`. Exposing it lets the ball arc and ball trail render with a depth-correct lift instead of guessing.

## Suggested starting constants (iterate on device in PERSP-002)

```
focalLength    = 460
cameraTilt     = 0.95          // radians, ~54°
cameraHeight   = 220
nearOffset     = 90
minDepthScale  = 0.55
maxDepthScale  = 1.15
referenceScale = focalLength / distance(Court.bottom)  // so near depth scale ≈ 1.0
```

These produce a near-baseline projected width ≈ 1.9× the far-baseline width, a screen-y stretch ratio ≈ 2.0× near vs. far, and `depthScaleForY` ≈ `0.58 → 1.10`. Adjust if PERSP-002 finds that fit-to-phone framing breaks.

## Tests to write / extend in `test/court_projection_test.dart`

Replace the existing `near baseline projects much wider than far baseline` test (current threshold `> 1.5`) with the stronger threshold above, and add:

- `screen-y delta is non-linear in court y` covering contract property (3).
- `z lift increases toward the near court` covering contract property (5).
- `depth scale ratio matches distance ratio` covering contract property (6).
- `depth scale never drops below readability floor` covering contract property (7).
- Existing tests (`monotonic x and y`, `increasing z displaces rendered y upward`, `net y maps consistently when ball is on the ground`, `projected court aspect is portrait friendly`) must still pass without modification.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test test/court_projection_test.dart
flutter test
```

Layout, sprite, net, court, environment, and aim renderers will look wrong at the end of this ticket — that is expected and is the work of the dependent tickets. The acceptance bar here is purely the projection contract and tests.

## Acceptance criteria

- `CourtProjection` is rewritten as a pinhole camera model with all four contract properties met.
- All existing `court_projection_test.dart` assertions still pass and new assertions for properties (3), (5), (6), (7) are added.
- `flutter analyze` is clean.
- `flutter test` passes for `court_projection_test.dart`. Other test suites may temporarily fail and are addressed by their owning dependent tickets.
- `Court.*` constants are unchanged. `BallState`, `PlayerState`, hitbox logic, and any gameplay system are untouched.

## Implementation notes

(Filled in by the implementing agent.)
