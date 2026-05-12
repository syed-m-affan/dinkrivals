---
id: P5D-003
phase: 5D
status: done
priority: medium
parallel_group: C
depends_on: [P5D-001, P5D-002]
blocks: [P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5D-003 - Matching Roster Portraits and Character Visual QA

## Goal

Update roster portraits to match the polished in-game character designs and verify character readability.

## Build Spec Coverage

Phase 5D - Character Personality and Animation Polish:

- Portraits match gameplay sprites.
- Characters are recognizable in both roster and gameplay views.

## Suggested File Ownership

- `dink_rivals/assets/images/ui/portrait_*.png`
- `dink_rivals/lib/screens/roster_screen.dart`
- `dink_rivals/test/roster_screen_test.dart`
- `docs/art/phase-5/phase-5d-character-check.png` (new if captured)
- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`

Do not alter gameplay animation behavior in this ticket unless fixing a mismatch introduced by P5D-002.

## Requirements

- Regenerate or update four portrait assets to match the approved gameplay sprite designs.
- Preserve roster layout and image keys expected by tests.
- Add or update tests confirming the four portraits render.
- Record any remaining character readability concerns in `PHASE_NOTES.md`.

## Non-Goals

- No new roster characters.
- No tournament/unlock systems.
- No character stats or gameplay differences.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Roster portraits visually match gameplay character designs.
- All four portraits render.
- Character readability issues are documented or resolved.

## Implementation Notes

- Regenerated the existing four roster portrait PNG paths as original hard-edge low-detail pixel bust portraits using the character palette tokens.
- Added `docs/art/phase-5/phase-5d-character-check.png` as a quick portrait contact sheet for visual review.
- Preserved roster screen layout, image paths, and existing roster tests.
- Claude review found no blockers. Remaining readability notes: Rally Queen reads more as yellow hair on pink than a distinct headband at portrait scale; Veteran's mint accent is subtle against the gray kit.

## Verification Result

Passed from `dink_rivals/` on 2026-05-11:

```bash
flutter analyze
flutter test
flutter build apk --debug
```
