---
id: VO2-004
phase: visual-overhaul-v2
status: review
priority: high
parallel_group: opponent-art
depends_on: [VO2-002]
blocks: [VO2-005, VO2-007, VO2-008]
owner: Asset Generation Agent -> Asset Normalization Agent -> Runtime Integration Agent
last_updated: 2026-05-12
---

# VO2-004 - Opponent Sprite Generation and Integration

## Goal

Create a distinct, concept-matched opponent with red identity and full 11-state 48x72 coverage.

## Owned Files

- `dink_rivals/assets/images/sprites/opponent_idle.png`
- `dink_rivals/assets/images/sprites/opponent_ready.png`
- `dink_rivals/assets/images/sprites/opponent_run.png`
- `dink_rivals/assets/images/sprites/opponent_dink.png`
- `dink_rivals/assets/images/sprites/opponent_drive.png`
- `dink_rivals/assets/images/sprites/opponent_lob.png`
- `dink_rivals/assets/images/sprites/opponent_smash.png`
- `dink_rivals/assets/images/sprites/opponent_miss.png`
- `dink_rivals/assets/images/sprites/opponent_hitConfirm.png`
- `dink_rivals/assets/images/sprites/opponent_pointWin.png`
- `dink_rivals/assets/images/sprites/opponent_pointLoss.png`
- Sprite manifest or README in the owning asset folder, if present.
- Contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-opponent-ingame.png`
- Evidence under `docs/art/visual-overhaul/evidence/vo2-opponent-*.png`

## Prompt Packet

- `docs/art/visual-overhaul/prompts/vo2-character-opponent.md`
- Inherits from `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`.

## Generation Requirements

- Identity: red cap and contrasting kit.
- Opponent silhouette must remain distinguishable from the player at gameplay scale through cap shape, kit color, and pose language.
- Perspective and style match VO2-003 exactly.
- Frame counts: idle 2, ready 3, run 6, dink 2, drive 3, lob 3, smash 3, miss 2, hitConfirm 2, pointWin 3, pointLoss 2.

## Normalization Requirements

- Each frame is exactly 48x72 px.
- Transparent background with no halo or fringe.
- Feet anchored at y=70 with 2-px foot padding.
- Pivot stable frame-to-frame; no horizontal foot drift outside `run`.
- Replace v1 opponent files using the existing runtime names.

## Acceptance Criteria

- Player and opponent are silhouette-distinct in a Pixel-distance screenshot.
- Opponent animates correctly through serve, rally, dink, drive, lob, smash, miss, point win, and point loss states.
- All 11 sheets pass the `vo2-shared-style-rules.md` gate.
- A 5-minute emulator rally smoke confirms `OpponentAISystem` behavior is unaffected.
- No analyze/test regressions.

## Closeout Status - 2026-05-12

Runtime integration and automated verification were completed, but art QA failed the opponent character result. The opponent still needs replacement art that is clearly distinct from the player at gameplay distance, and run-cycle coverage needs explicit validation. This ticket remains in `review` until the focused VO3 character follow-ups land and are validated in gameplay screenshots.

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

- Opponent can become too similar to player after depth scaling. Validate in actual rally screenshots.
- AI behavior must stay untouched; this ticket is visual-only apart from asset replacement.
