---
id: VO2-007
phase: visual-overhaul-v2
status: done
priority: high
parallel_group: screens
depends_on: [VO2-001, VO2-003, VO2-004, VO2-006]
blocks: [VO2-008]
owner: Runtime Integration Agent + Asset Generation Agent + Asset Normalization Agent
last_updated: 2026-05-11
---

# VO2-007 - Out-of-Match Screen Cohesion

## Goal

Carry the v2 arcade language into menu, roster, settings, pause, and end-match screens without rebuilding them in Flame.

## Owned Files

- `dink_rivals/lib/widgets/arcade_button.dart`
- `dink_rivals/lib/widgets/arcade_panel.dart`
- `dink_rivals/lib/screens/main_menu_screen.dart`
- `dink_rivals/lib/screens/roster_screen.dart`
- `dink_rivals/lib/screens/end_match_screen.dart`
- `dink_rivals/assets/images/ui/portrait_*.png`
- `dink_rivals/assets/images/ui/court_cards/classic_court_card.png`
- New menu hero background asset
- Contact sheets under `docs/art/visual-overhaul/contact-sheets/vo2-*`
- Evidence under `docs/art/visual-overhaul/evidence/vo2-screens-*.png`

## Prompt Packet

- `docs/art/visual-overhaul/prompts/vo2-portraits.md`
- `docs/art/visual-overhaul/prompts/vo2-environment-layers.md`
- Both inherit from `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`.

## Tasks

- Re-token `ArcadeButton` and `ArcadePanel` to the v2 palette.
- Add chunkier 3-px outer border and 2-px inner highlight to panels/buttons where appropriate.
- Regenerate the main menu hero background using the same prompt family as v2 environment layers.
- Preserve room for menu logo and text; avoid density that hurts UI readability.
- Regenerate `ui/portrait_*.png` for four roster characters.
- Player and opponent portraits must visibly resemble the new 48x72 gameplay sprite identities.
- Veteran and Showman portraits get a style-pass-only refresh.
- Update end-match result plaque to use the same plaque chrome as the in-game feedback plaque.
- Regenerate `assets/images/ui/court_cards/classic_court_card.png` to match the new layered environment.

## Acceptance Criteria

- Menu -> roster -> match -> pause -> end-match reads as one coherent visual world.
- Roster portraits look like the same characters as gameplay sprites.
- All regenerated assets pass the `vo2-shared-style-rules.md` gate.
- No text overlap or safe-area violations on Pixel.
- `flutter analyze` clean and `flutter test` green.

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

Capture menu, roster, settings, pause, end-match, and court-card evidence under `docs/art/visual-overhaul/evidence/vo2-screens-*`.

## Risks

- Portraits can drift away from gameplay sprites. Use the same seed/prompt family and validate side by side.
- Heavier chrome can crowd mobile screens. Verify on Pixel-class dimensions and safe areas.
