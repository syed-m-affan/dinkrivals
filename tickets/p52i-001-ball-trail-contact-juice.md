---
id: P52I-001
phase: 5.2H
status: todo
priority: high
parallel_group: G
depends_on: [P52A-002]
blocks: [P52M-001]
owner: unassigned
last_updated: 2026-05-11
---

# P52I-001 - Ball Trail and Contact Juice

## Goal

Add the concept-like arcing ball trail and polish contact/bounce VFX while keeping the ball readable and avoiding per-frame allocation costs.

## Build Spec Coverage

Phase 5.2H - Ball Trail and Contact Juice:

- Short arcing ball trail.
- Hit spark polish.
- Bounce dust polish.
- Fixed-size sample buffer.

## Suggested File Ownership

- `dink_rivals/lib/game/components/vfx/vfx_layer_component.dart`
- `dink_rivals/lib/game/components/ball_component.dart` only if trail sampling needs ball render state
- `dink_rivals/lib/game/dink_rivals_game.dart` only for existing event hookup adjustments
- `dink_rivals/assets/images/vfx/`
- `dink_rivals/test/vfx_layer_component_test.dart`
- `docs/art/phase-5.2-vfx-contact-sheet.png`
- `docs/art/phase-5.2-ball-trail.png`
- `tickets/status.md`

Coordinate with P5E-003 if its Android performance smoke remains open; do not duplicate VFX systems unnecessarily.

## Requirements

- Implement ball trail sampling with a capped ring buffer, ideally 8-12 samples, and no per-frame heap allocation.
- Draw the trail behind the ball and clear it on reset/contact/bounce as appropriate.
- Keep the ball itself higher contrast than the trail.
- Refresh hit spark and bounce dust using Phase 5E VFX conventions.
- Keep VFX lifetimes short and opacity low enough to avoid blocking ball/court lines.
- Add focused tests for capped sample count, clear behavior, and no unbounded effect growth.
- Capture contact-sheet or gameplay proof.

## Non-Goals

- No physics changes.
- No shot-power changes.
- No particle system rewrite if the existing VFX layer can be extended.
- No performance-heavy per-frame image generation.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

If Android is available, verify a short rally for frame drops or input lag.

## Acceptance Criteria

- Ball trail reads like the concept arc without hiding the ball.
- Hit and bounce VFX feel stronger but remain brief.
- Trail/effect buffers are capped.
- Existing VFX and gameplay tests pass.

## Planning Notes

- Claude flagged naive per-frame trail allocation as a performance risk. This ticket should be parallel-safe after P52A-002.
