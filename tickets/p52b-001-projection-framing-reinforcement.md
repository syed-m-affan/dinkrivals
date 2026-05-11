---
id: P52B-001
phase: 5.2B
status: todo
priority: high
parallel_group: B
depends_on: [P52A-002]
blocks: [P52C-001, P52D-001]
owner: unassigned
last_updated: 2026-05-11
---

# P52B-001 - 3/4 Projection and Framing Reinforcement

## Goal

Retune court projection and layout so the gameplay view reads closer to the concept screenshot's 3/4 composition while preserving logical court coordinates and input feel.

## Build Spec Coverage

Phase 5.2B - 3/4 Perspective Reinforcement:

- Player baseline visibly wider than opponent baseline.
- Stronger tilted-court read.
- Before/after screenshot evidence.
- Coordinate-stability and readability gates.

## Suggested File Ownership

- `dink_rivals/lib/game/util/court_projection.dart`
- `dink_rivals/lib/game/systems/court_layout_system.dart`
- `dink_rivals/test/court_projection_test.dart`
- `dink_rivals/test/court_layout_system_test.dart`
- `docs/art/phase-5.2-projection-before.png`
- `docs/art/phase-5.2-projection-after.png`
- `tickets/status.md`

Do not edit scoring, ball physics, AI, shot logic, input contract, or court logical constants unless the build spec is updated first.

## Requirements

- Use `P52A-001` deltas to define the target visual change.
- Increase the 3/4 perspective read without hiding either kitchen or shrinking the opponent beyond readability.
- Preserve `Court` logical bounds and all gameplay coordinates.
- Add or update deterministic tests for court corners, net midpoint, and monotonic projection behavior.
- Add a regression check that logical court dimensions are not changed by the projection retune.
- Capture before/after screenshots from the same gameplay state.
- Record any apparent contact/aim feel risk caused by the projection change.

## Non-Goals

- No court colors, texture, net, signage, HUD, controls, character, VFX, physics, or rule changes.
- No move toward pure side-view or pure top-down.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

If an Android phone is available, install and capture a serve/rally screenshot before closeout.

## Acceptance Criteria

- Court reads materially more 3/4 than Phase 5.1.
- Player baseline is visibly wider than opponent baseline in the captured screenshot.
- Kitchens, lines, ball, players, net, and controls remain readable.
- Projection/layout tests pass.
- No gameplay coordinate or input contract changes are introduced.

## Planning Notes

- Both subagents called this the highest-risk Phase 5.2 ticket. Keep it serial and land it before court/net placement tickets depend on final projection.
