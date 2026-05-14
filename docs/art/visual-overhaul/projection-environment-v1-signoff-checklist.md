# Projection Environment V1 Signoff Checklist

Date: 2026-05-14

Use this checklist to close the remaining physical-device and human visual
signoff gates for `projection_environment_v1.png`.

## Build

From `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter install -d <PHYSICAL_PIXEL_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

Record the device ID, Android version, and commit hash in the QA notes.

For repeatable screenshot capture of the automatable states, use:

```powershell
.\tools\capture_projection_environment_v1_evidence.ps1 `
  -DeviceId <PHYSICAL_PIXEL_ID> `
  -OutputDir docs/art/visual-overhaul/evidence/projection-environment-v1-physical `
  -SmokeSeconds 300
```

The script builds route-specific debug APKs for settings, roster, debug rally,
shot states, and seeded end-match evidence, then rebuilds/reinstalls the normal
no-define debug APK at the end and captures `normal-menu-after-qa.png`. It also
writes `capture-notes.txt` with the device, Android version, commit hash, and
smoke duration. Manual point or organic full-match captures are still separate
if required by closeout.

## Physical Pixel Evidence

Capture into:

`docs/art/visual-overhaul/evidence/projection-environment-v1-physical/`

Required normal-build screenshots:

- `menu.png`
- `serve.png`
- `pause.png`
- `point.png`

The helper captures `menu.png`, `serve.png`, and `pause.png`. Capture
`point.png` manually during play unless the organic full-match/end-state
requirement is explicitly waived.

Required QA-route screenshots:

- `settings.png` from `--dart-define=DINK_RIVALS_INITIAL_ROUTE=/settings`
- `roster.png` from `--dart-define=DINK_RIVALS_INITIAL_ROUTE=/roster`
- `debug-rally.png` from
  `--dart-define=DINK_RIVALS_INITIAL_ROUTE=/debug-rally`
- `dink.png`, `drive.png`, `lob.png`, and `smash.png` from debug rally
- `end-match-live.png` from
  `--dart-define=DINK_RIVALS_INITIAL_ROUTE=/end-match`
  `--dart-define=DINK_RIVALS_QA_END_MATCH=true`

The helper captures these QA-route screenshots automatically.

After QA-route captures, reinstall the normal no-define debug APK and confirm
the app launches to the menu. If using the script, confirm
`normal-menu-after-qa.png` was captured.

## Five-Minute Smoke

On the physical device:

- Start a normal quick match or debug rally.
- Keep the app foregrounded for five minutes.
- Confirm no crash, relaunch, freeze, severe input lag, or visible asset
  loading failure occurs.
- Capture a final screenshot as `smoke-5min.png`.

## Human Visual Review

Compare the physical screenshots against:

- `docs/art/concepts/concept-screenshot.png`
- `docs/art/concepts/concept-sheet.png`
- `docs/art/visual-overhaul/contact-sheets/vo3-player-skill-runtime-sheets.png`
- `docs/art/visual-overhaul/contact-sheets/vo3-opponent-skill-runtime-sheets.png`

Sign off only if:

- The court reads as a 3/4 projected court, not a flat rectangle.
- The blue court, green apron, fence/signage band, benches, planters, lamps, and
  props feel like one coherent arcade pickleball venue.
- Player and opponent sprites look stylistically compatible with the court and
  environment.
- Boundaries, kitchen zones, service lines, net, ball, shadows, and VFX remain
  readable during rally and shot states.
- HUD, shot chips, pause, menu, settings, roster, and end-match surfaces do not
  hide important play-space edges.
- No prior rejected painted-court, chain-link signage, or old character-model
  artifacts are visible.

## Closeout Rule

Do not mark VO3 final closeout `done` until:

- Physical Pixel evidence is committed.
- Human visual signoff is recorded with the reviewer name/date.
- Any required organic full-match end screen capture is either archived or
  explicitly waived in the closeout note.
