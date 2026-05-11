# Phase 5.2 Comparison and Closeout

Last updated: 2026-05-11

## Evidence

- Baseline/delta inventory: `docs/art/phase-5.2-delta-inventory.md`
- Visual rules and prompt direction: `docs/art/phase-5.2-art-direction.md`
- Generated asset contact sheet: `docs/art/phase-5.2-generated-asset-contact-sheet.png`
- Emulator menu smoke: `docs/art/phase-5.2-emulator-smoke.png`
- Emulator gameplay smoke: `docs/art/phase-5.2-gameplay-emulator-smoke.png`
- Updated UI golden: `docs/art/phase-5g-endmatch.png`

## Concept Delta Results

| Region | Result | Notes |
| --- | --- | --- |
| Projection/framing | Improved | Court projection uses stronger near/far width and z displacement while preserving logical coordinate tests. Emulator gameplay reads as a taller 3/4 court with bottom controls clear of the baseline. |
| Court zoning | Resolved | Court now has a navy apron, lighter playing surface, tinted kitchen zone, stronger line contrast, scuffs, and subtle surface texture. |
| Net and serving indicator | Resolved | Net has thicker posts, rail, mesh, and a stronger visual footprint. Serving state is integrated into the scoreboard flow instead of relying on a loose mid-scene marker. |
| Backdrop signage | Improved | Rear environment now includes original `DINK RIVALS` and `PARK COURTS` sign assets plus lamp/planter depth props. |
| Character identity | Improved | Player and opponent sprite sheets were regenerated with clearer outfit identity and run/swing frames; opponent now reads separately from the blue court. Roster portraits were regenerated, including a Rally Queen readability fix after Claude review. |
| Scoreboard/rally/last-shot readout | Resolved | HUD now shows YOU/RIVAL score panels, serving dot, rally count, and last-shot readout. |
| Feedback banner | Resolved | Rally feedback renders in a top-center banner with primary/secondary text helpers and safe-area-aware placement. |
| Ball trail/contact VFX | Resolved | VFX layer uses fixed-size trail buffering, refreshed contact/bounce sprites, and clears trails on contact, bounce, and point reset. |
| Controls | Resolved | Assisted controls and obsolete swing-power affordances are removed. The remaining percentage/ring feedback is tied to serve charge only, while manual move/swing touch regions are preserved. |
| Park depth | Improved | Added a darker rear tree band treatment, lamp, planters, and signage without changing gameplay bounds. |
| Menu/end-match residual composition | Improved | Generated portraits and updated goldens keep the existing menu/end-match flow intact; deeper screen redesign is deferred unless requested. |

## Claude Visual Review

Claude reviewed the generated contact sheet twice. The first pass found one blocker: `portrait_rally_queen.png` label occlusion. The portrait was regenerated with the label in a separate lower band, the contact sheet and goldens were refreshed, and Claude's final check reported no remaining blockers.

## Android/Emulator QA

- `flutter build apk --debug`: passed.
- `flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk`: passed.
- App launched on `emulator-5554`.
- Menu screenshot captured after splash.
- Quick Match screenshot captured in serve state; court, HUD, controls, generated characters, park props, and serve-charge feedback render correctly on Android emulator.

## Residual Gaps

- Physical-device human playtest and subjective concept-art signoff remain outside this automated closeout.
- No Phase 5.3 blocker was identified from automated tests, emulator smoke, or Claude review.
