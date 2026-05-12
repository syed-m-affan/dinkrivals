---
id: P51F-001
phase: 5.1F
status: done
priority: high
parallel_group: F
depends_on: [P51D-001, P51E-001]
blocks: [P51I-001]
owner: unassigned
last_updated: 2026-05-11
---

# P51F-001 - Park Depth and Background Richness

## Goal

Bring the Classic Court environment closer to the concept's layered park scene with richer but still readable background depth.

## Build Spec Coverage

Phase 5.1F - Park Depth and Background Richness:

- Layered far trees, fence/wall, mid props, benches, lamps, banners, planters, bags, and side depth.
- Environment richness without gameplay clutter.

## Suggested File Ownership

- `dink_rivals/assets/images/environment/classic/`
- `dink_rivals/assets/images/environment/shared/`
- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/test/environment_layout_test.dart`
- `docs/art/phase-5.1/phase-5.1-delta-inventory.md` (reference only)
- `tickets/status.md`

Coordinate with P51D/P51E if those tickets are active.

## Requirements

- Add concept-equivalent courtside detail where visible:
  - far tree mass
  - fence or wall layer
  - banners/signs behind far baseline
  - benches
  - lamps
  - planters/shrubs
  - equipment bag or small side props
- Keep top third visually layered: far background, fence, mid props, court.
- Use lower contrast and lower priority for decorative elements than gameplay-critical objects.
- Keep all props out of active court, controls, score, pause, feedback, and ball paths.
- Document any intentionally deferred concept details.

## Non-Goals

- No animated crowd.
- No dynamic banners.
- No weather, day/night, or parallax camera system.
- No tournament/unlock/court-selection work.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- The scene no longer reads as a basic court with sparse bushes.
- Top and side environment have layered depth closer to the concept screenshot.
- Added details do not reduce ball, court-line, kitchen, net, score, pause, or control readability.
- Environment placement remains data-driven and maintainable.

## Planning Notes

- Claude and the subagent both called out environment richness as separate from de-stretching and court grounding.
