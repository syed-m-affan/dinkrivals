---
id: P5H-007
phase: 5H
status: review
priority: low
parallel_group: F
depends_on: [P5D-002]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P5H-007 - Character Idle and Ready Micro-Animation

## Goal

Add subtle character personality through tiny idle/ready animation polish without changing movement, hitboxes, or shot timing.

## Background

P5G comparison notes still call out a character-personality gap versus the concept art.

## Requirements

- Add a subtle visual-only idle/ready bob or frame variation.
- Keep paddle/contact readability intact.
- Do not alter `PlayerState`, hitboxes, movement speed, swing timing, scoring, or AI.
- Add tests for pose selection if state precedence changes.

## Non-Goals

- No new character stats.
- No unlocks or progression.
- No gameplay timing changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Deferral Notes

- Deferred rather than implemented in the Phase 5.2 closeout because the current
  user feedback prioritizes correcting wonky animations over adding extra idle
  motion. Generated character sheets, frame-count handling, and movement-facing
  reflection were fixed in the visual overhaul pass; further micro-animation
  should wait for explicit visual review.
