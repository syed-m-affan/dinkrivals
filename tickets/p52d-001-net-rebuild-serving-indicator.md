---
id: P52D-001
phase: 5.2D
status: done
priority: high
parallel_group: C
depends_on: [P52B-001]
blocks: [P52G-001, P52M-001]
owner: codex
last_updated: 2026-05-11
---

# P52D-001 - Net Rebuild and Serving Indicator Relocation

## Goal

Rebuild the net to match the concept's rail, posts, mesh, and shadow while relocating the stray serve/indicator coin into the scoreboard flow.

## Build Spec Coverage

Phase 5.2D - Net Rebuild:

- Angled net rail.
- Posts at sideline ends.
- Vertical mesh strands.
- Coherent cast shadow.
- Serving indicator no longer floats over the net.

## Suggested File Ownership

- `dink_rivals/lib/game/components/net_component.dart`
- `dink_rivals/lib/game/components/score_component.dart` only for a minimal indicator handoff if needed
- `dink_rivals/lib/game/util/projected_shadow.dart` only if shared shadow behavior is reused
- `dink_rivals/test/score_component_test.dart` if indicator ownership changes
- `docs/art/phase-5.2-net-rebuild.png`
- `tickets/status.md`

Coordinate with P52G before making larger scoreboard changes.

## Requirements

- Draw net posts, top rail, mesh, and shadow in perspective with the retuned P52B projection.
- Keep the ball visible when it crosses or sits near the net.
- Avoid heavy diagonal mesh that creates visual noise.
- Remove or relocate any current rally/serve indicator coin that appears to sit on the net.
- If the indicator destination needs scoreboard support, add only the minimal bridge and leave full HUD restyle to P52G.
- Capture a screenshot with the ball near or above the net.

## Non-Goals

- No court surface zoning.
- No scoreboard restyle beyond indicator relocation handoff.
- No physics, collision, or rule changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Net reads as concept-like rail/posts/mesh instead of a flat band.
- Cast shadow feels attached to the net and does not obscure kitchen readability.
- Serving indicator is no longer visually stranded over the net.
- Ball crossing remains readable.

## Planning Notes

- Claude and subagents recommended committing the serving-indicator destination to the scoreboard to avoid P52D/P52G ambiguity.

## Implementation Notes

- Implemented: rebuilt net visual geometry and integrated serving state into the top scoreboard flow.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2-gameplay-emulator-smoke.png`.
