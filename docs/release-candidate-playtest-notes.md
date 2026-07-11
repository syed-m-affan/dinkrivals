# Release Candidate Playtest Notes

Date: 2026-07-10
Build: `0.2.0+2` internal Android release APK

Artifact: `dink_rivals/build/app/outputs/flutter-apk/app-release.apk`

SHA-256: `4C6B932465AFCA321D15E8D39C99D31FA6745ACEE76733AAEE6DE37B23619843`

## Automated and Emulator Pass

- Menu visual revision: three independent brand, mobile-UX, and Flutter/game-UI
  reviews converged on a park-scoreboard direction. The runtime menu now uses a
  custom-painted pickleball, pure typographic wordmark, selected-player versus
  Rookie Bot match poster, single coral Quick Match action, matching Cup ticket,
  and four compact numbered utility tabs. The former dashboard gradients,
  generic Material logo/nav icons, mini-court filler, duplicate visible fence
  branding, and large accidental control gaps are removed or covered.
- `flutter analyze`: pass, no issues.
- `flutter test`: pass, 308 tests.
- Strengthened RC preflight: pass with Google test AdMob IDs, AdMob enabled,
  fake placeholders disabled, QA UI disabled, branded launch assets present,
  all structured character sprite packs present, and release APK present.
- Sprite run: manifest accepted with no warnings; all 64 fixed-cell validation
  reports pass; all 64 motion audits pass with no warnings.
- Release install/launch: pass on `emulator-5554`; process stayed alive and
  `MainActivity` held focus.
- Android 12 splash: branded navy background and Dink Rivals paddle/ball mark;
  no default white launch screen or white icon plate.
- Quick Match: launches in one tap, tutorial dismisses, Rookie player/opponent
  art loads, court/HUD/controls render, and no pre-game fake ad appears.
- Roster: Rally Queen and Veteran show Challenge; locked Showman shows
  `WIN CLASSIC CUP`. Rally Queen challenge launches with Rally Queen sprite and
  `RALLY` HUD identity instead of Rookie/default identity.
- Rally Queen challenge pause flow: `RETURN TO MENU` clears challenge/session
  state, restores Rookie/default quick-match identity, and returns to the arcade
  menu. Covered by a widget regression test and repeated on `emulator-5554`.
- Classic Cup: menu card starts the Cup; semifinal bracket shows Rally Queen,
  Showman advances from the other semifinal, and final opponent is Showman.
- Offline monitor: 60 seconds, no crash or ANR signatures.
- Responsive widget coverage: 360x800 at 1.0 text scale and 412x915 at 1.3 text
  scale, with no overflow in the RC menu/roster flows.

## Pending Human/Physical Gates

- Complete a physical Android pass for fresh install, tutorial, full direct
  challenges, a complete Classic Cup, unlock persistence after restart,
  pause/resume, offline play, natural-break test ads, readability, and at least
  15 minutes without crash or ANR.
- Human-sign the arcade menu and all four character identities/animations.
- These gates require a connected physical device and subjective approval and
  were not claimed by the automated emulator pass.
