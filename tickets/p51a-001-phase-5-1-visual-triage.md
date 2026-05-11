---
id: P51A-001
phase: 5.1A
status: done
priority: high
parallel_group: A
depends_on: [P5G-001]
blocks: [P51B-001, P51C-001, P51D-001, P51E-001, P51F-001, P51G-001, P51H-001]
owner: unassigned
last_updated: 2026-05-11
---

# P51A-001 - Phase 5.1 Visual Triage

## Goal

Lock the current Phase 5.1 visual baseline and create a precise concept-delta inventory against `docs/art/concept-screenshot.png`.

## Build Spec Coverage

Phase 5.1 - Concept Fidelity Correction Pass:

- Current-vs-concept delta inventory.
- Player artifact, environment stretching, court grounding, depth, HUD, and controls gap categories.
- Render-layer and acceptance-shot notes for the rest of Phase 5.1.

## Suggested File Ownership

- `docs/art/phase-5.1-delta-inventory.md`
- `docs/art/render-layer-map.md`
- `docs/art/visual-direction.md`
- `docs/art/phase-5-screenshot.png` or `docs/art/phase-5.1-screenshot.png`
- `tickets/status.md`

Do not make implementation changes in this ticket.

## Requirements

- Capture or preserve the latest valid Android gameplay screenshot as the Phase 5.1 baseline.
- Compare the baseline against `docs/art/concept-screenshot.png`.
- Number each visible delta and group them by:
  - black player/opponent artifacts
  - player model mismatch before/after serve
  - stretched trees/fence/props
  - grass/background wonkiness
  - floating court / weak ground integration
  - environment richness/depth
  - court/net/kitchen material polish
  - HUD/control proportion issues
- Map overlapping `P5H-*` tickets as keep, replace, or supersede.
- Define the required Phase 5.1 acceptance screenshot set: serve/waiting-to-serve, post-serve rally, point feedback, pause, and any menu/HUD shot needed for comparison.
- Update render-layer notes if apron, court-shadow, fence-base, foliage, and prop layers need explicit ordering.

## Non-Goals

- No code changes.
- No asset generation.
- No subjective signoff without concrete screenshot evidence.
- No gameplay, physics, AI, scoring, ad, or control changes.

## Verification

- Confirm all referenced screenshot files exist.
- Confirm every high-priority user issue has a numbered delta entry.

## Acceptance Criteria

- `docs/art/phase-5.1-delta-inventory.md` exists and is specific enough for implementation agents to work from.
- Phase 5.1 acceptance shots are named and documented.
- `P5H-*` overlap is recorded so future agents do not duplicate work.
- No implementation files are changed.

## Planning Notes

- Claude and a Codex subagent both recommended a foundation triage ticket before implementation so visual fixes can be judged against concrete deltas rather than vibes.
