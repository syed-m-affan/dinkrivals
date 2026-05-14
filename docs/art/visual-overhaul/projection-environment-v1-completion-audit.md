# Projection Environment V1 Completion Audit

Date: 2026-05-14

## Objective

Finish the current visual-overhaul environment pass by creating court and
environment assets that:

- Match the active game perspective/projection.
- Use the concept screenshot and concept sheet as visual inspiration.
- Sit stylistically with the accepted player and opponent sprites.
- Preserve readable gameplay boundaries, kitchen zones, net, ball, VFX,
  players, controls, and UI states.
- Provide enough QA evidence to close the automated parts of VO3 honestly.

## Prompt-To-Artifact Checklist

| Requirement | Evidence | Status |
| --- | --- | --- |
| New court/environment art exists | `dink_rivals/assets/images/environment/classic/projection_environment_v1.png` | Covered |
| Asset matches projection dimensions | `docs/art/visual-overhaul/projection-environment-v1-manifest.json` records `979x1606` and the same image-space control points used by `CourtProjection` | Covered |
| Asset can be regenerated | `dink_rivals/tool/generate_projection_environment.py` | Covered |
| Runtime uses new asset in-game | `ClassicEnvironmentComponent` loads `EnvironmentLayout.projectionEnvironmentAsset` | Covered |
| Out-of-match screens use same current environment | `ParkBackdrop` uses `EnvironmentLayout.projectionEnvironmentAsset` | Covered |
| Concept screenshot/sheet used as inspiration | Manifest lists `docs/art/concepts/concept-screenshot.png` and `docs/art/concepts/concept-sheet.png`; QA report documents blue court, green apron, dark fence/signage, benches, planters, lamps, chunky arcade pixel styling | Covered |
| Existing player/opponent sprite style considered | Manifest lists accepted player/opponent runtime contact sheets | Covered |
| Gameplay lines remain projection-locked | `CourtComponent` draws procedural outer boundary, kitchen/service lines, center service lines, and net center mark above the bitmap | Covered |
| Debug kitchen zones are highlighted | `CourtComponent` renders kitchen highlight in free-rally debug mode; `dink.png` and `debug-rally-5min.png` show the highlight | Covered |
| Net remains readable over environment | `NetComponent` uses current palette; game/debug captures show net, ball, players, and court lines together | Covered |
| Shot chip layout does not clip | `TouchControlsComponent` layout fix and regression test in `touch_input_controller_test.dart`; screenshots show `DINK`, `DRIVE`, `LOB/SMASH` inside the canvas | Covered |
| Named shot evidence exists | `dink.png`, `drive.png`, `lob.png`, `smash.png` in `docs/art/visual-overhaul/evidence/projection-environment-v1/` | Covered |
| Core screen evidence exists | `menu.png`, `settings.png`, `roster.png`, `game.png`, `serve.png`, `pause.png`, `point.png`, `point-feedback.png` | Covered |
| End-match evidence exists | `end-match-widget.png` and seeded live-app `end-match-live.png` | Covered, with limitation |
| Five-minute gameplay smoke evidence exists | `debug-rally-5min.png`; emulator PID remained stable through 5:00 on `emulator-5554` | Covered on emulator |
| Automated verification passes | `flutter analyze`, `flutter test` (`206` tests), normal `flutter build apk --debug`, normal emulator install | Covered |
| QA launch hooks are guarded | `DINK_RIVALS_INITIAL_ROUTE`, `DINK_RIVALS_QA_END_MATCH`, and `DINK_RIVALS_QA_END_MATCH_WINNER` are build-time Dart defines; normal no-define build was rebuilt and reinstalled after QA captures | Covered |
| Physical Pixel validation | `flutter devices` shows only `emulator-5554`, Windows, Chrome, and Edge | Not covered |
| Physical and human signoff checklist | `docs/art/visual-overhaul/projection-environment-v1-signoff-checklist.md` | Ready to run |
| Physical capture helper | `tools/capture_projection_environment_v1_evidence.ps1` writes capture notes, captures automatable physical states, and restores a normal no-define APK | Ready to run |
| Human art-direction signoff | Requires subjective review against concept screenshot/sheet | Not covered |
| Organic full-match end screen | Seeded live app evidence exists; a naturally reached full-match end screen was not captured | Not covered if required |

## Audit Outcome

The asset creation, runtime integration, emulator evidence, and automated
verification parts of the objective are covered. The remaining uncovered gates
are not asset-generation or code tasks in the current environment:

- No physical Pixel device is connected for physical-device screenshots.
- Human visual signoff against the concept screenshot/sheet is external.
- If final QA requires a naturally completed match rather than seeded live-app
  end-match evidence, that organic end screen capture is still separate.

The remaining gates are prepared in
`docs/art/visual-overhaul/projection-environment-v1-signoff-checklist.md` for a
reviewer with a physical Pixel device.

Because those gates remain open, VO3 final closeout should stay in `review`
instead of `done`.
