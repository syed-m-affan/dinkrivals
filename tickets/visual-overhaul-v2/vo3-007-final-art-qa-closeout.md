---
id: VO3-007
phase: visual-overhaul-v3
status: review
priority: critical
parallel_group: final
depends_on: [VO3-001, VO3-002, VO3-003, VO3-004, VO3-005, VO3-006]
owner: Visual QA Agent + Closeout Agent
last_updated: 2026-05-14
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

2026-05-14 projection-environment update:

- Fresh court/environment graphics are active via
  `dink_rivals/assets/images/environment/classic/projection_environment_v1.png`.
- The asset was generated from `dink_rivals/tool/generate_projection_environment.py`
  using the same 979x1606 control points as `CourtProjection`.
- `ClassicEnvironmentComponent` renders that asset with the `CourtLayoutSystem`
  cover-fit transform; `CourtComponent` keeps gameplay boundaries procedural;
  `NetComponent` now uses the current palette.
- `ParkBackdrop` now uses the same projection environment asset for menu,
  settings, roster, and end-match widget surfaces instead of the retired
  `park_background_overhaul.png`.
- Emulator evidence exists under
  `docs/art/visual-overhaul/evidence/projection-environment-v1/` for menu,
  settings, roster, game/serve, pause, debug rally, debug dink/drive/lob/smash
  gesture or passive-contact states, point aftermath, and shot feedback.
- End-match widget evidence exists at
  `docs/art/visual-overhaul/evidence/projection-environment-v1/end-match-widget.png`
  from the refreshed Phase 5G golden path; it was not reached through a live
  emulator full-match flow.
- End-match live-app evidence exists at
  `docs/art/visual-overhaul/evidence/projection-environment-v1/end-match-live.png`
  from a QA build launched with `DINK_RIVALS_INITIAL_ROUTE=/end-match` and
  `DINK_RIVALS_QA_END_MATCH=true`; this proves the running app renders the
  end-match surface over the projection environment, but it is not an organic
  full-match playthrough.
- The bottom shot-chip layout was corrected so `LOB/SMASH` stays inside the
  portrait canvas.
- `flutter analyze`, focused projection/backdrop/control tests,
  focused QA launch tests, `flutter test --update-goldens
  test\phase5g_visual_golden_test.dart`, full `flutter test` (`206` tests),
  `flutter build apk --debug`, QA end-match evidence build, and emulator
  install passed. A separate QA debug-rally launch build captured the current
  projection environment in a DINK passive-contact state.
- Final closeout remains `review` because physical Pixel evidence,
  human visual signoff, and any required organic full-match end screen capture
  are not complete. The debug dink/drive/lob/smash captures are evidence of
  gesture/animation rendering, not final human shot-acceptance signoff.

2026-05-13 current-state update:

- Player/opponent sprites and gameplay animations are done for this visual pass
  through the documented sprite-generation workflow.
- Ball and VFX are mostly done for now.
- The painted court/environment/signage closeout path is superseded. Runtime now
  uses a flat gray background, projected gameplay boundaries, and a procedural
  graybox net to finalize perspective and boundary readability before new
  environment art is created.
- Final art closeout should not be attempted until projection/perspective,
  gameplay-boundary visuals, and the fresh environment rebuild are complete.
- Current source of truth:
  `docs/art/visual-overhaul/current-visual-overhaul-state.md`.

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
