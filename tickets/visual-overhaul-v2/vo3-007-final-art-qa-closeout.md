---
id: VO3-007
phase: visual-overhaul-v3
status: review
priority: critical
parallel_group: final
depends_on: [VO3-001, VO3-002, VO3-003, VO3-004, VO3-005, VO3-006]
owner: Visual QA Agent + Closeout Agent
last_updated: 2026-05-12
---

# VO3-007 - Final Art QA and Closeout

## Goal

Rerun final QA after the focused art fixes land and close VO2/VO3 only if the visual acceptance gates pass honestly.

## Scope

- Rebuild and install the latest debug APK.
- Capture final emulator evidence.
- Capture final physical Pixel evidence when hardware is visible.
- Run a 5-minute gameplay smoke.
- Compare final screenshots against `docs/art/concepts/concept-screenshot.png` and `docs/art/concepts/concept-sheet.png`.
- Update ticket statuses without claiming completion for any failed gate.

## Acceptance Criteria

- `flutter analyze`, `flutter test`, and `flutter build apk --debug` pass.
- Serve, rally, dink, drive, lob, smash, point, pause, roster, and end-match evidence is archived.
- Character replacement, run cycles, signage, and net visibility are accepted by art QA.
- Physical Pixel validation is complete, or the lack of hardware is explicitly recorded without marking physical QA complete.
- `VO2-008` and this ticket are marked `done` only after all required evidence and signoff exists.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Then perform emulator and physical-device visual QA according to `VO2-008`.

## Recovery QA Notes

2026-05-12 recovery QA was rerun and documented in `docs/art/visual-overhaul/evidence/vo2-recovery-art-qa-report.md`.

Result: review, not done.

- Automated verification is passing for the current recovery build.
- Fresh emulator menu/serve/rally evidence exists under `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/`.
- Additional emulator matrix captures exist for menu, roster, settings, serve, and pause.
- Dink/drive/lob-smash emulator capture attempts exist, but they do not yet prove complete shot animation and feedback coverage.
- Player/opponent runtime sprite sheets have no partial-alpha pixels or enclosed transparent holes.
- Player/opponent run sheets now have 8 frames.
- Rejected chain-link text signs and projected court/fence sign props are removed from the runtime evidence.
- Compact replacement boards are present in the background layer and captured in `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/serve_after_signage.png`.
- Roster portrait identity fixes are captured in `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/roster_portrait_fix.png`.
- Menu no longer uses the gameplay court background.
- Pixel APK install succeeded, but physical screenshots captured the locked device or a black frame, so physical visual evidence remains invalid.
- Final signage human art QA remains open.
- Full shot/screen evidence matrix remains incomplete: accepted dink, drive, lob, smash, point, and end-match evidence is still missing from the latest matrix.
- Human concept-quality signoff remains open.
