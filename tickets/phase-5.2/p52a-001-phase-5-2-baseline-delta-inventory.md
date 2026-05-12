---
id: P52A-001
phase: 5.2A
status: done
priority: high
parallel_group: A
depends_on: [P51I-001]
blocks: [P52A-002, P52B-001, P52C-001, P52D-001, P52E-001, P52F-001, P52G-001, P52H-001, P52I-001, P52J-001, P52K-001, P52L-001]
owner: codex
last_updated: 2026-05-11
---

# P52A-001 - Phase 5.2 Baseline and Concept Delta Inventory

## Goal

Lock the Phase 5.2 starting point and create an implementation-grade delta inventory against `docs/art/concepts/concept-screenshot.png` and `docs/art/concepts/concept-sheet.png`.

## Build Spec Coverage

Phase 5.2A - Composition Baseline and Concept Mapping:

- Phase 5.2 baseline screenshots.
- Region-keyed concept delta inventory.
- Explicit decision on whether open Phase 5.1/P5 review gates are prerequisites or absorbed by Phase 5.2.

## Suggested File Ownership

- `docs/art/phase-5.2/phase-5.2-delta-inventory.md`
- `docs/art/phase-5.2/phase-5.2-baseline-*.png`
- `docs/art/phase-5.1/phase-5.1-final-*.png` (reference only unless capturing a missing baseline)
- `docs/art/phase-5/visual-direction.md` (reference only)
- `tickets/status.md`

Do not edit gameplay, rendering, assets, or UI code in this ticket.

## Requirements

- Confirm the available Phase 5.1 final screenshots: serve, rally, pause, and any point-feedback capture.
- If `P51I-001` is still in `review`, record whether its remaining 5-minute Android smoke blocks Phase 5.2 or is absorbed by `P52M-001`.
- Compare the Phase 5.1 final rally/serve screenshots against `concept-screenshot.png`.
- Compare HUD, characters, court cards, roster, and serve-meter/control expectations against `concept-sheet.png`.
- Number deltas by concept region:
  - projection/framing
  - court zoning
  - net and serving indicator
  - backdrop signage
  - character identity
  - scoreboard/rally/last-shot readout
  - feedback banner
  - ball trail/contact VFX
  - serve meter/controls
  - park depth
  - menu/end-match residual composition
- Mark each older `P5H-*` visual follow-up as superseded, absorbed, kept, or deferred to Phase 5.3.
- Define the required Phase 5.2 final screenshot set: serve, rally, point feedback, pause, end-match, and main menu.

## Non-Goals

- No code changes.
- No new art generation.
- No subjective signoff without screenshot evidence.
- No gameplay, physics, AI, scoring, ad, audio, haptics, or input changes.

## Verification

- Confirm all referenced screenshot and concept files exist.
- Confirm every Phase 5.2 build-spec gap has a numbered delta or an explicit non-goal.

## Acceptance Criteria

- `docs/art/phase-5.2/phase-5.2-delta-inventory.md` exists and is specific enough for implementation agents to work from.
- Prior open visual gates are explicitly handled.
- P5H overlap is recorded to prevent duplicate work.
- No implementation files are changed.

## Planning Notes

- Claude and two Codex subagents agreed this baseline ticket must exist before implementation work. Subagent signoff is conditional on this ticket producing concrete deltas and handling open review gates.

## Implementation Notes

- Implemented: added `docs/art/phase-5.2/phase-5.2-delta-inventory.md`, handled prior review gates, and mapped concept deltas/P5H overlap for implementation.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2/phase-5.2-gameplay-emulator-smoke.png`.
