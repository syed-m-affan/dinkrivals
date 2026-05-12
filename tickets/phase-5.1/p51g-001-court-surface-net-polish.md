---
id: P51G-001
phase: 5.1G
status: done
priority: medium
parallel_group: G
depends_on: [P51E-001, P5C-003]
blocks: [P51I-001]
owner: unassigned
last_updated: 2026-05-11
---

# P51G-001 - Court Surface and Net Polish

## Goal

Refine the court surface, kitchen treatment, court line contrast, net rendering, and shadow cohesion toward the concept screenshot without hiding gameplay information.

## Build Spec Coverage

Phase 5.1G - Concept Court Surface and Net Polish:

- Concept-blue court material.
- Readable court lines and kitchen zone.
- Net rail/mesh/posts/cast shadow clarity.
- Unified lighting/shadow treatment.

## Suggested File Ownership

- `dink_rivals/lib/game/components/court_component.dart`
- `dink_rivals/lib/game/components/kitchen_zone_component.dart`
- `dink_rivals/lib/game/components/net_component.dart`
- `dink_rivals/lib/game/components/shadow_component.dart`
- `dink_rivals/lib/game/components/ball_component.dart` only if ball visibility is affected by court color
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/lib/game/util/projected_shadow.dart`
- `dink_rivals/test/projected_shadow_test.dart`
- `docs/art/phase-5.1/phase-5.1-delta-inventory.md` (reference only)
- `tickets/status.md`

Do not change court bounds, physics, scoring, or input.

## Requirements

- Tune court color and texture closer to the concept target while preserving contrast with the ball.
- Keep kitchen zone obvious during serve and rally.
- Ensure court lines read clearly on phone screenshots.
- Keep net readable as a physical object: posts, rail, mesh, and cast shadow.
- Avoid net/court shadows that hide the ball or ball shadow.
- Keep texture/scuffs subtle and not noisy.

## Non-Goals

- No `CourtProjection` changes.
- No new court selection or unlock work.
- No environment prop work outside net/court/shadow integration.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Court blue is closer to the concept target and still readable.
- Kitchen zone remains obvious.
- Net has clean posts, rail, mesh, and cast shadow without hiding the ball.
- Surface texture adds richness without reducing line readability.
- Existing court projection and gameplay tests remain green.

## Planning Notes

- This ticket should come after grounding so court polish can be tuned against the final surrounding colors.
