---
id: P0-011
phase: 0
status: in_progress
priority: medium
parallel_group: depth-cues
depends_on: []
blocks: [P0-008]
owner: claude
last_updated: 2026-05-11
---

# P0-011 - Debug Overlay Overlaps Score

## Problem

`DebugOverlayComponent` renders a single-line strip at `Rect.fromLTWH(8, 8, 342, 22)`. On a typical phone (~412 logical px wide), this extends to x=350, which overlaps the centered score chip at the top of the screen. Reference: `docs/art/p0-006-p0-007-perspective-screenshot.png` — the "0 - 0" score sits behind "PHASE 0  FPS 118  ...".

## Fix

Move the debug overlay below the score chip (`y = 40`) so the score has the top row to itself. Keep the overlay compact (single line) so it still fits inside the top reserve area.

## Suggested File Ownership

- `dink_rivals/lib/game/components/debug_overlay_component.dart`.

## Acceptance Criteria

- Score is fully readable, not occluded by the debug overlay.
- Debug overlay remains on-screen above the court.
- `flutter analyze` and `flutter test` pass.
