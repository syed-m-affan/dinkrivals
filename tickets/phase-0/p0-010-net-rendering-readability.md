---
id: P0-010
phase: 0
status: in_progress
priority: medium
parallel_group: depth-cues
depends_on: []
blocks: [P0-008]
owner: claude
last_updated: 2026-05-11
---

# P0-010 - Net Reads As Piano Keys

## Problem

After P0-007 the raised net renders as 7 evenly-spaced vertical struts between a top cord and a ground cord, with thick post lines at each end. The result looks like piano keys / a barcode rather than a pickleball net. Reference: `docs/art/phase-0/p0-006-p0-007-perspective-screenshot.png` — the net is the most confusing element in the scene.

## Fix

Replace the strut-based mesh with a single translucent dark "mesh fill" polygon between top cord and ground cord, plus a clean white top cord and dark posts. Skip individual vertical struts — the fill conveys mesh density at gray-box quality.

## Suggested File Ownership

- `dink_rivals/lib/game/components/net_component.dart`.

## Acceptance Criteria

- Net reads as a single mesh element with visible height.
- Posts and top cord remain visible.
- No piano-key / barcode visual.
- `flutter analyze` and `flutter test` pass.
