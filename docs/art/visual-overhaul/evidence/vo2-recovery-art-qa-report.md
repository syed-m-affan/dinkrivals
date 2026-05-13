# VO2 Recovery Art QA Report

Date: 2026-05-12

## Verdict

VO2 recovery is improved but not complete. The latest pass resolves several concrete runtime and asset defects, but final closeout remains blocked by incomplete shot-state evidence, unapproved replacement signage, invalid physical Pixel screenshots, and human art-direction signoff.

Do not mark VO2, VO3, or the active goal complete from this report.

## Evidence Reviewed

- Concept target: `docs/art/concepts/concept-screenshot.png`
- Spec: `docs/specs/visual-overhaul-v2-spec.md`
- Comparison doc: `docs/art/visual-overhaul/visual-overhaul-v2-comparison.md`
- Runtime player contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-player-normalized-runtime-sheets.png`
- Runtime opponent contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-opponent-normalized-runtime-sheets.png`
- Competitor player contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-player-competitor-runtime-sheets.png`
- Competitor opponent contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-opponent-competitor-runtime-sheets.png`
- Competitor sprite audit: `docs/art/visual-overhaul/evidence/vo2-competitor-sprite-audit.txt`
- Competitor sprite cleanup audit JSON: `docs/art/visual-overhaul/evidence/vo2-competitor-sprite-audit.json`
- 64x64 chibi sprite manifest: `docs/art/visual-overhaul/sprite-overhaul-run/run-manifest.json`
- Sprite cleanup previews: `docs/art/visual-overhaul/sprite-overhaul-run/qa/previews/`
- Sprite cell-size decision: `docs/art/visual-overhaul/sprite-overhaul-run/sprite-cell-size-decision.md`
- Sprite alpha diagnostics: `docs/art/visual-overhaul/evidence/vo2-sprite-alpha-diagnostic-after.png`
- Latest emulator menu: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/menu_ui_latest.png`
- Latest emulator serve: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/serve_ui_latest.png`
- Competitor sprite emulator serve: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/competitor_sprite_serve.png`
- Latest emulator rally: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/rally_ui_latest.png`
- Latest emulator signage check: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/serve_after_signage.png`
- Latest emulator evidence matrix additions: `menu_matrix.png`, `roster_matrix.png`, `settings_matrix.png`, `serve_matrix.png`, `pause_matrix.png`
- Roster portrait identity fix: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/roster_portrait_fix.png`
- Shot-state capture attempts: `dink_matrix.png`, `drive_matrix.png`, `lob_smash_matrix.png`
- Pixel install attempt: `docs/art/visual-overhaul/evidence/vo2-recovery-pixel/`

## Requirement Checklist

| Requirement | Status | Notes |
| --- | --- | --- |
| Character sprites no longer read as bland placeholders | Review | The rejected first 64x64 chibi pass has been replaced with a concept-guided redraw: the near player now reads as a blue-cap/white-shirt back-view competitor, the opponent reads as the red-shirt/white-cap front-view rival, and the paddle treatment is dark instead of the previous yellow-ring placeholder. New runtime contact sheets are archived in `vo2-player-competitor-runtime-sheets.png` and `vo2-opponent-competitor-runtime-sheets.png`. Final human concept signoff is still required. |
| Roster portraits match character identities | Review | Rookie portrait now uses the current blue player sprite face/body, and Rally Queen now uses the female pink-visor identity from the concept sheet. Emulator evidence is archived in `roster_portrait_fix.png`. |
| Transparent sprite artifacts removed | Pass | Runtime player/opponent sheets are native 64x64 chibi cells with binary alpha, no edge-contact clipping, and no audit warnings. Latest evidence is archived in `vo2-competitor-sprite-audit.json` and `sprite-overhaul-run/run-manifest.json`. |
| Running animations have more complete frame coverage | Pass | Player and opponent run strips now have 12 runtime frames (`768x64`), and component frame-count tests cover them. Runtime playback remains capped at 8 FPS so the cycle does not flash through frames too quickly. |
| Ball and opponent remain readable near/behind the net | Review | Net alpha/crop changes improve serve and rally evidence. Dink, lob, smash, and point-state captures are still missing. |
| Bad fence/court signage removed | Pass | Rejected `DINK RIVALS` and `PICKLEBALL LEGENDS` chain-link boards are no longer present in latest emulator serve/rally captures, and projected sign/fence props were removed from the court plane. |
| Concept-quality replacement signage | Review | Compact `DINK RIVALS` and `PARK COURTS` boards are now composited onto existing background sign-board faces, not projected court props. Human art QA is still required. |
| Scoreboard, fault board, buttons, and menu match the painted environment style | Review | Shared UI chrome has been retuned toward the park palette; latest menu/serve/rally emulator captures look coherent enough for review. |
| Menu does not use the game background | Pass | `MainMenuScreen` uses `ParkBackdrop(showCourtImage: false)` and latest menu capture does not show the gameplay court. |
| Emulator evidence | Partial | Fresh menu, roster, settings, serve, rally, signage, and pause screenshots exist. Dink/drive/lob-smash capture attempts exist, but they do not prove full shot animation/feedback coverage. Point and end-match are still missing. |
| Physical Pixel evidence | Blocked | APK installed on Pixel 10 Pro XL, but screenshots captured the locked device / black screen after unlock attempts, so physical visual evidence is invalid. |
| Automated verification | Pass | Latest reported run: `flutter analyze`, `flutter test` 177/177, phase 5G golden recheck, sprite audit with 0 errors/0 warnings, `flutter build apk --debug`, emulator install, and emulator gameplay capture. |

## Pixel Attempt

The Pixel 10 Pro XL was visible to Flutter and the APK installed successfully. ADB launch and screenshot capture did not reach the game surface because the device remained locked or returned a black capture after unlock attempts. The files in `docs/art/visual-overhaul/evidence/vo2-recovery-pixel/` are retained as invalid capture evidence only; they are not acceptable closeout screenshots.

## Open Gates

- Human-review the compact replacement venue signs against the concept target; the failed large chain-link signs are gone, but the new board-mounted signs still need art signoff.
- Capture accepted shot-state evidence for dink, drive, lob, and smash, plus point and end-match.
- Capture valid physical Pixel screenshots and run the 5-minute Pixel smoke.
- Obtain human concept-quality signoff for sprites, UI, net visibility, and overall match-to-concept quality.

## Closeout Decision

VO3-007 should move to review, not done. VO2-008 remains review. The active goal remains open until the open gates above are handled or explicitly descoped by the user.
