---
id: VO2-003
phase: visual-overhaul-v2
status: review
priority: high
parallel_group: player-art
depends_on: [VO2-002]
blocks: [VO2-005, VO2-007, VO2-008]
owner: Asset Generation Agent -> Asset Normalization Agent -> Runtime Integration Agent
last_updated: 2026-05-12
---

# VO2-003 - Player Sprite Generation and Integration

## Goal

Replace the 11 player sheets with concept-quality 48x72 pixel-art frames that read as a clearly drawn athlete at Pixel gameplay distance.

## Owned Files

- `dink_rivals/assets/images/sprites/player_idle.png`
- `dink_rivals/assets/images/sprites/player_ready.png`
- `dink_rivals/assets/images/sprites/player_run.png`
- `dink_rivals/assets/images/sprites/player_dink.png`
- `dink_rivals/assets/images/sprites/player_drive.png`
- `dink_rivals/assets/images/sprites/player_lob.png`
- `dink_rivals/assets/images/sprites/player_smash.png`
- `dink_rivals/assets/images/sprites/player_miss.png`
- `dink_rivals/assets/images/sprites/player_hitConfirm.png`
- `dink_rivals/assets/images/sprites/player_pointWin.png`
- `dink_rivals/assets/images/sprites/player_pointLoss.png`
- Sprite manifest or README in the owning asset folder, if present.
- Contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-player-ingame.png`
- Evidence under `docs/art/visual-overhaul/evidence/vo2-player-*.png`

## Prompt Packet

- `docs/art/visual-overhaul/prompts/vo2-character-player.md`
- Inherits from `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`.

## Generation Requirements

- Identity: blue cap, white shirt with red trim, navy shorts, visible paddle in right hand.
- Perspective: 3/4 mobile portrait gameplay angle.
- Style: polished pixel-art arcade sports, crisp 1-px outlines, upper-left light, grounded lower-right shadows.
- Frame counts: idle 2, ready 3, run 6, dink 2, drive 3, lob 3, smash 3, miss 2, hitConfirm 2, pointWin 3, pointLoss 2.

## Normalization Requirements

- Each frame is exactly 48x72 px.
- Transparent background with no halo or fringe.
- Feet anchored at y=70 with 2-px foot padding.
- Pivot stable frame-to-frame; no horizontal foot drift outside `run`.
- Replace v1 player files using the existing runtime names.
- No code changes should be required if VO2-002 landed correctly.

## Acceptance Criteria

- All 11 player sheets are 48x72 per frame.
- All sheets pass the `vo2-shared-style-rules.md` gate.
- Player reads as a clearly drawn athlete with cap and paddle visible at gameplay distance.
- Animation transitions idle -> run -> swing and swing -> hitConfirm play without frame snap.
- Hitbox alignment remains unchanged from VO2-002.
- `vo2-player-ingame.png` contact sheet exists.

## Closeout Status - 2026-05-12

Runtime integration and automated verification were completed, but art QA failed the player character result. The current player art does not satisfy the concept-quality athlete/readability bar, and run-cycle coverage still needs explicit repair. This ticket remains in `review` until the focused VO3 character follow-ups land and are validated in gameplay screenshots.

Residual tickets:

- `VO3-003` replaces failed character art with accepted concept-quality player/opponent sheets.
- `VO3-004` completes and validates readable run cycles for both characters.

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

- Generated state sheets can drift identity or pivot. Normalize before integration and reject style/pivot failures.
- Cap, face, and paddle can disappear at runtime scale. Verify on emulator and Pixel-distance screenshots, not only source frames.
