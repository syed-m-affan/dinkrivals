---
id: P52C-001
phase: 5.2C
status: todo
priority: high
parallel_group: C
depends_on: [P52B-001]
blocks: [P52M-001]
owner: unassigned
last_updated: 2026-05-11
---

# P52C-001 - Court Surface Zoning and Line Contrast

## Goal

Bring the court surface closer to the concept by adding a dark apron frame, brighter playing surface, kitchen tint, and clearer line hierarchy without changing logical court bounds.

## Build Spec Coverage

Phase 5.2C - Court Surface Zoning:

- Navy outer apron frame.
- Light blue playing surface.
- Muted kitchen tint.
- Updated line contrast.

## Suggested File Ownership

- `dink_rivals/lib/game/components/court_component.dart`
- `dink_rivals/lib/game/components/kitchen_zone_component.dart`
- `dink_rivals/lib/game/config/visual_palette.dart` only for token usage from P52A-002
- `dink_rivals/test/phase5g_visual_golden_test.dart` if UI/golden coverage is updated
- `docs/art/phase-5.2-court-zoning.png`
- `tickets/status.md`

Do not edit `CourtProjection`, `CourtLayoutSystem`, ball physics, rules, scoring, AI, or hitboxes.

## Requirements

- Draw a concept-like apron/frame around the court while preserving the existing playable area.
- Use `VisualPalette` tokens from `P52A-002`; do not add hardcoded colors.
- Make kitchen zones visible but subordinate to court lines and ball readability.
- Keep sidelines, baselines, kitchen lines, center line, and net line high contrast.
- Add subtle texture/wear only if it does not reduce readability.
- Capture a screenshot showing court zoning with player, opponent, ball, controls, and scoreboard visible.

## Non-Goals

- No projection changes.
- No net rebuild.
- No environment prop/signage changes.
- No gameplay changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Court reads as zoned apron / playing surface / kitchen rather than one flat blue rectangle.
- Court lines are brighter than court fill and environment detail.
- Ball shadow and ball remain easy to track.
- No gameplay tests regress.

## Planning Notes

- This ticket should wait for P52B so line and apron placement are tuned against the final projection.
