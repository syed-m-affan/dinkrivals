---
id: PERSP-000
phase: perspective-overhaul
status: done
priority: critical
parallel_group: overview
depends_on: []
blocks: [PERSP-001, PERSP-002, PERSP-003, PERSP-004, PERSP-005, PERSP-006, PERSP-007, PERSP-008, PERSP-009, PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-000 - Perspective Overhaul Overview

## Problem

The current gray-box / Phase 5.x build does not read as 2.5D the way the concept art does.

- Reference (current state, problem): `docs/art/perspective-overhaul/perspective-before-screenshot.png` — the court reads as a tilted rectangle. Side lines are nearly parallel, far baseline is only slightly narrower than the near baseline, and characters near and far are nearly the same size.
- Reference (target): `docs/art/concepts/concept-screenshot.png` — the court is a strong trapezoid, the far baseline is roughly half the width of the near baseline, the rival at the top of the court is visibly smaller than the player at the bottom, and the ball clearly separates from its shadow as it arcs.

The root cause is not a Flutter/Flame limitation. The current projection in `dink_rivals/lib/game/util/court_projection.dart` already uses a linearly-interpolated trapezoid (`farWidthScale = 0.46`, `nearWidthScale = 1.20`, `yCompression = 0.62`, `zDisplacement = 1.10`), but:

- The y-axis is a flat linear compression (`screenY = courtY * yCompression`). In a real forced perspective, equal court-y steps near the camera should consume far more screen pixels than equal steps far from the camera.
- The z displacement is a constant scalar. A ball at z=50 near the player should rise more pixels than a ball at z=50 at the far baseline.
- The entity depth scale curve is weak: `depthScaleForY` returns `0.72 → 1.08`, while the concept needs roughly `0.55 → 1.10`.
- The court is then auto-fit by `CourtLayoutSystem.resize(...)`, which clamps to the available vertical space and can flatten the perceptual trapezoid further.
- A few components (net, environment back band, court paint) draw in court-coordinate quads that already pick up the trapezoid, but the entity sprites bake their own scale via `depthScaleForY` (a separate linear curve), so the perspective contract is not coherent across renderers.

The fix is a coherent camera-style projection model (pinhole / vanishing-point) used as the single source of truth for: screen position, depth-derived scale, z lift, and shadow offset. Once that exists, the rest of the work is repointing each renderer at it.

## External-AI suggestions (double-checked against the code)

The user shared a limited-context AI's plan. Verdict:

- **"Use a trapezoidal court" — correct.** Already partially true via `CourtProjection.courtToScreen`. Need a stronger taper and a non-linear y-curve.
- **"`Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(...)` on a flat background" — wrong tool here.** Flame is already 2D and our renderers draw analytical quads in court space (`game.courtToWorld(...)`); a CSS-style perspective `Transform` would fight the existing model and break HUD/text rendering. We should keep the analytical projection in `CourtProjection` and just make it a proper pinhole model.
- **"Scale sprites by y position" — correct.** Already done via `depthScaleForY`. The curve needs to be stronger and derived from the same camera as the projection, not an independent table.
- **"Separate the ball from its shadow with a z variable" — already done.** `BallState` has `z`, `ShadowComponent` draws at z=0, `BallComponent` draws at `courtToWorld(pos, z)`. The work here is making the gap *scale with depth* so the lift reads correctly across the court.
- **"`scale = baseScale * (y / screenHeight)`" — wrong formula.** Use `scale = focal / (distance(y) + d0)` so it matches the projection used for positions; otherwise the sprite "floats" relative to the court.

## Phase scope

Per `CLAUDE.md` / `docs/specs/build-spec.md` §2 non-negotiables, the 3/4 perspective is a permanent product rule. This overhaul stays inside that rule; it is **not** a move to pure side-view or pure top-down. No new dependencies.

Gameplay logical coordinates (`Court.*` constants, `BallState.x/y/z`, court-space hitboxes) must stay untouched. This is a rendering and perceived-feel pass. Hit windows and physics constants are audited but only changed where the new perspective actively misleads the player.

## Ticket map

Tickets are designed to be picked up by separate agents. Run order:

1. `PERSP-001` — Pinhole camera rewrite of `CourtProjection`. Single source of truth. **Blocks everything else.**
2. `PERSP-002` — `CourtLayoutSystem` / framing pass so the redesigned projection fits a phone screen.
3. After 001+002 land, the following run in parallel groups:
   - Group **entities** (touches per-component renderers):
     - `PERSP-003` — Player, opponent, racket depth scaling.
     - `PERSP-004` — Ball, shadow, ball-trail z separation in the new projection.
     - `PERSP-005` — Net trapezoidal rebuild and post height.
   - Group **paint** (touches court / environment paint):
     - `PERSP-006` — Court surface, kitchens, lines, apron paint repaint for the new trapezoid.
     - `PERSP-007` — Environment back-wall band, fence, foliage realignment.
   - Group **input-overlay**:
     - `PERSP-008` — Aim indicator, swing lane, racket strokes, vfx wired to the new projection.
4. `PERSP-009` — Gameplay feel and physics audit (hit windows, ball arc, AI aim) under the new perspective.
5. `PERSP-010` — Tests + before/after screenshot set + Pixel-class device QA + closeout.

## Cross-cutting decisions (agents implementing 001 must record these in code)

These names are reserved so later tickets can reference them.

- The projection exposes a single function `CourtProjection.project(courtPos, z) -> Vector2` returning screen coordinates relative to a stable reference (the projected min corner). Existing call sites continue to use `game.courtToWorld(...)`.
- It exposes `CourtProjection.depthScaleForY(courtY)` and `CourtProjection.zLiftForY(courtY)` derived from the **same camera parameters** so depth scale and ball lift agree.
- Camera parameters are constants in `CourtProjection` (no new tuning class yet): `focalLength`, `cameraHeight`, `cameraTilt`, `nearOffset`, plus a single readability clamp on the depth-scale curve.
- Logical court coordinates (`Court.*`) and `BallState.x/y/z` are not changed.

## Non-goals for this overhaul

- No new asset generation. Sprites and props are reused; only their placement/scale changes.
- No move to a 3D engine. Stays in Flame's 2D canvas.
- No new shot types, scoring rules, or AI behavior changes — see `PERSP-009` for the narrow audit.
- No new dependencies (Riverpod, GoRouter, ads, IAP). Stay inside the current phase.

## Definition of done for the overhaul

- All ten tickets are `done` or `review`.
- `flutter analyze` and `flutter test` pass.
- `docs/art/perspective-overhaul/perspective-after-screenshot.png` exists, captured on a Pixel-class device, and side-by-side comparison with `concept-screenshot.png` shows: visibly stronger trapezoid, near baseline ≥ 1.7× the far baseline width, rival is at most ~0.65× the player's projected height when both stand at their start positions, ball/shadow gap visibly grows on lobs.
- No regression in rally feel: a 5-minute rally on a physical Android device runs without crash and without the player missing balls that were previously hittable at the same court coordinates (see `PERSP-009`).

## Implementation notes

Completed as the organizing ticket for the painted-court-aligned perspective pivot. PERSP-001 through PERSP-009 are implemented; PERSP-010 remains in review for human physical-device rally signoff.
