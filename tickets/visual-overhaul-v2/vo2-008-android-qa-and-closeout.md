---
id: VO2-008
phase: visual-overhaul-v2
status: review
priority: critical
parallel_group: closeout
depends_on: [VO2-001, VO2-002, VO2-003, VO2-004, VO2-005, VO2-006, VO2-007]
blocks: []
owner: Performance QA Agent + Closeout Agent
last_updated: 2026-05-12
---

# VO2-008 - Android QA, Performance, and Closeout

## Goal

Verify v2 on emulator and physical Pixel hardware, document the result against the concept target, and file residual `vo3-` follow-up tickets.

## Owned Files

- `docs/art/visual-overhaul/evidence/vo2-final-*.png`
- `docs/art/visual-overhaul/visual-overhaul-v2-comparison.md`
- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`
- `tickets/visual-overhaul-v2/vo3-*.md` or a later follow-up folder if residual gaps are filed

## Tasks

- From `dink_rivals/`, run the full verification command chain.
- Install on emulator and physical Pixel.
- Capture final evidence set: menu, roster, settings, serve, dink, drive, lob, smash, point-win, pause, end-match.
- Store final captures under `docs/art/visual-overhaul/evidence/vo2-final-*`.
- Run frame-pace audit for serve sequence, full rally with shot VFX, point burst, and menu transition.
- Confirm no sustained drops below 55 fps on Pixel.
- Check APK size delta from v1 and flag if greater than +8 MB.
- Create `docs/art/visual-overhaul/visual-overhaul-v2-comparison.md` with concept vs `vo2-final-rally.png` side by side.
- Convert residual gaps to `vo3-` follow-up tickets.
- Update `dink_rivals/PHASE_NOTES.md` with v2 closeout summary.
- Update `tickets/status.md`.

## Android Visual QA Checklist

- Launch: splash/menu without blank frames or stretched assets.
- Main menu: hero background, logo, buttons, and text have no overlap and respect safe areas.
- Roster: portraits match gameplay identities.
- Serve: server, receiver, ball, serve indicator, score, and controls are readable.
- Rally: player movement, opponent movement, ball trail, and court lines stay clear.
- Dink: small contact animation only on contact; `DINK!` plaque legible.
- Drive: horizontal swing arc visible; `DRIVE!` plaque legible.
- Lob: upward scoop and ball height cue read immediately.
- Smash: overhead band appears only in the proper zone; `SMASH!` plaque legible.
- Miss: miss animation does not trigger contact VFX or accidental dink visuals.
- Fault/out: callout legible and clears quickly.
- Point result: animation does not hide next serve setup.
- Pause/settings: panels styled consistently and fit safe areas.
- End match: result screen feels connected to match world.
- Performance: no obvious stutter during shot VFX, point bursts, or menu transitions.
- Style coherence: paused screenshots should not contain any element that reads like a different game.

## Acceptance Criteria

- All final evidence PNGs are archived.
- `flutter analyze` clean, `flutter test` green, and APK builds.
- 5-minute Pixel smoke has no crash and no jank spike.
- APK size delta is reported and not above +8 MB without explicit follow-up.
- `visual-overhaul-v2-comparison.md` exists and lists remaining gaps explicitly.
- Residual gaps are converted to `vo3-` follow-up tickets or documented deferrals.
- v2 satisfies the definition of done from `docs/specs/visual-overhaul-v2-spec.md`.

## Closeout Status - 2026-05-12

VO2 cannot be closed as complete. Automated build/test/emulator checks may be used as implementation evidence, but art QA failed key visual acceptance gates:

- Character art is not accepted as final concept-quality replacement.
- Player/opponent run cycles need explicit completion and gameplay-scale validation.
- Signage requires replacement rather than closeout deferral.
- Net and near-net visibility need correction.
- Final QA must rerun after those focused tickets land.

Focused residual tickets are `VO3-003` through `VO3-007`. Keep this ticket in `review` until those follow-ups are resolved and final QA evidence is recorded.

## Verification

Run from `dink_rivals/`:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Physical Pixel:

```bash
flutter devices
flutter install -d <PIXEL_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter run -d <PIXEL_ID>
```

Screenshot helper:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell screencap -p /sdcard/vo2.png
& $adb -s emulator-5554 pull /sdcard/vo2.png ..\dink_rivals\docs\art\visual-overhaul\evidence\vo2-final-rally.png
```

## Risks

- Physical-device capture can fail behind keyguard. Do not mark done without actual app screenshots or explicit human validation.
- More generated textures can regress memory or frame pace. File follow-ups if compression/atlas work is needed.
