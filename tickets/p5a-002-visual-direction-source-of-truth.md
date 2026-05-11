---
id: P5A-002
phase: 5A
status: done
priority: high
parallel_group: B
depends_on: [P5A-001]
blocks: [P5A-003, P5B-001, P5C-001, P5D-001, P5E-001, P5F-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5A-002 - Visual Direction Source of Truth

## Goal

Create the art-direction document that later agents use to produce compatible environment, sprite, VFX, and UI assets.

## Build Spec Coverage

Phase 5A - Concept Frame and Art Direction Lock:

- Visual-direction source-of-truth note.
- Approved concept references, revision date, locked decisions, provisional decisions, known gaps, and concept change intake rules.
- Pixel-density rules and minimum readable sizes.

## Suggested File Ownership

- `docs/art/visual-direction.md` (new)
- `docs/art/visual-gap-inventory.md`
- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`

Avoid editing Dart source or binary assets in this ticket.

## Requirements

- Create `docs/art/visual-direction.md`.
- Include approved references and their roles:
  - `docs/art/concept-screenshot.png`
  - `docs/art/concept-sheet.png`
  - current Phase 5 baseline screenshots from P5A-001.
- Define locked decisions, provisional decisions, and deferred decisions.
- Define minimum readable sizes for ball, player, opponent, paddles, court lines, scoreboard text, feedback text, and controls.
- Define pixel-density guidance for:
  - court/world textures
  - character sprites
  - VFX sprites
  - UI panels/buttons/icons
- Define concept-art intake rules so future concept changes become explicit ticket updates rather than silent scope creep.
- Link back to the gap inventory.

## Non-Goals

- No asset generation.
- No runtime code changes.
- No design changes that alter gameplay, projection, court bounds, or controls.

## Verification

- Markdown links resolve to existing files.
- The document is specific enough that an agent can decide whether a future asset is on-style.

## Acceptance Criteria

- `docs/art/visual-direction.md` exists and is the source of truth for Phase 5A-5G visual work.
- Later tickets can cite locked/provisional decisions from the document.
- No implementation files are changed.

## Implementation Notes

- Added `docs/art/visual-direction.md` with locked/provisional/deferred decisions, readable-size rules, concept intake rules, contrast rules, motion readability rules, and asset direction.
- Incorporated fallback Codex visual critique because Claude was unavailable due usage limit.
