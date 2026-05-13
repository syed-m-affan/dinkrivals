# Visual Overhaul v2 Recovery Comparison

Last updated: 2026-05-12

## Current Verdict

VO2 is still in review, not final closeout. The earlier `vo2-final-*` evidence set included invalid duplicate captures and should not be used as proof of visual completion. The current recovery pass fixes several concrete blockers, but concept-quality signage replacement, full shot-state evidence, valid physical Pixel screenshots, and human art signoff remain open.

## Evidence

- Spec: `docs/specs/visual-overhaul-v2-spec.md`
- Concept target: `docs/art/concepts/concept-screenshot.png`
- Decomp and style rules: `docs/art/visual-overhaul/visual-overhaul-v2-decomp.md`
- Shared style packet: `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`
- Alpha-cleaned player contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-player-normalized-runtime-sheets.png`
- Alpha-cleaned opponent contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-opponent-normalized-runtime-sheets.png`
- Blue/red competitor contact sheets: `docs/art/visual-overhaul/contact-sheets/vo2-player-competitor-runtime-sheets.png`, `docs/art/visual-overhaul/contact-sheets/vo2-opponent-competitor-runtime-sheets.png`
- Competitor sprite audit: `docs/art/visual-overhaul/evidence/vo2-competitor-sprite-audit.txt`
- Sprite alpha diagnostics: `docs/art/visual-overhaul/evidence/vo2-sprite-alpha-diagnostic.png`, `docs/art/visual-overhaul/evidence/vo2-sprite-alpha-diagnostic-after.png`
- Latest emulator menu: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/menu_ui_latest.png`
- Latest emulator serve: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/serve_ui_latest.png`
- Competitor sprite emulator serve: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/competitor_sprite_serve.png`
- Latest emulator rally: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/rally_ui_latest.png`
- Latest emulator signage check: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/serve_after_signage.png`
- Latest emulator matrix additions: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/menu_matrix.png`, `roster_matrix.png`, `settings_matrix.png`, `serve_matrix.png`, `pause_matrix.png`
- Roster portrait identity fix: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/roster_portrait_fix.png`
- Shot-state capture attempts: `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/dink_matrix.png`, `drive_matrix.png`, `lob_smash_matrix.png`
- Recovery QA report: `docs/art/visual-overhaul/evidence/vo2-recovery-art-qa-report.md`
- Failed-art QA report: `docs/art/visual-overhaul/evidence/vo2-art-qa-report.md`

## Implemented Changes

| Area | Result | Evidence |
| --- | --- | --- |
| Tickets and parallel plan | In review | `tickets/visual-overhaul-v2/vo2-000..vo2-008`, `VO3-003..VO3-007`, plus `tickets/status.md` dashboard rows. |
| Style rules and prompts | Complete | VO2 shared style rules plus character, environment, signage, HUD, ball-trail, and portrait packets under `docs/art/visual-overhaul/prompts/`. |
| Environment split | Complete | `layer_sky_trees.png`, `layer_fence_signage.png`, `layer_court_base.png`, and `layer_net.png`; `ClassicEnvironmentComponent` draws layers; `NetComponent` draws the dedicated net layer. |
| Projection preservation | Complete | `CourtProjection` and `CourtLayoutSystem` control points were not changed; tests still cover net and trapezoid alignment. |
| Character footprint | Complete | Player/opponent runtime constants use 33x49.5 court units and 48px frame slicing; sprite sheets are 48x72 per frame. |
| Player/opponent sprites | Improved, review | The rejected placeholder pass was replaced by the stronger athlete style, then retuned to match the concept competitor identities: blue player variant and red rival opponent. Runtime sheets are 48x72 per frame; run strips are 8 frames; deterministic alpha cleanup removed partial-alpha pixels and enclosed transparent holes. |
| Hitbox and paddle tuning | Complete | Paddle draw size is 14x25 court units; contact radii are lightly increased and documented in `Tuning`. |
| Ball scaling | Complete | Ball radius constants are centralized as `Tuning.ballRadiusBase` and `Tuning.ballRadiusAltitudeBoost`; tests cover the new formula. |
| HUD refit | Complete | Score remains a compact top-left two-panel block; rally/last-shot moved to `RallyStripComponent`; feedback remains a two-line top-center plaque; debug HUD gates behind `DebugFlags.showHud`. |
| Controls | Complete | Visual controls are tightened, `AIM` label removed, serve button stays bottom-center, and touch targets remain larger than visual radii. |
| Out-of-match cohesion | Complete for automated scope | Shared `ArcadeButton`/`ArcadePanel` chrome now uses 3px outer + 2px inner highlight; roster portraits and classic court card refreshed; goldens updated. |
| Signage | Review | Rejected chain-link text boards were removed from the runtime fence layer, projected sign/fence props were removed from the court plane, and compact replacement boards were composited onto existing background sign-board faces. Human art QA remains open. |
| Menu/UI cohesion | Improved, review | Menu no longer uses the gameplay court background. Shared panels/buttons and in-game UI colors were retuned toward the painted park palette. |
| Roster portraits | Improved, review | Rookie portrait is rebuilt from the current blue player sprite; Rally Queen uses the female concept-sheet identity. Human art QA remains open. |
| Emulator QA | In review | Latest debug APK built, installed on `emulator-5554`, launched, and captured menu/serve/rally evidence. The competitor sprite serve capture confirms the blue player and red opponent render in the park environment with runtime shadows. |
| Physical Pixel QA | Blocked | Pixel 10 Pro XL was visible and the APK installed, but captures showed the lock screen or black frames after unlock attempts, so the screenshots are invalid for closeout. |

## Verification

Commands run from `dink_rivals/`:

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

Results:

- `flutter analyze`: no issues found.
- `flutter test`: 177/177 passed after updating the affected screen goldens.
- `test/phase5g_visual_golden_test.dart`: passed after intentional golden refresh for the changed character/portrait pixels.
- `flutter build apk --debug`: passed.
- Emulator install and capture: passed on `emulator-5554`.
- Pixel install: passed on `58011FDCQ00992`; visual capture remained blocked by lock/black-screen output and is not accepted evidence.

## Residual Validation Tickets

- `tickets/visual-overhaul-v2/vo3-001-physical-pixel-visual-validation.md`
- `tickets/visual-overhaul-v2/vo3-002-concept-quality-art-signoff.md`
- `tickets/visual-overhaul-v2/vo3-005-signage-replacement.md`
- `tickets/visual-overhaul-v2/vo3-006-net-visibility-correction.md`
- `tickets/visual-overhaul-v2/vo3-007-final-art-qa-closeout.md`
