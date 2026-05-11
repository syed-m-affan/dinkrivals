---
id: P5E-003
phase: 5E
status: todo
priority: medium
parallel_group: C
depends_on: [P5E-002]
blocks: [P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5E-003 - Ball Trails, Point Bursts, and Performance Check

## Goal

Add selective ball trails and point-ending juice, then verify that VFX remain readable and performant on Android.

## Build Spec Coverage

Phase 5E - Ball Trail, Contact VFX, and Rally Juice:

- Ball arc/trail for lobs and high returns.
- Point-win burst/banner support.
- Optional very subtle screen shake only for point-ending smashes.
- No sustained frame drops on Android.

## Suggested File Ownership

- `dink_rivals/lib/game/components/vfx/`
- `dink_rivals/lib/game/dink_rivals_game.dart`
- `dink_rivals/PHASE_NOTES.md`
- `docs/art/phase-5e-vfx-check.png` (new if captured)
- `tickets/status.md`

Do not make scoring, physics, or shot-classification changes.

## Requirements

- Add a short trail for lobs/high returns that does not obscure the ball.
- Add point-ending burst/banner support tied to existing point award timing.
- If screen shake is added, keep it disabled by default or extremely subtle and only for point-ending smashes.
- Record Android performance observations in `PHASE_NOTES.md`.
- Create follow-up tickets for performance/readability issues instead of bundling broad retuning.

## Non-Goals

- No new gameplay events.
- No persistent particle systems.
- No camera/projection changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Android smoke:

- Play rallies with dink, drive, lob, smash, bounce, and point events.
- Watch for sustained frame drops or ball occlusion.

## Acceptance Criteria

- Trails and point effects improve readability without hiding gameplay.
- Android performance remains acceptable.
- Any remaining issues are documented as follow-up tickets.

