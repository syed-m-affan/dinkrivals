---
id: P5A-001
phase: 5A
status: todo
priority: high
parallel_group: A
depends_on: [P5-007]
blocks: [P5A-002, P5A-003, P5B-001, P5C-001, P5D-001, P5E-001, P5F-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5A-001 - Current Screenshot and Concept Gap Inventory

## Goal

Capture the current post-Phase-5 visual baseline and compare it against the approved concept references so later visual tickets have a concrete gap list.

## Build Spec Coverage

Phase 5A - Concept Frame and Art Direction Lock:

- Screenshot comparison between current Phase 5 gameplay and `docs/art/concept-screenshot.png`.
- Visual gap note under `docs/art/` or `PHASE_NOTES.md`.

## Suggested File Ownership

- `docs/art/phase-5-current-serve.png` (new)
- `docs/art/phase-5-current-rally.png` (new)
- `docs/art/phase-5-current-feedback.png` (new)
- `docs/art/visual-gap-inventory.md` (new)
- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`

Avoid editing gameplay, rendering code, assets, or app screens in this ticket unless a one-line test helper is required to capture stable screenshots.

## Requirements

- Capture current Phase 5 screenshots on Android for serve, rally, and feedback/point states where practical.
- If a screenshot cannot be captured from tooling, document the exact blocker and use the latest available local screenshot as a temporary reference.
- Create `docs/art/visual-gap-inventory.md` comparing current visuals to:
  - `docs/art/concept-screenshot.png`
  - `docs/art/concept-sheet.png`
  - any latest Phase 5 screenshot captured in this ticket.
- Categorize gaps by environment, court material, net/shadows, characters, VFX, HUD/menus, readability, and performance risk.
- Keep the gap list descriptive, not prescriptive: do not silently expand scope into implementation fixes.

## Non-Goals

- No new art assets beyond screenshots.
- No implementation changes to game visuals.
- No gameplay, physics, AI, scoring, ads, audio, haptics, or control changes.

## Verification

Run from `dink_rivals/` only if code changes are made:

```bash
flutter analyze
flutter test
```

Manual/asset verification:

- Confirm every referenced screenshot path exists or is explicitly marked as unavailable with a reason.
- Confirm `visual-gap-inventory.md` links to the concept files and current baseline files.

## Acceptance Criteria

- Current visual baseline is captured or blocker-documented.
- Gap inventory exists and is specific enough to feed P5A-002 and implementation tickets.
- No gameplay behavior changes.

