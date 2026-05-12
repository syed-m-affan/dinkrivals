---
id: P51E-001
phase: 5.1E
status: done
priority: high
parallel_group: E
depends_on: [P51D-001, P5C-003]
blocks: [P51F-001, P51G-001, P51I-001]
owner: unassigned
last_updated: 2026-05-11
---

# P51E-001 - Court Grounding and Grass Integration

## Goal

Fix the floating-court and wonky grass/background read by adding believable court-ground contact, apron transitions, soft shadows, and quiet ground under controls.

## Build Spec Coverage

Phase 5.1E - Grounding, Grass, and Court Integration:

- Ground/apron/court-edge treatment.
- Embedded court read instead of pasted-on court.
- Grass/pavement transitions and control-area quieting.

## Suggested File Ownership

- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/components/court_component.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/assets/images/environment/classic/`
- `dink_rivals/assets/images/environment/shared/`
- `dink_rivals/test/environment_layout_test.dart`
- `docs/art/phase-5.1/phase-5.1-delta-inventory.md` (reference only)
- `tickets/status.md`

Avoid `CourtProjection` changes. `CourtLayoutSystem` changes require evidence from P51A.

## Requirements

- Add or refine an apron/contact surface around the court.
- Add soft court-edge shadow, pavement/grass transition, edge wear, or equivalent grounding treatment.
- Remove visible repeated tile seams or strong tile-band artifacts from gameplay framing.
- Ensure bottom control area sits over quiet ground without a harsh horizontal seam.
- Keep court lines, kitchen, net, ball, and ball shadow higher priority than ground detail.
- Preserve SafeArea and controls.

## Non-Goals

- No gameplay, physics, AI, scoring, or control changes.
- No new environment props beyond what is needed for grounding.
- No full court unlock/selection work.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

If Android is available, capture serve and rally screenshots.

## Acceptance Criteria

- Court appears embedded in the park surface rather than floating over a flat or repeated tile background.
- Grass/pavement around the court has soft transitions and consistent perspective.
- Bottom controls remain readable and do not reveal ugly repeated tile blocks.
- Ball, ball shadow, court lines, kitchen, and net remain readable.

## Planning Notes

- This ticket may supersede `P5H-006` if it solves the environment depth/background band gap.
