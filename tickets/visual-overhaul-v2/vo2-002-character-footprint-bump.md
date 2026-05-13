---
id: VO2-002
phase: visual-overhaul-v2
status: done
priority: critical
parallel_group: character-foundation
depends_on: [VO2-000]
blocks: [VO2-003, VO2-004, VO2-005, VO2-008]
owner: Runtime Integration Agent
last_updated: 2026-05-11
---

# VO2-002 - Character Footprint Bump

## Goal

Make runtime code ready for 48x72 source frames at the new logical size before final character art lands.

## Owned Files

- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/components/racket_component.dart`
- `dink_rivals/lib/game/config/tuning_constants.dart`
- Temporary placeholder sheets under `dink_rivals/assets/images/sprites/`
- Evidence under `docs/art/visual-overhaul/evidence/vo2-character-footprint-*.png`

## Tasks

- In `player_component.dart:47-49`, set `_spriteWidth = 33`, `_spriteHeight = 49.5`, and recompute `_spriteFootPadding = _spriteHeight * (2 / 72)`.
- In `player_component.dart:245`, change `_frameCountFor` divisor from `/32` to `/48`.
- Mirror the same edits in `opponent_component.dart:47-49` and `opponent_component.dart:246`.
- In `tuning_constants.dart`, review `racketHitRadius`, `cleanContactRadius`, `forgivenContactRadius`, `emergencyBodyContactRadius`, and `verticalHitRadius`.
- Scale hit/contact radii by roughly 1.0x to 1.15x, favoring player reach slightly rather than strict 1.5x visual scale.
- Document final hitbox values in a comment block.
- In `racket_component.dart:171-172`, bump paddle render size from 10x18 to 14x25 court-units.
- Author 22 clearly named placeholder 48x72 sprite sheets: 11 player states and 11 opponent states.
- Capture emulator evidence showing player/opponent placeholder silhouettes at the new logical size and racket endpoint contact alignment.

## Acceptance Criteria

- `flutter analyze` has zero warnings and `flutter test` is green.
- Player and opponent silhouettes are visibly larger on emulator.
- Feet do not float or sink at idle, ready, run, and swing states.
- Ball contact during a standard rally still triggers `hitConfirm` consistently.
- Racket sprite endpoint visually meets the ball at contact.
- Temporary placeholder assets are clearly named so VO2-003/VO2-004 can replace or delete them safely.

## Verification

Run from `dink_rivals/`:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter run -d emulator-5554
```

## Risks

- Larger sprites can make hitboxes feel misleading. Keep gameplay deterministic and only tune visual-contact radii inside the specified constants.
- Placeholder sheets are temporary; do not let them become final style references for VO2-003/VO2-004.
